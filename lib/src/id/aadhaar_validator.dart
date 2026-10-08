/// Validator and masker for 12-digit Indian Aadhaar numbers,
/// utilizing the official Verhoeff checksum algorithm adopted by UIDAI.
class BharatAadhaar {
  // Verhoeff multiplication table (d)
  static const List<List<int>> _d = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
  ];

  // Verhoeff permutation table (p)
  static const List<List<int>> _p = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8]
  ];

  // Verhoeff inverse table (inv)
  static const List<int> _inv = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9];

  /// Validates whether the given string is a valid 12-digit Indian Aadhaar number
  /// using the UIDAI Verhoeff algorithm.
  ///
  /// Rules:
  /// 1. Exactly 12 numeric digits.
  /// 2. Does not start with '0' or '1'.
  /// 3. Passes the Verhoeff checksum.
  static bool validate(String? aadhaar) {
    if (aadhaar == null) return false;
    final digits = aadhaar.replaceAll(RegExp(r'\s+'), '');

    if (digits.length != 12) return false;
    if (!RegExp(r'^[2-9][0-9]{11}$').hasMatch(digits)) return false;

    return validateVerhoeff(digits);
  }

  /// Verifies a number string against the Verhoeff checksum algorithm.
  static bool validateVerhoeff(String number) {
    int c = 0;
    final reversed = number.split('').reversed.map(int.parse).toList();

    for (int i = 0; i < reversed.length; i++) {
      c = _d[c][_p[i % 8][reversed[i]]];
    }

    return c == 0;
  }

  /// Calculates the Verhoeff check digit for any numerical string.
  static int generateVerhoeffCheckDigit(String number) {
    int c = 0;
    final reversed = number.split('').reversed.map(int.parse).toList();

    for (int i = 0; i < reversed.length; i++) {
      c = _d[c][_p[(i + 1) % 8][reversed[i]]];
    }

    return _inv[c];
  }

  /// Masks the Aadhaar number, concealing the first 8 digits as per UIDAI privacy norms.
  ///
  /// Examples:
  /// ```dart
  /// BharatAadhaar.mask("234567890123"); // "XXXX XXXX 0123"
  /// BharatAadhaar.mask("234567890123", maskChar: '•'); // "•••• •••• 0123"
  /// ```
  static String mask(
    String aadhaar, {
    String maskChar = 'X',
    bool preserveSpacing = true,
  }) {
    final digits = aadhaar.replaceAll(RegExp(r'\s+'), '');
    if (digits.length != 12) return aadhaar;

    final maskedHead = maskChar * 8;
    final lastFour = digits.substring(8);

    if (preserveSpacing) {
      return '${maskedHead.substring(0, 4)} ${maskedHead.substring(4, 8)} $lastFour';
    }
    return '$maskedHead$lastFour';
  }

  /// Formats an Aadhaar number into standard 4-digit blocks (`XXXX XXXX XXXX`).
  static String format(String aadhaar) {
    final digits = aadhaar.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 12) return aadhaar;
    return '${digits.substring(0, 4)} ${digits.substring(4, 8)} ${digits.substring(8, 12)}';
  }
}
