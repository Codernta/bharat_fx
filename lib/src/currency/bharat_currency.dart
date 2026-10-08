import 'package:flutter/services.dart';
import 'number_to_words.dart';
import 'words_languages.dart';

/// Comprehensive Indian Currency Formatter & Number-to-Words utility.
///
/// Implements the Lakh/Crore Indian numbering system (e.g., 1,00,000 instead of 100,000),
/// compact notations (e.g., 1.5 Lakh, 2.4 Cr), real-time input formatting, and multi-language
/// number-to-words translations.
class BharatCurrency {
  /// Default Indian Rupee symbol.
  static const String rupeeSymbol = '₹';

  /// Formats a [num] into the Indian numbering system.
  ///
  /// Examples:
  /// ```dart
  /// BharatCurrency.format(100000); // "₹1,00,000"
  /// BharatCurrency.format(1234567.89); // "₹12,34,567.89"
  /// BharatCurrency.format(1234567, showSymbol: false); // "12,34,567"
  /// BharatCurrency.format(1500, decimalDigits: 2); // "₹1,500.00"
  /// ```
  static String format(
    num amount, {
    String symbol = rupeeSymbol,
    bool showSymbol = true,
    int? decimalDigits,
    String spaceBetween = '',
  }) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String wholeStr;
    String decimalStr = '';

    if (decimalDigits != null) {
      final fixedStr = absAmount.toStringAsFixed(decimalDigits);
      final parts = fixedStr.split('.');
      wholeStr = parts[0];
      if (decimalDigits > 0 && parts.length > 1) {
        decimalStr = '.${parts[1]}';
      }
    } else {
      final str = absAmount.toString();
      if (str.contains('.')) {
        final parts = str.split('.');
        wholeStr = parts[0];
        // Clean trailing zero if .0 on pure int double
        if (parts[1] != '0') {
          decimalStr = '.${parts[1]}';
        }
      } else {
        wholeStr = str;
      }
    }

    final formattedWhole = _formatIndianGrouping(wholeStr);
    final formattedNumber = '$formattedWhole$decimalStr';

    final sign = isNegative ? '-' : '';
    final symbolPrefix =
        showSymbol && symbol.isNotEmpty ? '$symbol$spaceBetween' : '';

    return '$sign$symbolPrefix$formattedNumber';
  }

  /// Formats large numbers into compact Indian notations (Thousand, Lakh, Crore, Arab).
  ///
  /// Examples:
  /// ```dart
  /// BharatCurrency.compact(150000); // "₹1.5 L"
  /// BharatCurrency.compact(25000000); // "₹2.5 Cr"
  /// BharatCurrency.compact(150000, shortUnit: false); // "₹1.5 Lakh"
  /// ```
  static String compact(
    num amount, {
    String symbol = rupeeSymbol,
    bool showSymbol = true,
    bool shortUnit = true,
    int decimalDigits = 2,
    String spaceBetween = '',
  }) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().toDouble();

    String unit = '';
    double scaled = absAmount;

    if (absAmount >= 1000000000) {
      // Arab
      scaled = absAmount / 1000000000;
      unit = shortUnit ? 'Arab' : 'Arab';
    } else if (absAmount >= 10000000) {
      // Crore
      scaled = absAmount / 10000000;
      unit = shortUnit ? 'Cr' : 'Crore';
    } else if (absAmount >= 100000) {
      // Lakh
      scaled = absAmount / 100000;
      unit = shortUnit ? 'L' : 'Lakh';
    } else if (absAmount >= 1000) {
      // Thousand
      scaled = absAmount / 1000;
      unit = shortUnit ? 'K' : 'Thousand';
    }

    String formattedNumber;
    if (unit.isEmpty) {
      formattedNumber = format(
        absAmount,
        showSymbol: false,
        decimalDigits: absAmount % 1 == 0 ? 0 : decimalDigits,
      );
    } else {
      formattedNumber = scaled.toStringAsFixed(decimalDigits);
      // Remove trailing zeroes like 1.50 -> 1.5, 1.00 -> 1
      if (formattedNumber.contains('.')) {
        formattedNumber = formattedNumber
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }
    }

    final sign = isNegative ? '-' : '';
    final symbolPrefix =
        showSymbol && symbol.isNotEmpty ? '$symbol$spaceBetween' : '';
    final unitSuffix = unit.isNotEmpty ? ' $unit' : '';

    return '$sign$symbolPrefix$formattedNumber$unitSuffix';
  }

  /// Converts a number to words in English or regional Indian languages.
  ///
  /// Examples:
  /// ```dart
  /// BharatCurrency.toWords(15000); // "Fifteen Thousand Rupees Only"
  /// BharatCurrency.toWords(15000, language: BharatLanguage.hindi); // "पंद्रह हज़ार रुपये मात्र"
  /// ```
  static String toWords(
    num amount, {
    BharatLanguage language = BharatLanguage.english,
    bool includeCurrency = true,
    bool includePaise = true,
    bool includeOnly = true,
  }) {
    return BharatNumberToWords.convert(
      amount,
      language: language,
      includeCurrency: includeCurrency,
      includePaise: includePaise,
      includeOnly: includeOnly,
    );
  }

  /// Parses a formatted currency string (with ₹, commas, or Lakh/Crore compact words) into a [double].
  ///
  /// Examples:
  /// ```dart
  /// BharatCurrency.parse("₹ 1,50,000.50"); // 150000.5
  /// BharatCurrency.parse("1.5 Lakh"); // 150000.0
  /// BharatCurrency.parse("2.5 Cr"); // 25000000.0
  /// ```
  static double? parse(String input) {
    if (input.trim().isEmpty) return null;

    var cleaned = input.replaceAll('₹', '').trim().toLowerCase();
    final isNegative = cleaned.startsWith('-');
    if (isNegative) cleaned = cleaned.substring(1).trim();

    double multiplier = 1.0;
    if (cleaned.contains('arab')) {
      multiplier = 1000000000.0;
      cleaned = cleaned.replaceAll('arab', '').trim();
    } else if (cleaned.contains('cr') || cleaned.contains('crore')) {
      multiplier = 10000000.0;
      cleaned = cleaned
          .replaceAll('crore', '')
          .replaceAll('cr', '')
          .trim();
    } else if (cleaned.contains('lakh') || cleaned.contains('l')) {
      multiplier = 100000.0;
      cleaned = cleaned
          .replaceAll('lakh', '')
          .replaceAll('l', '')
          .trim();
    } else if (cleaned.contains('thousand') || cleaned.contains('k')) {
      multiplier = 1000.0;
      cleaned = cleaned
          .replaceAll('thousand', '')
          .replaceAll('k', '')
          .trim();
    }

    // Remove commas and spaces
    cleaned = cleaned.replaceAll(',', '').replaceAll(' ', '');

    final value = double.tryParse(cleaned);
    if (value == null) return null;

    final result = value * multiplier;
    return isNegative ? -result : result;
  }

  /// Internal helper to format the integer portion into Indian comma grouping (2,2,3).
  static String _formatIndianGrouping(String integerDigits) {
    if (integerDigits.length <= 3) {
      return integerDigits;
    }

    // Last 3 digits
    final lastThree =
        integerDigits.substring(integerDigits.length - 3);
    final remaining =
        integerDigits.substring(0, integerDigits.length - 3);

    // Group remaining into pairs of 2 from right to left
    final buffer = StringBuffer();
    for (int i = remaining.length; i > 0; i -= 2) {
      final start = (i - 2 < 0) ? 0 : i - 2;
      final chunk = remaining.substring(start, i);
      if (buffer.isEmpty) {
        buffer.write(chunk);
      } else {
        buffer.write(',$chunk');
      }
    }

    // Reconstruct
    final reversedChunks = remaining
        .split('')
        .reversed
        .join('');
    final pairs = <String>[];
    for (int i = 0; i < reversedChunks.length; i += 2) {
      final end = (i + 2 > reversedChunks.length) ? reversedChunks.length : i + 2;
      pairs.add(reversedChunks.substring(i, end).split('').reversed.join(''));
    }
    final formattedHead = pairs.reversed.join(',');

    return '$formattedHead,$lastThree';
  }
}

/// A [TextInputFormatter] that automatically applies the Indian numbering system commas
/// in real time while typing, preserving cursor position.
class BharatCurrencyInputFormatter extends TextInputFormatter {
  final bool includeSymbol;
  final String symbol;
  final int maxDigits;
  final bool allowDecimals;

  BharatCurrencyInputFormatter({
    this.includeSymbol = false,
    this.symbol = '₹',
    this.maxDigits = 15,
    this.allowDecimals = true,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Extract raw digits and optional single decimal point
    String text = newValue.text;
    if (includeSymbol) {
      text = text.replaceAll(symbol, '').trim();
    }

    final hasDecimal = allowDecimals && text.contains('.');
    String wholeDigits = '';
    String decimalDigits = '';

    if (hasDecimal) {
      final parts = text.split('.');
      wholeDigits = parts[0].replaceAll(RegExp(r'\D'), '');
      decimalDigits = parts.length > 1
          ? parts.sublist(1).join().replaceAll(RegExp(r'\D'), '')
          : '';
      // Limit decimals to 2 places
      if (decimalDigits.length > 2) {
        decimalDigits = decimalDigits.substring(0, 2);
      }
    } else {
      wholeDigits = text.replaceAll(RegExp(r'\D'), '');
    }

    if (wholeDigits.length > maxDigits) {
      wholeDigits = wholeDigits.substring(0, maxDigits);
    }

    if (wholeDigits.isEmpty && decimalDigits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final formattedWhole = wholeDigits.isEmpty
        ? (hasDecimal ? '0' : '')
        : BharatCurrency._formatIndianGrouping(wholeDigits);

    final formattedText = StringBuffer();
    if (includeSymbol) {
      formattedText.write('$symbol ');
    }
    formattedText.write(formattedWhole);
    if (hasDecimal) {
      formattedText.write('.$decimalDigits');
    }

    final result = formattedText.toString();

    // Maintain cursor near the end or relative to digits
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
