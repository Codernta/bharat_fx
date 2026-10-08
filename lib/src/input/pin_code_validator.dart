import 'pin_code_data.dart';

/// Validator and local offline resolver for Indian Postal PIN codes.
class BharatPinCode {
  static final RegExp _pinRegex = RegExp(r'^[1-9][0-9]{5}$');

  /// Validates whether the given string is a valid 6-digit Indian PIN code.
  ///
  /// PIN codes must be exactly 6 digits and cannot start with 0.
  static bool isValid(String? pinCode) {
    if (pinCode == null) return false;
    final cleaned = pinCode.replaceAll(RegExp(r'\s+'), '');
    return _pinRegex.hasMatch(cleaned);
  }

  /// Synchronously and locally resolves the State, District, Postal Circle, and Zone
  /// for a 6-digit Indian PIN code without any network or external API call.
  ///
  /// Example:
  /// ```dart
  /// final info = BharatPinCode.lookup('560001');
  /// print(info.state); // "Karnataka"
  /// print(info.district); // "Bengaluru Urban"
  /// ```
  static PinCodeInfo lookup(String? pinCode) {
    if (pinCode == null) {
      return const PinCodeInfo(pinCode: '', isValid: false);
    }

    final cleaned = pinCode.replaceAll(RegExp(r'\s+'), '');
    if (!isValid(cleaned)) {
      return PinCodeInfo(pinCode: cleaned, isValid: false);
    }

    final zoneDigit = cleaned.substring(0, 1);
    final circlePrefix = cleaned.substring(0, 2);
    final districtPrefix = cleaned.substring(0, 3);

    final zone = BharatPinCodeData.zones[zoneDigit];
    final isArmy = zoneDigit == '9';

    // 1. Try 3-digit district resolution
    final districtMatch = BharatPinCodeData.districtData[districtPrefix];
    String? district = districtMatch?['district'];
    String? state = districtMatch?['state'];

    // 2. Fallback to 2-digit circle resolution if district not mapped
    final circleMatch = BharatPinCodeData.circleData[circlePrefix];
    state ??= circleMatch?['state'];
    final circle = circleMatch?['circle'];

    if (isArmy) {
      state = 'Army Postal Service (APS)';
      district = 'Field Post Office (FPO)';
    }

    return PinCodeInfo(
      pinCode: cleaned,
      isValid: true,
      state: state,
      district: district ?? 'Postal Division ($districtPrefix)',
      zone: zone,
      circle: circle,
      isArmyPostal: isArmy,
    );
  }

  /// Formats a 6-digit PIN code with an optional space grouping (e.g., `110 001`).
  static String format(String pinCode, {bool withSpace = true}) {
    final digits = pinCode.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 6) return pinCode;
    if (withSpace) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)}';
    }
    return digits;
  }
}
