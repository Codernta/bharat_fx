import 'words_languages.dart';

/// Utility class to convert numbers into words in regional Indian languages.
class BharatNumberToWords {
  /// Converts an integer or double into words in the specified Indian language.
  ///
  /// Example:
  /// ```dart
  /// BharatNumberToWords.convert(15000); // "Fifteen Thousand Rupees Only"
  /// BharatNumberToWords.convert(15000, language: BharatLanguage.hindi); // "पंद्रह हज़ार रुपये मात्र"
  /// BharatNumberToWords.convert(100000, includeCurrency: false); // "One Lakh"
  /// ```
  static String convert(
    num amount, {
    BharatLanguage language = BharatLanguage.english,
    bool includeCurrency = true,
    bool includePaise = true,
    bool includeOnly = true,
  }) {
    if (amount == 0) {
      final dict = BharatWordDictionaries.get(language);
      final buffer = StringBuffer(dict.zero);
      if (includeCurrency) {
        buffer.write(' ${dict.rupeePlural}');
      }
      if (includeOnly) {
        buffer.write(' ${dict.onlyWord}');
      }
      return buffer.toString().trim();
    }

    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final wholePart = absAmount.truncate();
    final paisePart = ((absAmount - wholePart) * 100).round();

    final dict = BharatWordDictionaries.get(language);
    final parts = <String>[];

    if (wholePart == 0) {
      if (paisePart == 0) {
        parts.add(dict.zero);
      }
    } else {
      final words = _convertInteger(wholePart, dict);
      parts.add(words);
    }

    // Currency suffix for main amount
    if (includeCurrency && wholePart > 0) {
      final rupeeWord = wholePart == 1 ? dict.rupeeSingular : dict.rupeePlural;
      parts.add(rupeeWord);
    }

    // Decimal / Paise part
    if (includePaise && paisePart > 0) {
      final paiseWords = dict.getUnderHundred(paisePart);
      final paiseUnit = paisePart == 1 ? dict.paiseSingular : dict.paisePlural;
      if (parts.isNotEmpty) {
        parts.add(dict.andWord);
      }
      parts.add(paiseWords);
      parts.add(paiseUnit);
    }

    if (includeOnly) {
      parts.add(dict.onlyWord);
    }

    var result = parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (isNegative) {
      result = 'Minus $result';
    }

    return result;
  }

  static String _convertInteger(int n, WordsDictionary dict) {
    if (n == 0) return '';
    final chunks = <String>[];

    // Arabs (10^9)
    if (n >= 1000000000) {
      final arabs = n ~/ 1000000000;
      chunks.add('${_convertInteger(arabs, dict)} ${dict.arab}');
      n %= 1000000000;
    }

    // Crores (10^7)
    if (n >= 10000000) {
      final crores = n ~/ 10000000;
      chunks.add('${_convertInteger(crores, dict)} ${dict.crore}');
      n %= 10000000;
    }

    // Lakhs (10^5)
    if (n >= 100000) {
      final lakhs = n ~/ 100000;
      chunks.add('${_convertInteger(lakhs, dict)} ${dict.lakh}');
      n %= 100000;
    }

    // Thousands (10^3)
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      chunks.add('${_convertInteger(thousands, dict)} ${dict.thousand}');
      n %= 1000;
    }

    // Hundreds (10^2)
    if (n >= 100) {
      final hundreds = n ~/ 100;
      chunks.add('${_convertInteger(hundreds, dict)} ${dict.hundred}');
      n %= 100;
    }

    // Remaining (0 - 99)
    if (n > 0) {
      chunks.add(dict.getUnderHundred(n));
    }

    return chunks.join(' ').trim();
  }
}
