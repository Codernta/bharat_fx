/// Validation result for Indian Central KYC (CKYC / KIN).
class CkycValidationResult {
  final String ckycNumber;
  final bool isValid;
  final bool isNumericOnly;
  final String? errorMessage;

  const CkycValidationResult({
    required this.ckycNumber,
    required this.isValid,
    this.isNumericOnly = true,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'CkycValidationResult(ckyc: $ckycNumber, valid: $isValid)';
  }
}

/// Validator and privacy masker for Indian Central KYC (CKYC) /
/// KYC Identification Number (KIN) managed by CERSAI.
class BharatCkyc {
  static final RegExp _cleanAlphanumericRegex = RegExp(r'[^A-Z0-9]');
  static final RegExp _digitsOnlyRegex = RegExp(r'^\d{14}$');
  static final RegExp _alphanumericRegex = RegExp(r'^[A-Z0-9]{14}$');

  /// Validates a 14-character CKYC / KIN identifier.
  ///
  /// Examples:
  /// ```dart
  /// final result = BharatCkyc.validate("10023456789012");
  /// print(result.isValid); // true
  /// ```
  static CkycValidationResult validate(String? ckycNumber) {
    if (ckycNumber == null || ckycNumber.trim().isEmpty) {
      return const CkycValidationResult(
        ckycNumber: '',
        isValid: false,
        errorMessage: 'CKYC number cannot be empty',
      );
    }

    final clean = ckycNumber.trim().toUpperCase().replaceAll(
          _cleanAlphanumericRegex,
          '',
        );

    if (clean.length != 14) {
      return CkycValidationResult(
        ckycNumber: clean,
        isValid: false,
        errorMessage:
            'CKYC / KIN must be exactly 14 characters (found ${clean.length})',
      );
    }

    if (!_alphanumericRegex.hasMatch(clean)) {
      return CkycValidationResult(
        ckycNumber: clean,
        isValid: false,
        errorMessage: 'CKYC / KIN must contain only uppercase alphanumeric characters',
      );
    }

    final isNumeric = _digitsOnlyRegex.hasMatch(clean);

    return CkycValidationResult(
      ckycNumber: clean,
      isValid: true,
      isNumericOnly: isNumeric,
    );
  }

  /// Masks a CKYC number for privacy compliance, preserving only the last 4 characters.
  ///
  /// Examples:
  /// ```dart
  /// BharatCkyc.mask("10023456789012"); // "XXXXXXXXXX9012"
  /// BharatCkyc.mask("10023456789012", maskChar: '•'); // "••••••••••9012"
  /// ```
  static String mask(String ckycNumber, {String maskChar = 'X'}) {
    final clean = ckycNumber.trim().toUpperCase().replaceAll(
          _cleanAlphanumericRegex,
          '',
        );
    if (clean.length != 14) return ckycNumber;

    return '${maskChar * 10}${clean.substring(10)}';
  }
}
