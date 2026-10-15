/// The Ultimate Indian Localization, Fintech & Input Toolkit for Flutter.
///
/// Features:
/// - Indian Currency Formatter with Lakh/Crore grouping and multi-language Number-to-Words.
/// - Exact fixed-point [BharatMoney] for precision fintech calculations and NPCI/RBI limit checks.
/// - Enterprise Fintech Security: Timing-safe equality, PII/SPII redaction, sensitive memory zeroization,
///   zero-dependency SHA-256 and HMAC checksum verification, and anti-keylogging guards.
/// - Offline Indian Postal PIN code validator and district/state auto-resolver.
/// - Vernacular text input filters and real-time phonetic transliteration keyboard.
/// - Indian Vehicle registration number plate validator, RTO resolver, and HSRP widget.
/// - Indian Government IDs, Banking & UPI validators (Aadhaar with Verhoeff, 16-digit VID, PAN, RuPay/Cards,
///   Bank Account validation, UPI Intent & tampering guard, GSTIN, IFSC with merged bank detection, Phone).
library;

// Fintech Security Module
export 'src/security/fintech_security.dart';
export 'src/security/input_security.dart';
export 'src/security/payload_integrity.dart';
export 'src/security/pii_redactor.dart';
export 'src/security/sensitive_data.dart';
export 'src/security/timing_safe.dart';

// Currency, GST & Precision Money Module
export 'src/currency/bharat_currency.dart';
export 'src/currency/bharat_gst.dart';
export 'src/currency/bharat_money.dart';
export 'src/currency/number_to_words.dart';
export 'src/currency/words_languages.dart';

// Indian Fiscal, GST Invoicing & Compliance Module
export 'src/fiscal/bharat_fiscal.dart';
export 'src/fiscal/bharat_hsn.dart';
export 'src/fiscal/gst_invoice_format.dart';
export 'src/fiscal/gst_qr_parser.dart';

// Address & PIN Code Module
export 'src/input/pin_code_data.dart';
export 'src/input/pin_code_form_field.dart';
export 'src/input/pin_code_formatter.dart';
export 'src/input/pin_code_validator.dart';

// Vernacular Text & Transliteration Module
export 'src/text/bharat_text.dart';
export 'src/text/indian_scripts.dart';
export 'src/text/phonetic_formatter.dart';
export 'src/text/script_formatter.dart';
export 'src/text/transliterator.dart';

// Vehicle Registration Module
export 'src/vehicle/rto_database.dart';
export 'src/vehicle/vehicle_formatter.dart';
export 'src/vehicle/vehicle_plate_widget.dart';
export 'src/vehicle/vehicle_types.dart';
export 'src/vehicle/vehicle_validator.dart';

// Government IDs, Payments, Banking & Identity Module
export 'src/id/aadhaar_validator.dart';
export 'src/id/bank_account_validator.dart';
export 'src/id/bharat_id.dart';
export 'src/id/card_token.dart';
export 'src/id/card_validator.dart';
export 'src/id/corporate_id_validator.dart';
export 'src/id/driving_license_validator.dart';
export 'src/id/gstin_validator.dart';
export 'src/id/id_formatters.dart';
export 'src/id/ifsc_validator.dart';
export 'src/id/pan_validator.dart';
export 'src/id/passport_validator.dart';
export 'src/id/phone_validator.dart';
export 'src/id/upi_intent.dart';
export 'src/id/upi_validator.dart';
export 'src/id/vid_validator.dart';
export 'src/id/voter_id_validator.dart';

// Specialized & Hardened Widgets
export 'src/widgets/bharat_currency_text.dart';
export 'src/widgets/bharat_text_field.dart';
