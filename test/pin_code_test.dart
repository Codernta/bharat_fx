import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  group('BharatPinCode Validator & Lookup', () {
    test('validates 6-digit Indian PIN codes', () {
      expect(BharatPinCode.isValid('560001'), isTrue);
      expect(BharatPinCode.isValid('110001'), isTrue);
      expect(BharatPinCode.isValid('400001'), isTrue);

      // Invalid cases
      expect(BharatPinCode.isValid('010001'), isFalse); // Cannot start with 0
      expect(BharatPinCode.isValid('56000'), isFalse); // Only 5 digits
      expect(BharatPinCode.isValid('5600012'), isFalse); // 7 digits
      expect(BharatPinCode.isValid('ABCDEF'), isFalse);
      expect(BharatPinCode.isValid(null), isFalse);
    });

    test('resolves Bengaluru Urban, Karnataka for 560001', () {
      final info = BharatPinCode.lookup('560001');
      expect(info.isValid, isTrue);
      expect(info.state, 'Karnataka');
      expect(info.district, 'Bengaluru Urban');
      expect(info.zone, contains('Southern'));
    });

    test('resolves New Delhi for 110001', () {
      final info = BharatPinCode.lookup('110001');
      expect(info.isValid, isTrue);
      expect(info.state, 'Delhi');
      expect(info.district, contains('Delhi'));
    });

    test('resolves Mumbai, Maharashtra for 400001', () {
      final info = BharatPinCode.lookup('400001');
      expect(info.isValid, isTrue);
      expect(info.state, 'Maharashtra');
      expect(info.district, contains('Mumbai'));
    });

    test('resolves Chennai, Tamil Nadu for 600001', () {
      final info = BharatPinCode.lookup('600001');
      expect(info.isValid, isTrue);
      expect(info.state, 'Tamil Nadu');
      expect(info.district, 'Chennai');
    });

    test('resolves Hyderabad, Telangana for 500001', () {
      final info = BharatPinCode.lookup('500001');
      expect(info.isValid, isTrue);
      expect(info.state, 'Telangana');
      expect(info.district, 'Hyderabad');
    });

    test('resolves Army Postal Service for 900001', () {
      final info = BharatPinCode.lookup('900001');
      expect(info.isValid, isTrue);
      expect(info.isArmyPostal, isTrue);
    });

    test('formats PIN code with space grouping', () {
      expect(BharatPinCode.format('560001'), '560 001');
      expect(BharatPinCode.format('560001', withSpace: false), '560001');
    });
  });

  group('BharatPinCodeInputFormatter', () {
    test('limits to 6 digits and formats with space', () {
      final formatter = BharatPinCodeInputFormatter(withSpace: true);
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '560001'),
      );
      expect(result.text, '560 001');
    });
  });
}
