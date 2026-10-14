# Changelog

## 1.0.4

* **🆔 Indian Identity & KYC Expansion (`BharatId`)**:
  * **MoRTH Driving License (`BharatDrivingLicense` / `BharatDl`)**: Validates 15/16-character MoRTH DLs, auto-hyphenates to `SS-RR-YYYY-NNNNNNN`, resolves state name, issuing RTO office, and issue year, with privacy masking (`DL-01-XXXX-XXX2345`).
  * **Voter ID / EPIC (`BharatVoterId` / `BharatEpic`)**: Validates 10-character Election Commission of India (ECI) Voter IDs, extracts assembly constituency code and serial number, with compliant masking (`ABCXXXX567`).
  * **Indian Passport (`BharatPassport`)**: Validates Ministry of External Affairs 8-character Indian passport format (series letter + 7 digits, rejecting invalid series like Q), with compliant masking (`KXXXXX67`).
  * **Corporate & MCA Identification (`BharatCin`, `BharatTan`, `BharatDin`)**:
    * **CIN (Corporate Identification Number)**: 21-character validator extracting listing status (Listed/Unlisted), 5-digit industry code, state, incorporation year, company classification (PTC, PLC, FTC, GOI, etc.), and registration number with privacy masking.
    * **TAN (Tax Deduction Account Number)**: 10-character validator with jurisdiction, deductor initial, and check letter extraction.
    * **DIN (Director Identification Number)**: 8-digit MCA director number validator and masking.
* **🧾 Indian Goods & Services Tax Engine (`BharatGst`)**:
  * Precision integer Paise tax arithmetic using `BharatMoney`.
  * Automatic tax bifurcation: **Intra-State** (50% CGST + 50% SGST) vs **Inter-State** (100% IGST).
  * Auto-detection of inter-state transactions from GSTINs or 2-digit GST state codes.
  * Reverse / Inclusive GST calculation (extract base taxable price and tax components from MRP).
  * Complete official 2-digit GST State / UT code directory.
* **📅 Indian Fiscal & Settlement Calendar (`BharatFiscal`)**:
  * Financial Year (`FY 2024-25`) and Assessment Year (`AY 2025-26`) resolution (April 1 – March 31 cycle).
  * Indian Fiscal Quarters (Q1: Apr-Jun, Q2: Jul-Sep, Q3: Oct-Dec, Q4: Jan-Mar).
  * Statutory Advance Tax installment schedule (15% by June 15, 45% by Sep 15, 75% by Dec 15, 100% by Mar 15).
  * RBI Banking Holiday engine: identifies Sundays, 2nd & 4th Saturdays, and national gazetted holidays (Jan 26, May 1, Aug 15, Oct 2).
  * Market settlement date calculator (`T+1` and `T+2` settlement skipping Indian banking holidays and weekends).
* **🔒 Enhanced Fintech Input Field (`BharatTextField`)**:
  * Added new input presets: `drivingLicense`, `voterId`, `passport`, `cin`, `tan`, and `din`.
  * Added dedicated text input formatters and automatic credential protection (suppresses cloud keyboard suggestions and autocorrect).
  * Added callbacks: `onDrivingLicenseResolved` and `onCinResolved`.
* **🛡️ Security & PII Redactor (`BharatPiiRedactor`)**:
  * Added sensitive key suppression for `driving_license`, `voter_id`, `passport`, `cin`, `tan`, and `din` in JSON telemetry scrubbers (DPDP Act 2023 compliant).
* **✨ 100% Backward Compatible**:
  * Zero breaking changes to existing APIs, signatures, or behavior.
  * 100% pure Dart & Flutter with zero external package dependencies.

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
