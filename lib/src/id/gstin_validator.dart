import 'pan_validator.dart';

/// Result of GSTIN validation.
class GstinValidationResult {
  final String gstin;
  final bool isValid;
  final String? stateCode;
  final String? pan;
  final String? entityCode;
  final String? errorMessage;

  const GstinValidationResult({
    required this.gstin,
    required this.isValid,
    this.stateCode,
    this.pan,
    this.entityCode,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'GstinValidationResult(gstin: $gstin, valid: $isValid, pan: $pan, state: $stateCode)';
  }
}

/// Validator for Indian Goods and Services Tax Identification Number (GSTIN).
class BharatGstin {
  static final RegExp _gstinRegex = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  );

  /// Validates a 15-character Indian GSTIN.
  ///
  /// Format:
  /// - 2 digits: State Code (01-37)
  /// - 10 characters: PAN of entity
  /// - 1 character: Entity number of the same PAN in the state (1-9, A-Z)
  /// - 1 character: 'Z' by default
  /// - 1 character: Checksum digit
  static GstinValidationResult validate(String? gstin) {
    if (gstin == null || gstin.trim().isEmpty) {
      return const GstinValidationResult(
        gstin: '',
        isValid: false,
        errorMessage: 'GSTIN cannot be empty',
      );
    }

    final cleaned = gstin.trim().toUpperCase();

    if (cleaned.length != 15) {
      return GstinValidationResult(
        gstin: cleaned,
        isValid: false,
        errorMessage: 'GSTIN must be exactly 15 characters',
      );
    }

    if (!_gstinRegex.hasMatch(cleaned)) {
      return GstinValidationResult(
        gstin: cleaned,
        isValid: false,
        errorMessage: 'Invalid GSTIN format structure',
      );
    }

    final stateCode = cleaned.substring(0, 2);
    final pan = cleaned.substring(2, 12);
    final entityCode = cleaned.substring(12, 13);

    // Verify PAN component
    final panResult = BharatPan.validate(pan);
    if (!panResult.isValid) {
      return GstinValidationResult(
        gstin: cleaned,
        isValid: false,
        stateCode: stateCode,
        pan: pan,
        errorMessage: 'Embedded PAN "$pan" in GSTIN is invalid: ${panResult.errorMessage}',
      );
    }

    return GstinValidationResult(
      gstin: cleaned,
      isValid: true,
      stateCode: stateCode,
      pan: pan,
      entityCode: entityCode,
    );
  }

  /// Masks a GSTIN string, showing state code and last 4 chars (e.g. `27XXXXXX1234Z1`).
  static String mask(String gstin, {String maskChar = 'X'}) {
    final cleaned = gstin.trim().toUpperCase();
    if (cleaned.length != 15) return gstin;
    return '${cleaned.substring(0, 2)}${maskChar * 9}${cleaned.substring(11)}';
  }
}
