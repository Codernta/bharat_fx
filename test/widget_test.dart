import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  testWidgets('BharatCurrencyText displays formatted amount and words', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BharatCurrencyText(150000, showWordsSubtitle: true),
        ),
      ),
    );

    expect(find.text('₹'), findsOneWidget);
    expect(find.text('1,50,000'), findsOneWidget);
    expect(find.text('One Lakh Fifty Thousand Rupees Only'), findsOneWidget);
  });

  testWidgets('BharatVehiclePlateWidget renders HSRP plate with IND badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BharatVehiclePlateWidget(
            plateNumber: 'KA 01 AB 1234',
            category: VehiclePlateCategory.privateVehicle,
          ),
        ),
      ),
    );

    expect(find.text('IND'), findsOneWidget);
    expect(find.text('KA 01 AB 1234'), findsOneWidget);
  });

  testWidgets(
    'BharatPinCodeFormField autofills state and district controllers',
    (tester) async {
      final stateController = TextEditingController();
      final districtController = TextEditingController();
      PinCodeInfo? resolved;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BharatPinCodeFormField(
              stateController: stateController,
              districtController: districtController,
              onResolved: (info) => resolved = info,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '560001');
      await tester.pumpAndSettle();

      expect(stateController.text, 'Karnataka');
      expect(districtController.text, 'Bengaluru Urban');
      expect(resolved?.isValid, isTrue);
    },
  );

  testWidgets('BharatTextField handles PAN and Aadhaar typing', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BharatTextField(
            controller: controller,
            type: BharatTextFieldType.pan,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'abcde1234f');
    await tester.pumpAndSettle();

    expect(controller.text, 'ABCDE1234F');
  });
}
