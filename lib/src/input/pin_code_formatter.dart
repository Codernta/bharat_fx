import 'package:flutter/services.dart';

/// [TextInputFormatter] that formats Indian PIN codes up to 6 digits,
/// with optional spacing (e.g. "110 001").
class BharatPinCodeInputFormatter extends TextInputFormatter {
  final bool withSpace;

  BharatPinCodeInputFormatter({this.withSpace = false});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Max 6 digits for Indian PIN codes
    final truncated = digits.length > 6 ? digits.substring(0, 6) : digits;

    if (!withSpace || truncated.length <= 3) {
      return TextEditingValue(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
    }

    final formatted =
        '${truncated.substring(0, 3)} ${truncated.substring(3)}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
