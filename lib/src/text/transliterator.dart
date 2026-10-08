import 'indian_scripts.dart';

/// Offline phonetic transliteration engine for converting Latin/Hinglish text
/// into Indian scripts (Devanagari, Tamil, Telugu, Kannada).
class BharatTransliterator {
  /// Common high-frequency Indian words mapped directly to their natural script spelling.
  static const Map<String, String> _commonDevanagari = {
    'namaste': 'नमस्ते',
    'namaskar': 'नमस्कार',
    'pranam': 'प्रणाम',
    'bharat': 'भारत',
    'india': 'इंडिया',
    'hindustan': 'हिंदुस्तान',
    'shanti': 'शांति',
    'dost': 'दोस्त',
    'mitra': 'मित्र',
    'ghar': 'घर',
    'desh': 'देश',
    'mahan': 'महान',
    'mera': 'मेरा',
    'meri': 'मेरी',
    'mere': 'मेरे',
    'apna': 'अपना',
    'apni': 'अपनी',
    'apne': 'अपने',
    'aap': 'आप',
    'tum': 'तुम',
    'hum': 'हम',
    'kavita': 'कविता',
    'dhanyawad': 'धन्यवाद',
    'dhanyavad': 'धन्यवाद',
    'shukriya': 'शुक्रिया',
    'jai': 'जय',
    'hind': 'हिंद',
    'swagatam': 'स्वागतम्',
    'kaise': 'कैसे',
    'kaisa': 'कैसा',
    'kaisi': 'कैसी',
    'kya': 'क्या',
    'kyun': 'क्यों',
    'kyon': 'क्यों',
    'kab': 'कब',
    'kahan': 'कहाँ',
    'achha': 'अच्छा',
    'accha': 'अच्छा',
    'theek': 'ठीक',
    'thik': 'ठीक',
    'haan': 'हाँ',
    'nahi': 'नहीं',
    'nahin': 'नहीं',
    'kisan': 'किसान',
    'paisa': 'पैसा',
    'rupaye': 'रुपये',
    'rupiya': 'रुपया',
    'aam': 'आम',
    'pani': 'पानी',
    'doodh': 'दूध',
    'chawal': 'चावल',
    'roti': 'रोटी',
    'sabji': 'सब्ज़ी',
  };

  static const Map<String, String> _commonTamil = {
    'vanakkam': 'வணக்கம்',
    'nandri': 'நன்றி',
    'bharat': 'பாரத்',
    'tamil': 'தமிழ்',
    'amma': 'அம்மா',
    'appa': 'அப்பா',
    'annai': 'அன்னை',
    'thambi': 'தம்பி',
  };

  static const Map<String, String> _commonTelugu = {
    'namaskaram': 'నమస్కారం',
    'dhanyavadalu': 'ధన్యవాదాలు',
    'bharat': 'భారత్',
    'telugu': 'తెలుగు',
    'amma': 'అమ్మ',
    'nanna': 'నాన్న',
  };

  static const Map<String, String> _commonKannada = {
    'namaskara': 'ನಮಸ್ಕಾರ',
    'dhanyavadagalu': 'ಧನ್ಯವಾದಗಳು',
    'bharat': 'ಭಾರತ',
    'kannada': 'ಕನ್ನಡ',
    'amma': 'ಅಮ್ಮ',
    'appa': 'ಅಪ್ಪ',
  };

  /// Consonants with halant in Devanagari.
  static const Map<String, String> _devanagariConsonants = {
    'k': 'क्',
    'kh': 'ख्',
    'g': 'ग्',
    'gh': 'घ्',
    'ch': 'च्',
    'chh': 'छ्',
    'j': 'ज्',
    'jh': 'झ्',
    't': 'त्',
    'th': 'थ्',
    'd': 'द्',
    'dh': 'ध्',
    'n': 'न्',
    'p': 'प्',
    'ph': 'फ्',
    'f': 'फ़्',
    'b': 'ब्',
    'bh': 'भ्',
    'm': 'म्',
    'y': 'य्',
    'r': 'र्',
    'l': 'ल्',
    'v': 'व्',
    'w': 'व्',
    'sh': 'श्',
    'shh': 'ष्',
    's': 'स्',
    'h': 'ह्',
    'z': 'ज़्',
    'q': 'क़्',
    'ksh': 'क्ष्',
    'tr': 'त्र्',
    'gy': 'ज्ञ्',
  };

  /// Standalone vowels in Devanagari.
  static const Map<String, String> _devanagariVowels = {
    'aa': 'आ',
    'ai': 'ऐ',
    'au': 'औ',
    'ee': 'ई',
    'ii': 'ई',
    'oo': 'ऊ',
    'uu': 'ऊ',
    'a': 'अ',
    'i': 'इ',
    'u': 'उ',
    'e': 'ए',
    'o': 'ओ',
    'ri': 'ऋ',
  };

  /// Dependent vowel matras in Devanagari.
  static const Map<String, String> _devanagariMatras = {
    'aa': 'ा',
    'ai': 'ै',
    'au': 'ौ',
    'ee': 'ी',
    'ii': 'ी',
    'oo': 'ू',
    'uu': 'ू',
    'a': '', // Inherent vowel removes virama
    'i': 'ि',
    'u': 'ु',
    'e': 'े',
    'o': 'ो',
    'ri': 'ृ',
  };

  /// Transliterates Latin/English text into the specified [targetScript].
  ///
  /// Examples:
  /// ```dart
  /// BharatTransliterator.transliterate("namaste"); // "नमस्ते"
  /// BharatTransliterator.transliterate("bharat mahan hai"); // "भारत महान है"
  /// ```
  static String transliterate(
    String input, {
    IndianScript targetScript = IndianScript.devanagari,
  }) {
    if (input.isEmpty) return input;

    // Split input into words, punctuation, and whitespace
    final tokens = _tokenize(input);
    final buffer = StringBuffer();

    for (final token in tokens) {
      if (token.isWord) {
        buffer.write(_transliterateWord(token.text, targetScript));
      } else {
        buffer.write(token.text);
      }
    }

    return buffer.toString();
  }

  static String _transliterateWord(String word, IndianScript targetScript) {
    final lower = word.toLowerCase();

    // 1. Direct common dictionary check
    if (targetScript == IndianScript.devanagari &&
        _commonDevanagari.containsKey(lower)) {
      return _commonDevanagari[lower]!;
    }
    if (targetScript == IndianScript.tamil &&
        _commonTamil.containsKey(lower)) {
      return _commonTamil[lower]!;
    }
    if (targetScript == IndianScript.telugu &&
        _commonTelugu.containsKey(lower)) {
      return _commonTelugu[lower]!;
    }
    if (targetScript == IndianScript.kannada &&
        _commonKannada.containsKey(lower)) {
      return _commonKannada[lower]!;
    }

    // 2. Rule-based phonetic transliteration for Devanagari
    if (targetScript == IndianScript.devanagari) {
      return _phoneticDevanagari(lower);
    }

    // For other scripts, fallback to word or Devanagari
    return word;
  }

  static String _phoneticDevanagari(String text) {
    final buffer = StringBuffer();
    int i = 0;
    const virama = '\u094D';

    while (i < text.length) {
      // Check multi-char consonants first (e.g. ksh, chh, kh, etc.)
      String? matchedConsonantKey;
      for (final key in ['ksh', 'chh', 'shh', 'kh', 'gh', 'ch', 'jh', 'th', 'dh', 'ph', 'bh', 'sh', 'tr', 'gy']) {
        if (text.startsWith(key, i)) {
          matchedConsonantKey = key;
          break;
        }
      }
      if (matchedConsonantKey == null) {
        final single = text[i];
        if (_devanagariConsonants.containsKey(single)) {
          matchedConsonantKey = single;
        }
      }

      if (matchedConsonantKey != null) {
        // We matched a consonant
        final baseHalant = _devanagariConsonants[matchedConsonantKey]!;
        final baseChar = baseHalant.replaceAll(virama, '');
        i += matchedConsonantKey.length;

        // Check if immediately followed by a vowel
        String? matchedVowelKey;
        for (final vKey in ['aa', 'ai', 'au', 'ee', 'ii', 'oo', 'uu', 'ri', 'a', 'i', 'u', 'e', 'o']) {
          if (text.startsWith(vKey, i)) {
            matchedVowelKey = vKey;
            break;
          }
        }

        if (matchedVowelKey != null) {
          final matra = _devanagariMatras[matchedVowelKey]!;
          buffer.write(baseChar);
          buffer.write(matra);
          i += matchedVowelKey.length;
        } else {
          // No vowel following:
          // If at the end of the word, in Hindi the consonant usually carries implicit schwa (no halant)
          if (i >= text.length) {
            buffer.write(baseChar);
          } else {
            // Conjunct consonant with virama
            buffer.write(baseHalant);
          }
        }
      } else {
        // Not a consonant: check standalone vowel
        String? matchedVowelKey;
        for (final vKey in ['aa', 'ai', 'au', 'ee', 'ii', 'oo', 'uu', 'ri', 'a', 'i', 'u', 'e', 'o']) {
          if (text.startsWith(vKey, i)) {
            matchedVowelKey = vKey;
            break;
          }
        }

        if (matchedVowelKey != null) {
          buffer.write(_devanagariVowels[matchedVowelKey]!);
          i += matchedVowelKey.length;
        } else {
          // Any other character (number, symbol)
          buffer.write(text[i]);
          i++;
        }
      }
    }

    return buffer.toString();
  }

  static List<_Token> _tokenize(String input) {
    final tokens = <_Token>[];
    final regex = RegExp(r'([a-zA-Z]+)|([^a-zA-Z]+)');
    for (final match in regex.allMatches(input)) {
      final text = match.group(0)!;
      final isWord = RegExp(r'^[a-zA-Z]+$').hasMatch(text);
      tokens.add(_Token(text: text, isWord: isWord));
    }
    return tokens;
  }
}

class _Token {
  final String text;
  final bool isWord;
  const _Token({required this.text, required this.isWord});
}
