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
- **🆔 UIDAI Aadhaar & Virtual ID (VID) (`BharatAadhaar` & `BharatVid`)**:
  - 12-digit Aadhaar and 16-digit Virtual ID validation with official UIDAI **Verhoeff checksum**.
  - UIDAI privacy masking (`XXXX XXXX 1234` and `XXXX XXXX XXXX 1234`).
- **⚡ 100% Dependency-Free**: Pure Flutter and Dart. Zero external package conflicts.

---

## 📦 Installation

Add `bharat_fx` to your `pubspec.yaml`:

```yaml
dependencies:
  bharat_fx: ^1.0.3
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

---

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
