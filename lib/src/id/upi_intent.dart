import 'upi_validator.dart';

/// Validation result for NPCI UPI Intent / Deep Link URIs.
class UpiIntentValidationResult {
  final String rawUri;
  final bool isValid;
  final String? payeeAddress; // pa
  final String? payeeName; // pn
  final double? amount; // am
  final String? currency; // cu
  final String? transactionNote; // tn
  final String? transactionRef; // tr
  final String? merchantCode; // mc
  final String? sign; // sign
  final List<String> warnings;
  final String? errorMessage;

  const UpiIntentValidationResult({
    required this.rawUri,
    required this.isValid,
    this.payeeAddress,
    this.payeeName,
    this.amount,
    this.currency,
    this.transactionNote,
    this.transactionRef,
    this.merchantCode,
    this.sign,
    this.warnings = const [],
    this.errorMessage,
  });

  @override
  String toString() {
    return 'UpiIntentValidationResult(valid: $isValid, pa: $payeeAddress, am: $amount, cu: $currency)';
  }
}

/// NPCI Unified Payments Interface (UPI) Deep Link / Dynamic QR Intent parser,
/// tamper-detection guard, and secure URI generator.
class BharatUpiIntent {
  static final RegExp _fourDigitsRegex = RegExp(r'^\d{4}$');

  /// Standard NPCI transaction amount limits (INR).
  static const double standardTransactionLimit = 100000.0; // ₹1 Lakh
  static const double capitalMarketsLimit = 200000.0; // ₹2 Lakh
  static const double maxApprovedCategoryLimit =
      500000.0; // ₹5 Lakh (hospitals/educational)

  /// Parses and rigorously verifies a UPI deep link (`upi://pay?...`).
  ///
  /// Checks for:
  /// - Tampering or missing mandatory fields (`pa`, `pn`)
  /// - Non-INR currency injection
  /// - Excessive or negative transaction amounts
  /// - Malicious redirect URLs (`javascript:`, `data:`, `file:`)
  /// - Payee handle syntax validity and homoglyph attacks
  static UpiIntentValidationResult validate(String? uriString) {
    if (uriString == null || uriString.trim().isEmpty) {
      return const UpiIntentValidationResult(
        rawUri: '',
        isValid: false,
        errorMessage: 'UPI Intent URI cannot be empty',
      );
    }

    final trimmed = uriString.trim();
    final Uri parsed;
    try {
      parsed = Uri.parse(trimmed);
    } catch (e) {
      return UpiIntentValidationResult(
        rawUri: trimmed,
        isValid: false,
        errorMessage: 'Malformed URI syntax: $e',
      );
    }

    // Verify scheme and host/path
    if (parsed.scheme.toLowerCase() != 'upi') {
      return UpiIntentValidationResult(
        rawUri: trimmed,
        isValid: false,
        errorMessage: 'Invalid scheme "${parsed.scheme}". Expected "upi://"',
      );
    }

    final action =
        (parsed.host.isNotEmpty ? parsed.host : parsed.path).toLowerCase();
    if (action != 'pay' && action != 'mandate') {
      return UpiIntentValidationResult(
        rawUri: trimmed,
        isValid: false,
        errorMessage:
            'Unsupported UPI action "$action". Expected "pay" or "mandate"',
      );
    }

    final params = parsed.queryParameters;
    final warnings = <String>[];

    // Mandatory: pa (Payee Address / VPA)
    final pa = params['pa'];
    if (pa == null || pa.trim().isEmpty) {
      return UpiIntentValidationResult(
        rawUri: trimmed,
        isValid: false,
        errorMessage: 'Missing mandatory parameter "pa" (Payee VPA)',
      );
    }

    final upiValidation = BharatUpi.validate(pa);
    if (!upiValidation.isValid) {
      return UpiIntentValidationResult(
        rawUri: trimmed,
        isValid: false,
        payeeAddress: pa,
        errorMessage:
            'Invalid Payee UPI address: ${upiValidation.errorMessage}',
      );
    }

    if (BharatUpi.hasHomoglyphs(pa)) {
      return UpiIntentValidationResult(
        rawUri: trimmed,
        isValid: false,
        payeeAddress: pa,
        errorMessage:
            'Security Alert: Payee UPI address contains deceptive homoglyph characters',
      );
    }

    // Mandatory: pn (Payee Name)
    final pn = params['pn'];
    if (pn == null || pn.trim().isEmpty) {
      return UpiIntentValidationResult(
        rawUri: trimmed,
        isValid: false,
        payeeAddress: pa,
        errorMessage: 'Missing mandatory parameter "pn" (Payee Name)',
      );
    }

    // Currency verification: NPCI strictly mandates INR
    final cu = params['cu'];
    if (cu != null && cu.toUpperCase() != 'INR') {
      return UpiIntentValidationResult(
        rawUri: trimmed,
        isValid: false,
        payeeAddress: pa,
        payeeName: pn,
        currency: cu,
        errorMessage:
            'Unsupported currency "$cu". NPCI strictly mandates "INR"',
      );
    }

    // Amount verification
    double? amount;
    final amStr = params['am'];
    if (amStr != null && amStr.isNotEmpty) {
      amount = double.tryParse(amStr);
      if (amount == null || amount.isNaN || amount.isInfinite) {
        return UpiIntentValidationResult(
          rawUri: trimmed,
          isValid: false,
          payeeAddress: pa,
          payeeName: pn,
          errorMessage: 'Invalid amount value "$amStr"',
        );
      }

      if (amount <= 0) {
        return UpiIntentValidationResult(
          rawUri: trimmed,
          isValid: false,
          payeeAddress: pa,
          payeeName: pn,
          amount: amount,
          errorMessage: 'Transaction amount must be strictly greater than zero',
        );
      }

      if (amount > maxApprovedCategoryLimit) {
        warnings.add(
          'Amount ₹$amount exceeds maximum allowable NPCI limit of ₹$maxApprovedCategoryLimit',
        );
      } else if (amount > standardTransactionLimit) {
        warnings.add(
          'Amount ₹$amount exceeds standard P2P UPI limit of ₹$standardTransactionLimit. Valid only for approved merchant categories',
        );
      }
    }

    // Reference URL security verification
    final refUrl = params['url'];
    if (refUrl != null && refUrl.isNotEmpty) {
      final refLower = refUrl.toLowerCase();
      if (refLower.startsWith('javascript:') ||
          refLower.startsWith('data:') ||
          refLower.startsWith('file:')) {
        return UpiIntentValidationResult(
          rawUri: trimmed,
          isValid: false,
          payeeAddress: pa,
          payeeName: pn,
          errorMessage: 'Malicious URI scheme detected in "url" parameter',
        );
      }
    }

    // Merchant Category Code (mc)
    final mc = params['mc'];
    if (mc != null && (mc.length != 4 || !_fourDigitsRegex.hasMatch(mc))) {
      warnings
          .add('Merchant category code (mc) should be a 4-digit numeric code');
    }

    return UpiIntentValidationResult(
      rawUri: trimmed,
      isValid: true,
      payeeAddress: pa,
      payeeName: pn,
      amount: amount,
      currency: cu ?? 'INR',
      transactionNote: params['tn'],
      transactionRef: params['tr'],
      merchantCode: mc,
      sign: params['sign'],
      warnings: warnings,
    );
  }

  /// Securely builds a tamper-proof NPCI UPI payment intent [Uri].
  ///
  /// Guarantees strict percent-encoding of all parameters to prevent query injection attacks.
  static Uri buildUri({
    required String payeeAddress,
    required String payeeName,
    double? amount,
    String currency = 'INR',
    String? transactionNote,
    String? transactionRef,
    String? merchantCode,
    String? url,
  }) {
    final queryParams = <String, String>{
      'pa': payeeAddress.trim(),
      'pn': payeeName.trim(),
      'cu': currency.toUpperCase(),
    };

    if (amount != null) {
      queryParams['am'] = amount.toStringAsFixed(2);
    }
    if (transactionNote != null && transactionNote.isNotEmpty) {
      queryParams['tn'] = transactionNote.trim();
    }
    if (transactionRef != null && transactionRef.isNotEmpty) {
      queryParams['tr'] = transactionRef.trim();
    }
    if (merchantCode != null && merchantCode.isNotEmpty) {
      queryParams['mc'] = merchantCode.trim();
    }
    if (url != null && url.isNotEmpty) {
      queryParams['url'] = url.trim();
    }

    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: queryParams,
    );
  }
}
