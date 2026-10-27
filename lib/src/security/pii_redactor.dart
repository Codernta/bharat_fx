import '../id/aadhaar_validator.dart';
import '../id/card_validator.dart';

/// Comprehensive PII & Sensitive Financial Data Sanitizer for Indian Fintech.
///
/// Compliant with:
/// - UIDAI Aadhaar Act 2016 (First 8 digits must be masked).
/// - RBI Card-on-File (CoFT) & PCI DSS 4.0 (Mask PAN, never expose full 16 digits or CVV).
/// - Digital Personal Data Protection (DPDP) Act 2023 (Scrub PII from logs/telemetry).
class BharatPiiRedactor {
  // Regex for 12-digit Aadhaar (isolated by word boundaries or formatting)
  static final RegExp _aadhaarRegex = RegExp(
    r'\b([2-9][0-9]{3})[\s\-]?([0-9]{4})[\s\-]?([0-9]{4})\b',
  );

  // Regex for 16-digit Virtual ID (VID)
  static final RegExp _vidRegex = RegExp(
    r'\b([2-9][0-9]{3})[\s\-]?([0-9]{4})[\s\-]?([0-9]{4})[\s\-]?([0-9]{4})\b',
  );

  // Regex for Indian PAN Card (5 letters, 4 digits, 1 letter)
  static final RegExp _panRegex = RegExp(
    r'\b([A-Z]{5})([0-9]{4})([A-Z])\b',
  );

  // Regex for 13 to 19 digit Payment Cards (RuPay, Visa, MC, Amex)
  static final RegExp _cardRegex = RegExp(
    r'\b(?:\d{4}[\s\-]?){3,4}\d{1,4}\b',
  );

  // Regex for CVV / CVC in key-value context
  static final RegExp _cvvContextRegex = RegExp(
    r'\b(cvv|cvc|security_code|cvv2)\s*[:=]\s*["' ']?([0-9]{3,4})["' ']?',
    caseSensitive: false,
  );

  // Regex for Bank Account Number in key-value or prefixed context
  static final RegExp _bankAccountContextRegex = RegExp(
    r'\b(account_no|account_num|account_number|acc_no|acct_no|a\/c)\s*[:=]\s*["'
    ']?([0-9]{9,18})["'
    ']?',
    caseSensitive: false,
  );

  // Regex for Indian Mobile Numbers
  static final RegExp _phoneRegex = RegExp(
    r'(?:(?:\+91|91|0)[\s\-]?)?([6-9]\d{4})[\s\-]?(\d{5})\b',
  );

  // Regex for UPI VPA (e.g. name@okaxis)
  static final RegExp _upiRegex = RegExp(
    r'\b([a-zA-Z0-9.\-_]{2,64})@([a-zA-Z]{2,64})\b',
  );
  static final RegExp _nonDigitsRegex = RegExp(r'\D');

  // Sensitive JSON / Map keys that must always be masked
  static final Set<String> _sensitiveKeys = {
    'password',
    'passcode',
    'pin',
    'mpin',
    'tpin',
    'cvv',
    'cvc',
    'cvv2',
    'otp',
    'secret',
    'secret_key',
    'client_secret',
    'private_key',
    'access_token',
    'refresh_token',
    'auth_token',
    'token',
    'bearer',
    'jwt',
    'biometric',
    'auth_code',
    'session_id',
    'encryption_key',
    'salt',
    'iv',
    'card_number',
    'card_num',
    'aadhaar',
    'aadhaar_no',
    'aadhaar_number',
    'pan',
    'pan_no',
    'pan_number',
    'account_number',
    'account_no',
    'acc_no',
    'driving_license',
    'dl_number',
    'dl_no',
    'voter_id',
    'epic_no',
    'passport',
    'passport_number',
    'passport_no',
    'cin',
    'tan',
    'din',
    'vpa',
    'irn',
  };

  /// Redacts all financial PII from arbitrary text, logs, or error strings.
  ///
  /// Examples:
  /// ```dart
  /// BharatPiiRedactor.redact("User Aadhaar: 2345 6789 0124 and PAN: ABCPD1234F");
  /// // "User Aadhaar: XXXX XXXX 0124 and PAN: XXXXX1234F"
  /// ```
  static String redact(String text, {String maskChar = 'X'}) {
    if (text.isEmpty) return text;

    String sanitized = text;

    // 1. Redact CVV / CVC in key-value contexts
    sanitized = sanitized.replaceAllMapped(_cvvContextRegex, (match) {
      final key = match.group(1);
      return '$key: ***';
    });

    // 2. Redact Bank Accounts in context
    sanitized = sanitized.replaceAllMapped(_bankAccountContextRegex, (match) {
      final key = match.group(1);
      final acc = match.group(2)!;
      final masked = acc.length > 4
          ? '${maskChar * (acc.length - 4)}${acc.substring(acc.length - 4)}'
          : maskChar * acc.length;
      return '$key: $masked';
    });

    // 3. Redact 16-digit Virtual IDs (VID)
    sanitized = sanitized.replaceAllMapped(_vidRegex, (match) {
      final p1 = match.group(1)!;
      final p2 = match.group(2)!;
      final p3 = match.group(3)!;
      final p4 = match.group(4)!;
      final clean = '$p1$p2$p3$p4';

      if (BharatAadhaar.validateVerhoeff(clean)) {
        return '${maskChar * 4} ${maskChar * 4} ${maskChar * 4} $p4';
      }
      return match.group(0)!;
    });

    // 4. Redact 12-digit Aadhaar numbers
    sanitized = sanitized.replaceAllMapped(_aadhaarRegex, (match) {
      final p1 = match.group(1)!;
      final p2 = match.group(2)!;
      final p3 = match.group(3)!;
      final clean = '$p1$p2$p3';

      if (BharatAadhaar.validate(clean)) {
        return '${maskChar * 4} ${maskChar * 4} $p3';
      }
      return match.group(0)!;
    });

    // 5. Redact Payment Cards (Luhn validated or structured card numbers)
    sanitized = sanitized.replaceAllMapped(_cardRegex, (match) {
      final raw = match.group(0)!;
      final cleanDigits = raw.replaceAll(_nonDigitsRegex, '');

      if (cleanDigits.length >= 13 && cleanDigits.length <= 19) {
        if (LuhnAlgorithm.validate(cleanDigits)) {
          final lastFour = cleanDigits.substring(cleanDigits.length - 4);
          return '${maskChar * 4}-${maskChar * 4}-${maskChar * 4}-$lastFour';
        }
      }
      return raw;
    });

    // 6. Redact PAN Cards
    sanitized = sanitized.replaceAllMapped(_panRegex, (match) {
      final digits = match.group(2)!;
      final lastLetter = match.group(3)!;
      return '${maskChar * 5}$digits$lastLetter';
    });

    // 7. Redact Mobile Phone Numbers
    sanitized = sanitized.replaceAllMapped(_phoneRegex, (match) {
      final last5 = match.group(2)!;
      final prefix = match.group(0)!.contains('+91') ? '+91 ' : '';
      return '$prefix${maskChar * 5} $last5';
    });

    // 8. Redact UPI VPAs (mask username, keep handle)
    sanitized = sanitized.replaceAllMapped(_upiRegex, (match) {
      final user = match.group(1)!;
      final handle = match.group(2)!;
      if (user.length <= 2) {
        return '***@$handle';
      }
      final maskedUser =
          '${user[0]}${maskChar * (user.length - 2)}${user[user.length - 1]}';
      return '$maskedUser@$handle';
    });

    return sanitized;
  }

  /// Recursively scrubs all sensitive keys and values from a JSON / Map structure.
  ///
  /// Prevents accidental data leaks when sending events to Sentry, Firebase, or analytics.
  static Map<String, dynamic> redactMap(
    Map<String, dynamic> map, {
    String maskChar = 'X',
  }) {
    final sanitized = <String, dynamic>{};

    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      final isKeySensitive = _sensitiveKeys.contains(key.toLowerCase()) ||
          _sensitiveKeys.any((s) => key.toLowerCase().contains(s));

      if (isKeySensitive) {
        sanitized[key] = '[REDACTED]';
      } else if (value is String) {
        sanitized[key] = redact(value, maskChar: maskChar);
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = redactMap(value, maskChar: maskChar);
      } else if (value is List) {
        sanitized[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return redactMap(item, maskChar: maskChar);
          } else if (item is String) {
            return redact(item, maskChar: maskChar);
          }
          return item;
        }).toList();
      } else {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  /// Checks whether a given string contains recognizable unmasked financial PII.
  static bool containsPii(String text) {
    if (text.isEmpty) return false;

    if (_panRegex.hasMatch(text)) return true;
    if (_cvvContextRegex.hasMatch(text)) return true;
    if (_bankAccountContextRegex.hasMatch(text)) return true;

    for (final match in _aadhaarRegex.allMatches(text)) {
      final digits = match.group(0)!.replaceAll(_nonDigitsRegex, '');
      if (BharatAadhaar.validate(digits)) return true;
    }

    for (final match in _cardRegex.allMatches(text)) {
      final digits = match.group(0)!.replaceAll(_nonDigitsRegex, '');
      if (digits.length >= 13 && LuhnAlgorithm.validate(digits)) return true;
    }

    return false;
  }
}
