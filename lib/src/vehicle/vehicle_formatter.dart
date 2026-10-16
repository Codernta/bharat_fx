import 'package:flutter/services.dart';

/// [TextInputFormatter] that formats vehicle registration plates,
/// forcing uppercase and restricting non-alphanumeric symbols.
class BharatVehicleInputFormatter extends TextInputFormatter {
  static final RegExp _disallowedCharsRegex = RegExp(r'[^A-Z0-9\s]');
  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  const BharatVehicleInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Convert to uppercase and strip non-alphanumeric except single space
    final cleaned = newValue.text
        .toUpperCase()
        .replaceAll(_disallowedCharsRegex, '')
        .replaceAll(_whitespaceRegex, ' ');

    // Max length for Indian number plate string is usually 13 (e.g. "DL 01 AAA 1234")
    final truncated = cleaned.length > 13 ? cleaned.substring(0, 13) : cleaned;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}
