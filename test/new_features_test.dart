import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  group('BharatDrivingLicense & Formatter', () {
    test(
        'validates standard MoRTH Driving License with state and RTO resolution',
        () {
      final res = BharatDrivingLicense.validate('DL-01-2020-0012345');
      expect(res.isValid, isTrue);
      expect(res.stateCode, 'DL');
      expect(res.stateName, 'Delhi');
      expect(res.rtoCode, 'DL01');
      expect(res.rtoName, 'Mall Road, North Delhi');
      expect(res.issueYear, 2020);
      expect(res.uniqueNumber, '0012345');
      expect(res.formattedNumber, 'DL-01-2020-0012345');
    });

    test('validates unspaced and slash formats', () {
      final res1 = BharatDrivingLicense.validate('DL0120200012345');
      expect(res1.isValid, isTrue);
      expect(res1.formattedNumber, 'DL-01-2020-0012345');

      final res2 = BharatDrivingLicense.validate('KA01/2019/0001234');
      expect(res2.isValid, isTrue);
      expect(res2.stateName, 'Karnataka');
    });

    test('rejects invalid state code or future/unreasonable year', () {
      final invalidState = BharatDrivingLicense.validate('ZZ-01-2020-0012345');
      expect(invalidState.isValid, isFalse);
      expect(invalidState.errorMessage, contains('Unrecognized state code'));

      final invalidYear = BharatDrivingLicense.validate('DL-01-1800-0012345');
      expect(invalidYear.isValid, isFalse);
      expect(invalidYear.errorMessage, contains('Invalid issue year'));
    });

    test('masks Driving License according to privacy norms', () {
      expect(
        BharatDrivingLicense.mask('DL-01-2020-0012345'),
        'DL-01-XXXX-XXX2345',
      );
    });

    test('BharatDrivingLicenseInputFormatter auto-hyphens input', () {
      final formatter = BharatDrivingLicenseInputFormatter();
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: 'DL0120200012345');
      final formatted = formatter.formatEditUpdate(oldValue, newValue);
      expect(formatted.text, 'DL-01-2020-0012345');
    });
  });

  group('BharatVoterId (EPIC)', () {
    test('validates standard 10-char ECI Voter ID', () {
      final res = BharatVoterId.validate('ABC1234567');
      expect(res.isValid, isTrue);
      expect(res.constituencyCode, 'ABC');
      expect(res.serialNumber, '1234567');
    });

    test('rejects invalid structures', () {
      expect(BharatVoterId.validate('AB12345678').isValid, isFalse);
      expect(BharatVoterId.validate('ABCD123456').isValid, isFalse);
      expect(BharatVoterId.validate('').isValid, isFalse);
    });

    test('masks Voter ID preserving prefix and last 3 digits', () {
      expect(BharatVoterId.mask('ABC1234567'), 'ABCXXXX567');
    });
  });

  group('BharatPassport', () {
    test('validates standard 8-character Indian passport', () {
      final res = BharatPassport.validate('K1234567');
      expect(res.isValid, isTrue);
      expect(res.seriesLetter, 'K');
      expect(res.serialNumber, '1234567');
    });

    test('rejects invalid series letter Q and wrong length', () {
      expect(BharatPassport.validate('Q1234567').isValid, isFalse);
      expect(BharatPassport.validate('K123456').isValid, isFalse);
      expect(BharatPassport.validate('12345678').isValid, isFalse);
    });

    test('masks Passport number preserving series letter and last 2 digits',
        () {
      expect(BharatPassport.mask('K1234567'), 'KXXXXX67');
    });
  });

  group('BharatCin, BharatTan, BharatDin', () {
    test('validates 21-character MCA Corporate Identification Number (CIN)',
        () {
      final res = BharatCin.validate('U72200KA2020PTC123456');
      expect(res.isValid, isTrue);
      expect(res.isListed, isFalse);
      expect(res.industryCode, '72200');
      expect(res.stateCode, 'KA');
      expect(res.stateName, 'Karnataka');
      expect(res.incorporationYear, 2020);
      expect(res.companyTypeCode, 'PTC');
      expect(res.companyTypeDescription, 'Private Limited Company');
      expect(res.registrationNumber, '123456');
    });

    test('masks CIN by hiding company type code', () {
      expect(
        BharatCin.mask('U72200KA2020PTC123456'),
        'U72200KA2020XXX123456',
      );
    });

    test('validates TAN structure and masks', () {
      final res = BharatTan.validate('DELA12345B');
      expect(res.isValid, isTrue);
      expect(res.jurisdictionCode, 'DEL');
      expect(res.deductorInitial, 'A');
      expect(res.serialNumber, '12345');
      expect(res.checkLetter, 'B');
      expect(BharatTan.mask('DELA12345B'), 'DELXXXXXXB');
    });

    test('validates DIN and masks', () {
      final res = BharatDin.validate('00123456');
      expect(res.isValid, isTrue);
      expect(BharatDin.mask('00123456'), 'XXXX3456');
      expect(BharatDin.validate('12345').isValid, isFalse);
    });
  });

  group('BharatGst Tax Calculator & Reverse Engine', () {
    test('calculates intra-state GST (CGST + SGST equal split)', () {
      final base = BharatMoney.fromRupees(1000.00);
      final res = BharatGst.calculate(
        taxableAmount: base,
        rate: 18.0,
        isInterState: false,
      );

      expect(res.isInterState, isFalse);
      expect(res.cgst.inRupees, 90.0);
      expect(res.sgst.inRupees, 90.0);
      expect(res.igst.inRupees, 0.0);
      expect(res.totalTax.inRupees, 180.0);
      expect(res.totalAmount.inRupees, 1180.0);
    });

    test('calculates inter-state GST (IGST only)', () {
      final base = BharatMoney.fromRupees(1000.00);
      final res = BharatGst.calculate(
        taxableAmount: base,
        rate: 18.0,
        isInterState: true,
      );

      expect(res.isInterState, isTrue);
      expect(res.cgst.inRupees, 0.0);
      expect(res.sgst.inRupees, 0.0);
      expect(res.igst.inRupees, 180.0);
      expect(res.totalTax.inRupees, 180.0);
      expect(res.totalAmount.inRupees, 1180.0);
    });

    test('auto-detects intra-state vs inter-state from GSTINs', () {
      final base = BharatMoney.fromRupees(2000.00);
      final res = BharatGst.calculate(
        taxableAmount: base,
        rate: 18.0,
        supplierGstin: '27AAPFU0939F1ZV', // Maharashtra (27)
        buyerGstin: '29AAPFU0939F1ZV', // Karnataka (29)
      );

      expect(res.isInterState, isTrue);
      expect(res.supplierState, 'Maharashtra');
      expect(res.buyerState, 'Karnataka');
      expect(res.igst.inRupees, 360.0);
    });

    test('reverse calculates GST from MRP inclusive of tax', () {
      final gross = BharatMoney.fromRupees(1180.00);
      final res = BharatGst.reverseCalculate(
        grossAmount: gross,
        rate: 18.0,
        isInterState: false,
      );

      expect(res.taxableAmount.inRupees, 1000.0);
      expect(res.totalTax.inRupees, 180.0);
      expect(res.cgst.inRupees, 90.0);
      expect(res.sgst.inRupees, 90.0);
      expect(res.totalAmount.inRupees, 1180.0);
    });

    test('resolves official 2-digit GST state codes', () {
      expect(BharatGst.getStateName('07'), 'Delhi');
      expect(BharatGst.getStateName('27'), 'Maharashtra');
      expect(BharatGst.getStateName('29'), 'Karnataka');
      expect(BharatGst.getStateName('33'), 'Tamil Nadu');
    });
  });

  group('BharatFiscal Indian Financial Calendar', () {
    test('computes Indian Financial Year and Assessment Year', () {
      final july2024 = DateTime(2024, 7, 15);
      expect(BharatFiscal.financialYear(date: july2024), 'FY 2024-25');
      expect(BharatFiscal.assessmentYear(date: july2024), 'AY 2025-26');

      final feb2025 = DateTime(2025, 2, 10);
      expect(BharatFiscal.financialYear(date: feb2025), 'FY 2024-25');
      expect(BharatFiscal.assessmentYear(date: feb2025), 'AY 2025-26');
    });

    test('resolves fiscal quarters', () {
      expect(
          BharatFiscal.quarter(date: DateTime(2024, 5, 1)), FiscalQuarter.q1);
      expect(
          BharatFiscal.quarter(date: DateTime(2024, 8, 1)), FiscalQuarter.q2);
      expect(
          BharatFiscal.quarter(date: DateTime(2024, 11, 1)), FiscalQuarter.q3);
      expect(
          BharatFiscal.quarter(date: DateTime(2025, 2, 1)), FiscalQuarter.q4);
    });

    test(
        'identifies bank holidays (Sundays, 2nd & 4th Saturdays, National Holidays)',
        () {
      // 15 August 2024 (Independence Day)
      expect(BharatFiscal.isBankHoliday(DateTime(2024, 8, 15)), isTrue);
      // 26 January 2024 (Republic Day)
      expect(BharatFiscal.isBankHoliday(DateTime(2024, 1, 26)), isTrue);
      // 2 October 2024 (Gandhi Jayanti)
      expect(BharatFiscal.isBankHoliday(DateTime(2024, 10, 2)), isTrue);

      // Sunday 11 August 2024
      expect(BharatFiscal.isBankHoliday(DateTime(2024, 8, 11)), isTrue);

      // 2nd Saturday: 10 August 2024
      expect(BharatFiscal.isBankHoliday(DateTime(2024, 8, 10)), isTrue);

      // 1st Saturday: 3 August 2024 (Not a bank holiday)
      expect(BharatFiscal.isBankHoliday(DateTime(2024, 8, 3)), isFalse);
    });

    test('calculates T+1 settlement date skipping holidays', () {
      // Wednesday 14 August 2024 (Thursday 15 August is Independence Day)
      // T+1 settlement must be Friday 16 August 2024
      final trade = DateTime(2024, 8, 14);
      final settlement =
          BharatFiscal.calculateSettlementDate(trade, settlementDays: 1);
      expect(settlement, DateTime(2024, 8, 16));
    });

    test('provides statutory Advance Tax installment deadlines', () {
      final dates = BharatFiscal.advanceTaxDueDates(fiscalStartYear: 2024);
      expect(dates.length, 4);
      expect(dates[0].dueDate, DateTime(2024, 6, 15));
      expect(dates[0].cumulativePercentage, 15);
      expect(dates[3].dueDate, DateTime(2025, 3, 15));
      expect(dates[3].cumulativePercentage, 100);
    });
  });

  group('BharatId Facade Integration', () {
    test('exposes all new validators cleanly on BharatId facade', () {
      expect(BharatId.validateDrivingLicense('DL-01-2020-0012345').isValid,
          isTrue);
      expect(BharatId.maskDrivingLicense('DL-01-2020-0012345'),
          'DL-01-XXXX-XXX2345');
      expect(BharatId.formatDrivingLicense('DL0120200012345'),
          'DL-01-2020-0012345');

      expect(BharatId.validateVoterId('ABC1234567').isValid, isTrue);
      expect(BharatId.maskVoterId('ABC1234567'), 'ABCXXXX567');

      expect(BharatId.validatePassport('K1234567').isValid, isTrue);
      expect(BharatId.maskPassport('K1234567'), 'KXXXXX67');

      expect(BharatId.validateCin('U72200KA2020PTC123456').isValid, isTrue);
      expect(
          BharatId.maskCin('U72200KA2020PTC123456'), 'U72200KA2020XXX123456');

      expect(BharatId.validateTan('DELA12345B').isValid, isTrue);
      expect(BharatId.maskTan('DELA12345B'), 'DELXXXXXXB');

      expect(BharatId.validateDin('00123456').isValid, isTrue);
      expect(BharatId.maskDin('00123456'), 'XXXX3456');
    });
  });

  group('PII Redactor with New Identity Keys', () {
    test('redacts map entries with new identity keys', () {
      final telemetry = {
        'name': 'Ramesh',
        'driving_license': 'DL-01-2020-0012345',
        'voter_id': 'ABC1234567',
        'passport': 'K1234567',
        'cin': 'U72200KA2020PTC123456',
        'tan': 'DELA12345B',
        'din': '00123456',
      };

      final sanitized = BharatSecurity.redactMap(telemetry);
      expect(sanitized['name'], 'Ramesh');
      expect(sanitized['driving_license'], '[REDACTED]');
      expect(sanitized['voter_id'], '[REDACTED]');
      expect(sanitized['passport'], '[REDACTED]');
      expect(sanitized['cin'], '[REDACTED]');
      expect(sanitized['tan'], '[REDACTED]');
      expect(sanitized['din'], '[REDACTED]');
    });
  });
}
