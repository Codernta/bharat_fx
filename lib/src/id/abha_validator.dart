import 'upi_validator.dart';

/// Validation result for Ayushman Bharat Health Account (ABHA ID and ABHA Address).
class AbhaValidationResult {
  final String abhaNumber;
  final String formattedNumber;
  final bool isValid;
  final String? errorMessage;

  const AbhaValidationResult({
    required this.abhaNumber,
    required this.formattedNumber,
    required this.isValid,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'AbhaValidationResult(abha: $formattedNumber, valid: $isValid)';
  }
}

/// Validation result for an ABHA Address (PHR handle).
class AbhaAddressValidationResult {
  final String abhaAddress;
  final bool isValid;
  final String? username;
  final String? domain;
  final String? errorMessage;

  const AbhaAddressValidationResult({
    required this.abhaAddress,
    required this.isValid,
    this.username,
    this.domain,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'AbhaAddressValidationResult(address: $abhaAddress, valid: $isValid)';
  }
}

/// National Health Authority (NHA) & Ayushman Bharat Digital Mission (ABDM)
/// ABHA ID (14-digit Health ID) and ABHA Address (PHR Handle) validator and masker.
class BharatAbha {
  static final RegExp _digitsOnlyRegex = RegExp(r'^\d+$');
  static final RegExp _nonDigitsRegex = RegExp(r'\D');
  static final RegExp _abhaAddressRegex = RegExp(
    r'^[a-zA-Z0-9._]{3,32}@[a-zA-Z]{3,16}$',
  );

  /// Validates a 14-digit Indian ABHA Number (Ayushman Bharat Health Account).
  ///
  /// Rules:
  /// - Exactly 14 digits.
  /// - Cannot start with 0 or 1 (NHA ABDM specification).
  /// - Accepts both raw (`12345678901234`) and hyphenated (`12-3456-7890-1234`) formats.
  static AbhaValidationResult validate(String? abhaNumber) {
    if (abhaNumber == null || abhaNumber.trim().isEmpty) {
      return const AbhaValidationResult(
        abhaNumber: '',
        formattedNumber: '',
        isValid: false,
        errorMessage: 'ABHA number cannot be empty',
      );
    }

    final raw = abhaNumber.trim();
    final digits = raw.replaceAll(_nonDigitsRegex, '');

    if (digits.length != 14 || !_digitsOnlyRegex.hasMatch(digits)) {
      return AbhaValidationResult(
        abhaNumber: raw,
        formattedNumber: raw,
        isValid: false,
        errorMessage:
            'ABHA number must be exactly 14 digits (found ${digits.length})',
      );
    }

    // NHA ABDM standard: first digit cannot be 0 or 1
    final firstChar = digits.codeUnitAt(0);
    if (firstChar == 48 || firstChar == 49) {
      return AbhaValidationResult(
        abhaNumber: raw,
        formattedNumber: raw,
        isValid: false,
        errorMessage: 'ABHA number cannot start with 0 or 1',
      );
    }

    final formatted = format(digits);

    return AbhaValidationResult(
      abhaNumber: digits,
      formattedNumber: formatted,
      isValid: true,
    );
  }

  /// Formats a 14-digit ABHA number into standard `XX-XXXX-XXXX-XXXX` blocks.
  static String format(String abhaNumber) {
    final digits = abhaNumber.replaceAll(_nonDigitsRegex, '');
    if (digits.length != 14) return abhaNumber;

    return '${digits.substring(0, 2)}-${digits.substring(2, 6)}-${digits.substring(6, 10)}-${digits.substring(10, 14)}';
  }

  /// Masks an ABHA number for privacy compliance, preserving only the last 4 digits.
  ///
  /// Examples:
  /// ```dart
  /// BharatAbha.mask("91-1234-5678-9012"); // "XX-XXXX-XXXX-9012"
  /// BharatAbha.mask("91123456789012", maskChar: '•'); // "••-••••-••••-9012"
  /// ```
  static String mask(String abhaNumber, {String maskChar = 'X'}) {
    final digits = abhaNumber.replaceAll(_nonDigitsRegex, '');
    if (digits.length != 14) return abhaNumber;

    final m2 = maskChar * 2;
    final m4 = maskChar * 4;
    final last4 = digits.substring(10, 14);

    return '$m2-$m4-$m4-$last4';
  }

  /// Validates an Ayushman Bharat Health Account Address / PHR handle (e.g. `user@abdm`, `rahul.kumar@sbx`).
  static AbhaAddressValidationResult validateAddress(String? abhaAddress) {
    if (abhaAddress == null || abhaAddress.trim().isEmpty) {
      return const AbhaAddressValidationResult(
        abhaAddress: '',
        isValid: false,
        errorMessage: 'ABHA address cannot be empty',
      );
    }

    if (BharatUpi.hasHomoglyphs(abhaAddress)) {
      return AbhaAddressValidationResult(
        abhaAddress: abhaAddress,
        isValid: false,
        errorMessage:
            'Security Warning: ABHA address contains deceptive homoglyph characters',
      );
    }

    final sanitized = BharatUpi.sanitize(abhaAddress).toLowerCase();
    if (!_abhaAddressRegex.hasMatch(sanitized)) {
      return AbhaAddressValidationResult(
        abhaAddress: sanitized,
        isValid: false,
        errorMessage:
            'Invalid ABHA address format (expected: username@domain, e.g. name@abdm)',
      );
    }

    final parts = sanitized.split('@');
    return AbhaAddressValidationResult(
      abhaAddress: sanitized,
      isValid: true,
      username: parts[0],
      domain: parts[1],
    );
  }
}
