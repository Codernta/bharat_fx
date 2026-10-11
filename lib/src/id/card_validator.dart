/// Indian & International card schemes.
enum BharatCardType {
  rupay,
  visa,
  mastercard,
  amex,
  dinersClub,
  discover,
  unknown,
}

/// Standard Luhn algorithm (Modulo 10) checksum validator used by credit & debit cards worldwide.
class LuhnAlgorithm {
  /// Validates a numerical card number string against the Luhn checksum.
  static bool validate(String? number) {
    if (number == null) return false;
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 12 || digits.length > 19) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }
      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Calculates the Luhn check digit for an incomplete numerical string.
  static int generateCheckDigit(String numberWithoutCheck) {
    final digits = numberWithoutCheck.replaceAll(RegExp(r'\D'), '');
    int sum = 0;
    bool alternate = true;

    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }
      sum += n;
      alternate = !alternate;
    }

    final mod = sum % 10;
    return mod == 0 ? 0 : 10 - mod;
  }
}

/// Validation result for payment cards.
class CardValidationResult {
  final String cardNumber;
  final bool isValid;
  final BharatCardType cardType;
  final String cardTypeName;
  final bool isRuPay;
  final String? lastFour;
  final bool isLuhnValid;
  final String? errorMessage;

  const CardValidationResult({
    required this.cardNumber,
    required this.isValid,
    this.cardType = BharatCardType.unknown,
    this.cardTypeName = 'Unknown',
    this.isRuPay = false,
    this.lastFour,
    this.isLuhnValid = false,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'CardValidationResult(type: $cardTypeName, valid: $isValid, isRuPay: $isRuPay, last4: $lastFour)';
  }
}

/// Validator, identifier, and PCI DSS 4.0 compliant masker for Indian RuPay,
/// Visa, Mastercard, and other payment cards.
class BharatCard {
  /// Determines the card network / scheme based on BIN prefix.
  ///
  /// Specialized support for NPCI RuPay ranges (60, 65, 81, 82, 508, 353, 356).
  static BharatCardType getCardType(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return BharatCardType.unknown;

    // RuPay checks (NPCI domestic card network)
    if (digits.startsWith('60') ||
        digits.startsWith('508') ||
        digits.startsWith('81') ||
        digits.startsWith('82') ||
        digits.startsWith('353') ||
        digits.startsWith('356')) {
      return BharatCardType.rupay;
    }
    if (digits.length >= 6) {
      final prefix6 = int.tryParse(digits.substring(0, 6));
      if (prefix6 != null && prefix6 >= 652150 && prefix6 <= 652200) {
        return BharatCardType.rupay;
      }
    }

    // Visa (starts with 4)
    if (digits.startsWith('4')) {
      return BharatCardType.visa;
    }

    // Mastercard (51-55 or 2221-2720)
    if (digits.length >= 2) {
      final prefix2 = int.tryParse(digits.substring(0, 2));
      if (prefix2 != null && prefix2 >= 51 && prefix2 <= 55) {
        return BharatCardType.mastercard;
      }
    }
    if (digits.length >= 4) {
      final prefix4 = int.tryParse(digits.substring(0, 4));
      if (prefix4 != null && prefix4 >= 2221 && prefix4 <= 2720) {
        return BharatCardType.mastercard;
      }
    }

    // American Express (34 or 37, 15 digits)
    if (digits.startsWith('34') || digits.startsWith('37')) {
      return BharatCardType.amex;
    }

    // Diners Club (300-305, 36, 38)
    if (digits.startsWith('36') || digits.startsWith('38')) {
      return BharatCardType.dinersClub;
    }
    if (digits.length >= 3) {
      final prefix3 = int.tryParse(digits.substring(0, 3));
      if (prefix3 != null && prefix3 >= 300 && prefix3 <= 305) {
        return BharatCardType.dinersClub;
      }
    }

    // Discover (6011, 644-649, 65)
    if (digits.startsWith('6011') || digits.startsWith('65')) {
      return BharatCardType.discover;
    }

    return BharatCardType.unknown;
  }

  /// Validates a debit or credit card number.
  ///
  /// Checks length constraints, network scheme, and Luhn algorithm.
  static CardValidationResult validate(String? cardNumber) {
    if (cardNumber == null || cardNumber.trim().isEmpty) {
      return const CardValidationResult(
        cardNumber: '',
        isValid: false,
        errorMessage: 'Card number cannot be empty',
      );
    }

    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 13 || digits.length > 19) {
      return CardValidationResult(
        cardNumber: digits,
        isValid: false,
        errorMessage: 'Invalid card length (must be between 13 and 19 digits)',
      );
    }

    final isLuhn = LuhnAlgorithm.validate(digits);
    if (!isLuhn) {
      return CardValidationResult(
        cardNumber: digits,
        isValid: false,
        isLuhnValid: false,
        errorMessage: 'Card number failed Luhn checksum validation',
      );
    }

    final type = getCardType(digits);
    final lastFour = digits.substring(digits.length - 4);
    final isRuPay = type == BharatCardType.rupay;

    final typeName = switch (type) {
      BharatCardType.rupay => 'RuPay',
      BharatCardType.visa => 'Visa',
      BharatCardType.mastercard => 'Mastercard',
      BharatCardType.amex => 'American Express',
      BharatCardType.dinersClub => 'Diners Club',
      BharatCardType.discover => 'Discover',
      BharatCardType.unknown => 'Unknown',
    };

    return CardValidationResult(
      cardNumber: digits,
      isValid: true,
      cardType: type,
      cardTypeName: typeName,
      isRuPay: isRuPay,
      lastFour: lastFour,
      isLuhnValid: true,
    );
  }

  /// Validates a card expiration date.
  ///
  /// [month] must be between 1 and 12.
  /// [year] can be 2-digit (YY) or 4-digit (YYYY).
  static bool validateExpiry(int month, int year) {
    if (month < 1 || month > 12) return false;

    final now = DateTime.now();
    final fullYear = year < 100 ? 2000 + year : year;

    // Check not expired (expires at end of stated month)
    if (fullYear < now.year) return false;
    if (fullYear == now.year && month < now.month) return false;

    // Not excessively in future (e.g. max 25 years)
    if (fullYear > now.year + 25) return false;

    return true;
  }

  /// Validates an expiration string formatted as `MM/YY` or `MM/YYYY`.
  static bool validateExpiryString(String? expiry) {
    if (expiry == null || expiry.trim().isEmpty) return false;
    final parts = expiry.trim().split(RegExp(r'[/\-]'));
    if (parts.length != 2) return false;

    final month = int.tryParse(parts[0].trim());
    final year = int.tryParse(parts[1].trim());

    if (month == null || year == null) return false;
    return validateExpiry(month, year);
  }

  /// Validates a CVV / CVC code.
  ///
  /// Requires 3 digits for RuPay, Visa, Mastercard; 4 digits for American Express.
  static bool validateCvv(String? cvv, {BharatCardType? cardType}) {
    if (cvv == null) return false;
    final clean = cvv.trim();
    if (!RegExp(r'^\d+$').hasMatch(clean)) return false;

    if (cardType == BharatCardType.amex) {
      return clean.length == 4;
    }
    return clean.length == 3;
  }

  /// Masks a card number compliant with PCI DSS 4.0 regulations.
  ///
  /// Default formats:
  /// - Standard: `XXXX-XXXX-XXXX-1234`
  /// - BIN-Preserving (first 6 and last 4): `6071 23XX XXXX 1234`
  static String mask(
    String cardNumber, {
    String maskChar = 'X',
    bool preserveBin = false,
  }) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 12) return cardNumber;

    final lastFour = digits.substring(digits.length - 4);

    if (preserveBin && digits.length >= 10) {
      final bin = digits.substring(0, 6);
      final middleMask = maskChar * (digits.length - 10);
      final formattedMiddle = middleMask.length > 4
          ? '${middleMask.substring(0, 4)} ${middleMask.substring(4)}'
          : middleMask;
      return '${bin.substring(0, 4)} ${bin.substring(4, 6)}$formattedMiddle $lastFour';
    }

    final maskPart = maskChar * 4;
    return '$maskPart-$maskPart-$maskPart-$lastFour';
  }

  /// Formats a card number into 4-digit spaced groups.
  static String format(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }
}
