import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  group('BharatHsn & BharatSac Tests', () {
    test('Validates 2, 4, 6, and 8 digit HSN codes', () {
      final hsn2 = BharatHsn.validate('85');
      expect(hsn2.isValid, isTrue);
      expect(hsn2.length, 2);
      expect(hsn2.chapterCode, '85');
      expect(hsn2.chapterDescription, contains('Electrical machinery'));

      final hsn4 = BharatHsn.validate('8517');
      expect(hsn4.isValid, isTrue);
      expect(hsn4.length, 4);
      expect(hsn4.headingCode, '8517');

      final hsn6 = BharatHsn.validate('851712');
      expect(hsn6.isValid, isTrue);
      expect(hsn6.length, 6);

      final hsn8 = BharatHsn.validate('85171200');
      expect(hsn8.isValid, isTrue);
      expect(hsn8.length, 8);
    });

    test('Rejects invalid length or non-numeric HSN codes', () {
      expect(BharatHsn.validate(null).isValid, isFalse);
      expect(BharatHsn.validate('').isValid, isFalse);
      expect(BharatHsn.validate('123').isValid, isFalse); // 3 digits invalid
      expect(BharatHsn.validate('12345').isValid, isFalse); // 5 digits invalid
      expect(BharatHsn.validate('8517AB').isValid, isFalse); // Alpha chars invalid
    });

    test('Rejects Chapter 99 for HSN (reserved for SAC)', () {
      final res = BharatHsn.validate('998314');
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains('reserved for SAC'));
    });

    test('Turnover compliance check based on turnover threshold', () {
      // Turnover <= 5 Cr:
      // B2B requires min 4 digits
      expect(
        BharatHsn.isTurnoverCompliant(
          hsnCode: '85',
          turnoverInCrores: 3.5,
          isB2b: true,
        ),
        isFalse,
      );
      expect(
        BharatHsn.isTurnoverCompliant(
          hsnCode: '8517',
          turnoverInCrores: 3.5,
          isB2b: true,
        ),
        isTrue,
      );

      // Turnover > 5 Cr:
      // Requires min 6 digits
      expect(
        BharatHsn.isTurnoverCompliant(
          hsnCode: '8517',
          turnoverInCrores: 10.0,
          isB2b: true,
        ),
        isFalse,
      );
      expect(
        BharatHsn.isTurnoverCompliant(
          hsnCode: '851712',
          turnoverInCrores: 10.0,
          isB2b: true,
        ),
        isTrue,
      );

      // Export requires 8 digits
      expect(
        BharatHsn.isTurnoverCompliant(
          hsnCode: '851712',
          turnoverInCrores: 10.0,
          isExportOrImport: true,
        ),
        isFalse,
      );
      expect(
        BharatHsn.isTurnoverCompliant(
          hsnCode: '85171200',
          turnoverInCrores: 10.0,
          isExportOrImport: true,
        ),
        isTrue,
      );
    });

    test('Validates 6-digit SAC codes starting with 99', () {
      final sac = BharatSac.validate('998314');
      expect(sac.isValid, isTrue);
      expect(sac.headingCode, '9983');
      expect(sac.serviceCategory, contains('Information Technology'));

      final transport = BharatSac.validate('996511');
      expect(transport.isValid, isTrue);
      expect(transport.serviceCategory, contains('Goods transport'));
    });

    test('Rejects invalid SAC codes', () {
      expect(BharatSac.validate(null).isValid, isFalse);
      expect(BharatSac.validate('').isValid, isFalse);
      expect(BharatSac.validate('851712').isValid, isFalse); // Doesn't start with 99
      expect(BharatSac.validate('9983').isValid, isFalse); // Not 6 digits
      expect(BharatSac.validate('9983AB').isValid, isFalse); // Non-numeric
    });
  });

  group('BharatGstInvoice Rule 46(b) Tests', () {
    test('Validates compliant invoice serial numbers', () {
      final res1 = BharatGstInvoice.validateInvoiceNumber('INV/24-25/0001');
      expect(res1.isValid, isTrue);
      expect(res1.length, 14);

      final res2 = BharatGstInvoice.validateInvoiceNumber('A-10293/99');
      expect(res2.isValid, isTrue);

      final res3 = BharatGstInvoice.validateInvoiceNumber('1234567890123456');
      expect(res3.isValid, isTrue);
      expect(res3.length, 16);
    });

    test('Rejects invoice numbers exceeding 16 characters', () {
      final res = BharatGstInvoice.validateInvoiceNumber('INV/2024-2025/00001');
      expect(res.isValid, isFalse);
      expect(res.length, 19);
      expect(res.errorMessage, contains('exceeds maximum 16 characters'));
    });

    test('Rejects invoice numbers with illegal characters', () {
      final res = BharatGstInvoice.validateInvoiceNumber('INV 24_25#01');
      expect(res.isValid, isFalse);
      expect(res.invalidCharacters, contains('<space>'));
      expect(res.invalidCharacters, contains('_'));
      expect(res.invalidCharacters, contains('#'));
    });

    test('Sanitizes illegal characters into compliant format', () {
      final sanitized = BharatGstInvoice.sanitizeInvoiceNumber(
        'INV 2024_01#99',
        replacementSeparator: '-',
      );
      expect(sanitized, 'INV-2024-01-99');

      final truncated = BharatGstInvoice.sanitizeInvoiceNumber(
        'INV-LONG-PREFIX-SERIES-2024-9999',
        truncateTo16Chars: true,
      );
      expect(truncated.length, lessThanOrEqualTo(16));
    });

    test('Builds standardized 16-character compliant invoice number', () {
      final inv = BharatGstInvoice.buildInvoiceNumber(
        prefix: 'TAX',
        sequenceNumber: 7,
        date: DateTime(2024, 8, 15),
      );
      expect(inv, 'TAX/24-25/0007');
      expect(BharatGstInvoice.validateInvoiceNumber(inv).isValid, isTrue);
    });
  });

  group('BharatGstQr Tests', () {
    test('Validates 64-char IRN hexadecimal hash', () {
      const validIrn =
          'f1a8b9c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0';
      expect(BharatGstQr.validateIrn(validIrn), isTrue);
      expect(BharatGstQr.validateIrn('short-irn'), isFalse);
      expect(BharatGstQr.validateIrn(''), isFalse);
      expect(BharatGstQr.validateIrn(null), isFalse);
    });

    test('Parses signed B2B e-Invoice QR code JWT payload offline', () {
      // Create mock JWT payload
      final claims = {
        'SellerGstin': '27ABCDE1234F1Z5',
        'BuyerGstin': '29ABCDE5678G1Z2',
        'DocNo': 'INV/24-25/0042',
        'DocTyp': 'INV',
        'DocDt': '15/07/2024',
        'TotInvVal': 18550.0,
        'ItemCnt': 3,
        'MainHsnCode': '851712',
        'Irn':
            'f1a8b9c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0',
        'IrnDt': '2024-07-15 14:30:00',
      };

      final headerBase64 = base64Url.encode(utf8.encode('{"alg":"RS256"}'));
      final payloadBase64 =
          base64Url.encode(utf8.encode(jsonEncode(claims)));
      const mockSignature = 'mock_signature_bytes';

      final mockJwt = '$headerBase64.$payloadBase64.$mockSignature';

      final result = BharatGstQr.parseEInvoiceQr(mockJwt);

      expect(result.isValid, isTrue);
      expect(result.sellerGstin, '27ABCDE1234F1Z5');
      expect(result.buyerGstin, '29ABCDE5678G1Z2');
      expect(result.documentNumber, 'INV/24-25/0042');
      expect(result.documentType, GstDocumentType.taxInvoice);
      expect(result.documentDate, '15/07/2024');
      expect(result.totalInvoiceValue, 18550.0);
      expect(result.itemCount, 3);
      expect(result.mainHsnCode, '851712');
      expect(
        result.irn,
        'f1a8b9c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0',
      );
    });

    test('Gracefully handles invalid or corrupted QR text', () {
      final res1 = BharatGstQr.parseEInvoiceQr('random_invalid_string');
      expect(res1.isValid, isFalse);

      final res2 = BharatGstQr.parseEInvoiceQr('');
      expect(res2.isValid, isFalse);

      final res3 = BharatGstQr.parseEInvoiceQr(null);
      expect(res3.isValid, isFalse);
    });
  });
}
