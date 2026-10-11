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

    final codeUnitsA = a.codeUnits;
    final codeUnitsB = b.codeUnits;

    // If lengths differ, we still iterate through one of them to avoid
    // an early exit that reveals length directly without dummy cycles.
    int diff = codeUnitsA.length ^ codeUnitsB.length;
    final minLength = codeUnitsA.length < codeUnitsB.length
        ? codeUnitsA.length
        : codeUnitsB.length;

    for (int i = 0; i < minLength; i++) {
      diff |= codeUnitsA[i] ^ codeUnitsB[i];
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

    int diff = a.length ^ b.length;
    final minLength = a.length < b.length ? a.length : b.length;

    for (int i = 0; i < minLength; i++) {
      diff |= a[i] ^ b[i];
    }

    return diff == 0;
  }

  /// Compares two integer values in constant time without conditional branch divergence.
  static bool equalsInt(int a, int b) {
    return (a ^ b) == 0;
  }
}
