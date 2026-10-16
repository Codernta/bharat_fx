import '../vehicle/rto_database.dart';

/// Parsed result of an Indian Driving License (DL) validation.
class DrivingLicenseValidationResult {
  final String dlNumber;
  final String formattedNumber;
  final bool isValid;
  final String? stateCode;
  final String? stateName;
  final String? rtoCode;
  final String? rtoName;
  final int? issueYear;
  final String? uniqueNumber;
  final String? errorMessage;

  const DrivingLicenseValidationResult({
    required this.dlNumber,
    required this.formattedNumber,
    required this.isValid,
    this.stateCode,
    this.stateName,
    this.rtoCode,
    this.rtoName,
    this.issueYear,
    this.uniqueNumber,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'DrivingLicenseValidationResult(dl: $formattedNumber, valid: $isValid, state: $stateName, rto: $rtoName, year: $issueYear)';
  }
}

/// Official Ministry of Road Transport and Highways (MoRTH) Indian Driving License validator.
///
/// Implements parsing for the pan-India standardized 15/16 character Driving License format:
/// `SS-RR-YYYY-NNNNNNN` (State Code, RTO Code, 4-digit Issue Year, 7-digit Serial Number).
class BharatDrivingLicense {
  // Regex for standard 15-character MoRTH Driving License
  // e.g. DL-01-2020-0012345, DL01 20200012345, DL0120200012345
  static final RegExp _standardRegex = RegExp(
    r'^([A-Z]{2})[-/\s]?([0-9]{2})[-/\s]?([0-9]{4})[-/\s]?([0-9]{7})$',
  );

  // Fallback for legacy state licenses (e.g. 1-digit RTO or variable length serials)
  static final RegExp _legacyRegex = RegExp(
    r'^([A-Z]{2})[-/\s]?([0-9]{1,3})[-/\s]?([0-9]{4})[-/\s]?([0-9]{5,8})$',
  );
  static final RegExp _cleanAlphanumericRegex = RegExp(r'[^A-Z0-9]');

  /// Validates and parses an Indian Driving License number.
  ///
  /// Examples:
  /// ```dart
  /// final result = BharatDrivingLicense.validate("DL-01-2020-0012345");
  /// print(result.isValid);   // true
  /// print(result.stateName); // "Delhi"
  /// print(result.rtoName);   // "Mall Road, North Delhi"
  /// print(result.issueYear); // 2020
  /// ```
  static DrivingLicenseValidationResult validate(String? dlNumber) {
    if (dlNumber == null || dlNumber.trim().isEmpty) {
      return const DrivingLicenseValidationResult(
        dlNumber: '',
        formattedNumber: '',
        isValid: false,
        errorMessage: 'Driving license cannot be empty',
      );
    }

    final raw = dlNumber.trim().toUpperCase();
    final clean = raw.replaceAll(_cleanAlphanumericRegex, '');

    if (clean.length < 14 || clean.length > 17) {
      return DrivingLicenseValidationResult(
        dlNumber: raw,
        formattedNumber: raw,
        isValid: false,
        errorMessage:
            'Driving license must have between 14 and 16 alphanumeric characters',
      );
    }

    final match = _standardRegex.firstMatch(raw) ??
        _standardRegex.firstMatch(clean) ??
        _legacyRegex.firstMatch(raw) ??
        _legacyRegex.firstMatch(clean);

    if (match == null) {
      return DrivingLicenseValidationResult(
        dlNumber: raw,
        formattedNumber: raw,
        isValid: false,
        errorMessage: 'Invalid Driving License format structure',
      );
    }

    final state = match.group(1)!;
    final rtoNum = match.group(2)!.padLeft(2, '0');
    final yearStr = match.group(3)!;
    final uniqueNum = match.group(4)!;

    // Verify State Code against MoRTH Indian State codes
    final stateName = BharatRtoDatabase.stateCodes[state];
    if (stateName == null) {
      return DrivingLicenseValidationResult(
        dlNumber: raw,
        formattedNumber: raw,
        isValid: false,
        stateCode: state,
        errorMessage: 'Unrecognized state code "$state" in Driving License',
      );
    }

    // Verify Year
    final year = int.tryParse(yearStr);
    final currentYear = DateTime.now().year + 1;
    if (year == null || year < 1950 || year > currentYear) {
      return DrivingLicenseValidationResult(
        dlNumber: raw,
        formattedNumber: raw,
        isValid: false,
        stateCode: state,
        stateName: stateName,
        issueYear: year,
        errorMessage: 'Invalid issue year "$yearStr" in Driving License',
      );
    }

    // Resolve RTO Office Name
    final rtoCode = '$state$rtoNum';
    final rtoName = BharatRtoDatabase.rtoLocations[rtoCode];

    final formatted = '$state-$rtoNum-$yearStr-$uniqueNum';

    return DrivingLicenseValidationResult(
      dlNumber: raw,
      formattedNumber: formatted,
      isValid: true,
      stateCode: state,
      stateName: stateName,
      rtoCode: rtoCode,
      rtoName: rtoName,
      issueYear: year,
      uniqueNumber: uniqueNum,
    );
  }

  /// Formats a Driving License number into canonical `SS-RR-YYYY-NNNNNNN` notation.
  static String format(String dlNumber) {
    final result = validate(dlNumber);
    return result.isValid
        ? result.formattedNumber
        : dlNumber.trim().toUpperCase();
  }

  /// Masks a Driving License number for privacy compliance, preserving state, RTO and last 4 digits.
  ///
  /// Example:
  /// `DL-01-2020-0012345` -> `DL-01-XXXX-XXX2345`
  static String mask(String dlNumber, {String maskChar = 'X'}) {
    final result = validate(dlNumber);
    if (!result.isValid) return dlNumber;

    final state = result.stateCode!;
    final rto = result.rtoCode!.substring(2);
    final unique = result.uniqueNumber!;
    final visibleLast =
        unique.length > 4 ? unique.substring(unique.length - 4) : unique;
    final maskedPrefix = maskChar * (unique.length > 4 ? unique.length - 4 : 0);

    return '$state-$rto-${maskChar * 4}-$maskedPrefix$visibleLast';
  }
}

/// Convenience alias for [BharatDrivingLicense].
typedef BharatDl = BharatDrivingLicense;
