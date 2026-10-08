import 'package:flutter/material.dart';
import 'vehicle_types.dart';
import 'vehicle_validator.dart';

/// A realistic Flutter visual widget rendering an authentic Indian High-Security
/// Registration Plate (HSRP), with the blue `IND` strip, Ashoka hologram emblem,
/// and customizable plate category colors (White, Yellow, Green for EV, etc.).
class BharatVehiclePlateWidget extends StatelessWidget {
  final String plateNumber;
  final VehiclePlateCategory category;
  final double height;
  final double? width;
  final bool showIndStrip;
  final VoidCallback? onTap;

  const BharatVehiclePlateWidget({
    super.key,
    required this.plateNumber,
    this.category = VehiclePlateCategory.privateVehicle,
    this.height = 54,
    this.width,
    this.showIndStrip = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final validated = BharatVehicle.validate(plateNumber);
    final displayText = validated.isValid
        ? validated.formattedNumber
        : plateNumber.toUpperCase();

    // Determine plate background and foreground color
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (category) {
      case VehiclePlateCategory.privateVehicle:
        backgroundColor = Colors.white;
        textColor = const Color(0xFF1E1E1E);
        borderColor = const Color(0xFF333333);
        break;
      case VehiclePlateCategory.commercialVehicle:
        backgroundColor = const Color(0xFFFFCC00);
        textColor = const Color(0xFF1E1E1E);
        borderColor = const Color(0xFF333333);
        break;
      case VehiclePlateCategory.electricVehicle:
        backgroundColor = const Color(0xFF1B5E20);
        textColor = Colors.white;
        borderColor = const Color(0xFF003300);
        break;
      case VehiclePlateCategory.commercialElectricVehicle:
        backgroundColor = const Color(0xFF1B5E20);
        textColor = const Color(0xFFFFCC00);
        borderColor = const Color(0xFF003300);
        break;
      case VehiclePlateCategory.rentalVehicle:
        backgroundColor = const Color(0xFF1E1E1E);
        textColor = const Color(0xFFFFCC00);
        borderColor = const Color(0xFF555555);
        break;
      case VehiclePlateCategory.diplomaticVehicle:
        backgroundColor = const Color(0xFF0D47A1);
        textColor = Colors.white;
        borderColor = const Color(0xFF002171);
        break;
    }

    final plateWidget = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height * 0.12),
        border: Border.all(color: borderColor, width: 2.2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height * 0.10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Blue IND Strip on the left
            if (showIndStrip)
              Container(
                width: height * 0.58,
                color: const Color(0xFF003399),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hologram Chakra circle
                    Container(
                      width: height * 0.22,
                      height: height * 0.22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.lightBlueAccent.withValues(alpha: 0.4),
                        border: Border.all(
                          color: Colors.lightBlueAccent,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: height * 0.08,
                          height: height * 0.08,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'IND',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: height * 0.22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

            // Number plate text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.3),
              child: Center(
                child: Text(
                  displayText,
                  style: TextStyle(
                    color: textColor,
                    fontSize: height * 0.50,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(height * 0.12),
        child: plateWidget,
      );
    }

    return plateWidget;
  }
}
