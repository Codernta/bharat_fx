import 'aadhaar_validator.dart';

/// Validator and masker for 16-digit Indian Virtual IDs (VID),
/// mandated by UIDAI to protect user privacy as an alternative to Aadhaar.
class BharatVid {
  static final RegExp _whitespaceRegex = RegExp(r'\s+');
  static final RegExp _vidFormatRegex = RegExp(r'^[2-9][0-9]{15}$');
  static final RegExp _nonDigitsRegex = RegExp(r'\D');

  /// Validates whether the given string is a valid 16-digit UIDAI Virtual ID (VID).
  ///
  /// Rules:
  /// 1. Exactly 16 numeric digits.
  /// 2. Does not start with '0' or '1'.
  /// 3. Validated via the official Verhoeff checksum algorithm.
  static bool validate(String? vid) {
    if (vid == null) return false;
    final digits = vid.replaceAll(_whitespaceRegex, '');

    if (digits.length != 16) return false;
    if (!_vidFormatRegex.hasMatch(digits)) return false;

    return BharatAadhaar.validateVerhoeff(digits);
  }

  /// Masks a 16-digit Virtual ID, concealing the first 12 digits.
  ///
  /// Examples:
  /// ```dart
  /// BharatVid.mask("2345678901234567"); // "XXXX XXXX XXXX 4567"
  /// ```
  static String mask(
    String vid, {
    String maskChar = 'X',
    bool preserveSpacing = true,
  }) {
    final digits = vid.replaceAll(_whitespaceRegex, '');
    if (digits.length != 16) return vid;

    final maskedHead = maskChar * 12;
    final lastFour = digits.substring(12);

    if (preserveSpacing) {
      return '${maskedHead.substring(0, 4)} ${maskedHead.substring(4, 8)} ${maskedHead.substring(8, 12)} $lastFour';
    }
    return '$maskedHead$lastFour';
  }

  /// Formats a 16-digit VID into standard 4-digit blocks (`XXXX XXXX XXXX XXXX`).
  static String format(String vid) {
    final digits = vid.replaceAll(_nonDigitsRegex, '');
    if (digits.length != 16) return vid;
    return '${digits.substring(0, 4)} ${digits.substring(4, 8)} ${digits.substring(8, 12)} ${digits.substring(12, 16)}';
  }
}
