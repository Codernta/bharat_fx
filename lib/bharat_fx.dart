/// The Ultimate Indian Localization & Input Toolkit for Flutter.
///
/// Features:
/// - Indian Currency Formatter with Lakh/Crore grouping and multi-language Number-to-Words.
/// - Offline Indian Postal PIN code validator and district/state auto-resolver.
/// - Vernacular text input filters and real-time phonetic transliteration keyboard.
/// - Indian Vehicle registration number plate validator, RTO resolver, and HSRP widget.
/// - Indian Government IDs & UPI validators (Aadhaar with Verhoeff algorithm, PAN, UPI, GSTIN, IFSC, Phone).
library;

// Currency Module
export 'src/currency/bharat_currency.dart';
export 'src/currency/number_to_words.dart';
export 'src/currency/words_languages.dart';

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

// Government IDs, Payments & Identity Module
export 'src/id/aadhaar_validator.dart';
export 'src/id/bharat_id.dart';
export 'src/id/gstin_validator.dart';
export 'src/id/id_formatters.dart';
export 'src/id/ifsc_validator.dart';
export 'src/id/pan_validator.dart';
export 'src/id/phone_validator.dart';
export 'src/id/upi_validator.dart';

// Specialized Widgets
export 'src/widgets/bharat_currency_text.dart';
export 'src/widgets/bharat_text_field.dart';
