import 'indian_scripts.dart';
import 'transliterator.dart';

/// Top-level facade for Indian text utilities, script detection, and transliteration.
class BharatText {
  /// Detects the dominant Indian script in the provided text.
  static IndianScript? detectScript(String text) =>
      BharatScriptDetector.detectScript(text);

  /// Checks if the text strictly consists of characters from the given script.
  static bool isPure(
    String text,
    IndianScript script, {
    bool allowWhitespace = true,
    bool allowPunctuation = true,
  }) =>
      BharatScriptDetector.isPureScript(
        text,
        script,
        allowWhitespace: allowWhitespace,
        allowPunctuation: allowPunctuation,
      );

  /// Converts standard numbers (0-9) to native Indic script digits (e.g. 123 -> १२३).
  static String toIndicDigits(String text, IndianScript script) =>
      BharatScriptDetector.toIndicDigits(text, script);

  /// Converts native Indic script digits back to standard digits (0-9).
  static String fromIndicDigits(String text) =>
      BharatScriptDetector.fromIndicDigits(text);

  /// Transliterates phonetic English/Hinglish text to an Indian script.
  static String transliterate(
    String text, {
    IndianScript targetScript = IndianScript.devanagari,
  }) =>
      BharatTransliterator.transliterate(text, targetScript: targetScript);
}
