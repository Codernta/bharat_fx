/// Supported Indian scripts and their Unicode characteristics.
enum IndianScript {
  devanagari, // Hindi, Marathi, Sanskrit, Nepali
  tamil,
  telugu,
  kannada,
  malayalam,
  bengali, // Bengali, Assamese
  gujarati,
  gurmukhi, // Punjabi
  odia,
}

/// Helper extension providing Unicode ranges and metadata for Indian scripts.
extension IndianScriptExtension on IndianScript {
  /// Name of the script.
  String get name {
    switch (this) {
      case IndianScript.devanagari:
        return 'Devanagari';
      case IndianScript.tamil:
        return 'Tamil';
      case IndianScript.telugu:
        return 'Telugu';
      case IndianScript.kannada:
        return 'Kannada';
      case IndianScript.malayalam:
        return 'Malayalam';
      case IndianScript.bengali:
        return 'Bengali';
      case IndianScript.gujarati:
        return 'Gujarati';
      case IndianScript.gurmukhi:
        return 'Gurmukhi';
      case IndianScript.odia:
        return 'Odia';
    }
  }

  /// Primary Unicode range `[start, end]`.
  (int, int) get unicodeRange {
    switch (this) {
      case IndianScript.devanagari:
        return (0x0900, 0x097F);
      case IndianScript.bengali:
        return (0x0980, 0x09FF);
      case IndianScript.gurmukhi:
        return (0x0A00, 0x0A7F);
      case IndianScript.gujarati:
        return (0x0A80, 0x0AFF);
      case IndianScript.odia:
        return (0x0B00, 0x0B7F);
      case IndianScript.tamil:
        return (0x0B80, 0x0BFF);
      case IndianScript.telugu:
        return (0x0C00, 0x0C7F);
      case IndianScript.kannada:
        return (0x0C80, 0x0CFF);
      case IndianScript.malayalam:
        return (0x0D00, 0x0D7F);
    }
  }

  /// Unicode digit offset for '0' in this script (if applicable).
  int? get zeroDigitCodePoint {
    switch (this) {
      case IndianScript.devanagari:
        return 0x0966;
      case IndianScript.bengali:
        return 0x09E6;
      case IndianScript.gurmukhi:
        return 0x0A66;
      case IndianScript.gujarati:
        return 0x0AE6;
      case IndianScript.odia:
        return 0x0B66;
      case IndianScript.tamil:
        return 0x0BE6;
      case IndianScript.telugu:
        return 0x0C66;
      case IndianScript.kannada:
        return 0x0CE6;
      case IndianScript.malayalam:
        return 0x0D66;
    }
  }

  /// Halant / Virama character code for the script.
  String get virama {
    switch (this) {
      case IndianScript.devanagari:
        return '\u094D';
      case IndianScript.bengali:
        return '\u09CD';
      case IndianScript.gurmukhi:
        return '\u0A4D';
      case IndianScript.gujarati:
        return '\u0ACD';
      case IndianScript.odia:
        return '\u0B4D';
      case IndianScript.tamil:
        return '\u0BCD';
      case IndianScript.telugu:
        return '\u0C4D';
      case IndianScript.kannada:
        return '\u0CCD';
      case IndianScript.malayalam:
        return '\u0D4D';
    }
  }
}

/// Utility for detecting and inspecting Indian scripts.
class BharatScriptDetector {
  /// Detects the dominant Indian script present in [text], or null if none found.
  static IndianScript? detectScript(String text) {
    final counts = <IndianScript, int>{};

    for (final char in text.runes) {
      for (final script in IndianScript.values) {
        final (start, end) = script.unicodeRange;
        if (char >= start && char <= end) {
          counts[script] = (counts[script] ?? 0) + 1;
        }
      }
    }

    if (counts.isEmpty) return null;

    IndianScript? dominant;
    int maxCount = 0;
    for (final entry in counts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        dominant = entry.key;
      }
    }
    return dominant;
  }

  /// Checks if [text] strictly contains only characters belonging to [script]
  /// (ignoring whitespace and standard punctuation).
  static bool isPureScript(
    String text,
    IndianScript script, {
    bool allowWhitespace = true,
    bool allowPunctuation = true,
  }) {
    if (text.isEmpty) return true;
    final (start, end) = script.unicodeRange;

    for (final char in text.runes) {
      if (allowWhitespace && (char == 32 || char == 9 || char == 10)) {
        continue;
      }
      if (allowPunctuation && _isPunctuation(char)) {
        continue;
      }
      if (char < start || char > end) {
        return false;
      }
    }
    return true;
  }

  /// Converts standard Arabic digits (0-9) to the corresponding Indic script digits.
  static String toIndicDigits(String text, IndianScript script) {
    final zeroCode = script.zeroDigitCodePoint;
    if (zeroCode == null) return text;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      if (codeUnit >= 48 && codeUnit <= 57) {
        final digit = codeUnit - 48;
        buffer.writeCharCode(zeroCode + digit);
      } else {
        buffer.write(text[i]);
      }
    }
    return buffer.toString();
  }

  /// Converts Indic script digits back to standard Arabic digits (0-9).
  static String fromIndicDigits(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      int? arabicDigit;
      for (final script in IndianScript.values) {
        final zeroCode = script.zeroDigitCodePoint;
        if (zeroCode != null && rune >= zeroCode && rune <= zeroCode + 9) {
          arabicDigit = rune - zeroCode;
          break;
        }
      }
      if (arabicDigit != null) {
        buffer.write(arabicDigit);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static bool _isPunctuation(int rune) {
    // Standard ASCII punctuation and Indic danda (।)
    return (rune >= 33 && rune <= 47) ||
        (rune >= 58 && rune <= 64) ||
        (rune >= 91 && rune <= 96) ||
        (rune >= 123 && rune <= 126) ||
        rune == 0x0964 || // । (Purna Viram)
        rune == 0x0965; // ॥ (Deergh Viram)
  }
}
