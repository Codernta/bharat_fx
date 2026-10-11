import 'dart:typed_data';
import 'input_security.dart';
import 'payload_integrity.dart';
import 'pii_redactor.dart';
import 'sensitive_data.dart';
import 'timing_safe.dart';
import '../id/ifsc_validator.dart';
import '../id/upi_intent.dart';
import '../id/upi_validator.dart';

/// Unified security facade for fintech applications using `bharat_fx`.
///
/// Provides essential security controls:
/// - Side-channel timing attack defense for OTPs, signatures, and tokens.
/// - PII & financial data redaction (UIDAI, RBI, DPDP Act 2023 compliance).
/// - Memory zeroization and non-leaking sensitive wrappers.
/// - Zero-dependency SHA-256 and HMAC payload integrity signing.
/// - NPCI UPI Intent validation and deep-link tampering detection.
/// - Defunct/merged bank IFSC detection.
class BharatSecurity {
  /// Compares two strings in constant time to prevent timing side-channel attacks.
  static bool timingSafeEquals(String? a, String? b) => TimingSafe.equals(a, b);

  /// Compares two byte buffers in constant time.
  static bool timingSafeBytesEquals(List<int>? a, List<int>? b) =>
      TimingSafe.bytesEquals(a, b);

  /// Redacts all financial PII (Aadhaar, PAN, Cards, CVV, Bank Accounts, UPI, Phone)
  /// from raw logs or text strings.
  static String redactPii(String text, {String maskChar = 'X'}) =>
      BharatPiiRedactor.redact(text, maskChar: maskChar);

  /// Recursively scrubs sensitive keys and values from JSON / Map payloads
  /// before transmitting to telemetry, Sentry, or Firebase.
  static Map<String, dynamic> redactMap(
    Map<String, dynamic> map, {
    String maskChar = 'X',
  }) =>
      BharatPiiRedactor.redactMap(map, maskChar: maskChar);

  /// Detects whether free text contains recognizable unmasked financial PII.
  static bool containsPii(String text) => BharatPiiRedactor.containsPii(text);

  /// Computes a SHA-256 hash in pure Dart (zero external dependencies).
  static String sha256(String input) => BharatHash.sha256(input);

  /// Computes a SHA-256 hash of raw byte buffers.
  static Uint8List sha256Bytes(List<int> bytes) =>
      BharatHash.sha256Bytes(bytes);

  /// Computes an HMAC-SHA256 signature according to RFC 2104.
  static String hmacSha256(String key, String message) =>
      BharatHash.hmacSha256(key, message);

  /// Canonicalizes and signs a parameter map using HMAC-SHA256.
  static String signPayload(Map<String, dynamic> params, String secretKey) =>
      BharatHash.generateChecksum(params, secretKey);

  /// Verifies a payment checksum using constant-time comparison.
  static bool verifyPayload(
    Map<String, dynamic> params,
    String secretKey,
    String expectedChecksum,
  ) =>
      BharatHash.verifyChecksum(params, secretKey, expectedChecksum);

  /// Wraps sensitive data (MPIN, CVV, Card Number, Aadhaar) in a secure,
  /// non-leaking memory container that supports zeroization.
  static SensitiveValue<T> protect<T>(
    T value, {
    String label = 'FINANCIAL_DATA',
  }) =>
      SensitiveValue<T>(value, label: label);

  /// Sanitizes a UPI handle, stripping invisible Unicode characters.
  static String sanitizeUpi(String? upiId) => BharatUpi.sanitize(upiId);

  /// Parses and validates an NPCI UPI payment deep link (`upi://pay?...`)
  /// checking for tampering, amount limits, and parameter integrity.
  static UpiIntentValidationResult validateUpiIntent(String? uriString) =>
      BharatUpiIntent.validate(uriString);

  /// Checks if an IFSC code belongs to a merged or defunct bank.
  static bool isDefunctIfsc(String ifsc) => BharatIfsc.isMerged(ifsc);

  /// Creates a rate-limiter to protect authentication and validation endpoints
  /// from brute-force attempts.
  static AntiBruteForceGuard createRateLimiter({
    int maxAttempts = 5,
    Duration window = const Duration(minutes: 5),
  }) =>
      AntiBruteForceGuard(maxAttempts: maxAttempts, window: window);
}
