import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  group('TimingSafe Side-Channel Defense', () {
    test('compares strings in constant time', () {
      expect(TimingSafe.equals('secret_token_123', 'secret_token_123'), isTrue);
      expect(
          TimingSafe.equals('secret_token_123', 'secret_token_124'), isFalse);
      expect(TimingSafe.equals('short', 'longer_string'), isFalse);
      expect(TimingSafe.equals(null, null), isTrue);
      expect(TimingSafe.equals('abc', null), isFalse);
    });

    test('compares byte arrays in constant time', () {
      final a = Uint8List.fromList([1, 2, 3, 4, 5]);
      final b = Uint8List.fromList([1, 2, 3, 4, 5]);
      final c = Uint8List.fromList([1, 2, 3, 4, 6]);

      expect(TimingSafe.bytesEquals(a, b), isTrue);
      expect(TimingSafe.bytesEquals(a, c), isFalse);
      expect(TimingSafe.bytesEquals(a, Uint8List.fromList([1, 2])), isFalse);
    });

    test('compares integers in constant time', () {
      expect(TimingSafe.equalsInt(42, 42), isTrue);
      expect(TimingSafe.equalsInt(42, 43), isFalse);
    });
  });

  group('SensitiveValue Memory & Logging Protection', () {
    test('prevents raw value leaks in toString and JSON', () {
      final mpin = SensitiveValue('9876', label: 'MPIN');

      expect(mpin.toString(), '[PROTECTED_MPIN]');
      expect(mpin.toJson(), '[PROTECTED_MPIN]');
      expect(mpin.label, 'MPIN');
      expect(mpin.isDisposed, isFalse);

      // Scoped reveal
      final revealedInScope = mpin.use((val) => 'Read: $val');
      expect(revealedInScope, 'Read: 9876');

      // Explicit reveal
      expect(mpin.reveal(), '9876');

      // Zeroize and verify disposal
      mpin.zeroize();
      expect(mpin.isDisposed, isTrue);
      expect(mpin.toString(), '[DISPOSED_MPIN]');
      expect(() => mpin.reveal(), throwsStateError);
      expect(() => mpin.use((v) => v), throwsStateError);
    });

    test('zeroizes byte buffers in memory', () {
      final keyBytes = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF]);
      final sensitiveKey = SensitiveValue(keyBytes, label: 'KEY');

      sensitiveKey.zeroize();
      expect(keyBytes, [0, 0, 0, 0]);
    });

    test('supports timing-safe equality', () {
      final s1 = SensitiveValue('auth_token_xyz');
      final s2 = SensitiveValue('auth_token_xyz');
      final s3 = SensitiveValue('auth_token_abc');

      expect(s1 == s2, isTrue);
      expect(s1 == s3, isFalse);
    });
  });

  group('BharatHash Cryptographic Integrity & Checksums', () {
    test('matches NIST SHA-256 test vectors', () {
      // Vector 1: Empty string
      expect(
        BharatHash.sha256(''),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );

      // Vector 2: "abc"
      expect(
        BharatHash.sha256('abc'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );

      // Vector 3: 448-bit edge case
      expect(
        BharatHash.sha256(
            'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'),
        '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1',
      );
    });

    test('matches RFC 2104 HMAC-SHA256 test vectors', () {
      final hmac = BharatHash.hmacSha256(
        'key',
        'The quick brown fox jumps over the lazy dog',
      );
      expect(
        hmac,
        'f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8',
      );
    });

    test('canonicalizes payment parameters and verifies checksums', () {
      final params = {
        'order_id': 'ORD_9988',
        'amount': '1500.00',
        'currency': 'INR',
        'merchant_id': 'MERCH_01',
      };

      final canonical = BharatHash.canonicalize(params);
      expect(canonical,
          'amount=1500.00&currency=INR&merchant_id=MERCH_01&order_id=ORD_9988');

      const secret = 'prod_secret_key_88';
      final checksum = BharatHash.generateChecksum(params, secret);

      expect(BharatHash.verifyChecksum(params, secret, checksum), isTrue);
      expect(
          BharatHash.verifyChecksum(params, 'wrong_secret', checksum), isFalse);

      // Tampering test: changed amount
      final tamperedParams = Map<String, dynamic>.from(params);
      tamperedParams['amount'] = '150.00';
      expect(
          BharatHash.verifyChecksum(tamperedParams, secret, checksum), isFalse);
    });
  });

  group('BharatPiiRedactor Data Protection', () {
    test('redacts 12-digit Aadhaar numbers', () {
      const log = 'User Aadhaar is 234567890124 for KYC verification';
      final redacted = BharatPiiRedactor.redact(log);
      expect(redacted, contains('XXXX XXXX 0124'));
      expect(redacted, isNot(contains('234567890124')));
    });

    test('redacts 16-digit Virtual IDs (VID)', () {
      const base15 = '234567890123456';
      final check = BharatAadhaar.generateVerhoeffCheckDigit(base15);
      final vid = '$base15$check';

      final log = 'Submitted VID: $vid';
      final redacted = BharatPiiRedactor.redact(log);
      expect(redacted, contains('XXXX XXXX XXXX ${vid.substring(12)}'));
    });

    test('redacts Indian PAN cards', () {
      const log = 'Taxpayer PAN: ABCPD1234F verified successfully';
      final redacted = BharatPiiRedactor.redact(log);
      expect(redacted, 'Taxpayer PAN: XXXXX1234F verified successfully');
    });

    test('redacts Luhn-valid payment cards', () {
      const cardPrefix = '607123123456789';
      final check = LuhnAlgorithm.generateCheckDigit(cardPrefix);
      final card = '$cardPrefix$check';

      final log = 'Charged card: $card';
      final redacted = BharatPiiRedactor.redact(log);
      expect(redacted,
          contains('XXXX-XXXX-XXXX-${card.substring(card.length - 4)}'));
    });

    test('redacts CVVs and bank account numbers in context', () {
      const log = 'Payment auth: cvv: 123 and account_number: 123456789012';
      final redacted = BharatPiiRedactor.redact(log);
      expect(redacted, contains('cvv: ***'));
      expect(redacted, contains('account_number: XXXXXXXX9012'));
    });

    test('redacts Indian mobile numbers and UPI handles', () {
      const log = 'Contact +91 98765 43210 or VPA ramesh@okaxis';
      final redacted = BharatPiiRedactor.redact(log);
      expect(redacted, contains('+91 XXXXX 43210'));
      expect(redacted, contains('r****h@okaxis'));
    });

    test('redacts recursive JSON and telemetry maps', () {
      final payload = {
        'status': 'success',
        'auth': {
          'mpin': '1234',
          'access_token': 'secret_jwt_token',
          'pan': 'ABCPD1234F',
        },
        'customer': {
          'name': 'Rahul Sharma',
          'notes': 'Verified Aadhaar 234567890124',
        },
      };

      final scrubbed = BharatPiiRedactor.redactMap(payload);
      final authMap = scrubbed['auth'] as Map<String, dynamic>;
      final customerMap = scrubbed['customer'] as Map<String, dynamic>;

      expect(authMap['mpin'], '[REDACTED]');
      expect(authMap['access_token'], '[REDACTED]');
      expect(authMap['pan'], '[REDACTED]');
      expect(customerMap['notes'], contains('XXXX XXXX 0124'));
    });

    test('detects presence of unmasked PII in text', () {
      expect(BharatPiiRedactor.containsPii('Valid PAN ABCPD1234F'), isTrue);
      expect(
          BharatPiiRedactor.containsPii('Valid Aadhaar 234567890124'), isTrue);
      expect(BharatPiiRedactor.containsPii('Non sensitive text here'), isFalse);
    });
  });

  group('AntiBruteForceGuard Throttling', () {
    test('enforces rate limits on attempts', () {
      final guard = AntiBruteForceGuard(
        maxAttempts: 3,
        window: const Duration(seconds: 2),
      );

      expect(guard.recordAttempt('user_1'), isTrue);
      expect(guard.recordAttempt('user_1'), isTrue);
      expect(guard.recordAttempt('user_1'), isTrue);
      expect(guard.recordAttempt('user_1'), isFalse); // Blocked
      expect(guard.isBlocked('user_1'), isTrue);

      // Separate user is unaffected
      expect(guard.recordAttempt('user_2'), isTrue);

      // Reset
      guard.reset('user_1');
      expect(guard.isBlocked('user_1'), isFalse);
    });
  });
}
