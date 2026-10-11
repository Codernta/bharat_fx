import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  group('BharatVid (UIDAI 16-digit Virtual ID)', () {
    test('validates valid 16-digit VID with Verhoeff checksum', () {
      const base15 = '234567890123456';
      final check = BharatAadhaar.generateVerhoeffCheckDigit(base15);
      final validVid = '$base15$check';

      expect(BharatVid.validate(validVid), isTrue);

      // Mutate one digit
      final corrupted = '${base15.substring(0, 14)}9$check';
      expect(BharatVid.validate(corrupted), isFalse);
    });

    test('rejects VID starting with 0 or 1', () {
      final check0 =
          BharatAadhaar.generateVerhoeffCheckDigit('012345678901234');
      expect(BharatVid.validate('012345678901234$check0'), isFalse);

      final check1 =
          BharatAadhaar.generateVerhoeffCheckDigit('123456789012345');
      expect(BharatVid.validate('123456789012345$check1'), isFalse);
    });

    test('masks VID hiding first 12 digits', () {
      const vid = '2345678901234567';
      expect(BharatVid.mask(vid), 'XXXX XXXX XXXX 4567');
      expect(BharatVid.mask(vid, preserveSpacing: false), 'XXXXXXXXXXXX4567');
    });

    test('formats VID with 4-digit grouping', () {
      expect(
        BharatVid.format('2345678901234567'),
        '2345 6789 0123 4567',
      );
    });
  });

  group('BharatBankAccount & Validation', () {
    test('validates generic 9-18 digit account numbers', () {
      expect(BharatBankAccount.validate('12345678901').isValid, isTrue);
      expect(BharatBankAccount.validate('12345').isValid, isFalse);
      expect(
          BharatBankAccount.validate('1234567890123456789').isValid, isFalse);
      expect(BharatBankAccount.validate('ABC12345678').isValid, isFalse);
    });

    test('validates bank-specific length rules', () {
      // SBI (11 or 17 digits)
      expect(
          BharatBankAccount.validate('12345678901', bankCode: 'SBIN').isValid,
          isTrue);
      expect(
          BharatBankAccount.validate('12345678901234567', bankCode: 'SBIN')
              .isValid,
          isTrue);
      expect(BharatBankAccount.validate('1234567890', bankCode: 'SBIN').isValid,
          isFalse);

      // HDFC (14 digits)
      expect(
          BharatBankAccount.validate('12345678901234', bankCode: 'HDFC')
              .isValid,
          isTrue);
      expect(
          BharatBankAccount.validate('123456789012', bankCode: 'HDFC').isValid,
          isFalse);

      // ICICI (12 digits)
      expect(
          BharatBankAccount.validate('123456789012', bankCode: 'ICIC').isValid,
          isTrue);

      // Axis (15 digits)
      expect(
          BharatBankAccount.validate('123456789012345', bankCode: 'UTIB')
              .isValid,
          isTrue);
    });

    test('masks bank accounts displaying last 4 digits', () {
      expect(BharatBankAccount.mask('123456789012'), 'XXXXXXXX9012');
      expect(BharatBankAccount.mask('123456789012', maskChar: '•'),
          '••••••••9012');
    });

    test('matches account numbers with timing safety', () {
      expect(BharatBankAccount.match('123456789012', '123456789012'), isTrue);
      expect(BharatBankAccount.match('123456789012', ' 123456789012 '), isTrue);
      expect(BharatBankAccount.match('123456789012', '123456789013'), isFalse);
    });
  });

  group('BharatCard (RuPay, Visa, Mastercard & PCI DSS)', () {
    test('identifies and validates RuPay cards with Luhn algorithm', () {
      const rupayPrefix = '607123123456789';
      final check = LuhnAlgorithm.generateCheckDigit(rupayPrefix);
      final validRuPay = '$rupayPrefix$check';

      final res = BharatCard.validate(validRuPay);
      expect(res.isValid, isTrue);
      expect(res.cardType, BharatCardType.rupay);
      expect(res.isRuPay, isTrue);
      expect(res.lastFour, validRuPay.substring(validRuPay.length - 4));
    });

    test('identifies Visa and Mastercard', () {
      // Visa
      const visaPrefix = '411111111111111';
      final visaCheck = LuhnAlgorithm.generateCheckDigit(visaPrefix);
      expect(BharatCard.validate('$visaPrefix$visaCheck').cardType,
          BharatCardType.visa);

      // Mastercard
      const mcPrefix = '550000000000000';
      final mcCheck = LuhnAlgorithm.generateCheckDigit(mcPrefix);
      expect(BharatCard.validate('$mcPrefix$mcCheck').cardType,
          BharatCardType.mastercard);
    });

    test('validates card expiration dates', () {
      final nextYear = DateTime.now().year + 2;
      expect(BharatCard.validateExpiry(12, nextYear), isTrue);
      expect(BharatCard.validateExpiry(13, nextYear), isFalse); // invalid month
      expect(BharatCard.validateExpiry(1, 2020), isFalse); // past year
      expect(BharatCard.validateExpiryString('12/$nextYear'), isTrue);
    });

    test('validates CVVs per card scheme', () {
      expect(BharatCard.validateCvv('123', cardType: BharatCardType.rupay),
          isTrue);
      expect(BharatCard.validateCvv('12', cardType: BharatCardType.rupay),
          isFalse);
      expect(BharatCard.validateCvv('1234', cardType: BharatCardType.amex),
          isTrue);
      expect(BharatCard.validateCvv('123', cardType: BharatCardType.amex),
          isFalse);
    });

    test('masks cards according to PCI DSS 4.0', () {
      const card = '6071231234567890';
      expect(BharatCard.mask(card), 'XXXX-XXXX-XXXX-7890');
      expect(BharatCard.mask(card, preserveBin: true), contains('6071 23'));
    });
  });

  group('BharatCardToken (RBI Card-on-File Tokenization)', () {
    test('validates RBI CoFT compliant token data', () {
      final token = BharatCardToken(
        token: 'tok_network_998877',
        tokenReferenceNumber: 'TRN_NET_1234',
        lastFour: '7890',
        cardType: BharatCardType.rupay,
        expiryMonth: 12,
        expiryYear: DateTime.now().year + 2,
        issuerBank: 'State Bank of India',
      );

      expect(token.isValid, isTrue);
      expect(
          token.displayName, contains('State Bank of India RuPay •••• 7890'));
    });
  });

  group('BharatUpi Security & Intent Deep Links', () {
    test('defends against invisible zero-width spaces and Cyrillic homoglyphs',
        () {
      expect(BharatUpi.sanitize('user\u200B@okaxis'), 'user@okaxis');
      expect(BharatUpi.hasHomoglyphs('рaytm@okaxis'), isTrue); // Cyrillic 'р'
      expect(BharatUpi.validate('рaytm@okaxis').isValid, isFalse);
      expect(
        BharatUpi.validate('рaytm@okaxis').errorMessage,
        contains('homoglyph'),
      );
    });

    test('detects phishing handle patterns', () {
      expect(BharatUpi.isSuspiciousPhishingHandle('refund-support-help@okaxis'),
          isTrue);
      expect(BharatUpi.isSuspiciousPhishingHandle('john.doe@okaxis'), isFalse);
    });

    test('validates NPCI compliant UPI payment Intent URIs', () {
      const validUri =
          'upi://pay?pa=merchant@okhdfcbank&pn=BookStore&am=1500.00&cu=INR&tn=Invoice%2042';

      final res = BharatUpiIntent.validate(validUri);
      expect(res.isValid, isTrue);
      expect(res.payeeAddress, 'merchant@okhdfcbank');
      expect(res.payeeName, 'BookStore');
      expect(res.amount, 1500.00);
      expect(res.currency, 'INR');
      expect(res.transactionNote, 'Invoice 42');
    });

    test('rejects tampered or fraudulent UPI Intent URIs', () {
      // Missing pa
      expect(BharatUpiIntent.validate('upi://pay?pn=Store&am=500').isValid,
          isFalse);

      // Non INR currency
      expect(
        BharatUpiIntent.validate(
                'upi://pay?pa=store@okaxis&pn=Store&am=500&cu=USD')
            .isValid,
        isFalse,
      );

      // Negative amount
      expect(
        BharatUpiIntent.validate(
                'upi://pay?pa=store@okaxis&pn=Store&am=-50&cu=INR')
            .isValid,
        isFalse,
      );

      // Dangerous javascript URL
      expect(
        BharatUpiIntent.validate(
          'upi://pay?pa=store@okaxis&pn=Store&url=javascript:alert(1)',
        ).isValid,
        isFalse,
      );
    });

    test('builds tamper-proof encoded UPI URIs', () {
      final uri = BharatUpiIntent.buildUri(
        payeeAddress: 'merchant@okaxis',
        payeeName: 'Ram & Sons',
        amount: 250.75,
        transactionNote: 'Order #1001',
      );

      expect(uri.scheme, 'upi');
      expect(uri.host, 'pay');
      expect(uri.queryParameters['pa'], 'merchant@okaxis');
      expect(uri.queryParameters['pn'], 'Ram & Sons');
      expect(uri.queryParameters['am'], '250.75');
      expect(uri.queryParameters['cu'], 'INR');
    });
  });

  group('BharatIfsc Merged Bank Detection', () {
    test('flags merged and defunct bank IFSC codes with guidance', () {
      final res = BharatIfsc.validate('ALLA0210001');
      expect(res.isValid, isTrue);
      expect(res.isMergedOrDefunct, isTrue);
      expect(res.bankName, 'Allahabad Bank');
      expect(res.successorBankName, contains('Indian Bank'));
      expect(res.warningMessage, contains('merged'));

      expect(BharatIfsc.isMerged('SYNB0000123'), isTrue);
      expect(BharatIfsc.isMerged('SBIN0000123'), isFalse);
    });
  });

  group('BharatMoney Exact Fixed-Point Precision', () {
    test('prevents floating point rounding errors', () {
      final m1 = BharatMoney.fromRupees(0.1);
      final m2 = BharatMoney.fromRupees(0.2);
      final sum = m1 + m2;

      expect(sum.inPaise, 30);
      expect(sum.inRupees, 0.3);
      expect(sum.format(), '₹0.30');
    });

    test('performs exact arithmetic and GST calculations', () {
      final subtotal = BharatMoney.fromRupees(1500.00);
      final gst = subtotal.percentage(18); // 18% GST

      expect(gst.inRupees, 270.00);
      final total = subtotal + gst;
      expect(total.inRupees, 1770.00);
      expect(total.wholeRupees, 1770);
      expect(total.paiseFraction, 0);
    });

    test(
        'safely parses Indian currency strings and rejects scientific notation',
        () {
      final m = BharatMoney.parse('₹ 1,50,000.50');
      expect(m, isNotNull);
      expect(m!.inPaise, 15000050);

      // Compact format parsing
      final compact = BharatMoney.parse('2.5 Cr');
      expect(compact, isNotNull);
      expect(compact!.inRupees, 25000000.0);

      // Rejects scientific notation injection
      expect(BharatMoney.parse('1e5'), isNull);
      expect(BharatMoney.parse('1E10'), isNull);
    });

    test('validates against RBI & NPCI transaction limits', () {
      final m1Lakh = BharatMoney.fromRupees(100000);
      expect(m1Lakh.isWithinUpiLimit, isTrue);

      final m1Lakh1 = BharatMoney.fromRupees(100001);
      expect(m1Lakh1.isWithinUpiLimit, isFalse);
      expect(m1Lakh1.isWithinUpiCapitalMarketsLimit, isTrue);

      final m6Lakh = BharatMoney.fromRupees(600000);
      expect(m6Lakh.isWithinUpiMaxLimit, isFalse);
      expect(m6Lakh.isWithinImpsLimit, isFalse);
    });
  });
}
