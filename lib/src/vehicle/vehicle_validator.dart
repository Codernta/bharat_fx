import 'rto_database.dart';
import 'vehicle_types.dart';

/// Validator and parser for Indian vehicle registration plates (Standard, BH series, Military, Diplomatic).
class BharatVehicle {
  // Spaced format: DL 01 AB 1234 or DL 3C AB 1234
  static final RegExp _standardSpacedRegex = RegExp(
    r'^([A-Z]{2})\s+([0-9]{1,2}[A-Z]?)\s+([A-Z]{1,3})\s+([0-9]{1,4})$',
  );

  // Spaced format without series: MH 12 1234
  static final RegExp _standardNoSeriesRegex = RegExp(
    r'^([A-Z]{2})\s+([0-9]{1,2})\s+([0-9]{1,4})$',
  );

  // Compact unspaced: KA05M9999, DL01AB1234
  static final RegExp _standardCompactRegex = RegExp(
    r'^([A-Z]{2})([0-9]{2})([A-Z]{1,3})([0-9]{1,4})$',
  );

  // Compact unspaced without series: MH121234
  static final RegExp _standardCompactNoSeriesRegex = RegExp(
    r'^([A-Z]{2})([0-9]{2})([0-9]{1,4})$',
  );

  // Delhi single-digit or letter RTO compact: DL3CAB1234
  static final RegExp _delhiCompactRegex = RegExp(
    r'^(DL)([0-9]{1,2}[A-Z])([A-Z]{1,2})([0-9]{1,4})$',
  );

  // Regex for Bharat Series: 21 BH 1234 AA
  static final RegExp _bhSeriesRegex = RegExp(
    r'^([0-9]{2})\s*(BH)\s*([0-9]{4})\s*([A-Z]{1,2})$',
  );

  // Regex for Defense / Military plates: ↑ 12 D 123456 X or 12D123456X
  static final RegExp _defenseRegex = RegExp(
    r'^[↑\^]?\s*([0-9]{2})\s*([A-Z])\s*([0-9]{5,6})\s*([A-Z])$',
  );

  // Regex for Diplomatic plates: 77 CD 1234
  static final RegExp _diplomaticRegex = RegExp(
    r'^([0-9]{1,3})\s*(CD|CC|UN)\s*([0-9]{1,4})$',
  );

  /// Checks if [plateNumber] matches any recognized Indian registration format.
  static bool isValid(String? plateNumber) {
    if (plateNumber == null) return false;
    final info = validate(plateNumber);
    return info.isValid;
  }

  /// Parses and validates [plateNumber], extracting state, RTO, series, and type.
  ///
  /// Examples:
  /// ```dart
  /// final info = BharatVehicle.validate("DL 01 AB 1234");
  /// print(info.stateName); // "Delhi"
  /// print(info.rtoName); // "Mall Road, North Delhi"
  ///
  /// final bhInfo = BharatVehicle.validate("21 BH 1234 AA");
  /// print(bhInfo.type); // VehiclePlateType.bharatSeries
  /// ```
  static VehiclePlateInfo validate(String? plateNumber) {
    if (plateNumber == null || plateNumber.trim().isEmpty) {
      return const VehiclePlateInfo(
        rawNumber: '',
        formattedNumber: '',
        isValid: false,
        errorMessage: 'Vehicle number cannot be empty',
      );
    }

    final raw = plateNumber.trim();
    final normalized = raw
        .toUpperCase()
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final unspaced = normalized.replaceAll(' ', '');

    // 1. Check Bharat Series (BH)
    final bhMatch = _bhSeriesRegex.firstMatch(unspaced);
    if (bhMatch != null) {
      final yearDigits = bhMatch.group(1)!;
      final year = 2000 + int.parse(yearDigits);
      final number = bhMatch.group(3)!;
      final series = bhMatch.group(4)!;
      final formatted = '$yearDigits BH $number $series';

      return VehiclePlateInfo(
        rawNumber: raw,
        formattedNumber: formatted,
        isValid: true,
        type: VehiclePlateType.bharatSeries,
        stateCode: 'BH',
        stateName: 'Bharat (Pan-India)',
        series: series,
        registrationNumber: number,
        registrationYear: year,
      );
    }

    // 2. Check Standard State Registration
    String? stateCode;
    String? rtoCode;
    String? series;
    String? number;

    final spacedMatch = _standardSpacedRegex.firstMatch(normalized);
    if (spacedMatch != null) {
      stateCode = spacedMatch.group(1);
      rtoCode = spacedMatch.group(2);
      series = spacedMatch.group(3);
      number = spacedMatch.group(4);
    } else {
      final noSeriesMatch = _standardNoSeriesRegex.firstMatch(normalized);
      if (noSeriesMatch != null) {
        stateCode = noSeriesMatch.group(1);
        rtoCode = noSeriesMatch.group(2);
        series = '';
        number = noSeriesMatch.group(3);
      } else {
        final compactMatch = _standardCompactRegex.firstMatch(unspaced);
        if (compactMatch != null) {
          stateCode = compactMatch.group(1);
          rtoCode = compactMatch.group(2);
          series = compactMatch.group(3);
          number = compactMatch.group(4);
        } else {
          final delhiMatch = _delhiCompactRegex.firstMatch(unspaced);
          if (delhiMatch != null) {
            stateCode = delhiMatch.group(1);
            rtoCode = delhiMatch.group(2);
            series = delhiMatch.group(3);
            number = delhiMatch.group(4);
          } else {
            final compactNoSeries =
                _standardCompactNoSeriesRegex.firstMatch(unspaced);
            if (compactNoSeries != null) {
              stateCode = compactNoSeries.group(1);
              rtoCode = compactNoSeries.group(2);
              series = '';
              number = compactNoSeries.group(3);
            }
          }
        }
      }
    }

    if (stateCode != null && rtoCode != null && number != null) {
      final stateName = BharatRtoDatabase.getStateName(stateCode);
      if (stateName == null) {
        return VehiclePlateInfo(
          rawNumber: raw,
          formattedNumber: normalized,
          isValid: false,
          errorMessage: 'Unrecognized Indian State code "$stateCode"',
        );
      }

      final rtoLocation = BharatRtoDatabase.getRtoLocation(stateCode, rtoCode);

      final formattedBuffer = StringBuffer('$stateCode $rtoCode');
      if (series != null && series.isNotEmpty) {
        formattedBuffer.write(' $series');
      }
      formattedBuffer.write(' $number');

      return VehiclePlateInfo(
        rawNumber: raw,
        formattedNumber: formattedBuffer.toString(),
        isValid: true,
        type: VehiclePlateType.standard,
        stateCode: stateCode,
        stateName: stateName,
        rtoCode: rtoCode,
        rtoName: rtoLocation,
        series: (series == null || series.isEmpty) ? null : series,
        registrationNumber: number,
      );
    }

    // 3. Check Defense plates
    final defenseMatch = _defenseRegex.firstMatch(normalized);
    if (defenseMatch != null) {
      final yearDigits = defenseMatch.group(1)!;
      final classLetter = defenseMatch.group(2)!;
      final serial = defenseMatch.group(3)!;
      final suffix = defenseMatch.group(4)!;
      final formatted = '↑ $yearDigits $classLetter $serial $suffix';

      return VehiclePlateInfo(
        rawNumber: raw,
        formattedNumber: formatted,
        isValid: true,
        type: VehiclePlateType.defense,
        stateCode: 'DEF',
        stateName: 'Indian Armed Forces',
        series: classLetter,
        registrationNumber: serial,
        registrationYear: 2000 + int.parse(yearDigits),
      );
    }

    // 4. Check Diplomatic plates
    final diplomaticMatch = _diplomaticRegex.firstMatch(normalized);
    if (diplomaticMatch != null) {
      final countryCode = diplomaticMatch.group(1)!;
      final category = diplomaticMatch.group(2)!;
      final serial = diplomaticMatch.group(3)!;
      final formatted = '$countryCode $category $serial';

      return VehiclePlateInfo(
        rawNumber: raw,
        formattedNumber: formatted,
        isValid: true,
        type: VehiclePlateType.diplomatic,
        stateCode: 'DIP',
        stateName: 'Diplomatic Corps / UN',
        registrationNumber: serial,
      );
    }

    return VehiclePlateInfo(
      rawNumber: raw,
      formattedNumber: normalized,
      isValid: false,
      errorMessage: 'Invalid Indian vehicle number plate format',
    );
  }
}
