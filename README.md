# Bharat FX 🇮🇳
### The Ultimate Indian Localization & Input Toolkit for Flutter

[![pub package](https://img.shields.io/pub/v/bharat_fx.svg)](https://pub.dev/packages/bharat_fx)
[![pub points](https://img.shields.io/pub/points/bharat_fx.svg)](https://pub.dev/packages/bharat_fx/score)
[![CI](https://github.com/Codernta/bharat_fx/actions/workflows/ci.yml/badge.svg)](https://github.com/Codernta/bharat_fx/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.x%20%7C%20Dart%203.x-02569B.svg?logo=flutter)](https://flutter.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/Codernta/bharat_fx)

<p align="center">
  <img src="https://raw.githubusercontent.com/Codernta/bharat_fx/main/assets/banner.jpg" alt="Bharat FX Banner" width="100%" style="border-radius: 8px;">
</p>

**`bharat_fx`** is a **lightweight, 100% dependency-free Flutter package** tailored specifically for the Indian market. Global packages often overlook the unique cultural, financial, and linguistic nuances of India. `bharat_fx` solves these India-specific pain points out of the box with zero external dependencies and zero API fees.

---

## 🌟 Key Highlights

- **💰 Indian Currency Formatter (`BharatCurrency`)**: Formats numbers into the Indian numbering system (**Lakh / Crore**: `₹1,50,000` instead of `150,000`), compact scales (`1.5 L`, `2.5 Cr`), and converts numbers to words in **8 Indian languages** (English, Hindi, Tamil, Telugu, Kannada, Marathi, Gujarati, Bengali).
- **📍 Smart Indian Address & PIN Code Validator (`BharatInput`)**: 6-digit Indian PIN code validator with a **bundled offline local algorithm** that instantly resolves **District, State, Postal Circle, and Zone** in sub-millisecond time without network calls.
- **✍️ Vernacular Keyboard & Phonetic Filters (`BharatText`)**: Input formatters that restrict inputs to native Indian scripts (Devanagari, Tamil, Telugu, etc.) or convert **Hinglish/Phonetic text to Indian scripts in real-time** (e.g. typing `"namaste"` becomes `"नमस्ते"`).
- **🚗 Vehicle Number Plate Validator & HSRP Widget (`BharatVehicle`)**: Comprehensive regex validator for State formats (`DL 01 AB 1234`), the new **Bharat (`BH`) series**, Military, and Diplomatic plates. Includes an authentic **High-Security Registration Plate (HSRP)** visual widget.
- **🆔 Government IDs & UPI Masker / Validator (`BharatId`)**:
  - **Aadhaar Card**: 12 digits with the official **UIDAI Verhoeff algorithm** checksum and UIDAI-compliant masking (`XXXX XXXX 1234`).
  - **PAN Card**: 10-character structure with **4th character entity status decoding** (`P` for Individual, `C` for Company, `T` for Trust, etc.).
  - **UPI ID**: Validates VPA format and automatically identifies the **PSP and Bank** (`@okaxis` -> Google Pay / Axis Bank, `@ybl` -> PhonePe / YES Bank, etc.).
  - **GSTIN, IFSC & Mobile Number**: 15-char GSTIN with PAN extraction, 11-char IFSC bank identifier, and 10-digit Indian mobile number formatters.
- **⚡ 100% Dependency-Free**: Pure Flutter and Dart. Zero external package conflicts.

---

## 📦 Installation

Add `bharat_fx` to your `pubspec.yaml`:

```yaml
dependencies:
  bharat_fx: ^1.0.0
```

Import the package:

```dart
import 'package:bharat_fx/bharat_fx.dart';
```

---

## 🚀 Module Walkthrough

### 1. Indian Currency Formatter (`BharatCurrency`)

Global formatters use millions and billions, but India operates on Lakhs and Crores.

```dart
// Format with Indian comma grouping (2,2,3 grouping)
BharatCurrency.format(150000); // "₹1,50,000"
BharatCurrency.format(1234567.50); // "₹12,34,567.50"
BharatCurrency.format(10000000, showSymbol: false); // "1,00,00,000"

// Compact Indian notation
BharatCurrency.compact(150000); // "₹1.5 L"
BharatCurrency.compact(150000, shortUnit: false); // "₹1.5 Lakh"
BharatCurrency.compact(25000000); // "₹2.5 Cr"
BharatCurrency.compact(1200000000); // "₹1.2 Arab"

// Convert numbers into words across 8 Indian languages
BharatCurrency.toWords(15000);
// "Fifteen Thousand Rupees Only"

BharatCurrency.toWords(15000, language: BharatLanguage.hindi);
// "पंद्रह हज़ार रुपये मात्र"

BharatCurrency.toWords(100000, language: BharatLanguage.tamil);
// "ஒரு லட்சம் ரூபாய் மட்டும்"

BharatCurrency.toWords(100000, language: BharatLanguage.telugu);
// "ఒక లక్ష రూపాయలు మాత్రమే"

// Live typing TextInputFormatter for TextFields
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [BharatCurrencyInputFormatter()],
)

// Display Widget
BharatCurrencyText(
  150000,
  showWordsSubtitle: true, // Displays "One Lakh Fifty Thousand Rupees Only" below
)
```

---

### 2. Smart Indian Address & PIN Code Validator (`BharatInput`)

Validate 6-digit Indian PIN codes and resolve geographical details **100% offline with zero network latency**:

```dart
// Validation
BharatPinCode.isValid('560001'); // true
BharatPinCode.isValid('010001'); // false (Indian PINs never start with 0)

// Instant offline local lookup
final info = BharatPinCode.lookup('560001');
print(info.state);    // "Karnataka"
print(info.district); // "Bengaluru Urban"
print(info.zone);     // "Southern Postal Zone"
print(info.circle);   // "Karnataka"
```

#### Real-Time Auto-Filling Form Field:
Drop in `BharatPinCodeFormField` to auto-fill the user's State and District controllers as soon as 6 digits are typed:

```dart
final stateController = TextEditingController();
final districtController = TextEditingController();

BharatPinCodeFormField(
  stateController: stateController,
  districtController: districtController,
  showResolvedInfoInline: true,
  onResolved: (PinCodeInfo info) {
    print("Resolved: ${info.district}, ${info.state}");
  },
)
```

---

### 3. Vernacular Keyboard & Phonetic Filters (`BharatText`)

Provide natural typing for regional Indian users:

```dart
// Real-time Phonetic / Hinglish transliteration
BharatTransliterator.transliterate("namaste"); // "नमस्ते"
BharatTransliterator.transliterate("bharat mahan hai"); // "भारत महान है"
BharatTransliterator.transliterate("vanakkam", targetScript: IndianScript.tamil); // "வணக்கம்"

// Live phonetic keyboard formatter in TextField (converts on space)
TextField(
  inputFormatters: [
    BharatPhoneticInputFormatter(
      targetScript: IndianScript.devanagari,
      convertOnSpace: true,
    ),
  ],
)

// Restrict input exclusively to an Indian script
TextField(
  inputFormatters: [
    BharatScriptInputFormatter.single(IndianScript.devanagari),
  ],
)

// Convert numbers between Arabic and Indic numerals
BharatText.toIndicDigits("12345", IndianScript.devanagari); // "१२३४५"
BharatText.fromIndicDigits("१२३४५"); // "12345"
```

---

### 4. Vehicle Registration Plate Validator (`BharatVehicle`)

Validate Indian vehicle registration numbers and display authentic High-Security Registration Plates (HSRP):

```dart
// Validate and parse standard state format
final plate = BharatVehicle.validate("DL 01 AB 1234");
print(plate.isValid);    // true
print(plate.stateName);  // "Delhi"
print(plate.rtoName);    // "Mall Road, North Delhi"
print(plate.rtoCode);    // "01"
print(plate.series);     // "AB"
print(plate.registrationNumber); // "1234"

// Validate the new pan-India Bharat (BH) series
final bh = BharatVehicle.validate("21 BH 1234 AA");
print(bh.isValid);          // true
print(bh.type);             // VehiclePlateType.bharatSeries
print(bh.registrationYear); // 2021

// Also supports Military (↑ 21 D 123456 X) and Diplomatic (77 CD 1234) plates
```

#### Realistic HSRP License Plate Widget:

```dart
BharatVehiclePlateWidget(
  plateNumber: 'KA 01 AB 1234',
  category: VehiclePlateCategory.privateVehicle, // White plate
  // Or: commercialVehicle (Yellow), electricVehicle (Green), rentalVehicle (Black)
  height: 56,
)
```

---

### 5. Indian Government IDs & Payment Validators (`BharatId`)

#### Aadhaar Card (12 Digits with UIDAI Verhoeff Checksum):
```dart
// Validates 12 digits, checks non-0/1 start, and runs the Verhoeff checksum algorithm
BharatId.isAadhaar("234567890124"); // true / false

// Masking per UIDAI privacy standards
BharatId.maskAadhaar("234567890124"); // "XXXX XXXX 0124"
BharatId.maskAadhaar("234567890124", maskChar: '•'); // "•••• •••• 0124"
```

#### PAN Card (10 Characters with 4th Char Entity Classifier):
```dart
final pan = BharatId.validatePan("ABCPD1234F");
print(pan.isValid);             // true
print(pan.category);            // PanCategory.individual
print(pan.categoryDescription); // "Individual (Person)"

// Validate entity category constraints
final companyPan = BharatId.validatePan(
  "AAACR1234G",
  expectedCategory: PanCategory.individual,
);
print(companyPan.isValid); // false (PAN belongs to Company)

// Masking
BharatId.maskPan("ABCPD1234F"); // "XXXXX1234F"
```

#### UPI ID / VPA with PSP & Bank Detection:
```dart
final upi = BharatId.validateUpi("user@okaxis");
print(upi.isValid);  // true
print(upi.pspName);  // "Google Pay"
print(upi.bankName); // "Axis Bank"

final phonePe = BharatId.validateUpi("9876543210@ybl");
print(phonePe.pspName); // "PhonePe"
print(phonePe.bankName); // "YES Bank"
```

#### GSTIN, IFSC & Mobile Phone:
```dart
// GSTIN
final gstin = BharatId.validateGstin("27AAPFU0939F1ZV");
print(gstin.stateCode); // "27" (Maharashtra)
print(gstin.pan);       // "AAPFU0939F"

// IFSC
final ifsc = BharatId.validateIfsc("SBIN0000123");
print(ifsc.bankName); // "State Bank of India"

// Indian Mobile (+91)
final phone = BharatId.validatePhone("9876543210");
print(phone.formattedNumber); // "+91 98765 43210"
```

---

### 6. Specialized UI Widget: `BharatTextField`

An all-in-one pre-configured `TextFormField` with pre-wired formatters, regex, keyboards, and live validation indicators:

```dart
// Aadhaar field with 4-digit space grouping and Verhoeff validation
BharatTextField(
  type: BharatTextFieldType.aadhaar,
)

// PAN field with auto-capitalization and category decoding
BharatTextField(
  type: BharatTextFieldType.pan,
)

// UPI field with live PSP badge
BharatTextField(
  type: BharatTextFieldType.upi,
)

// Currency field with Rupee prefix and live Indian comma formatting
BharatTextField(
  type: BharatTextFieldType.currency,
)

// Vehicle plate field with auto-capitalization
BharatTextField(
  type: BharatTextFieldType.vehiclePlate,
)
```

---

## 📱 Interactive Showcase App

An interactive demo app showcasing all 5 modules is included in the `example/` directory.

To run it:

```bash
cd example
flutter run
```

---

## 🧪 Comprehensive Test Coverage

Every algorithm (Lakh/Crore grouping, Verhoeff checksum, PAN entity classification, PIN code resolution, phonetic transliteration, and vehicle plate regex) is backed by 55+ unit and widget tests:

```bash
flutter test
```

---

## 📄 License

This package is released under the **MIT License**. See [LICENSE](LICENSE) for details.
