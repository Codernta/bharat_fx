/// Category of Indian vehicle registration plate.
enum VehiclePlateType {
  /// Regular state registration (e.g. DL 01 AB 1234, KA 05 M 9999).
  standard,

  /// All-India Bharat Series (e.g. 21 BH 1234 AA).
  bharatSeries,

  /// Indian Armed Forces / Military vehicle plate (e.g. ↑ 12 D 123456 X).
  defense,

  /// Diplomatic Corps / United Nations (e.g. 12 CD 34, 56 UN 78).
  diplomatic,

  /// Temporary registration plate.
  temporary,

  /// Unknown or unrecognised plate format.
  unknown,
}

/// Visual styling / color scheme of the vehicle number plate.
enum VehiclePlateCategory {
  /// Private vehicles (Black text on White background).
  privateVehicle,

  /// Commercial / Transport vehicles (Black text on Yellow background).
  commercialVehicle,

  /// Electric vehicles (White text on Green background).
  electricVehicle,

  /// Commercial Electric vehicles (Yellow text on Green background).
  commercialElectricVehicle,

  /// Self-drive rental vehicles (Yellow text on Black background).
  rentalVehicle,

  /// Diplomatic vehicles (White text on Blue background).
  diplomaticVehicle,
}

/// Rich parsed details extracted from an Indian vehicle registration number.
class VehiclePlateInfo {
  final String rawNumber;
  final String formattedNumber;
  final bool isValid;
  final VehiclePlateType type;
  final String? stateCode;
  final String? stateName;
  final String? rtoCode;
  final String? rtoName;
  final String? series;
  final String? registrationNumber;
  final int? registrationYear;
  final String? errorMessage;

  const VehiclePlateInfo({
    required this.rawNumber,
    required this.formattedNumber,
    required this.isValid,
    this.type = VehiclePlateType.unknown,
    this.stateCode,
    this.stateName,
    this.rtoCode,
    this.rtoName,
    this.series,
    this.registrationNumber,
    this.registrationYear,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'VehiclePlateInfo(plate: $formattedNumber, valid: $isValid, type: $type, state: $stateName, rto: $rtoName)';
  }
}
