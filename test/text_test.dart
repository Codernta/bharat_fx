import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  group('BharatText & Scripts', () {
    test('detects Indian scripts correctly', () {
      expect(BharatText.detectScript('नमस्ते भारत'), IndianScript.devanagari);
      expect(BharatText.detectScript('வணக்கம்'), IndianScript.tamil);
      expect(BharatText.detectScript('నమస్కారం'), IndianScript.telugu);
      expect(BharatText.detectScript('ನಮಸ್ಕಾರ'), IndianScript.kannada);
      expect(BharatText.detectScript('Hello World'), isNull);
    });

    test('checks pure script text', () {
      expect(BharatText.isPure('नमस्ते भारत', IndianScript.devanagari), isTrue);
      expect(
        BharatText.isPure('नमस्ते Hello', IndianScript.devanagari),
        isFalse,
      );
    });

    test('converts numbers to and from Indic digits', () {
      expect(
        BharatText.toIndicDigits('12345', IndianScript.devanagari),
        '१२३४५',
      );
      expect(BharatText.fromIndicDigits('१२३४५'), '12345');
      expect(BharatText.toIndicDigits('987', IndianScript.tamil), '௯௮௭');
      expect(BharatText.fromIndicDigits('௯௮௭'), '987');
    });
  });

  group('BharatTransliterator', () {
    test('transliterates common Indian words into Devanagari', () {
      expect(BharatTransliterator.transliterate('namaste'), 'नमस्ते');
      expect(BharatTransliterator.transliterate('bharat'), 'भारत');
      expect(BharatTransliterator.transliterate('shanti'), 'शांति');
      expect(BharatTransliterator.transliterate('dost'), 'दोस्त');
      expect(
        BharatTransliterator.transliterate('mera desh mahan'),
        'मेरा देश महान',
      );
    });

    test('transliterates phonetic syllables into Devanagari', () {
      expect(BharatTransliterator.transliterate('kisan'), 'किसान');
      expect(BharatTransliterator.transliterate('kavita'), 'कविता');
    });

    test('transliterates into Tamil', () {
      expect(
        BharatTransliterator.transliterate(
          'vanakkam',
          targetScript: IndianScript.tamil,
        ),
        'வணக்கம்',
      );
    });
  });

  group('BharatScriptInputFormatter', () {
    test('restricts input to Devanagari characters', () {
      final formatter = BharatScriptInputFormatter.single(
        IndianScript.devanagari,
        allowSpaces: true,
      );

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'नमस्ते Hello 123'),
      );

      // 'Hello' is rejected, Devanagari and allowed digits/spaces kept
      expect(result.text, 'नमस्ते  123');
    });
  });

  group('BharatPhoneticInputFormatter', () {
    test('converts word on space', () {
      final formatter = BharatPhoneticInputFormatter(
        targetScript: IndianScript.devanagari,
        convertOnSpace: true,
      );

      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: 'namaste'),
        const TextEditingValue(text: 'namaste '),
      );

      expect(result.text, 'नमस्ते ');
    });
  });
}
