import 'package:flutter/services.dart';
import 'indian_scripts.dart';
import 'transliterator.dart';

/// A [TextInputFormatter] that automatically converts phonetic Hinglish/Latin input
/// into Indian scripts (e.g. Devanagari) in real-time.
class BharatPhoneticInputFormatter extends TextInputFormatter {
  final IndianScript targetScript;
  final bool convertOnSpace;

  BharatPhoneticInputFormatter({
    this.targetScript = IndianScript.devanagari,
    this.convertOnSpace = true,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // In convertOnSpace mode:
    // When the user has just typed a space, transliterate the preceding word.
    if (convertOnSpace) {
      if (newValue.text.endsWith(' ') && !oldValue.text.endsWith(' ')) {
        final textWithoutTrailingSpace = newValue.text.substring(
          0,
          newValue.text.length - 1,
        );
        final transliterated = BharatTransliterator.transliterate(
          textWithoutTrailingSpace,
          targetScript: targetScript,
        );
        final finalText = '$transliterated ';
        return TextEditingValue(
          text: finalText,
          selection: TextSelection.collapsed(offset: finalText.length),
        );
      }
      return newValue;
    }

    // Continuous mode:
    final transliterated = BharatTransliterator.transliterate(
      newValue.text,
      targetScript: targetScript,
    );

    return TextEditingValue(
      text: transliterated,
      selection: TextSelection.collapsed(offset: transliterated.length),
    );
  }
}
