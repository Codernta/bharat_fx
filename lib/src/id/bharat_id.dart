import 'aadhaar_validator.dart';
import 'gstin_validator.dart';
import 'ifsc_validator.dart';
import 'pan_validator.dart';
import 'phone_validator.dart';
import 'upi_validator.dart';

/// Unified access facade for Indian Government IDs, payments, and identification validators.
class BharatId {
  /// Validates a 12-digit Indian Aadhaar number with UIDAI Verhoeff algorithm.
  static bool isAadhaar(String? aadhaar) => BharatAadhaar.validate(aadhaar);

  /// Masks an Aadhaar number to `XXXX XXXX 1234`.
  static String maskAadhaar(String aadhaar, {String maskChar = 'X'}) =>
      BharatAadhaar.mask(aadhaar, maskChar: maskChar);

  /// Validates an Indian PAN card.
  static PanValidationResult validatePan(
    String? pan, {
    PanCategory? expectedCategory,
    String? surnameInitial,
  }) => BharatPan.validate(
    pan,
    expectedCategory: expectedCategory,
    surnameInitial: surnameInitial,
  );

  /// Masks a PAN card to `XXXXXX1234F`.
  static String maskPan(String pan, {String maskChar = 'X'}) =>
      BharatPan.mask(pan, maskChar: maskChar);

  /// Validates a UPI ID and extracts handle details and bank provider.
  static UpiValidationResult validateUpi(String? upiId) =>
      BharatUpi.validate(upiId);

  /// Validates an Indian GSTIN (Goods and Services Tax Identification Number).
  static GstinValidationResult validateGstin(String? gstin) =>
      BharatGstin.validate(gstin);

  /// Masks a GSTIN number.
  static String maskGstin(String gstin, {String maskChar = 'X'}) =>
      BharatGstin.mask(gstin, maskChar: maskChar);

  /// Validates an Indian IFSC code.
  static IfscValidationResult validateIfsc(String? ifsc) =>
      BharatIfsc.validate(ifsc);

  /// Validates a 10-digit Indian Mobile Phone number.
  static PhoneValidationResult validatePhone(String? phone) =>
      BharatPhone.validate(phone);
}
