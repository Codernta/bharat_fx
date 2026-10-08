import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  group('BharatCurrency Formatter', () {
    test('formats numbers into Indian numbering system correctly', () {
      expect(BharatCurrency.format(0, showSymbol: false), '0');
      expect(BharatCurrency.format(5, showSymbol: false), '5');
      expect(BharatCurrency.format(99, showSymbol: false), '99');
      expect(BharatCurrency.format(999, showSymbol: false), '999');
      expect(BharatCurrency.format(1000, showSymbol: false), '1,000');
      expect(BharatCurrency.format(10000, showSymbol: false), '10,000');
      expect(
        BharatCurrency.format(100000, showSymbol: false),
        '1,00,000',
      ); // 1 Lakh
      expect(
        BharatCurrency.format(1000000, showSymbol: false),
        '10,00,000',
      ); // 10 Lakh
      expect(
        BharatCurrency.format(10000000, showSymbol: false),
        '1,00,00,000',
      ); // 1 Crore
      expect(
        BharatCurrency.format(100000000, showSymbol: false),
        '10,00,00,000',
      ); // 10 Crore
      expect(
        BharatCurrency.format(1000000000, showSymbol: false),
        '1,00,00,00,000',
      ); // 100 Crore / 1 Arab
      expect(
        BharatCurrency.format(123456789, showSymbol: false),
        '12,34,56,789',
      );
    });

    test('formats with currency symbol and decimals', () {
      expect(
        BharatCurrency.format(150000),
        '₹1,00,000'.replaceFirst('1,00,000', '1,50,000'),
      );
      expect(BharatCurrency.format(150000, spaceBetween: ' '), '₹ 1,50,000');
      expect(BharatCurrency.format(1500.5, decimalDigits: 2), '₹1,500.50');
      expect(BharatCurrency.format(-100000), '-₹1,00,000');
    });

    test('formats compact Indian scales (Lakh, Crore)', () {
      expect(BharatCurrency.compact(500, showSymbol: false), '500');
      expect(BharatCurrency.compact(50000, showSymbol: false), '50 K');
      expect(BharatCurrency.compact(150000, showSymbol: false), '1.5 L');
      expect(
        BharatCurrency.compact(150000, showSymbol: false, shortUnit: false),
        '1.5 Lakh',
      );
      expect(BharatCurrency.compact(25000000, showSymbol: false), '2.5 Cr');
      expect(
        BharatCurrency.compact(25000000, showSymbol: false, shortUnit: false),
        '2.5 Crore',
      );
      expect(BharatCurrency.compact(1200000000, showSymbol: false), '1.2 Arab');
    });

    test('parses Indian formatted amounts', () {
      expect(BharatCurrency.parse('₹ 1,50,000.50'), 150000.50);
      expect(BharatCurrency.parse('1,00,000'), 100000.0);
      expect(BharatCurrency.parse('1.5 Lakh'), 150000.0);
      expect(BharatCurrency.parse('2.5 Cr'), 25000000.0);
      expect(BharatCurrency.parse('-₹5,000'), -5000.0);
    });
  });

  group('BharatCurrency toWords in Indian Languages', () {
    test('converts numbers to English words (Indian scale)', () {
      expect(BharatCurrency.toWords(15000), 'Fifteen Thousand Rupees Only');
      expect(
        BharatCurrency.toWords(100000, includeOnly: false),
        'One Lakh Rupees',
      );
      expect(
        BharatCurrency.toWords(10000000, includeOnly: false),
        'One Crore Rupees',
      );
      expect(
        BharatCurrency.toWords(1250.50, includeOnly: false),
        'One Thousand Two Hundred Fifty Rupees and Fifty Paise',
      );
    });

    test('converts numbers to Hindi words', () {
      expect(
        BharatCurrency.toWords(15000, language: BharatLanguage.hindi),
        'पंद्रह हज़ार रुपये मात्र',
      );
      expect(
        BharatCurrency.toWords(
          100000,
          language: BharatLanguage.hindi,
          includeOnly: false,
        ),
        'एक लाख रुपये',
      );
      expect(
        BharatCurrency.toWords(
          20000000,
          language: BharatLanguage.hindi,
          includeOnly: false,
        ),
        'दो करोड़ रुपये',
      );
    });

    test('converts numbers to Tamil words', () {
      expect(
        BharatCurrency.toWords(15000, language: BharatLanguage.tamil),
        contains('ஆயிரம்'),
      );
      expect(
        BharatCurrency.toWords(100000, language: BharatLanguage.tamil),
        contains('லட்சம்'),
      );
    });

    test('converts numbers to Telugu words', () {
      expect(
        BharatCurrency.toWords(15000, language: BharatLanguage.telugu),
        contains('వేలు'),
      );
      expect(
        BharatCurrency.toWords(100000, language: BharatLanguage.telugu),
        contains('లక్ష'),
      );
    });

    test('converts numbers to Kannada words', () {
      expect(
        BharatCurrency.toWords(15000, language: BharatLanguage.kannada),
        contains('ಸಾವಿರ'),
      );
      expect(
        BharatCurrency.toWords(100000, language: BharatLanguage.kannada),
        contains('ಲಕ್ಷ'),
      );
    });
  });

  group('BharatCurrencyInputFormatter', () {
    test('formats text dynamically on typing', () {
      final formatter = BharatCurrencyInputFormatter();
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '123456'),
      );
      expect(result.text, '1,23,456');
    });

    test('formats text with decimals', () {
      final formatter = BharatCurrencyInputFormatter();
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '1500.5'),
      );
      expect(result.text, '1,500.5');
    });
  });
}
