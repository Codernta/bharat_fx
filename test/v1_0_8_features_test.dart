import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  group('BharatAbha (Ayushman Bharat Health Account)', () {
    test('validates 14-digit ABHA number with standard formatting', () {
      final res = BharatAbha.validate('91-1234-5678-9012');
      expect(res.isValid, isTrue);
      expect(res.abhaNumber, '91123456789012');
      expect(res.formattedNumber, '91-1234-5678-9012');
    });

    test('validates raw unhyphenated ABHA number and formats', () {
      final res = BharatAbha.validate('23456789012345');
      expect(res.isValid, isTrue);
      expect(res.formattedNumber, '23-4567-8901-2345');
    });

    test('rejects ABHA number starting with 0 or 1 per NHA ABDM standard', () {
      final res0 = BharatAbha.validate('01-1234-5678-9012');
      expect(res0.isValid, isFalse);
      expect(res0.errorMessage, contains('cannot start with 0 or 1'));

      final res1 = BharatAbha.validate('12-3456-7890-1234');
      expect(res1.isValid, isFalse);
      expect(res1.errorMessage, contains('cannot start with 0 or 1'));
    });

    test('rejects invalid length or non-numeric ABHA numbers', () {
      final resShort = BharatAbha.validate('91-1234-5678');
      expect(resShort.isValid, isFalse);
      expect(resShort.errorMessage, contains('must be exactly 14 digits'));

      final resAlpha = BharatAbha.validate('91-1234-5678-901A');
      expect(resAlpha.isValid, isFalse);
    });

    test('masks ABHA number preserving last 4 digits', () {
      expect(
        BharatAbha.mask('91-1234-5678-9012'),
        'XX-XXXX-XXXX-9012',
      );
      expect(
        BharatAbha.mask('91123456789012', maskChar: '•'),
        '••-••••-••••-9012',
      );
    });

    test('validates ABHA Address (PHR handle)', () {
      final valid = BharatAbha.validateAddress('rahul.kumar@abdm');
      expect(valid.isValid, isTrue);
      expect(valid.username, 'rahul.kumar');
      expect(valid.domain, 'abdm');

      final sbx = BharatAbha.validateAddress('user_123@sbx');
      expect(sbx.isValid, isTrue);

      final invalid = BharatAbha.validateAddress('bad');
      expect(invalid.isValid, isFalse);
    });

    test('BharatAbhaInputFormatter auto-hyphens input', () {
      const formatter = BharatAbhaInputFormatter();
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '91123456789012');
      final formatted = formatter.formatEditUpdate(oldValue, newValue);
      expect(formatted.text, '91-1234-5678-9012');
    });
  });

  group('BharatCkyc (Central KYC Registry / KIN)', () {
    test('validates 14-digit numeric CKYC number', () {
      final res = BharatCkyc.validate('10023456789012');
      expect(res.isValid, isTrue);
      expect(res.isNumericOnly, isTrue);
      expect(res.ckycNumber, '10023456789012');
    });

    test('validates 14-character alphanumeric KIN', () {
      final res = BharatCkyc.validate('1002345678901A');
      expect(res.isValid, isTrue);
      expect(res.isNumericOnly, isFalse);
    });

    test('rejects invalid length CKYC number', () {
      final res = BharatCkyc.validate('123456');
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains('must be exactly 14 characters'));
    });

    test('masks CKYC number preserving last 4 characters', () {
      expect(BharatCkyc.mask('10023456789012'), 'XXXXXXXXXX9012');
      expect(BharatCkyc.mask('10023456789012', maskChar: '•'), '••••••••••9012');
    });

    test('BharatCkycInputFormatter enforces 14 uppercase chars', () {
      const formatter = BharatCkycInputFormatter();
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '1002345678901a9999');
      final formatted = formatter.formatEditUpdate(oldValue, newValue);
      expect(formatted.text, '1002345678901A');
      expect(formatted.text.length, 14);
    });
  });

  group('BharatLei (Legal Entity Identifier - ISO 17442)', () {
    test('calculates Mod 97-10 check digits and verifies valid LEI', () {
      const root18 = '335800123456789012';
      final checkDigits = BharatLei.calculateCheckDigits(root18);
      expect(checkDigits.length, 2);

      final fullLei = '$root18$checkDigits';
      final res = BharatLei.validate(fullLei);
      expect(res.isValid, isTrue);
      expect(res.louCode, '3358');
      expect(res.louName, 'Legal Entity Identifier India Ltd (LEIL)');
      expect(res.checkDigits, checkDigits);
    });

    test('rejects LEI with corrupted or mismatched check digits', () {
      const root18 = '335800123456789012';
      final checkDigits = BharatLei.calculateCheckDigits(root18);
      // Flip the check digits
      final corruptedCheck = checkDigits == '99' ? '01' : '99';
      final corruptedLei = '$root18$corruptedCheck';

      final res = BharatLei.validate(corruptedLei);
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains('Mod 97-10 check digits'));
    });

    test('rejects LEI not having reserved 00 at positions 5-6', () {
      final res = BharatLei.validate('33581112345678901234');
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains('must be "00"'));
    });

    test('masks LEI preserving LOU prefix and last 4 characters', () {
      expect(
        BharatLei.mask('33580012345678901234'),
        '3358XXXXXXXXXXXX1234',
      );
    });

    test('BharatLeiInputFormatter limits to 20 uppercase characters', () {
      const formatter = BharatLeiInputFormatter();
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '33580012345678901234extra');
      final formatted = formatter.formatEditUpdate(oldValue, newValue);
      expect(formatted.text, '33580012345678901234');
      expect(formatted.text.length, 20);
    });
  });

  group('TimingSafe.equalsCaseInsensitive', () {
    test('compares ASCII strings case-insensitively in constant time', () {
      expect(TimingSafe.equalsCaseInsensitive('ABCDEF', 'abcdef'), isTrue);
      expect(TimingSafe.equalsCaseInsensitive('AaBbCc123', 'aAbBcC123'), isTrue);
      expect(TimingSafe.equalsCaseInsensitive('sha256_hash_XYZ', 'SHA256_HASH_xyz'), isTrue);
    });

    test('rejects mismatched characters or differing lengths', () {
      expect(TimingSafe.equalsCaseInsensitive('ABCDEF', 'ABCDEG'), isFalse);
      expect(TimingSafe.equalsCaseInsensitive('ABCDEF', 'ABCDE'), isFalse);
      expect(TimingSafe.equalsCaseInsensitive('ABC', 'ABCD'), isFalse);
    });

    test('handles null parameters safely', () {
      expect(TimingSafe.equalsCaseInsensitive(null, null), isTrue);
      expect(TimingSafe.equalsCaseInsensitive('abc', null), isFalse);
      expect(TimingSafe.equalsCaseInsensitive(null, 'abc'), isFalse);
    });
  });

  group('BharatHash Fast Hex & Checksum Verification', () {
    test('computes standard SHA-256 and matches RFC test vectors', () {
      final hash = BharatHash.sha256('hello world');
      expect(
        hash,
        'b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9',
      );
    });

    test('verifies checksum with case-insensitive signature without allocation', () {
      final params = {'amount': '500', 'currency': 'INR', 'order_id': 'ord_1'};
      const secret = 'test_secret_key';
      final checksum = BharatHash.generateChecksum(params, secret);

      // Verify uppercase checksum
      expect(
        BharatHash.verifyChecksum(params, secret, checksum.toUpperCase()),
        isTrue,
      );
      // Verify lowercase checksum
      expect(
        BharatHash.verifyChecksum(params, secret, checksum.toLowerCase()),
        isTrue,
      );
      // Verify tampered checksum fails
      expect(
        BharatHash.verifyChecksum(params, secret, '0000$checksum'),
        isFalse,
      );
    });
  });

  group('BharatUpiIntent Security Hardening', () {
    test('rejects CRLF injection in transaction reference (tr)', () {
      final malicious =
          'upi://pay?pa=merchant@okhdfcbank&pn=Merchant&tr=order123%0D%0Ainjected=true&am=100&cu=INR';
      final res = BharatUpiIntent.validate(malicious);
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains('Control characters or CRLF detected'));
    });

    test('rejects newline character in transaction note (tn)', () {
      final malicious =
          'upi://pay?pa=merchant@okhdfcbank&pn=Merchant&tn=Payment%0AInjected&am=100&cu=INR';
      final res = BharatUpiIntent.validate(malicious);
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains('Control characters or CRLF detected'));
    });
  });

  group('BharatPiiRedactor DPDP & ABHA Redaction', () {
    test('redacts 14-digit ABHA numbers in text logs', () {
      final log = 'Patient ABHA: 91-1234-5678-9012 admitted with vitals';
      final redacted = BharatPiiRedactor.redact(log);
      expect(redacted, contains('XX-XXXX-XXXX-9012'));
    });

    test('redacts new sensitive fintech keys in telemetry maps', () {
      final map = {
        'abha_number': '91123456789012',
        'ckyc': '10023456789012',
        'lei': '33580012345678901234',
        'upi_pin': '123456',
        'api_secret': 'super_secret',
        'non_sensitive': 'public_info',
      };
      final scrubbed = BharatPiiRedactor.redactMap(map);
      expect(scrubbed['abha_number'], '[REDACTED]');
      expect(scrubbed['ckyc'], '[REDACTED]');
      expect(scrubbed['lei'], '[REDACTED]');
      expect(scrubbed['upi_pin'], '[REDACTED]');
      expect(scrubbed['api_secret'], '[REDACTED]');
      expect(scrubbed['non_sensitive'], 'public_info');
    });
  });

  group('BharatId Facade Expansion', () {
    test('exposes ABHA, CKYC, and LEI validation and masking', () {
      expect(BharatId.validateAbha('91-1234-5678-9012').isValid, isTrue);
      expect(BharatId.maskAbha('91-1234-5678-9012'), 'XX-XXXX-XXXX-9012');
      expect(BharatId.formatAbha('91123456789012'), '91-1234-5678-9012');
      expect(BharatId.validateAbhaAddress('user@abdm').isValid, isTrue);

      expect(BharatId.validateCkyc('10023456789012').isValid, isTrue);
      expect(BharatId.maskCkyc('10023456789012'), 'XXXXXXXXXX9012');

      const root18 = '335800123456789012';
      final check = BharatLei.calculateCheckDigits(root18);
      expect(BharatId.validateLei('$root18$check').isValid, isTrue);
      expect(BharatId.maskLei('$root18$check'), '3358XXXXXXXXXXXX${('$root18$check').substring(16)}');
    });
  });
}
