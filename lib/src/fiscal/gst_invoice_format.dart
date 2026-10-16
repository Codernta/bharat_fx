/// Validation result for Indian GST Tax Invoice Number under CGST Rule 46(b).
class GstInvoiceNumberValidationResult {
  /// The invoice number string submitted.
  final String invoiceNumber;

  /// Whether the invoice number complies strictly with CGST Rule 46(b).
  final bool isValid;

  /// Character length of the invoice number.
  final int length;

  /// Detailed explanation if validation failed.
  final String? errorMessage;

  /// Prohibited characters detected (e.g. [' ', '_', '#']).
  final List<String> invalidCharacters;

  const GstInvoiceNumberValidationResult({
    required this.invoiceNumber,
    required this.isValid,
    required this.length,
    this.errorMessage,
    this.invalidCharacters = const [],
  });

  @override
  String toString() {
    return 'GstInvoiceNumberValidationResult(invoice: $invoiceNumber, valid: $isValid, len: $length)';
  }
}

/// Standard GST Document Types recognized on the GST Portal & e-Invoice IRP.
enum GstDocumentType {
  /// Tax Invoice (standard B2B / B2C invoice).
  taxInvoice('INV', 'Tax Invoice'),

  /// Credit Note (issued for returns, discounts, deficiencies).
  creditNote('CRN', 'Credit Note'),

  /// Debit Note (issued for supplementary billing / price increases).
  debitNote('DBN', 'Debit Note'),

  /// Bill of Supply (issued for exempt supplies or composition dealers).
  billOfSupply('BOS', 'Bill of Supply'),

  /// Delivery Challan (issued for goods sent on approval, job work).
  deliveryChallan('CHL', 'Delivery Challan');

  final String code;
  final String description;
  const GstDocumentType(this.code, this.description);

  /// Resolves a 3-letter code or description into a [GstDocumentType].
  static GstDocumentType? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toUpperCase();
    for (final type in GstDocumentType.values) {
      if (type.code == normalized) return type;
    }
    return null;
  }
}

/// Helper and compliance validator for Indian GST Tax Invoice formatting according to
/// Rule 46(b) of the Central Goods and Services Tax (CGST) Rules, 2017.
class BharatGstInvoice {
  /// Strictly allowed characters: Alphanumerics, hyphen (`-`), and slash (`/`).
  static final RegExp _allowedCharsRegex = RegExp(r'^[A-Za-z0-9/-]+$');
  static final RegExp _disallowedCharsRegex = RegExp(r'[^A-Za-z0-9/-]+');
  static final RegExp _multipleHyphensRegex = RegExp(r'-+');

  /// Validates an Indian GST tax invoice serial number against statutory CGST Rule 46(b).
  ///
  /// Statutory Requirements:
  /// 1. Maximum length of **16 characters**.
  /// 2. Must only contain alphanumeric characters (`A-Z`, `a-z`, `0-9`) and
  ///    special characters restricted strictly to hyphen (`-`) and slash (`/`).
  /// 3. Cannot contain spaces, periods, underscores, hash symbols, or backslashes.
  /// 4. Must be unique for a Financial Year.
  static GstInvoiceNumberValidationResult validateInvoiceNumber(
      String? invoiceNumber) {
    if (invoiceNumber == null || invoiceNumber.trim().isEmpty) {
      return const GstInvoiceNumberValidationResult(
        invoiceNumber: '',
        isValid: false,
        length: 0,
        errorMessage: 'Invoice number cannot be empty',
      );
    }

    final trimmed = invoiceNumber.trim();
    final len = trimmed.length;

    if (len > 16) {
      return GstInvoiceNumberValidationResult(
        invoiceNumber: trimmed,
        isValid: false,
        length: len,
        errorMessage:
            'Invoice number exceeds maximum 16 characters permitted by CGST Rule 46(b) (got $len chars)',
      );
    }

    if (!_allowedCharsRegex.hasMatch(trimmed)) {
      final invalidChars = <String>{};
      for (final rune in trimmed.runes) {
        final char = String.fromCharCode(rune);
        if (!_allowedCharsRegex.hasMatch(char)) {
          invalidChars.add(char == ' ' ? '<space>' : char);
        }
      }

      final charList = invalidChars.toList();
      return GstInvoiceNumberValidationResult(
        invoiceNumber: trimmed,
        isValid: false,
        length: len,
        invalidCharacters: charList,
        errorMessage:
            'Contains invalid characters [${charList.join(', ')}]. CGST Rule 46(b) strictly permits only letters, numbers, hyphens (-), and slashes (/)',
      );
    }

    return GstInvoiceNumberValidationResult(
      invoiceNumber: trimmed,
      isValid: true,
      length: len,
    );
  }

  /// Automatically sanitizes an invoice number candidate by:
  /// - Trimming surrounding spaces
  /// - Replacing prohibited separators (spaces, underscores, dots) with slashes or dashes
  /// - Stripping remaining illegal characters
  /// - Truncating to 16 characters if requested
  static String sanitizeInvoiceNumber(
    String input, {
    String replacementSeparator = '-',
    bool truncateTo16Chars = false,
  }) {
    if (input.isEmpty) return '';

    // Replace any run of characters not allowed under Rule 46(b) with the separator
    var result = input.trim().replaceAll(_disallowedCharsRegex, replacementSeparator);

    // Collapse multiple consecutive separators
    if (replacementSeparator.isNotEmpty) {
      if (replacementSeparator == '-') {
        result = result.replaceAll(_multipleHyphensRegex, '-');
      } else {
        final escaped = RegExp.escape(replacementSeparator);
        result = result.replaceAll(RegExp('$escaped+'), replacementSeparator);
      }
      // Strip leading and trailing separator
      if (result.startsWith(replacementSeparator)) {
        result = result.substring(replacementSeparator.length);
      }
      if (result.endsWith(replacementSeparator)) {
        result =
            result.substring(0, result.length - replacementSeparator.length);
      }
    }

    if (truncateTo16Chars && result.length > 16) {
      result = result.substring(0, 16);
    }
    return result;
  }

  /// Generates a standardized, CGST-compliant invoice serial number adhering to the 16-character limit.
  ///
  /// Example:
  /// ```dart
  /// BharatGstInvoice.buildInvoiceNumber(
  ///   prefix: 'INV',
  ///   sequenceNumber: 12,
  ///   date: DateTime(2024, 7, 1),
  /// ); // "INV/24-25/0012" (13 characters)
  /// ```
  static String buildInvoiceNumber({
    required String prefix,
    required int sequenceNumber,
    DateTime? date,
    int sequencePadding = 4,
    String separator = '/',
    bool useShortYear = true,
  }) {
    final target = date ?? DateTime.now();
    final year = target.year;
    final isAfterApril = target.month >= 4;
    final startYear = isAfterApril ? year : year - 1;

    final String fyString;
    if (useShortYear) {
      final startShort = (startYear % 100).toString().padLeft(2, '0');
      final endShort = ((startYear + 1) % 100).toString().padLeft(2, '0');
      fyString = '$startShort-$endShort';
    } else {
      final endShort = ((startYear + 1) % 100).toString().padLeft(2, '0');
      fyString = '$startYear-$endShort';
    }

    final seq = sequenceNumber.toString().padLeft(sequencePadding, '0');
    final invoice = '$prefix$separator$fyString$separator$seq';

    final validation = validateInvoiceNumber(invoice);
    if (!validation.isValid) {
      throw ArgumentError(
        'Generated invoice number "$invoice" exceeds the statutory 16-character limit (${invoice.length} chars). Reduce prefix or padding.',
      );
    }

    return invoice;
  }
}
