import 'package:flutter/services.dart';

/// [TextInputFormatter] for 12-digit Indian Aadhaar numbers.
/// Automatically spaces into 4-digit groups: `XXXX XXXX XXXX`.
class BharatAadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digits.length > 12 ? digits.substring(0, 12) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(truncated[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// [TextInputFormatter] for Indian PAN card input.
/// Enforces uppercase and maximum 10 alphanumeric characters.
class BharatPanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final uppercase = newValue.text.toUpperCase().replaceAll(
          RegExp(r'[^A-Z0-9]'),
          '',
        );
    final truncated =
        uppercase.length > 10 ? uppercase.substring(0, 10) : uppercase;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}

/// [TextInputFormatter] for UPI IDs.
/// Restricts to valid UPI character set and converts to lowercase.
class BharatUpiInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final cleaned = newValue.text.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9.\-_@]'),
          '',
        );

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}

/// [TextInputFormatter] for Indian GSTIN (15 characters, uppercase).
class BharatGstinInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final uppercase = newValue.text.toUpperCase().replaceAll(
          RegExp(r'[^A-Z0-9]'),
          '',
        );
    final truncated =
        uppercase.length > 15 ? uppercase.substring(0, 15) : uppercase;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}

/// [TextInputFormatter] for Indian IFSC codes (11 characters, uppercase).
class BharatIfscInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final uppercase = newValue.text.toUpperCase().replaceAll(
          RegExp(r'[^A-Z0-9]'),
          '',
        );
    final truncated =
        uppercase.length > 11 ? uppercase.substring(0, 11) : uppercase;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}

/// [TextInputFormatter] for 10-digit Indian Mobile Numbers (e.g. `98765 43210`).
class BharatPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digits.length > 10 ? digits.substring(0, 10) : digits;

    if (truncated.length <= 5) {
      return TextEditingValue(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
    }

    final formatted = '${truncated.substring(0, 5)} ${truncated.substring(5)}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// [TextInputFormatter] for 16-digit UIDAI Virtual IDs (VID).
/// Formats into 4-digit groups: `XXXX XXXX XXXX XXXX`.
class BharatVidInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digits.length > 16 ? digits.substring(0, 16) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(truncated[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// [TextInputFormatter] for payment cards (RuPay, Visa, Mastercard, Amex).
/// Formats into 4-digit blocks up to 19 digits.
class BharatCardInputFormatter extends TextInputFormatter {
  final int maxDigits;

  BharatCardInputFormatter({this.maxDigits = 19});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated =
        digits.length > maxDigits ? digits.substring(0, maxDigits) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(truncated[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// [TextInputFormatter] for Indian bank account numbers (digits only, max 18).
class BharatBankAccountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digits.length > 18 ? digits.substring(0, 18) : digits;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}

/// [TextInputFormatter] for CVV / CVC input (digits only, max 4).
class BharatCvvInputFormatter extends TextInputFormatter {
  final int maxDigits;

  BharatCvvInputFormatter({this.maxDigits = 4});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated =
        digits.length > maxDigits ? digits.substring(0, maxDigits) : digits;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}

/// [TextInputFormatter] for MoRTH Indian Driving License.
/// Automatically hyphens into `SS-RR-YYYY-NNNNNNN`.
class BharatDrivingLicenseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final clean =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final truncated = clean.length > 15 ? clean.substring(0, 15) : clean;

    final buffer = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i == 2 || i == 4 || i == 8) {
        buffer.write('-');
      }
      buffer.write(truncated[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// [TextInputFormatter] for Indian Voter ID / EPIC (max 10 alphanumeric, uppercase).
class BharatVoterIdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final clean =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final truncated = clean.length > 10 ? clean.substring(0, 10) : clean;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}

/// [TextInputFormatter] for Indian Passport (max 8 alphanumeric, uppercase).
class BharatPassportInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final clean =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final truncated = clean.length > 8 ? clean.substring(0, 8) : clean;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}

/// [TextInputFormatter] for Corporate Identification Number (max 21 alphanumeric, uppercase).
class BharatCinInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final clean =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final truncated = clean.length > 21 ? clean.substring(0, 21) : clean;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}

/// [TextInputFormatter] for Tax Deduction Account Number (max 10 alphanumeric, uppercase).
class BharatTanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final clean =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final truncated = clean.length > 10 ? clean.substring(0, 10) : clean;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}

/// [TextInputFormatter] for Director Identification Number (max 8 digits).
class BharatDinInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final clean = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = clean.length > 8 ? clean.substring(0, 8) : clean;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}
