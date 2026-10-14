import 'bharat_money.dart';

/// Standard Indian GST tax rate brackets.
enum GstRate {
  /// Nil / Exempt rate (0%).
  zero(0.0),

  /// Concessional rate for essential commodities (5%).
  five(5.0),

  /// Standard lower slab (12%).
  twelve(12.0),

  /// Standard upper slab (18%).
  eighteen(18.0),

  /// Luxury and demerit goods slab (28%).
  twentyEight(28.0);

  final double percentage;
  const GstRate(this.percentage);
}

/// Detailed itemized tax breakdown of a GST calculation.
class GstBreakdown {
  /// Taxable base amount before GST.
  final BharatMoney taxableAmount;

  /// Effective GST percentage applied (e.g. 18.0).
  final double ratePercentage;

  /// True if transaction is inter-state (IGST), false if intra-state (CGST + SGST).
  final bool isInterState;

  /// Central GST component (0 if inter-state).
  final BharatMoney cgst;

  /// State / UT GST component (0 if inter-state).
  final BharatMoney sgst;

  /// Integrated GST component (0 if intra-state).
  final BharatMoney igst;

  /// Total GST levied (CGST + SGST or IGST).
  final BharatMoney totalTax;

  /// Grand total inclusive of GST (Taxable Amount + Total Tax).
  final BharatMoney totalAmount;

  /// Supplier state name if resolvable.
  final String? supplierState;

  /// Buyer / Recipient state name if resolvable.
  final String? buyerState;

  const GstBreakdown({
    required this.taxableAmount,
    required this.ratePercentage,
    required this.isInterState,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalTax,
    required this.totalAmount,
    this.supplierState,
    this.buyerState,
  });

  @override
  String toString() {
    return 'GstBreakdown(taxable: ${taxableAmount.format()}, tax: ${totalTax.format()}, total: ${totalAmount.format()}, interState: $isInterState)';
  }
}

/// Indian Goods and Services Tax (GST) Calculator & Tax Engine.
///
/// Features:
/// - Precise integer Paise arithmetic without IEEE-754 floating point rounding errors.
/// - Automatic tax bifurcation: Intra-State (50% CGST + 50% SGST) vs Inter-State (100% IGST).
/// - Automatic state code resolution from GSTIN or 2-digit GST state codes.
/// - Forward GST calculation (tax added onto base amount).
/// - Reverse / Inclusive GST calculation (extract base price and tax from gross MRP).
class BharatGst {
  /// Official 2-digit Indian GST State / UT code registry.
  static const Map<String, String> stateCodes = {
    '01': 'Jammu and Kashmir',
    '02': 'Himachal Pradesh',
    '03': 'Punjab',
    '04': 'Chandigarh',
    '05': 'Uttarakhand',
    '06': 'Haryana',
    '07': 'Delhi',
    '08': 'Rajasthan',
    '09': 'Uttar Pradesh',
    '10': 'Bihar',
    '11': 'Sikkim',
    '12': 'Arunachal Pradesh',
    '13': 'Nagaland',
    '14': 'Manipur',
    '15': 'Mizoram',
    '16': 'Tripura',
    '17': 'Meghalaya',
    '18': 'Assam',
    '19': 'West Bengal',
    '20': 'Jharkhand',
    '21': 'Odisha',
    '22': 'Chhattisgarh',
    '23': 'Madhya Pradesh',
    '24': 'Gujarat',
    '26': 'Dadra and Nagar Haveli and Daman and Diu',
    '27': 'Maharashtra',
    '28': 'Andhra Pradesh',
    '29': 'Karnataka',
    '30': 'Goa',
    '31': 'Lakshadweep',
    '32': 'Kerala',
    '33': 'Tamil Nadu',
    '34': 'Puducherry',
    '35': 'Andaman and Nicobar Islands',
    '36': 'Telangana',
    '37': 'Andhra Pradesh',
    '38': 'Ladakh',
    '97': 'Other Territory',
    '99': 'Centre Jurisdiction',
  };

  /// Resolves a 2-digit GST state code to its official State / Union Territory name.
  static String? getStateName(String? code) {
    if (code == null) return null;
    return stateCodes[code.trim().padLeft(2, '0')];
  }

  /// Calculates GST for an exclusive taxable amount.
  ///
  /// Examples:
  /// ```dart
  /// final base = BharatMoney.fromRupees(1000.00);
  ///
  /// // Intra-state (CGST 9% + SGST 9%)
  /// final res = BharatGst.calculate(
  ///   taxableAmount: base,
  ///   rate: 18.0,
  ///   isInterState: false,
  /// );
  /// print(res.cgst); // ₹90.00
  /// print(res.sgst); // ₹90.00
  /// print(res.totalAmount); // ₹1,180.00
  ///
  /// // Auto-detect from GSTIN
  /// final autoRes = BharatGst.calculate(
  ///   taxableAmount: base,
  ///   rate: 18.0,
  ///   supplierGstin: '27AAPFU0939F1ZV', // MH
  ///   buyerGstin: '29AAPFU0939F1ZV',    // KA -> Inter-state
  /// );
  /// print(autoRes.isInterState); // true (IGST ₹180.00)
  /// ```
  static GstBreakdown calculate({
    required BharatMoney taxableAmount,
    double rate = 18.0,
    bool? isInterState,
    String? supplierStateCode,
    String? buyerStateCode,
    String? supplierGstin,
    String? buyerGstin,
  }) {
    final sCode = supplierStateCode ?? _extractStateCode(supplierGstin);
    final bCode = buyerStateCode ?? _extractStateCode(buyerGstin);

    final interState =
        isInterState ?? (sCode != null && bCode != null && sCode != bCode);

    final totalTaxPaise = ((taxableAmount.inPaise * rate) / 100.0).round();
    final totalTax = BharatMoney.fromPaise(totalTaxPaise);
    final grandTotal = taxableAmount + totalTax;

    BharatMoney cgst;
    BharatMoney sgst;
    BharatMoney igst;

    if (interState) {
      cgst = BharatMoney.zero;
      sgst = BharatMoney.zero;
      igst = totalTax;
    } else {
      // Split evenly without dropping fractional paise
      final halfPaise = totalTaxPaise ~/ 2;
      cgst = BharatMoney.fromPaise(halfPaise);
      sgst = BharatMoney.fromPaise(totalTaxPaise - halfPaise);
      igst = BharatMoney.zero;
    }

    return GstBreakdown(
      taxableAmount: taxableAmount,
      ratePercentage: rate,
      isInterState: interState,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      totalTax: totalTax,
      totalAmount: grandTotal,
      supplierState: getStateName(sCode),
      buyerState: getStateName(bCode),
    );
  }

  /// Reverse calculates GST from a gross amount that is already inclusive of tax (e.g. MRP).
  ///
  /// Examples:
  /// ```dart
  /// final gross = BharatMoney.fromRupees(1180.00);
  /// final res = BharatGst.reverseCalculate(
  ///   grossAmount: gross,
  ///   rate: 18.0,
  /// );
  /// print(res.taxableAmount); // ₹1,000.00
  /// print(res.totalTax);      // ₹180.00
  /// ```
  static GstBreakdown reverseCalculate({
    required BharatMoney grossAmount,
    double rate = 18.0,
    bool? isInterState,
    String? supplierStateCode,
    String? buyerStateCode,
    String? supplierGstin,
    String? buyerGstin,
  }) {
    final sCode = supplierStateCode ?? _extractStateCode(supplierGstin);
    final bCode = buyerStateCode ?? _extractStateCode(buyerGstin);
    final interState =
        isInterState ?? (sCode != null && bCode != null && sCode != bCode);

    final grossPaise = grossAmount.inPaise;
    final taxablePaise = ((grossPaise * 100.0) / (100.0 + rate)).round();
    final totalTaxPaise = grossPaise - taxablePaise;

    final taxableAmount = BharatMoney.fromPaise(taxablePaise);
    final totalTax = BharatMoney.fromPaise(totalTaxPaise);

    BharatMoney cgst;
    BharatMoney sgst;
    BharatMoney igst;

    if (interState) {
      cgst = BharatMoney.zero;
      sgst = BharatMoney.zero;
      igst = totalTax;
    } else {
      final halfPaise = totalTaxPaise ~/ 2;
      cgst = BharatMoney.fromPaise(halfPaise);
      sgst = BharatMoney.fromPaise(totalTaxPaise - halfPaise);
      igst = BharatMoney.zero;
    }

    return GstBreakdown(
      taxableAmount: taxableAmount,
      ratePercentage: rate,
      isInterState: interState,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      totalTax: totalTax,
      totalAmount: grossAmount,
      supplierState: getStateName(sCode),
      buyerState: getStateName(bCode),
    );
  }

  static String? _extractStateCode(String? gstin) {
    if (gstin == null || gstin.trim().length < 2) return null;
    final code = gstin.trim().substring(0, 2);
    return stateCodes.containsKey(code) ? code : null;
  }
}
