/// Validation result for an Indian Passport.
class PassportValidationResult {
  final String passportNumber;
  final String formattedNumber;
  final bool isValid;
  final String? seriesLetter;
  final String? serialNumber;
  final String? errorMessage;

  const PassportValidationResult({
    required this.passportNumber,
    required this.formattedNumber,
    required this.isValid,
    this.seriesLetter,
    this.serialNumber,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'PassportValidationResult(passport: $formattedNumber, valid: $isValid, series: $seriesLetter)';
  }
}

/// Validator for Indian Passports issued by the Ministry of External Affairs (MEA).
///
/// Implements standard 8-character Indian passport format:
/// 1 uppercase letter (series) followed by 7 numeric digits (e.g. `K1234567`, `A2098765`).
class BharatPassport {
  // Standard 8-character format: 1 letter followed by 7 digits (non-zero leading digit)
  static final RegExp _passportRegex = RegExp(r'^([A-Z])([1-9][0-9]{6})$');

  // Fallback allowing zero leading digit in legacy booklets
  static final RegExp _relaxedRegex = RegExp(r'^([A-Z])([0-9]{7})$');

  /// Validates an Indian passport number.
  ///
  /// Examples:
  /// ```dart
  /// final result = BharatPassport.validate("K1234567");
  /// print(result.isValid);      // true
  /// print(result.seriesLetter); // "K"
  /// print(result.serialNumber); // "1234567"
  /// ```
  static PassportValidationResult validate(String? passportNumber) {
    if (passportNumber == null || passportNumber.trim().isEmpty) {
      return const PassportValidationResult(
        passportNumber: '',
        formattedNumber: '',
        isValid: false,
        errorMessage: 'Passport number cannot be empty',
      );
    }

    final raw = passportNumber.trim().toUpperCase();
    final clean = raw.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (clean.length != 8) {
      return PassportValidationResult(
        passportNumber: raw,
        formattedNumber: raw,
        isValid: false,
        errorMessage:
            'Passport number must be exactly 8 characters (1 letter followed by 7 digits)',
      );
    }

    final match =
        _passportRegex.firstMatch(clean) ?? _relaxedRegex.firstMatch(clean);
    if (match == null) {
      return PassportValidationResult(
        passportNumber: raw,
        formattedNumber: raw,
        isValid: false,
        errorMessage:
            'Invalid Passport format structure (must start with a letter followed by 7 digits)',
      );
    }

    final letter = match.group(1)!;
    final serial = match.group(2)!;

    // Disallow letters not used in standard Indian passport series (e.g., Q)
    if (letter == 'Q') {
      return PassportValidationResult(
        passportNumber: raw,
        formattedNumber: raw,
        isValid: false,
        seriesLetter: letter,
        errorMessage: 'Series letter "Q" is not issued for Indian passports',
      );
    }

    return PassportValidationResult(
      passportNumber: raw,
      formattedNumber: clean,
      isValid: true,
      seriesLetter: letter,
      serialNumber: serial,
    );
  }

  /// Masks an Indian Passport for privacy compliance, preserving series letter and last 2 digits.
  ///
  /// Example:
  /// `K1234567` -> `KXXXXX67`
  static String mask(String passportNumber, {String maskChar = 'X'}) {
    final result = validate(passportNumber);
    if (!result.isValid) return passportNumber;

    final letter = result.seriesLetter!;
    final serial = result.serialNumber!;
    final last2 = serial.substring(serial.length - 2);

    return '$letter${maskChar * 5}$last2';
  }
}
