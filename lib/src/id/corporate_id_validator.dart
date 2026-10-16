import '../vehicle/rto_database.dart';

/// Parsed result of a Corporate Identification Number (CIN) validation.
class CinValidationResult {
  final String cin;
  final String formattedCin;
  final bool isValid;
  final bool? isListed;
  final String? industryCode;
  final String? stateCode;
  final String? stateName;
  final int? incorporationYear;
  final String? companyTypeCode;
  final String? companyTypeDescription;
  final String? registrationNumber;
  final String? errorMessage;

  const CinValidationResult({
    required this.cin,
    required this.formattedCin,
    required this.isValid,
    this.isListed,
    this.industryCode,
    this.stateCode,
    this.stateName,
    this.incorporationYear,
    this.companyTypeCode,
    this.companyTypeDescription,
    this.registrationNumber,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'CinValidationResult(cin: $formattedCin, valid: $isValid, state: $stateName, year: $incorporationYear, type: $companyTypeDescription)';
  }
}

/// Validation result of a Tax Deduction and Collection Account Number (TAN).
class TanValidationResult {
  final String tan;
  final String formattedTan;
  final bool isValid;
  final String? jurisdictionCode;
  final String? deductorInitial;
  final String? serialNumber;
  final String? checkLetter;
  final String? errorMessage;

  const TanValidationResult({
    required this.tan,
    required this.formattedTan,
    required this.isValid,
    this.jurisdictionCode,
    this.deductorInitial,
    this.serialNumber,
    this.checkLetter,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'TanValidationResult(tan: $formattedTan, valid: $isValid, jurisdiction: $jurisdictionCode)';
  }
}

/// Validation result of a Director Identification Number (DIN).
class DinValidationResult {
  final String din;
  final bool isValid;
  final String? errorMessage;

  const DinValidationResult({
    required this.din,
    required this.isValid,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'DinValidationResult(din: $din, valid: $isValid)';
  }
}

/// Corporate & MCA (Ministry of Corporate Affairs) ID validators.
///
/// Features:
/// - CIN: Corporate Identification Number (21 alphanumeric characters).
/// - TAN: Tax Deduction Account Number (10 alphanumeric characters).
/// - DIN: Director Identification Number (8 numeric digits).
class BharatCin {
  static final RegExp _cinRegex = RegExp(
    r'^([LU])([0-9]{5})([A-Z]{2})([0-9]{4})([A-Z]{3})([0-9]{6})$',
  );
  static final RegExp _cleanAlphanumericRegex = RegExp(r'[^A-Z0-9]');

  static const Map<String, String> _companyTypes = {
    'PTC': 'Private Limited Company',
    'PLC': 'Public Limited Company',
    'FTC': 'Subsidiary of a Foreign Company',
    'GOI': 'Government of India Owned Company',
    'SGC': 'State Government Owned Company',
    'ULL': 'Public Unlisted Company',
    'NPL': 'Not for Profit / Section 8 Company',
    'GAP': 'General Association Private',
    'GAT': 'General Association Public',
    'OPC': 'One Person Company',
  };

  /// Validates a 21-character Indian Corporate Identification Number (CIN).
  ///
  /// Examples:
  /// ```dart
  /// final result = BharatCin.validate("U72200KA2020PTC123456");
  /// print(result.isValid);                // true
  /// print(result.isListed);               // false (Unlisted)
  /// print(result.stateName);              // "Karnataka"
  /// print(result.incorporationYear);      // 2020
  /// print(result.companyTypeDescription); // "Private Limited Company"
  /// ```
  static CinValidationResult validate(String? cin) {
    if (cin == null || cin.trim().isEmpty) {
      return const CinValidationResult(
        cin: '',
        formattedCin: '',
        isValid: false,
        errorMessage: 'CIN cannot be empty',
      );
    }

    final raw = cin.trim().toUpperCase();
    final clean = raw.replaceAll(_cleanAlphanumericRegex, '');

    if (clean.length != 21) {
      return CinValidationResult(
        cin: raw,
        formattedCin: raw,
        isValid: false,
        errorMessage: 'CIN must be exactly 21 alphanumeric characters',
      );
    }

    final match = _cinRegex.firstMatch(clean);
    if (match == null) {
      return CinValidationResult(
        cin: raw,
        formattedCin: raw,
        isValid: false,
        errorMessage: 'Invalid CIN structure format',
      );
    }

    final listingChar = match.group(1)!;
    final isListed = listingChar == 'L';
    final industryCode = match.group(2)!;
    final stateCode = match.group(3)!;
    final yearStr = match.group(4)!;
    final typeCode = match.group(5)!;
    final registrationNum = match.group(6)!;

    // Verify state code
    final stateName = BharatRtoDatabase.stateCodes[stateCode];
    if (stateName == null) {
      return CinValidationResult(
        cin: raw,
        formattedCin: clean,
        isValid: false,
        stateCode: stateCode,
        errorMessage: 'Unrecognized state code "$stateCode" in CIN',
      );
    }

    // Verify incorporation year
    final year = int.tryParse(yearStr);
    final currentYear = DateTime.now().year + 1;
    if (year == null || year < 1850 || year > currentYear) {
      return CinValidationResult(
        cin: raw,
        formattedCin: clean,
        isValid: false,
        stateCode: stateCode,
        stateName: stateName,
        incorporationYear: year,
        errorMessage: 'Invalid incorporation year "$yearStr" in CIN',
      );
    }

    final typeDescription = _companyTypes[typeCode] ?? 'Other Corporate Entity';

    return CinValidationResult(
      cin: raw,
      formattedCin: clean,
      isValid: true,
      isListed: isListed,
      industryCode: industryCode,
      stateCode: stateCode,
      stateName: stateName,
      incorporationYear: year,
      companyTypeCode: typeCode,
      companyTypeDescription: typeDescription,
      registrationNumber: registrationNum,
    );
  }

  /// Masks a CIN for display, preserving listing status, state, year, and registration number.
  ///
  /// Example:
  /// `U72200KA2020PTC123456` -> `U72200KA2020XXX123456`
  static String mask(String cin, {String maskChar = 'X'}) {
    final result = validate(cin);
    if (!result.isValid) return cin;

    final clean = result.formattedCin;
    // Mask the 3-letter entity type
    return '${clean.substring(0, 12)}${maskChar * 3}${clean.substring(15)}';
  }
}

/// Tax Deduction and Collection Account Number (TAN) validator.
class BharatTan {
  static final RegExp _tanRegex =
      RegExp(r'^([A-Z]{3})([A-Z])([0-9]{5})([A-Z])$');
  static final RegExp _cleanAlphanumericRegex = RegExp(r'[^A-Z0-9]');

  /// Validates a 10-character Indian TAN.
  ///
  /// Examples:
  /// ```dart
  /// final result = BharatTan.validate("DELA12345B");
  /// print(result.isValid);          // true
  /// print(result.jurisdictionCode); // "DEL"
  /// print(result.deductorInitial);  // "A"
  /// ```
  static TanValidationResult validate(String? tan) {
    if (tan == null || tan.trim().isEmpty) {
      return const TanValidationResult(
        tan: '',
        formattedTan: '',
        isValid: false,
        errorMessage: 'TAN cannot be empty',
      );
    }

    final raw = tan.trim().toUpperCase();
    final clean = raw.replaceAll(_cleanAlphanumericRegex, '');

    if (clean.length != 10) {
      return TanValidationResult(
        tan: raw,
        formattedTan: raw,
        isValid: false,
        errorMessage: 'TAN must be exactly 10 alphanumeric characters',
      );
    }

    final match = _tanRegex.firstMatch(clean);
    if (match == null) {
      return TanValidationResult(
        tan: raw,
        formattedTan: raw,
        isValid: false,
        errorMessage:
            'Invalid TAN structure (must be 4 letters, 5 digits, and 1 letter)',
      );
    }

    return TanValidationResult(
      tan: raw,
      formattedTan: clean,
      isValid: true,
      jurisdictionCode: match.group(1),
      deductorInitial: match.group(2),
      serialNumber: match.group(3),
      checkLetter: match.group(4),
    );
  }

  /// Masks a TAN, preserving jurisdiction and last character.
  ///
  /// Example:
  /// `DELA12345B` -> `DELXXXXXXB`
  static String mask(String tan, {String maskChar = 'X'}) {
    final result = validate(tan);
    if (!result.isValid) return tan;

    final clean = result.formattedTan;
    return '${clean.substring(0, 3)}${maskChar * 6}${clean.substring(9)}';
  }
}

/// Director Identification Number (DIN) validator.
class BharatDin {
  static final RegExp _dinRegex = RegExp(r'^[0-9]{8}$');
  static final RegExp _digitsOnlyRegex = RegExp(r'\D');

  /// Validates an 8-digit Director Identification Number (DIN).
  static DinValidationResult validate(String? din) {
    if (din == null || din.trim().isEmpty) {
      return const DinValidationResult(
        din: '',
        isValid: false,
        errorMessage: 'DIN cannot be empty',
      );
    }

    final clean = din.trim().replaceAll(_digitsOnlyRegex, '');

    if (clean.length != 8 || !_dinRegex.hasMatch(clean)) {
      return DinValidationResult(
        din: din,
        isValid: false,
        errorMessage: 'DIN must be exactly 8 numeric digits',
      );
    }

    return DinValidationResult(
      din: clean,
      isValid: true,
    );
  }

  /// Masks a DIN, preserving only the last 4 digits.
  ///
  /// Example:
  /// `00123456` -> `XXXX3456`
  static String mask(String din, {String maskChar = 'X'}) {
    final result = validate(din);
    if (!result.isValid) return din;

    return '${maskChar * 4}${result.din.substring(4)}';
  }
}
