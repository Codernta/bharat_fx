/// Result of Indian mobile phone number validation.
class PhoneValidationResult {
  final String rawNumber;
  final bool isValid;
  final String? tenDigitNumber;
  final String? formattedNumber;
  final String? errorMessage;

  const PhoneValidationResult({
    required this.rawNumber,
    required this.isValid,
    this.tenDigitNumber,
    this.formattedNumber,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'PhoneValidationResult(valid: $isValid, number: $formattedNumber)';
  }
}

/// Indian mobile phone number validator and formatter.
class BharatPhone {
  static final RegExp _mobileRegex = RegExp(r'^[6-9][0-9]{9}$');

  /// Validates whether the given string is a valid 10-digit Indian mobile number
  /// (starting with 6, 7, 8, or 9), allowing for optional +91 or leading 0 prefix.
  static PhoneValidationResult validate(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return const PhoneValidationResult(
        rawNumber: '',
        isValid: false,
        errorMessage: 'Phone number cannot be empty',
      );
    }

    final raw = phone.trim();
    var digits = raw.replaceAll(RegExp(r'\D'), '');

    // Strip country code (+91) or leading 0
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }

    if (digits.length != 10) {
      return PhoneValidationResult(
        rawNumber: raw,
        isValid: false,
        errorMessage: 'Mobile number must be 10 digits long',
      );
    }

    if (!_mobileRegex.hasMatch(digits)) {
      return PhoneValidationResult(
        rawNumber: raw,
        isValid: false,
        errorMessage: 'Indian mobile numbers must start with 6, 7, 8, or 9',
      );
    }

    final formatted =
        '+91 ${digits.substring(0, 5)} ${digits.substring(5, 10)}';

    return PhoneValidationResult(
      rawNumber: raw,
      isValid: true,
      tenDigitNumber: digits,
      formattedNumber: formatted,
    );
  }

  /// Formats a 10-digit phone number into `+91 XXXXX XXXXX` or `XXXXX XXXXX`.
  static String format(String phone, {bool includeCountryCode = true}) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }

    if (digits.length != 10) return phone;

    final grouped = '${digits.substring(0, 5)} ${digits.substring(5, 10)}';
    return includeCountryCode ? '+91 $grouped' : grouped;
  }
}
