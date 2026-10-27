/// Utilities for constant-time comparisons to mitigate timing side-channel attacks.
///
/// In fintech environments, standard string or byte equality checks (e.g. `==`)
/// abort immediately on the first differing character or byte. Attackers can
/// measure execution latency (down to microseconds) to infer OTPs, authorization
/// tokens, MPINs, webhook signatures, or API keys character-by-character.
class TimingSafe {
  /// Compares two strings in constant time relative to their length.
  ///
  /// Returns `true` if both strings are equal, `false` otherwise.
  /// Does not leak timing information about the position of mismatched characters.
  static bool equals(String? a, String? b) {
    if (a == null || b == null) {
      return a == b;
    }

    final lenA = a.length;
    final lenB = b.length;
    int diff = lenA ^ lenB;
    final maxLen = lenA > lenB ? lenA : lenB;

    for (int i = 0; i < maxLen; i++) {
      final ca = i < lenA ? a.codeUnitAt(i) : 0;
      final cb = i < lenB ? b.codeUnitAt(i) : 0;
      diff |= ca ^ cb;
    }

    return diff == 0;
  }

  /// Compares two byte lists in constant time relative to their length.
  ///
  /// Essential for verifying HMAC-SHA256 signatures, hashes, and token digests.
  static bool bytesEquals(List<int>? a, List<int>? b) {
    if (a == null || b == null) {
      return a == b;
    }

    final lenA = a.length;
    final lenB = b.length;
    int diff = lenA ^ lenB;
    final maxLen = lenA > lenB ? lenA : lenB;

    for (int i = 0; i < maxLen; i++) {
      final byteA = i < lenA ? a[i] : 0;
      final byteB = i < lenB ? b[i] : 0;
      diff |= byteA ^ byteB;
    }

    return diff == 0;
  }

  /// Compares two integer values in constant time without conditional branch divergence.
  static bool equalsInt(int a, int b) {
    return (a ^ b) == 0;
  }
}
