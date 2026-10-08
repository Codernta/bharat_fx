import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  group('BharatVehicle Plate Validator', () {
    test(
      'validates and parses standard state registration (DL, KA, MH, TN)',
      () {
        final dl = BharatVehicle.validate('DL 01 AB 1234');
        expect(dl.isValid, isTrue);
        expect(dl.type, VehiclePlateType.standard);
        expect(dl.stateCode, 'DL');
        expect(dl.stateName, 'Delhi');
        expect(dl.rtoCode, '01');
        expect(dl.rtoName, 'Mall Road, North Delhi');
        expect(dl.series, 'AB');
        expect(dl.registrationNumber, '1234');
        expect(dl.formattedNumber, 'DL 01 AB 1234');

        final ka = BharatVehicle.validate('KA05M9999');
        expect(ka.isValid, isTrue);
        expect(ka.stateCode, 'KA');
        expect(ka.stateName, 'Karnataka');
        expect(ka.rtoCode, '05');
        expect(ka.rtoName, 'Jayanagar, Bengaluru South');
        expect(ka.series, 'M');
        expect(ka.registrationNumber, '9999');

        final mh = BharatVehicle.validate('MH 12 1234');
        expect(mh.isValid, isTrue);
        expect(mh.stateCode, 'MH');
        expect(mh.stateName, 'Maharashtra');
        expect(mh.rtoCode, '12');
        expect(mh.rtoName, 'Pune Central');

        final dlSpecial = BharatVehicle.validate('DL 3C AB 1234');
        expect(dlSpecial.isValid, isTrue);
        expect(dlSpecial.stateCode, 'DL');
        expect(dlSpecial.rtoCode, '3C');
      },
    );

    test('validates and parses Bharat Series (BH)', () {
      final bh = BharatVehicle.validate('21 BH 1234 AA');
      expect(bh.isValid, isTrue);
      expect(bh.type, VehiclePlateType.bharatSeries);
      expect(bh.stateCode, 'BH');
      expect(bh.stateName, contains('Bharat'));
      expect(bh.registrationYear, 2021);
      expect(bh.registrationNumber, '1234');
      expect(bh.series, 'AA');

      final bh2 = BharatVehicle.validate('22bh5678b');
      expect(bh2.isValid, isTrue);
      expect(bh2.registrationYear, 2022);
      expect(bh2.formattedNumber, '22 BH 5678 B');
    });

    test('validates Indian Armed Forces / Defense plates', () {
      final def = BharatVehicle.validate('↑ 21 D 123456 X');
      expect(def.isValid, isTrue);
      expect(def.type, VehiclePlateType.defense);
      expect(def.stateName, 'Indian Armed Forces');
    });

    test('validates Diplomatic plates', () {
      final dip = BharatVehicle.validate('77 CD 1234');
      expect(dip.isValid, isTrue);
      expect(dip.type, VehiclePlateType.diplomatic);
    });

    test('rejects invalid number plates', () {
      expect(BharatVehicle.isValid('INVALID123'), isFalse);
      expect(
        BharatVehicle.isValid('ZZ 99 ZZ 9999'),
        isFalse,
      ); // ZZ not valid Indian state
      expect(BharatVehicle.isValid(''), isFalse);
      expect(BharatVehicle.isValid(null), isFalse);
    });
  });

  group('BharatVehicleInputFormatter', () {
    test('formats and uppercases input', () {
      final formatter = BharatVehicleInputFormatter();
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'ka 01 ab 1234'),
      );
      expect(result.text, 'KA 01 AB 1234');
    });
  });
}
