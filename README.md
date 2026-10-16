# Bharat FX 🇮🇳
### The Ultimate Indian Localization, Fintech & Input Toolkit for Flutter

[![pub package](https://img.shields.io/pub/v/bharat_fx.svg)](https://pub.dev/packages/bharat_fx)
[![pub points](https://img.shields.io/pub/points/bharat_fx.svg)](https://pub.dev/packages/bharat_fx/score)
[![CI](https://github.com/Codernta/bharat_fx/actions/workflows/ci.yml/badge.svg)](https://github.com/Codernta/bharat_fx/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.x%20%7C%20Dart%203.x-02569B.svg?logo=flutter)](https://flutter.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/Codernta/bharat_fx)

<p align="center">
  <img src="https://raw.githubusercontent.com/Codernta/bharat_fx/main/assets/banner.jpg" alt="Bharat FX Banner" width="100%" style="border-radius: 8px;">
</p>

**`bharat_fx`** is an **enterprise-grade, 100% dependency-free Flutter & Dart toolkit** designed specifically for Indian localization, fintech, and banking applications. It incorporates strict compliance guidelines from the **Reserve Bank of India (RBI)**, **National Payments Corporation of India (NPCI)**, **Unique Identification Authority of India (UIDAI)**, **PCI DSS 4.0**, and the **Digital Personal Data Protection (DPDP) Act 2023**.

---

## 🌟 Key Highlights

- **🛡️ Enterprise Fintech Security (`BharatSecurity`)**:
  - **Timing Side-Channel Defense (`TimingSafe`)**: Constant-time equality checks for OTPs, MPINs, transaction signatures, and auth tokens.
  - **Sensitive Memory Protection (`SensitiveValue<T>`)**: Zeroizable, leak-proof memory wrapper that suppresses raw values from logs, crash reports, and JSON telemetry.
  - **Comprehensive PII Redactor (`BharatPiiRedactor`)**: Auto-detects and redacts Aadhaar (UIDAI rules), VIDs, PANs, Luhn-verified cards, CVVs, bank accounts, UPI VPAs, and phones in text and JSON maps.
  - **Zero-Dependency Cryptographic Integrity (`BharatHash`)**: Pure-Dart RFC 6234 SHA-256 and RFC 2104 HMAC-SHA256 payload signing and payment checksum verification.
  - **Anti-Keylogging & Anti-Clipboard Guards**: Disables third-party cloud keyboard harvesting and clipboard snooping on sensitive financial inputs.
  - **Anti-Brute Force Guard (`AntiBruteForceGuard`)**: Sliding-window rate limiter to throttle credential and OTP guessing attacks.
- **💰 Exact Precision Money & Indian Currency (`BharatMoney` & `BharatCurrency`)**:
  - Eliminates IEEE 754 floating-point rounding bugs using integer Paise (`1 Rupee = 100 Paise`).
  - Pre-built NPCI & RBI transaction limit checks (UPI ₹1L standard, ₹2L capital markets, ₹5L tax/institutions; IMPS ₹5L).
  - Indian numbering system (**Lakh / Crore**: `₹1,50,000`), compact scales (`1.5 L`, `2.5 Cr`), and number-to-words in **8 Indian languages**.
- **💳 Payment Cards & RBI Tokenization (`BharatCard` & `BharatCardToken`)**:
  - **RuPay (NPCI)**, Visa, Mastercard, and Amex detection with Luhn (Modulo 10) checksum verification.
  - PCI DSS 4.0 compliant masking and RBI Card-on-File Tokenization (CoFT) models.
- **📱 NPCI UPI Intent & Fraud Defenses (`BharatUpiIntent` & `BharatUpi`)**:
  - Parses and verifies `upi://pay` deep links against parameter tampering, amount limits, and non-INR currency injection.
  - Defends against invisible zero-width spaces, Cyrillic/Greek homoglyphs, and phishing handle patterns.
- **🏦 Indian Bank Accounts & Merged IFSC (`BharatBankAccount` & `BharatIfsc`)**:
  - 9-to-18 digit account validation with bank-specific lengths (SBI, HDFC, ICICI, Axis, PNB, etc.) and timing-safe confirmation matching.
  - Detects defunct merged bank IFSC codes (Allahabad, Syndicate, Oriental, etc.) with migration advisories.
- **🆔 Comprehensive Government, Identity & Corporate IDs (`BharatId`)**:
  - **UIDAI Aadhaar & Virtual ID (VID)**: 12-digit Aadhaar & 16-digit VID with official **Verhoeff checksum** and privacy masking.
  - **MoRTH Driving License (`BharatDrivingLicense`)**: 15/16-char format parsing, state and RTO office lookup, issue year extraction, and auto-hyphenation.
  - **Voter ID (EPIC) & Passport (`BharatVoterId` & `BharatPassport`)**: Standard 10-char ECI Voter IDs and 8-char MEA Passports with privacy masking.
  - **Corporate & MCA Registrations (`BharatCin`, `BharatTan`, `BharatDin`)**: 21-char CIN with listing status, NIC industry, and corporate entity type; 10-char TAN; and 8-digit DIN.
- **🧾 Indian GST & Tax Calculation Engine (`BharatGst`)**:
  - Precision integer Paise arithmetic: automatic **Intra-State** (CGST + SGST equal split) vs **Inter-State** (IGST).
  - Reverse / Inclusive GST calculation extracting taxable base amount and tax components from MRP.
- **📅 Indian Fiscal & Market Settlement Calendar (`BharatFiscal`)**:
  - Indian Financial Year (`FY 2024-25`) and Assessment Year (`AY 2025-26`) resolution (April-March cycle).
  - Advance Tax installment due date schedules (June 15, Sep 15, Dec 15, Mar 15).
  - RBI Bank Holiday calendar with `T+1` and `T+2` market settlement date calculation.
- **⚡ 100% Dependency-Free**: Pure Flutter and Dart. Zero external package conflicts.

---

## 📦 Installation

Add `bharat_fx` to your `pubspec.yaml`:

```yaml
dependencies:
  bharat_fx: ^1.0.6
```

Import the package:

```dart
import 'package:bharat_fx/bharat_fx.dart';
```

---

## 🛡️ Enterprise Fintech Security Walkthrough

### 1. Timing-Safe Equality Checks (Side-Channel Defense)

Standard `==` operations in programming languages abort on the first mismatched byte, creating timing discrepancies that attackers can exploit to recover OTPs, MPINs, or webhook HMAC signatures.

```dart
// Constant-time string comparison
final isValidOtp = TimingSafe.equals(enteredOtp, expectedOtp);

// Constant-time byte array comparison for signature verification
final isSignatureValid = TimingSafe.bytesEquals(calculatedHmacBytes, receivedHmacBytes);
```

### 2. Sensitive Memory Protection & Zeroization (`SensitiveValue`)

Compliant with OWASP MASVS-STORAGE and MASVS-PRIVACY:

```dart
// Wrap sensitive credentials in memory
final mpin = SensitiveValue('4829', label: 'MPIN');

// Prevents accidental logging in console, Sentry, or Firebase
print(mpin); // "[PROTECTED_MPIN]"
print(mpin.toJson()); // "[PROTECTED_MPIN]"

// Access value only when dispatching to secured API
final raw = mpin.reveal();

// Scoped execution
mpin.use((value) {
  paymentService.submit(value);
});

// Securely wipe memory buffers immediately after use
mpin.zeroize();
print(mpin.isDisposed); // true
```

### 3. Comprehensive PII & Financial Data Redactor (`BharatPiiRedactor`)

Complies with the **Digital Personal Data Protection (DPDP) Act 2023** and **UIDAI Privacy Norms**:

```dart
final rawLog = "Customer Aadhaar 234567890124 and PAN ABCPD1234F initiated payment with cvv: 999";

// Automatically sanitizes free text, logs, and crash traces
final cleanLog = BharatSecurity.redactPii(rawLog);
// "Customer Aadhaar XXXX XXXX 0124 and PAN XXXXX1234F initiated payment with cvv: ***"

// Recursively scrubs JSON/Map payloads before sending to telemetry
final telemetryEvent = {
  'user': 'Vikram',
  'mpin': '1234',
  'card_number': '6071231234567890',
  'contact': {'phone': '+91 98765 43210'},
};

final sanitizedPayload = BharatSecurity.redactMap(telemetryEvent);
// Keys like mpin & card_number are replaced with [REDACTED], while phone is masked!
```

### 4. Zero-Dependency Cryptographic Integrity (`BharatHash`)

Calculate SHA-256 hashes, HMAC-SHA256 signatures, and canonical payment gateway checksums (Razorpay, Cashfree, PayU, PhonePe PG, NPCI):

```dart
// SHA-256 (RFC 6234 pure Dart)
final hash = BharatSecurity.sha256("transaction_payload");

// HMAC-SHA256 (RFC 2104)
final signature = BharatSecurity.hmacSha256("api_secret_key", "order_id=123&amount=500.00");

// Canonical parameter signing & constant-time checksum verification
final params = {
  'merchant_id': 'MERCH_99',
  'amount': '1500.00',
  'currency': 'INR',
  'order_id': 'ORD_5544',
};

final checksum = BharatSecurity.signPayload(params, 'secret_key');
final isValid = BharatSecurity.verifyPayload(params, 'secret_key', checksum); // true
```

### 5. Anti-Brute Force Sliding-Window Rate Limiter

```dart
final rateLimiter = BharatSecurity.createRateLimiter(
  maxAttempts: 3,
  window: const Duration(minutes: 5),
);

if (!rateLimiter.recordAttempt(userId)) {
  throw Exception("Too many attempts. Please try again after 5 minutes.");
}
```

---

## 💰 Precision Financial Currency (`BharatMoney` & `BharatCurrency`)

### Exact Fixed-Point Indian Money (`BharatMoney`)

Avoid IEEE 754 floating-point inaccuracies (`0.1 + 0.2 != 0.3`) in financial transactions:

```dart
// Exact Paise arithmetic (1 Rupee = 100 Paise)
final itemPrice = BharatMoney.fromRupees(150.25);
final deliveryFee = BharatMoney.fromRupees(50.75);
final total = itemPrice + deliveryFee;

print(total.inRupees); // 201.0
print(total.inPaise);  // 20100
print(total.format()); // "₹201.00"

// Precision GST calculation (18%)
final subtotal = BharatMoney.fromRupees(1000.00);
final gst = subtotal.percentage(18); // ₹180.00
final grandTotal = subtotal + gst;   // ₹1180.00

// NPCI & RBI Transaction Limit Validations
print(total.isWithinUpiLimit);               // true (<= ₹1,00,000)
print(total.isWithinUpiCapitalMarketsLimit); // true (<= ₹2,00,000)
print(total.isWithinUpiMaxLimit);            // true (<= ₹5,00,000)
print(total.isWithinImpsLimit);              // true (<= ₹5,00,000)

// Safe String Parsing (rejects scientific notation injection)
final parsed = BharatMoney.parse("₹ 1,50,000.50");
```

### Indian Currency Formatter (`BharatCurrency`)

```dart
// Format with Indian comma grouping (2,2,3 grouping)
BharatCurrency.format(150000); // "₹1,50,000"
BharatCurrency.format(10000000, showSymbol: false); // "1,00,00,000"

// Compact Indian notation
BharatCurrency.compact(150000); // "₹1.5 L"
BharatCurrency.compact(25000000); // "₹2.5 Cr"

// Convert numbers into words across 8 Indian languages
BharatCurrency.toWords(15000); // "Fifteen Thousand Rupees Only"
BharatCurrency.toWords(15000, language: BharatLanguage.hindi); // "पंद्रह हज़ार रुपये मात्र"
BharatCurrency.toWords(100000, language: BharatLanguage.tamil); // "ஒரு லட்சம் ரூபாய் மட்டும்"
```

---

## 💳 Cards, Banking, UPI & Government IDs (`BharatId`)

### 1. Payment Cards & RuPay (`BharatCard`)
```dart
// Validates RuPay (NPCI), Visa, Mastercard, Amex with Luhn checksum
final cardResult = BharatId.validateCard("6071231234567890");
print(cardResult.isValid);     // true / false
print(cardResult.isRuPay);     // true (NPCI RuPay network)
print(cardResult.cardType);    // BharatCardType.rupay

// Expiry & CVV
BharatId.validateCardExpiry(12, 2028); // true
BharatId.validateCvv("123", cardType: BharatCardType.rupay); // true

// PCI DSS 4.0 Compliant Masking
BharatId.maskCard("6071231234567890"); // "XXXX-XXXX-XXXX-7890"
BharatId.maskCard("6071231234567890", preserveBin: true); // "6071 23XX XXXX 7890"
```

### 2. Indian Bank Account Number Validator (`BharatBankAccount`)
```dart
// Validates 9-to-18 digit account number with bank-specific length rules
final sbiAccount = BharatId.validateBankAccount("12345678901", bankCode: "SBIN");
print(sbiAccount.isValid); // true (11 digits for SBI)

// Masking per RBI guidelines
BharatId.maskBankAccount("123456789012"); // "XXXXXXXX9012"

// Timing-safe account number matching (prevents confirmation timing leaks)
final matches = BharatId.matchBankAccounts("123456789012", confirmAccountNumber);
```

### 3. NPCI UPI Intent & Deep Link Guard (`BharatUpiIntent`)
```dart
// Validates NPCI UPI Intent URIs against tampering, negative amounts, and non-INR currency
final intent = BharatId.validateUpiIntent(
  "upi://pay?pa=merchant@okhdfcbank&pn=Store&am=500.00&cu=INR"
);
print(intent.isValid); // true
print(intent.amount);  // 500.0

// Secure URI Builder (guarantees strict RFC 3986 percent-encoding)
final secureUri = BharatUpiIntent.buildUri(
  payeeAddress: "merchant@okhdfcbank",
  payeeName: "Store Name",
  amount: 1500.00,
);
```

### 4. Defunct & Merged Bank IFSC Detector (`BharatIfsc`)
```dart
// Flags merged banks and provides RBI migration advice to prevent transfer failures
final ifsc = BharatId.validateIfsc("ALLA0210001");
print(ifsc.isMergedOrDefunct); // true
print(ifsc.successorBankName); // "Indian Bank (IDIB)"
print(ifsc.warningMessage);    // Advisory to use updated successor IFSC
```

### 5. UIDAI Aadhaar & 16-Digit Virtual ID (`BharatAadhaar` & `BharatVid`)
```dart
// 12-Digit Aadhaar with UIDAI Verhoeff Checksum
BharatId.isAadhaar("234567890124"); // true
BharatId.maskAadhaar("234567890124"); // "XXXX XXXX 0124"

// 16-Digit Virtual ID (VID) Mandated by UIDAI for privacy
BharatId.isVid("2345678901234567"); // true
BharatId.maskVid("2345678901234567"); // "XXXX XXXX XXXX 4567"
```

### 6. MoRTH Indian Driving License & RTO Resolver (`BharatDrivingLicense`)
```dart
// Validates 15/16-character MoRTH Driving Licenses and resolves issuing RTO
final dl = BharatId.validateDrivingLicense("DL-01-2020-0012345");
print(dl.isValid);       // true
print(dl.stateName);     // "Delhi"
print(dl.rtoName);       // "Mall Road, North Delhi"
print(dl.issueYear);     // 2020

// Auto-hyphenation and DPDP-compliant privacy masking
BharatId.formatDrivingLicense("DL0120200012345"); // "DL-01-2020-0012345"
BharatId.maskDrivingLicense("DL-01-2020-0012345");   // "DL-01-XXXX-XXX2345"
```

### 7. Voter ID (EPIC) & Indian Passport (`BharatVoterId` & `BharatPassport`)
```dart
// 10-Character ECI Electors Photo Identity Card (Voter ID)
final voterId = BharatId.validateVoterId("ABC1234567");
print(voterId.constituencyCode); // "ABC"
BharatId.maskVoterId("ABC1234567"); // "ABCXXXX567"

// 8-Character Ministry of External Affairs Indian Passport
final passport = BharatId.validatePassport("K1234567");
print(passport.seriesLetter); // "K"
BharatId.maskPassport("K1234567"); // "KXXXXX67"
```

### 8. Corporate MCA Registrations: CIN, TAN, DIN (`BharatCin`, `BharatTan`, `BharatDin`)
```dart
// 21-Character Corporate Identification Number (CIN)
final cin = BharatId.validateCin("U72200KA2020PTC123456");
print(cin.isListed);               // false (Unlisted)
print(cin.stateName);              // "Karnataka"
print(cin.incorporationYear);      // 2020
print(cin.companyTypeDescription); // "Private Limited Company"
BharatId.maskCin("U72200KA2020PTC123456"); // "U72200KA2020XXX123456"

// Tax Deduction Account Number (TAN)
final tan = BharatId.validateTan("DELA12345B");
print(tan.jurisdictionCode); // "DEL"
BharatId.maskTan("DELA12345B"); // "DELXXXXXXB"

// 8-Digit Director Identification Number (DIN)
BharatId.validateDin("00123456"); // true
BharatId.maskDin("00123456");     // "XXXX3456"
```

---

## 🧾 Indian GST & Tax Engine (`BharatGst`)

Eliminate tax discrepancies with exact integer Paise GST calculations:

```dart
final subtotal = BharatMoney.fromRupees(1000.00);

// Intra-state calculation (CGST 9% + SGST 9%)
final intra = BharatGst.calculate(
  taxableAmount: subtotal,
  rate: 18.0,
  isInterState: false,
);
print(intra.cgst);        // ₹90.00
print(intra.sgst);        // ₹90.00
print(intra.totalAmount); // ₹1,180.00

// Auto-detect Inter-state (IGST) using GSTIN state codes
final inter = BharatGst.calculate(
  taxableAmount: subtotal,
  rate: 18.0,
  supplierGstin: '27AAPFU0939F1ZV', // MH
  buyerGstin: '29AAPFU0939F1ZV',    // KA -> Inter-state
);
print(inter.isInterState); // true
print(inter.igst);         // ₹180.00

// Reverse/Inclusive GST (Extract taxable base and tax from ₹1,180 MRP)
final reverse = BharatGst.reverseCalculate(
  grossAmount: BharatMoney.fromRupees(1180.00),
  rate: 18.0,
);
print(reverse.taxableAmount); // ₹1,000.00
print(reverse.totalTax);      // ₹180.00
```

---

## 📑 Indian GST Invoicing, HSN/SAC & e-Invoice QR

Zero-dependency compliance helpers for GST invoice serialization, HSN/SAC classification, and B2B e-invoice QR decoding:

```dart
// 1. HSN (Goods) & SAC (Services) Validation with Offline Chapter Lookup
final hsn = BharatHsn.validate('851712');
print(hsn.isValid);             // true (6 digits)
print(hsn.chapterDescription);  // "Electrical machinery and equipment..."

// Turnover compliance (Notification 78/2020: 4 digits <= ₹5 Cr, 6 digits > ₹5 Cr)
final compliant = BharatHsn.isTurnoverCompliant(
  hsnCode: '8517',
  turnoverInCrores: 3.5, // true (B2B requires min 4 digits)
);

final sac = BharatSac.validate('998314');
print(sac.isValid);         // true (starts with 99)
print(sac.serviceCategory); // "Other professional, technical and business services..."

// 2. CGST Rule 46(b) Tax Invoice Serial Number Validation
// Strictly validates: max 16 chars, allowed chars [A-Za-z0-9/-]
final invCheck = BharatGstInvoice.validateInvoiceNumber('INV/24-25/0001');
print(invCheck.isValid); // true

// Sanitize irregular invoice numbers into compliant format
final cleanInv = BharatGstInvoice.sanitizeInvoiceNumber('INV 2024_01#99');
print(cleanInv); // "INV-2024-01-99"

// 3. Offline B2B e-Invoice QR Code Decoder (Decodes NIC/IRP JWT without network calls)
final qrResult = BharatGstQr.parseEInvoiceQr(scannedQrString);
if (qrResult.isValid) {
  print(qrResult.sellerGstin);        // "27ABCDE1234F1Z5"
  print(qrResult.documentNumber);     // "INV/24-25/0042"
  print(qrResult.totalInvoiceValue);  // 18550.0
  print(qrResult.irn);                // 64-character SHA-256 IRN hash
}
```

---

## 📅 Indian Fiscal Calendar & Settlement (`BharatFiscal`)

```dart
// Indian Financial Year & Assessment Year (April-March cycle)
BharatFiscal.financialYear(date: DateTime(2024, 7, 15)); // "FY 2024-25"
BharatFiscal.assessmentYear(date: DateTime(2024, 7, 15)); // "AY 2025-26"
BharatFiscal.quarter(date: DateTime(2024, 8, 1));        // FiscalQuarter.q2

// Advance Tax Installment Due Dates
final installments = BharatFiscal.advanceTaxDueDates(fiscalStartYear: 2024);
// 15% by 15 June, 45% by 15 Sep, 75% by 15 Dec, 100% by 15 Mar

// RBI Bank Holiday Engine
BharatFiscal.isBankHoliday(DateTime(2024, 8, 15)); // true (Independence Day)
BharatFiscal.isBankHoliday(DateTime(2024, 8, 10)); // true (2nd Saturday)

// T+1 / T+2 Trade Settlement Date (skipping holidays & weekends)
final settlement = BharatFiscal.calculateSettlementDate(
  DateTime(2024, 8, 14), // Wednesday before Aug 15
  settlementDays: 1,
); // Resolves to Friday, Aug 16 (skipping holiday)
```

## 🔒 Hardened Fintech Input Field: `BharatTextField`

A batteries-included `TextFormField` hardened for fintech and sensitive inputs:

```dart
// Card field with RuPay detection and anti-clipboard guard
BharatTextField(
  type: BharatTextFieldType.card,
  onCardResolved: (result) {
    print("Detected: ${result.cardTypeName}");
  },
)

// CVV field (automatically obscured, disables copy/paste, disables cloud predictions)
BharatTextField(
  type: BharatTextFieldType.cvv,
  showObscureToggle: true,
)

// Bank Account field with bank code validation
BharatTextField(
  type: BharatTextFieldType.bankAccount,
  bankCode: 'SBIN',
)

// Aadhaar field with UIDAI Verhoeff validator
BharatTextField(
  type: BharatTextFieldType.aadhaar,
)

// Virtual ID (VID) field
BharatTextField(
  type: BharatTextFieldType.vid,
)

// Precision Fintech Money field
BharatTextField(
  type: BharatTextFieldType.money,
  onMoneyResolved: (money) {
    print("Amount in paise: ${money.inPaise}");
  },
)

// MoRTH Driving License field with RTO resolver
BharatTextField(
  type: BharatTextFieldType.drivingLicense,
  onDrivingLicenseResolved: (dl) {
    print("State: ${dl.stateName}, RTO: ${dl.rtoName}");
  },
)

// Corporate CIN field
BharatTextField(
  type: BharatTextFieldType.cin,
  onCinResolved: (cin) {
    print("Company: ${cin.companyTypeDescription}");
  },
)
```

---

## 🧪 Comprehensive Test Coverage

Every algorithm, cryptographic routine, and security validator is backed by rigorous tests:
- Timing-safe constant-time equality
- SensitiveValue memory zeroization
- Pure-Dart SHA-256 and HMAC-SHA256 against NIST test vectors
- PII and SPII redaction across text and deep maps
- RuPay and credit/debit card Modulo-10 Luhn checksums
- UIDAI Verhoeff checksum algorithm for Aadhaar and Virtual IDs
- Bank-specific account lengths and NPCI UPI Intent parsing

Run tests:

```bash
flutter test
```

---

## 📄 License

This package is released under the **MIT License**. See [LICENSE](LICENSE) for details.
