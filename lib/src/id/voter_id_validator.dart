/// Validation result for Indian Voter ID (Electors Photo Identity Card / EPIC).
class VoterIdValidationResult {
  final String voterId;
  final String formattedNumber;
  final bool isValid;
  final String? constituencyCode;
  final String? serialNumber;
  final String? errorMessage;

  const VoterIdValidationResult({
    required this.voterId,
    required this.formattedNumber,
    required this.isValid,
    this.constituencyCode,
    this.serialNumber,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'VoterIdValidationResult(voterId: $formattedNumber, valid: $isValid, constituency: $constituencyCode)';
  }
}

/// Validator for Indian Voter ID / Electors Photo Identity Card (EPIC) issued by ECI.
///
/// Implements standard Election Commission of India (ECI) 10-character alphanumeric structure:
/// 3 alphabetical letters (assembly / constituency prefix) followed by 7 numeric digits (e.g. `ABC1234567`).
class BharatVoterId {
  static final RegExp _standardRegex = RegExp(r'^([A-Z]{3})([0-9]{7})$');
  static final RegExp _cleanAlphanumericRegex = RegExp(r'[^A-Z0-9]');

  /// Validates an Indian Voter ID (EPIC) card.
  ///
  /// Examples:
  /// ```dart
  /// final result = BharatVoterId.validate("ABC1234567");
  /// print(result.isValid);          // true
  /// print(result.constituencyCode); // "ABC"
  /// print(result.serialNumber);     // "1234567"
  /// ```
  static VoterIdValidationResult validate(String? voterId) {
    if (voterId == null || voterId.trim().isEmpty) {
      return const VoterIdValidationResult(
        voterId: '',
        formattedNumber: '',
        isValid: false,
        errorMessage: 'Voter ID cannot be empty',
      );
    }

    final raw = voterId.trim().toUpperCase();
    final clean = raw.replaceAll(_cleanAlphanumericRegex, '');

    if (clean.length != 10) {
      return VoterIdValidationResult(
        voterId: raw,
        formattedNumber: raw,
        isValid: false,
        errorMessage: 'Voter ID must be exactly 10 alphanumeric characters',
      );
    }

    final match = _standardRegex.firstMatch(clean);
    if (match == null) {
      return VoterIdValidationResult(
        voterId: raw,
        formattedNumber: raw,
        isValid: false,
        errorMessage:
            'Invalid Voter ID format (must be 3 letters followed by 7 digits)',
      );
    }

    final code = match.group(1)!;
    final serial = match.group(2)!;

    return VoterIdValidationResult(
      voterId: raw,
      formattedNumber: clean,
      isValid: true,
      constituencyCode: code,
      serialNumber: serial,
    );
  }

  /// Masks a Voter ID for privacy compliance, preserving constituency code and last 3 digits.
  ///
  /// Example:
  /// `ABC1234567` -> `ABCXXXX567`
  static String mask(String voterId, {String maskChar = 'X'}) {
    final result = validate(voterId);
    if (!result.isValid) return voterId;

    final code = result.constituencyCode!;
    final serial = result.serialNumber!;
    final last3 = serial.substring(serial.length - 3);

    return '$code${maskChar * 4}$last3';
  }
}

/// Convenience alias for [BharatVoterId].
typedef BharatEpic = BharatVoterId;
