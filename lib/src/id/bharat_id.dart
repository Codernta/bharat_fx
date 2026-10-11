import 'aadhaar_validator.dart';
import 'bank_account_validator.dart';
import 'card_validator.dart';
import 'gstin_validator.dart';
import 'ifsc_validator.dart';
import 'pan_validator.dart';
import 'phone_validator.dart';
import 'upi_intent.dart';
import 'upi_validator.dart';
import 'vid_validator.dart';

/// Unified access facade for Indian Government IDs, payments, banking, and identification validators.
class BharatId {
  /// Validates a 12-digit Indian Aadhaar number with UIDAI Verhoeff algorithm.
  static bool isAadhaar(String? aadhaar) => BharatAadhaar.validate(aadhaar);

  /// Masks an Aadhaar number to `XXXX XXXX 1234`.
  static String maskAadhaar(String aadhaar, {String maskChar = 'X'}) =>
      BharatAadhaar.mask(aadhaar, maskChar: maskChar);

  /// Validates a 16-digit UIDAI Virtual ID (VID) with Verhoeff algorithm.
  static bool isVid(String? vid) => BharatVid.validate(vid);

  /// Masks a 16-digit Virtual ID to `XXXX XXXX XXXX 1234`.
  static String maskVid(String vid, {String maskChar = 'X'}) =>
      BharatVid.mask(vid, maskChar: maskChar);

  /// Validates an Indian PAN card.
  static PanValidationResult validatePan(
    String? pan, {
    PanCategory? expectedCategory,
    String? surnameInitial,
  }) =>
      BharatPan.validate(
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

  /// Sanitizes a UPI ID by stripping invisible characters.
  static String sanitizeUpi(String? upiId) => BharatUpi.sanitize(upiId);

  /// Validates an NPCI UPI payment deep link / Intent URI (`upi://pay?...`).
  static UpiIntentValidationResult validateUpiIntent(String? uri) =>
      BharatUpiIntent.validate(uri);

  /// Validates an Indian Bank Account Number (9 - 18 digits).
  static BankAccountValidationResult validateBankAccount(
    String? accountNumber, {
    String? bankCode,
  }) =>
      BharatBankAccount.validate(accountNumber, bankCode: bankCode);

  /// Masks a bank account number, preserving only the last [visibleDigits] digits.
  static String maskBankAccount(
    String accountNumber, {
    String maskChar = 'X',
    int visibleDigits = 4,
  }) =>
      BharatBankAccount.mask(
        accountNumber,
        maskChar: maskChar,
        visibleDigits: visibleDigits,
      );

  /// Verifies in constant time that two bank account numbers match.
  static bool matchBankAccounts(String? account, String? confirmAccount) =>
      BharatBankAccount.match(account, confirmAccount);

  /// Validates a payment card (RuPay, Visa, Mastercard, Amex) using Luhn checksum.
  static CardValidationResult validateCard(String? cardNumber) =>
      BharatCard.validate(cardNumber);

  /// Masks a card number compliant with PCI DSS 4.0 regulations.
  static String maskCard(
    String cardNumber, {
    String maskChar = 'X',
    bool preserveBin = false,
  }) =>
      BharatCard.mask(
        cardNumber,
        maskChar: maskChar,
        preserveBin: preserveBin,
      );

  /// Validates an expiration date (`MM/YY` or `MM/YYYY`).
  static bool validateCardExpiry(int month, int year) =>
      BharatCard.validateExpiry(month, year);

  /// Validates a CVV code.
  static bool validateCvv(String? cvv, {BharatCardType? cardType}) =>
      BharatCard.validateCvv(cvv, cardType: cardType);

  /// Validates an Indian GSTIN (Goods and Services Tax Identification Number).
  static GstinValidationResult validateGstin(String? gstin) =>
      BharatGstin.validate(gstin);

  /// Masks a GSTIN number.
  static String maskGstin(String gstin, {String maskChar = 'X'}) =>
      BharatGstin.mask(gstin, maskChar: maskChar);

  /// Validates an Indian IFSC code and detects merged banks.
  static IfscValidationResult validateIfsc(String? ifsc) =>
      BharatIfsc.validate(ifsc);

  /// Validates a 10-digit Indian Mobile Phone number.
  static PhoneValidationResult validatePhone(String? phone) =>
      BharatPhone.validate(phone);
}
