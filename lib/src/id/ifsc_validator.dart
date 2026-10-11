/// Result of IFSC code validation.
class IfscValidationResult {
  final String ifsc;
  final bool isValid;
  final String? bankCode;
  final String? bankName;
  final String? branchCode;
  final bool isMergedOrDefunct;
  final String? successorBankName;
  final String? warningMessage;
  final String? errorMessage;

  const IfscValidationResult({
    required this.ifsc,
    required this.isValid,
    this.bankCode,
    this.bankName,
    this.branchCode,
    this.isMergedOrDefunct = false,
    this.successorBankName,
    this.warningMessage,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'IfscValidationResult(ifsc: $ifsc, valid: $isValid, bank: $bankName, merged: $isMergedOrDefunct)';
  }
}

/// Indian Financial System Code (IFSC) validator, bank resolver,
/// and RBI bank merger / defunct IFSC detector.
class BharatIfsc {
  static final RegExp _ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  /// Major Indian active bank codes to institution names.
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
    'IDIB': 'Indian Bank',
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

  /// Historical merged / defunct Indian bank codes and their successor institutions.
  static const Map<String, (String formerName, String successorName)>
      _mergedBanks = {
    'ALLA': ('Allahabad Bank', 'Indian Bank (IDIB)'),
    'ANDB': ('Andhra Bank', 'Union Bank of India (UBIN)'),
    'CORP': ('Corporation Bank', 'Union Bank of India (UBIN)'),
    'ORBC': ('Oriental Bank of Commerce', 'Punjab National Bank (PUNB)'),
    'UTBI': ('United Bank of India', 'Punjab National Bank (PUNB)'),
    'SYNB': ('Syndicate Bank', 'Canara Bank (CNRB)'),
    'VIJB': ('Vijaya Bank', 'Bank of Baroda (BARB)'),
    'DENA': ('Dena Bank', 'Bank of Baroda (BARB)'),
    'PMCB': ('Punjab and Maharashtra Co-op Bank', 'Unity Small Finance Bank'),
  };

  /// Validates an 11-character Indian IFSC code.
  ///
  /// Checks format, identifies institution, and detects merged banks
  /// to prevent payment failures in NEFT/RTGS/IMPS settlement.
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
        errorMessage:
            'Invalid IFSC format (expected 4 letters, 0, and 6 branch characters)',
      );
    }

    final bankCode = cleaned.substring(0, 4);
    final branchCode = cleaned.substring(5);

    final mergedInfo = _mergedBanks[bankCode];
    if (mergedInfo != null) {
      return IfscValidationResult(
        ifsc: cleaned,
        isValid: true,
        bankCode: bankCode,
        bankName: mergedInfo.$1,
        branchCode: branchCode,
        isMergedOrDefunct: true,
        successorBankName: mergedInfo.$2,
        warningMessage:
            '${mergedInfo.$1} has merged into ${mergedInfo.$2}. Please use the updated successor IFSC to prevent transfer failure.',
      );
    }

    final bankName = _bankCodes[bankCode] ?? 'Bank ($bankCode)';

    return IfscValidationResult(
      ifsc: cleaned,
      isValid: true,
      bankCode: bankCode,
      bankName: bankName,
      branchCode: branchCode,
    );
  }

  /// Checks if a bank code belongs to a merged or defunct bank.
  static bool isMerged(String ifsc) {
    if (ifsc.length >= 4) {
      final code = ifsc.substring(0, 4).toUpperCase();
      return _mergedBanks.containsKey(code);
    }
    return false;
  }
}
