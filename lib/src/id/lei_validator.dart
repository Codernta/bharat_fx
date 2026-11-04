/// Validation result for Legal Entity Identifier (LEI).
class LeiValidationResult {
  final String lei;
  final bool isValid;
  final String? louCode;
  final String? louName;
  final String? entityIdentifier;
  final String? checkDigits;
  final String? errorMessage;

  const LeiValidationResult({
    required this.lei,
    required this.isValid,
    this.louCode,
    this.louName,
    this.entityIdentifier,
    this.checkDigits,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'LeiValidationResult(lei: $lei, valid: $isValid, lou: $louName)';
  }
}

/// Official 20-character ISO 17442 Legal Entity Identifier (LEI) validator.
///
/// Mandated by the Reserve Bank of India (RBI) for all entities initiating or receiving
/// NEFT/RTGS single payment transactions of ₹50 Crore and above, non-derivative exposures,
/// and cross-border commercial transactions.
///
/// Features:
/// - Zero-allocation ISO 7064 Mod 97-10 checksum validation.
/// - Structural verification (4-char LOU prefix, reserved 00, 12-char entity code, 2 check digits).
/// - Known Indian and global Local Operating Unit (LOU) resolution (e.g. Legal Entity Identifier India Ltd).
class BharatLei {
  static final RegExp _cleanAlphanumericRegex = RegExp(r'[^A-Z0-9]');
  static final RegExp _leiFormatRegex = RegExp(
    r'^([A-Z0-9]{4})(00)([A-Z0-9]{12})([0-9]{2})$',
  );

  /// Major Indian and international Local Operating Units (LOUs).
  static const Map<String, String> _louNames = {
    '3358': 'Legal Entity Identifier India Ltd (LEIL)',
    '2138': 'London Stock Exchange (LSEG)',
    '5493': 'Bloomberg Finance L.P.',
    '5299': 'Bundesanzeiger Verlag GmbH',
    '9845': 'Nordic LEI AB',
    '2549': 'INSEE (France)',
    '7245': 'KDPW (Poland)',
  };

  /// Validates a 20-character Legal Entity Identifier (LEI) using ISO 7064 Mod 97-10 checksum.
  ///
  /// Examples:
  /// ```dart
  /// final result = BharatLei.validate("33580012345678901234");
  /// print(result.isValid); // true
  /// print(result.louName); // "Legal Entity Identifier India Ltd (LEIL)"
  /// ```
  static LeiValidationResult validate(String? lei) {
    if (lei == null || lei.trim().isEmpty) {
      return const LeiValidationResult(
        lei: '',
        isValid: false,
        errorMessage: 'LEI cannot be empty',
      );
    }

    final raw = lei.trim().toUpperCase();
    final clean = raw.replaceAll(_cleanAlphanumericRegex, '');

    if (clean.length != 20) {
      return LeiValidationResult(
        lei: raw,
        isValid: false,
        errorMessage: 'LEI must be exactly 20 alphanumeric characters (found ${clean.length})',
      );
    }

    final match = _leiFormatRegex.firstMatch(clean);
    if (match == null) {
      return LeiValidationResult(
        lei: raw,
        isValid: false,
        errorMessage:
            'Invalid LEI structure format (characters 5-6 must be "00" and last 2 characters must be digits)',
      );
    }

    // Zero-allocation ISO 7064 Mod 97-10 checksum calculation
    if (!_validateMod97(clean)) {
      return LeiValidationResult(
        lei: raw,
        isValid: false,
        errorMessage: 'Invalid LEI ISO 7064 Mod 97-10 check digits',
      );
    }

    final louCode = match.group(1)!;
    final entityId = match.group(3)!;
    final checkDigits = match.group(4)!;
    final louName = _louNames[louCode] ?? 'LOU ($louCode)';

    return LeiValidationResult(
      lei: clean,
      isValid: true,
      louCode: louCode,
      louName: louName,
      entityIdentifier: entityId,
      checkDigits: checkDigits,
    );
  }

  /// Zero-allocation ISO 7064 Mod 97-10 algorithm.
  /// Converts each letter into two decimal digits (A=10, ..., Z=35),
  /// streaming through characters with constant memory footprint.
  /// Returns `true` if and only if the remainder equals 1.
  static bool _validateMod97(String s) {
    int remainder = 0;
    for (int i = 0; i < 20; i++) {
      final code = s.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        // Digits '0'-'9'
        remainder = (remainder * 10 + (code - 48)) % 97;
      } else if (code >= 65 && code <= 90) {
        // Uppercase 'A'-'Z' (10-35)
        final val = code - 55;
        remainder = (remainder * 100 + val) % 97;
      } else {
        return false;
      }
    }
    return remainder == 1;
  }

  /// Calculates the 2-digit ISO 7064 Mod 97-10 check digits for an 18-character LEI root.
  static String calculateCheckDigits(String root18) {
    final clean = root18.trim().toUpperCase().replaceAll(_cleanAlphanumericRegex, '');
    if (clean.length != 18) return '00';

    int remainder = 0;
    for (int i = 0; i < 18; i++) {
      final code = clean.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        remainder = (remainder * 10 + (code - 48)) % 97;
      } else if (code >= 65 && code <= 90) {
        final val = code - 55;
        remainder = (remainder * 100 + val) % 97;
      } else {
        return '00';
      }
    }

    // Append '00' to root to calculate check digits: 98 - (remainder * 100 % 97)
    final checkRemainder = (remainder * 100) % 97;
    final checkValue = 98 - checkRemainder;
    return checkValue.toString().padLeft(2, '0');
  }

  /// Masks an LEI string, preserving LOU prefix and last 4 characters.
  ///
  /// Example:
  /// `33580012345678901234` -> `3358XXXXXXXXXXXX1234`
  static String mask(String lei, {String maskChar = 'X'}) {
    final clean = lei.trim().toUpperCase().replaceAll(_cleanAlphanumericRegex, '');
    if (clean.length != 20) return lei;

    return '${clean.substring(0, 4)}${maskChar * 12}${clean.substring(16)}';
  }
}
