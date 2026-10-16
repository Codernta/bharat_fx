import 'bharat_currency.dart';
import 'words_languages.dart';

/// Exact fixed-point representation for Indian currency amounts (Rupees & Paise).
///
/// Eliminates IEEE-754 binary floating-point rounding errors (e.g. `0.1 + 0.2 != 0.3`)
/// by storing all values strictly as integer Paise (`1 Rupee = 100 Paise`).
///
/// Includes:
/// - Exact arithmetic (addition, subtraction, multiplication, division).
/// - RBI & NPCI transaction limit validations (UPI ₹1L/₹5L, IMPS ₹5L).
/// - Protection against `NaN`, `Infinity`, scientific notation, and precision drift.
/// - Seamless formatting and regional language conversion.
class BharatMoney implements Comparable<BharatMoney> {
  final int _paise;

  /// Default zero money.
  static const BharatMoney zero = BharatMoney._(0);

  /// Standard NPCI UPI transaction limit (₹1,00,000 = 10,000,000 Paise).
  static const int upiStandardLimitPaise = 10000000;

  /// NPCI UPI capital markets / tax limit (₹2,00,000 = 20,000,000 Paise).
  static const int upiCapitalMarketsLimitPaise = 20000000;

  /// NPCI UPI educational / hospital limit (₹5,00,000 = 50,000,000 Paise).
  static const int upiMaxLimitPaise = 50000000;

  /// RBI IMPS per-transaction limit (₹5,00,000 = 50,000,000 Paise).
  static const int impsLimitPaise = 50000000;

  const BharatMoney._(this._paise);

  /// Creates a [BharatMoney] instance from an exact integer count of [paise].
  factory BharatMoney.fromPaise(int paise) {
    return BharatMoney._(paise);
  }

  /// Creates a [BharatMoney] instance from [rupees], rounding to exact paise.
  ///
  /// Throws [ArgumentError] if [rupees] is `NaN` or `Infinite`.
  factory BharatMoney.fromRupees(num rupees) {
    if (rupees.isNaN || rupees.isInfinite) {
      throw ArgumentError.value(
        rupees,
        'rupees',
        'Fintech security: Amount cannot be NaN or Infinite.',
      );
    }
    return BharatMoney._((rupees * 100).round());
  }

  /// Total value in integer Paise.
  int get inPaise => _paise;

  /// Value converted to standard decimal Rupees.
  double get inRupees => _paise / 100.0;

  /// Whole Rupee component.
  int get wholeRupees => _paise ~/ 100;

  /// Fractional Paise component (0 - 99).
  int get paiseFraction => _paise.abs() % 100;

  /// Whether the amount is strictly positive.
  bool get isPositive => _paise > 0;

  /// Whether the amount is zero.
  bool get isZero => _paise == 0;

  /// Whether the amount is negative.
  bool get isNegative => _paise < 0;

  /// Safely parses an Indian formatted currency string into exact [BharatMoney].
  ///
  /// Accepts strings like `₹ 1,50,000.50`, `1.5 Lakh`, `2.5 Cr`, or `5000`.
  /// Rejects scientific notation (`1e5`), NaN, or malformed input.
  static BharatMoney? parse(String? input, {bool allowNegative = false}) {
    if (input == null || input.trim().isEmpty) return null;

    final trimmed = input.trim();
    // Reject scientific notation
    if (trimmed.contains('e') || trimmed.contains('E')) return null;

    final parsedVal = BharatCurrency.parse(trimmed);
    if (parsedVal == null || parsedVal.isNaN || parsedVal.isInfinite) {
      return null;
    }

    if (!allowNegative && parsedVal < 0) {
      return null;
    }

    return BharatMoney.fromRupees(parsedVal);
  }

  // --- Arithmetic ---

  BharatMoney operator +(BharatMoney other) {
    return BharatMoney._(_paise + other._paise);
  }

  BharatMoney operator -(BharatMoney other) {
    return BharatMoney._(_paise - other._paise);
  }

  BharatMoney operator *(num factor) {
    if (factor.isNaN || factor.isInfinite) {
      throw ArgumentError('Multiplier cannot be NaN or Infinite');
    }
    return BharatMoney._((_paise * factor).round());
  }

  BharatMoney divide(num divisor) {
    if (divisor == 0) {
      throw UnsupportedError('Division by zero is not supported.');
    }
    if (divisor.isNaN || divisor.isInfinite) {
      throw ArgumentError('Divisor cannot be NaN or Infinite');
    }
    return BharatMoney._((_paise / divisor).round());
  }

  /// Computes a percentage of this amount (e.g. 18 for 18% GST).
  BharatMoney percentage(num percent) {
    return BharatMoney._(((_paise * percent) / 100).round());
  }

  // --- Limit Validations ---

  /// Checks if amount is within standard NPCI UPI limit (₹1,00,000).
  bool get isWithinUpiLimit => _paise >= 0 && _paise <= upiStandardLimitPaise;

  /// Checks if amount is within NPCI UPI capital markets limit (₹2,00,000).
  bool get isWithinUpiCapitalMarketsLimit =>
      _paise >= 0 && _paise <= upiCapitalMarketsLimitPaise;

  /// Checks if amount is within NPCI UPI approved category limit (₹5,00,000).
  bool get isWithinUpiMaxLimit => _paise >= 0 && _paise <= upiMaxLimitPaise;

  /// Checks if amount is within RBI IMPS per-transaction limit (₹5,00,000).
  bool get isWithinImpsLimit => _paise >= 0 && _paise <= impsLimitPaise;

  /// Checks if amount is within a specified [limit].
  bool isWithinLimit(BharatMoney limit) =>
      _paise >= 0 && _paise <= limit._paise;

  // --- Formatting ---

  /// Formats into standard Indian numbering system (`₹1,50,000.00`).
  String format({
    bool showSymbol = true,
    String symbol = BharatCurrency.rupeeSymbol,
    String spaceBetween = '',
    int decimalDigits = 2,
  }) {
    return BharatCurrency.format(
      inRupees,
      showSymbol: showSymbol,
      symbol: symbol,
      spaceBetween: spaceBetween,
      decimalDigits: decimalDigits,
    );
  }

  /// Formats into compact Indian scales (`₹1.5 Lakh`, `₹2.5 Cr`).
  String compact({
    bool showSymbol = true,
    bool shortUnit = true,
    int decimalDigits = 2,
    String spaceBetween = '',
  }) {
    return BharatCurrency.compact(
      inRupees,
      showSymbol: showSymbol,
      shortUnit: shortUnit,
      decimalDigits: decimalDigits,
      spaceBetween: spaceBetween,
    );
  }

  /// Converts this amount into words in Indian languages.
  String toWords({
    BharatLanguage language = BharatLanguage.english,
    bool includeCurrency = true,
    bool includePaise = true,
    bool includeOnly = true,
  }) {
    return BharatCurrency.toWords(
      inRupees,
      language: language,
      includeCurrency: includeCurrency,
      includePaise: includePaise,
      includeOnly: includeOnly,
    );
  }

  // --- Comparison & Identity ---

  @override
  int compareTo(BharatMoney other) => _paise.compareTo(other._paise);

  bool operator <(BharatMoney other) => _paise < other._paise;
  bool operator <=(BharatMoney other) => _paise <= other._paise;
  bool operator >(BharatMoney other) => _paise > other._paise;
  bool operator >=(BharatMoney other) => _paise >= other._paise;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BharatMoney && other._paise == _paise);

  @override
  int get hashCode => _paise.hashCode;

  @override
  String toString() => format();
}
