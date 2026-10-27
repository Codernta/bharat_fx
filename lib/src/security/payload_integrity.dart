import 'dart:convert';
import 'dart:typed_data';
import 'timing_safe.dart';

/// Cryptographic hashing and HMAC utilities in pure Dart (zero external dependencies).
///
/// Designed for Indian fintech workflows:
/// - Request signing & checksum verification (e.g. Razorpay, Cashfree, PayU, PhonePe PG, NPCI).
/// - Constant-time HMAC comparison to prevent timing attacks.
/// - Canonical query string parameter serialization.
class BharatHash {
  static const List<int> _k = [
    0x428a2f98,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2,
  ];

  static int _rotr(int x, int n) => ((x >>> n) | (x << (32 - n))) & 0xFFFFFFFF;

  /// Computes the SHA-256 hash of a string (UTF-8 encoded) and returns a lowercase hex string.
  static String sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256Bytes(bytes);
    return _bytesToHex(digest);
  }

  /// Computes the SHA-256 hash of raw byte input and returns a 32-byte [Uint8List].
  static Uint8List sha256Bytes(List<int> bytes) {
    int h0 = 0x6a09e667;
    int h1 = 0xbb67ae85;
    int h2 = 0x3c6ef372;
    int h3 = 0xa54ff53a;
    int h4 = 0x510e527f;
    int h5 = 0x9b05688c;
    int h6 = 0x1f83d9ab;
    int h7 = 0x5be0cd19;

    final length = bytes.length;
    final bitLength = length * 8;

    // Padding
    final remainder = (length + 9) % 64;
    final padLength = remainder == 0 ? 0 : 64 - remainder;
    final totalLength = length + 1 + padLength + 8;

    final padded = Uint8List(totalLength);
    padded.setRange(0, length, bytes);
    padded[length] = 0x80;

    // Append 64-bit big-endian length
    final byteData = ByteData.sublistView(padded);
    byteData.setUint64(totalLength - 8, bitLength, Endian.big);

    final w = Uint32List(64);

    for (int chunk = 0; chunk < totalLength; chunk += 64) {
      for (int i = 0; i < 16; i++) {
        w[i] = byteData.getUint32(chunk + (i * 4), Endian.big);
      }

      for (int i = 16; i < 64; i++) {
        final s0 =
            _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >>> 3);
        final s1 =
            _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >>> 10);
        w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xFFFFFFFF;
      }

      int a = h0;
      int b = h1;
      int c = h2;
      int d = h3;
      int e = h4;
      int f = h5;
      int g = h6;
      int h = h7;

      for (int i = 0; i < 64; i++) {
        final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
        final ch = (e & f) ^ ((~e) & g);
        final temp1 = (h + s1 + ch + _k[i] + w[i]) & 0xFFFFFFFF;
        final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = (s0 + maj) & 0xFFFFFFFF;

        h = g;
        g = f;
        f = e;
        e = (d + temp1) & 0xFFFFFFFF;
        d = c;
        c = b;
        b = a;
        a = (temp1 + temp2) & 0xFFFFFFFF;
      }

      h0 = (h0 + a) & 0xFFFFFFFF;
      h1 = (h1 + b) & 0xFFFFFFFF;
      h2 = (h2 + c) & 0xFFFFFFFF;
      h3 = (h3 + d) & 0xFFFFFFFF;
      h4 = (h4 + e) & 0xFFFFFFFF;
      h5 = (h5 + f) & 0xFFFFFFFF;
      h6 = (h6 + g) & 0xFFFFFFFF;
      h7 = (h7 + h) & 0xFFFFFFFF;
    }

    final out = Uint8List(32);
    final outData = ByteData.sublistView(out);
    outData.setUint32(0, h0, Endian.big);
    outData.setUint32(4, h1, Endian.big);
    outData.setUint32(8, h2, Endian.big);
    outData.setUint32(12, h3, Endian.big);
    outData.setUint32(16, h4, Endian.big);
    outData.setUint32(20, h5, Endian.big);
    outData.setUint32(24, h6, Endian.big);
    outData.setUint32(28, h7, Endian.big);

    return out;
  }

  /// Computes HMAC-SHA256 according to RFC 2104.
  ///
  /// Returns the digest as a lowercase hex string.
  static String hmacSha256(String key, String message) {
    final keyBytes = utf8.encode(key);
    final msgBytes = utf8.encode(message);
    final digest = hmacSha256Bytes(keyBytes, msgBytes);
    return _bytesToHex(digest);
  }

  /// Computes HMAC-SHA256 over raw byte inputs and returns a 32-byte [Uint8List].
  static Uint8List hmacSha256Bytes(List<int> key, List<int> message) {
    const blockSize = 64;
    Uint8List effectiveKey = Uint8List(blockSize);

    if (key.length > blockSize) {
      final hashedKey = sha256Bytes(key);
      effectiveKey.setRange(0, hashedKey.length, hashedKey);
    } else {
      effectiveKey.setRange(0, key.length, key);
    }

    final kIpad = Uint8List(blockSize);
    final kOpad = Uint8List(blockSize);

    for (int i = 0; i < blockSize; i++) {
      kIpad[i] = effectiveKey[i] ^ 0x36;
      kOpad[i] = effectiveKey[i] ^ 0x5C;
    }

    final inner = Uint8List(kIpad.length + message.length);
    inner.setRange(0, kIpad.length, kIpad);
    inner.setRange(kIpad.length, inner.length, message);
    final innerHash = sha256Bytes(inner);

    final outer = Uint8List(kOpad.length + innerHash.length);
    outer.setRange(0, kOpad.length, kOpad);
    outer.setRange(kOpad.length, outer.length, innerHash);

    final result = sha256Bytes(outer);

    // Cryptographic zeroization: clear intermediate key buffers from memory
    effectiveKey.fillRange(0, effectiveKey.length, 0);
    kIpad.fillRange(0, kIpad.length, 0);
    kOpad.fillRange(0, kOpad.length, 0);
    inner.fillRange(0, inner.length, 0);
    outer.fillRange(0, outer.length, 0);

    return result;
  }

  /// Serializes a map of parameters into a canonical query string sorted alphabetically by key.
  ///
  /// Standard format utilized across Indian payment gateways:
  /// `amount=1500&currency=INR&order_id=ord_123`
  static String canonicalize(Map<String, dynamic> params) {
    final sortedKeys = params.keys.toList()..sort();
    final buffer = StringBuffer();

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final val = params[key];
      if (val == null) continue;

      if (buffer.isNotEmpty) {
        buffer.write('&');
      }
      buffer.write('$key=$val');
    }

    return buffer.toString();
  }

  /// Generates a HMAC-SHA256 checksum for a parameter payload using [secretKey].
  ///
  /// 1. Canonicalizes the map alphabetically.
  /// 2. Signs the string with HMAC-SHA256.
  static String generateChecksum(
    Map<String, dynamic> params,
    String secretKey,
  ) {
    final payload = canonicalize(params);
    return hmacSha256(secretKey, payload);
  }

  /// Verifies a received payment [checksum] against computed HMAC-SHA256 in constant time.
  ///
  /// Prevents timing attacks on signature validation.
  static bool verifyChecksum(
    Map<String, dynamic> params,
    String secretKey,
    String expectedChecksum,
  ) {
    final computed = generateChecksum(params, secretKey);
    return TimingSafe.equals(
      computed.toLowerCase(),
      expectedChecksum.toLowerCase().trim(),
    );
  }

  static String _bytesToHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
