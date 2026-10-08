/// Result of IFSC code validation.
class IfscValidationResult {
  final String ifsc;
  final bool isValid;
  final String? bankCode;
  final String? bankName;
  final String? branchCode;
  final String? errorMessage;

  const IfscValidationResult({
    required this.ifsc,
    required this.isValid,
    this.bankCode,
    this.bankName,
    this.branchCode,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'IfscValidationResult(ifsc: $ifsc, valid: $isValid, bank: $bankName)';
  }
}

/// Indian Financial System Code (IFSC) validator and bank resolver.
class BharatIfsc {
  static final RegExp _ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  /// Major Indian bank codes to institution names.
  static const Map<String, String> _bankCodes = {
    'SBIN': 'State Bank of India',
    'HDFC': 'HDFC Bank',
    'ICIC': 'ICICI Bank',
    'UTIB': 'Axis Bank',
    'KKBK': 'Kotak Mahindra Bank',
    'BARB': 'Bank of Baroda',
    'PUNB': 'Punjab National Bank',
    'CNRB': 'Canara Bank',
    'UBIN': 'Union Bank of India',
    'IDFB': 'IDFC FIRST Bank',
    'INDB': 'IndusInd Bank',
    'YESB': 'YES Bank',
    'FDRL': 'Federal Bank',
    'IOBA': 'Indian Overseas Bank',
    'MAHB': 'Bank of Maharashtra',
    'PSIB': 'Punjab & Sind Bank',
    'UCOB': 'UCO Bank',
    'CBIN': 'Central Bank of India',
    'BKID': 'Bank of India',
    'KARB': 'Karnataka Bank',
    'SIBL': 'South Indian Bank',
    'KVBL': 'Karur Vysya Bank',
  };

  /// Validates an 11-character Indian IFSC code.
  static IfscValidationResult validate(String? ifsc) {
    if (ifsc == null || ifsc.trim().isEmpty) {
      return const IfscValidationResult(
        ifsc: '',
        isValid: false,
        errorMessage: 'IFSC cannot be empty',
      );
    }

    final cleaned = ifsc.trim().toUpperCase();

    if (cleaned.length != 11) {
      return IfscValidationResult(
        ifsc: cleaned,
        isValid: false,
        errorMessage: 'IFSC must be exactly 11 characters',
      );
    }

    if (!_ifscRegex.hasMatch(cleaned)) {
      return IfscValidationResult(
        ifsc: cleaned,
        isValid: false,
        errorMessage: 'Invalid IFSC format (expected 4 letters, 0, and 6 branch chars)',
      );
    }

    final bankCode = cleaned.substring(0, 4);
    final branchCode = cleaned.substring(5);
    final bankName = _bankCodes[bankCode] ?? 'Bank ($bankCode)';

    return IfscValidationResult(
      ifsc: cleaned,
      isValid: true,
      bankCode: bankCode,
      bankName: bankName,
      branchCode: branchCode,
    );
  }
}
