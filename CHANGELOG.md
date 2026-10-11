# Changelog

## 1.0.3

* **🛡️ Enterprise Fintech Security Module (`BharatSecurity`)**:
  * **Side-Channel Timing Attack Defense (`TimingSafe`)**: Constant-time string, byte, and integer comparisons for OTPs, MPINs, webhook signatures, and tokens.
  * **Sensitive Memory Protection (`SensitiveValue<T>`)**: Zeroizable, leak-proof memory wrapper that suppresses raw values from logs, crash reports, and JSON telemetry (OWASP MASVS-STORAGE / PRIVACY).
  * **Comprehensive PII Redactor (`BharatPiiRedactor`)**: Auto-detects and redacts Aadhaar (UIDAI rules), VIDs, PANs, Luhn-verified cards, CVVs, bank accounts, UPI VPAs, and phones in text and JSON maps (DPDP Act 2023 compliant).
  * **Zero-Dependency Cryptographic Integrity (`BharatHash`)**: Pure-Dart RFC 6234 SHA-256 and RFC 2104 HMAC-SHA256 payload signing and payment checksum verification.
  * **Anti-Brute Force Guard (`AntiBruteForceGuard`)**: Sliding-window rate limiter to throttle credential and OTP guessing attacks.
  * **Fintech Input Security (`FintechInputSecurityConfig`)**: Mobile keylogging and cloud prediction prevention with clipboard guards.
* **💰 Exact Precision Money (`BharatMoney`)**:
  * Fixed-point integer Paise arithmetic (`1 Rupee = 100 Paise`) eliminating IEEE-754 floating-point rounding bugs.
  * Pre-built NPCI & RBI transaction limit validations (UPI standard ₹1L, capital markets ₹2L, institutional ₹5L; IMPS ₹5L).
  * Rejection of scientific notation and injection attacks during string parsing.
* **💳 Payment Cards & RBI Tokenization (`BharatCard` & `BharatCardToken`)**:
  * NPCI RuPay, Visa, Mastercard, and American Express validation with Luhn (Modulo 10) algorithm.
  * PCI DSS 4.0 compliant masking and RBI Card-on-File Tokenization (CoFT) data models.
  * Card expiry and CVV validation.
* **🏦 Banking & UPI Deep Link Guards**:
  * 9-to-18 digit Indian Bank Account validation with bank-specific lengths (SBI, HDFC, ICICI, Axis, PNB, etc.) and timing-safe confirmation matching (`BharatBankAccount`).
  * NPCI UPI Intent & Deep Link parser (`BharatUpiIntent`) with tampering detection, amount limit verification, and non-INR currency rejection.
  * Defenses against invisible zero-width spaces, Cyrillic/Greek homoglyph attacks, and phishing handles in UPI VPAs.
  * Merged and defunct bank IFSC detection with RBI migration advisories (`BharatIfsc`).
  * UIDAI 16-digit Virtual ID (VID) validation with Verhoeff algorithm and masking (`BharatVid`).
* **🔒 Hardened `BharatTextField` Widget**:
  * Added `BharatTextFieldType` presets: `vid`, `card`, `cvv`, `bankAccount`, and `money`.
  * Support for `obscureText`, obscure toggle buttons, clipboard copy/paste protection, and cloud prediction keyboard suppression.

## 1.0.2

* Shortened package description in `pubspec.yaml` to adhere to pub.dev conventions.

## 1.0.1

* Standardized Dart code formatting across all library files.
* Enhanced documentation with visual banner graphic.
* Refined Dart SDK constraints for broad compatibility.

## 1.0.0

* Initial release of `bharat_fx`: The Ultimate Indian Localization & Input Toolkit for Flutter.
* Module 1: Indian Currency Formatter (`BharatCurrency`)
* Module 2: Smart Indian Address & PIN Code Validator (`BharatInput`)
* Module 3: Vernacular Keyboard & Input Filters (`BharatText`)
* Module 4: Local Vehicle Number Plate Validator (`BharatVehicle`)
* Module 5: Indian Government IDs & UPI Validators (`BharatId`)
* Module 6: Batteries-Included UI Widgets
