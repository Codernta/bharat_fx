# Changelog

## 1.0.2

* Shortened package description in `pubspec.yaml` to adhere to pub.dev conventions.

## 1.0.1

* Standardized Dart code formatting across all library files.
* Enhanced documentation with visual banner graphic.
* Refined Dart SDK constraints for broad compatibility.

## 1.0.0

* Initial release of `bharat_fx`: The Ultimate Indian Localization & Input Toolkit for Flutter.
* **Module 1: Indian Currency Formatter (`BharatCurrency`)**
  * Indian numbering scale grouping (`1,00,000` Lakh and `1,00,00,000` Crore).
  * Compact notations (`₹1.5 L`, `₹2.5 Cr`, `₹1.2 Arab`).
  * Real-time currency live typing formatter (`BharatCurrencyInputFormatter`).
  * Number to words in 8 Indian languages (English, Hindi, Tamil, Telugu, Kannada, Marathi, Gujarati, Bengali).
  * Currency display widget (`BharatCurrencyText`).
* **Module 2: Smart Indian Address & PIN Code Validator (`BharatInput`)**
  * 6-digit Indian PIN code validation.
  * 100% offline local directory with instant sub-millisecond resolution of District, State, Postal Circle, and Zone.
  * Auto-filling `BharatPinCodeFormField` widget for State & District controllers.
* **Module 3: Vernacular Keyboard & Input Filters (`BharatText`)**
  * Script restriction input formatter for all major Indic scripts (Devanagari, Tamil, Telugu, Kannada, Malayalam, Bengali, Gujarati, Gurmukhi, Odia).
  * Live phonetic transliteration keyboard (`BharatPhoneticInputFormatter`) converting Hinglish to Indian scripts.
  * Indic numerals converter (`123` <-> `१२३`).
* **Module 4: Local Vehicle Number Plate Validator (`BharatVehicle`)**
  * Validators for Standard State plates, new Bharat Series (`BH`), Defense forces, and Diplomatic plates.
  * Complete 36 State / UT and RTO office resolver.
  * Authentic Indian High-Security Registration Plate (HSRP) visual widget (`BharatVehiclePlateWidget`).
* **Module 5: Indian Government IDs & UPI Validators (`BharatId`)**
  * Aadhaar Card: 12-digit format with official UIDAI Verhoeff checksum algorithm and masking.
  * PAN Card: 10-character structure with 4th character entity status decoding (Individual, Company, HUF, Trust, Firm, etc.).
  * UPI ID: Syntax validation with instant Payment Service Provider (PSP) and bank detection (Google Pay, PhonePe, Paytm, BHIM, Amazon Pay, etc.).
  * GSTIN: 15-character structure validation and embedded PAN extraction.
  * IFSC Code: 11-character validation with major bank institution mapping.
  * Indian Mobile Number: 10-digit validation (+91 and 6-9 prefixes) and formatters.
* **Module 6: Batteries-Included UI Widgets**
  * `BharatTextField` with ready-to-use presets for all Indian data fields.
