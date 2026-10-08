import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  group('BharatAadhaar & Verhoeff algorithm', () {
    test('generates and validates Aadhaar with Verhoeff checksum', () {
      const base11 = '23456789012';
      final checkDigit = BharatAadhaar.generateVerhoeffCheckDigit(base11);
      final validAadhaar = '$base11$checkDigit';

      expect(BharatAadhaar.validate(validAadhaar), isTrue);

      // Mutate one digit (single digit error)
      final corrupted = '${base11.substring(0, 10)}9$checkDigit';
      expect(BharatAadhaar.validate(corrupted), isFalse);

      // Transposition error (adjacent swap)
      final transposed = '24356789012$checkDigit';
      expect(BharatAadhaar.validate(transposed), isFalse);
    });

    test('rejects Aadhaar starting with 0 or 1', () {
      final check0 = BharatAadhaar.generateVerhoeffCheckDigit('01234567890');
      expect(BharatAadhaar.validate('01234567890$check0'), isFalse);

      final check1 = BharatAadhaar.generateVerhoeffCheckDigit('12345678901');
      expect(BharatAadhaar.validate('12345678901$check1'), isFalse);
    });

    test('masks Aadhaar according to UIDAI guidelines', () {
      const aadhaar = '234567890124';
      expect(BharatAadhaar.mask(aadhaar), 'XXXX XXXX 0124');
      expect(BharatAadhaar.mask(aadhaar, maskChar: '•'), '•••• •••• 0124');
      expect(
        BharatAadhaar.mask(aadhaar, preserveSpacing: false),
        'XXXXXXXX0124',
      );
    });

    test('formats Aadhaar with 4-digit spacing', () {
      expect(BharatAadhaar.format('234567890124'), '2345 6789 0124');
    });
  });

  group('BharatPan Card', () {
    test('validates Individual PAN with 4th character P', () {
      final res = BharatPan.validate('ABCPD1234F');
      expect(res.isValid, isTrue);
      expect(res.category, PanCategory.individual);
      expect(res.categoryDescription, 'Individual (Person)');
      expect(res.surnameOrNameInitial, 'D');
    });

    test('validates Company PAN with 4th character C', () {
      final res = BharatPan.validate('AAACR1234G');
      expect(res.isValid, isTrue);
      expect(res.category, PanCategory.company);
      expect(res.categoryDescription, 'Company');
    });

    test('validates expectedCategory constraint', () {
      final validIndividual = BharatPan.validate(
        'ABCPD1234F',
        expectedCategory: PanCategory.individual,
      );
      expect(validIndividual.isValid, isTrue);

      final invalidExpected = BharatPan.validate(
        'AAACR1234G',
        expectedCategory: PanCategory.individual,
      );
      expect(invalidExpected.isValid, isFalse);
      expect(invalidExpected.errorMessage, contains('PAN category is Company'));
    });

    test('masks PAN card showing last 5 characters', () {
      expect(BharatPan.mask('ABCPD1234F'), 'XXXXX1234F');
    });

    test('rejects invalid PAN format', () {
      expect(BharatPan.validate('12345ABCDE').isValid, isFalse);
      expect(BharatPan.validate('ABC12345').isValid, isFalse);
      expect(BharatPan.validate('').isValid, isFalse);
      expect(BharatPan.validate(null).isValid, isFalse);
    });
  });

  group('BharatUpi ID & PSP Resolver', () {
    test('validates Google Pay handles (@okaxis, @okhdfcbank)', () {
      final res = BharatUpi.validate('john.doe@okaxis');
      expect(res.isValid, isTrue);
      expect(res.username, 'john.doe');
      expect(res.handle, 'okaxis');
      expect(res.pspName, 'Google Pay');
      expect(res.bankName, 'Axis Bank');
    });

    test('validates PhonePe handles (@ybl, @ibl)', () {
      final res = BharatUpi.validate('user9876@ybl');
      expect(res.isValid, isTrue);
      expect(res.pspName, 'PhonePe');
      expect(res.bankName, 'YES Bank');
    });

    test('validates Paytm & Amazon Pay handles', () {
      final paytm = BharatUpi.validate('shop@paytm');
      expect(paytm.isValid, isTrue);
      expect(paytm.pspName, 'Paytm');

      final amazon = BharatUpi.validate('shopper@apl');
      expect(amazon.isValid, isTrue);
      expect(amazon.pspName, 'Amazon Pay');
    });

    test('accepts custom valid UPI handles', () {
      final custom = BharatUpi.validate('myname@custombank');
      expect(custom.isValid, isTrue);
      expect(custom.isKnownHandle, isFalse);
    });

    test('rejects invalid UPI structures', () {
      expect(BharatUpi.isValid('invalid-upi'), isFalse);
      expect(BharatUpi.isValid('@okaxis'), isFalse);
      expect(BharatUpi.isValid('user@'), isFalse);
    });
  });

  group('BharatGstin & BharatIfsc & BharatPhone', () {
    test('validates GSTIN structure and embedded PAN', () {
      final res = BharatGstin.validate('27AAPFU0939F1ZV');
      expect(res.isValid, isTrue);
      expect(res.stateCode, '27');
      expect(res.pan, 'AAPFU0939F');
    });

    test('validates IFSC codes and identifies banks', () {
      final sbi = BharatIfsc.validate('SBIN0000123');
      expect(sbi.isValid, isTrue);
      expect(sbi.bankName, 'State Bank of India');
      expect(sbi.branchCode, '000123');

      final hdfc = BharatIfsc.validate('HDFC0001234');
      expect(hdfc.isValid, isTrue);
      expect(hdfc.bankName, 'HDFC Bank');
    });

    test('validates Indian mobile numbers', () {
      final p1 = BharatPhone.validate('9876543210');
      expect(p1.isValid, isTrue);
      expect(p1.formattedNumber, '+91 98765 43210');

      final p2 = BharatPhone.validate('+91 9876543210');
      expect(p2.isValid, isTrue);
      expect(p2.tenDigitNumber, '9876543210');

      // Invalid starts with 5
      expect(BharatPhone.validate('5876543210').isValid, isFalse);
      // Invalid 9 digits
      expect(BharatPhone.validate('987654321').isValid, isFalse);
    });
  });
}
