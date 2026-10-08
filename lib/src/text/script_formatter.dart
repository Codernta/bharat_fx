import 'package:flutter/services.dart';
import 'indian_scripts.dart';

/// A [TextInputFormatter] that restricts text input to characters of specific
/// Indian scripts (e.g. Devanagari, Tamil, Telugu).
class BharatScriptInputFormatter extends TextInputFormatter {
  final List<IndianScript> allowedScripts;
  final bool allowSpaces;
  final bool allowPunctuation;
  final bool allowLatin;
  final bool allowDigits;

  BharatScriptInputFormatter({
    required this.allowedScripts,
    this.allowSpaces = true,
    this.allowPunctuation = true,
    this.allowLatin = false,
    this.allowDigits = true,
  });

  /// Convenience factory for a single script.
  factory BharatScriptInputFormatter.single(
    IndianScript script, {
    bool allowSpaces = true,
    bool allowPunctuation = true,
    bool allowLatin = false,
    bool allowDigits = true,
  }) {
    return BharatScriptInputFormatter(
      allowedScripts: [script],
      allowSpaces: allowSpaces,
      allowPunctuation: allowPunctuation,
      allowLatin: allowLatin,
      allowDigits: allowDigits,
    );
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (final rune in newValue.text.runes) {
      if (_isAllowed(rune)) {
        buffer.writeCharCode(rune);
      }
    }

    final filtered = buffer.toString();
    final newSelectionOffset =
        newValue.selection.baseOffset <= filtered.length
            ? newValue.selection.baseOffset
            : filtered.length;

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(
        offset: newSelectionOffset >= 0 ? newSelectionOffset : filtered.length,
      ),
    );
  }

  bool _isAllowed(int rune) {
    // Whitespace
    if (allowSpaces && (rune == 32 || rune == 9 || rune == 10)) {
      return true;
    }

    // Latin alphabet (A-Z, a-z)
    if (allowLatin &&
        ((rune >= 65 && rune <= 90) || (rune >= 97 && rune <= 122))) {
      return true;
    }

    // Standard Arabic Digits (0-9)
    if (allowDigits && (rune >= 48 && rune <= 57)) {
      return true;
    }

    // Check Indic scripts
    for (final script in allowedScripts) {
      final (start, end) = script.unicodeRange;
      if (rune >= start && rune <= end) {
        return true;
      }
    }

    // Punctuation
    if (allowPunctuation && _isPunctuation(rune)) {
      return true;
    }

    return false;
  }

  static bool _isPunctuation(int rune) {
    return (rune >= 33 && rune <= 47) ||
        (rune >= 58 && rune <= 64) ||
        (rune >= 91 && rune <= 96) ||
        (rune >= 123 && rune <= 126) ||
        rune == 0x0964 || // ।
        rune == 0x0965; // ॥
  }
}
