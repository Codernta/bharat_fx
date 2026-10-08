/// Result of UPI ID validation with PSP and bank resolution.
class UpiValidationResult {
  final String upiId;
  final bool isValid;
  final String? username;
  final String? handle;
  final String? pspName;
  final String? bankName;
  final bool isKnownHandle;
  final String? errorMessage;

  const UpiValidationResult({
    required this.upiId,
    required this.isValid,
    this.username,
    this.handle,
    this.pspName,
    this.bankName,
    this.isKnownHandle = false,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'UpiValidationResult(upiId: $upiId, valid: $isValid, psp: $pspName, bank: $bankName)';
  }
}

/// Validator and Payment Service Provider (PSP) resolver for Indian Unified Payments Interface (UPI) IDs.
class BharatUpi {
  static final RegExp _upiRegex =
      RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');

  /// Known UPI handles and their associated PSP / Bank providers.
  static const Map<String, (String psp, String bank)> _knownHandles = {
    // Google Pay
    'okaxis': ('Google Pay', 'Axis Bank'),
    'okhdfcbank': ('Google Pay', 'HDFC Bank'),
    'okicici': ('Google Pay', 'ICICI Bank'),
    'oksbi': ('Google Pay', 'State Bank of India'),

    // PhonePe
    'ybl': ('PhonePe', 'YES Bank'),
    'ibl': ('PhonePe', 'ICICI Bank'),
    'axl': ('PhonePe', 'Axis Bank'),

    // Paytm
    'paytm': ('Paytm', 'Paytm Payments Bank'),
    'ptaxis': ('Paytm', 'Axis Bank'),
    'pthdfc': ('Paytm', 'HDFC Bank'),
    'ptsbi': ('Paytm', 'State Bank of India'),

    // BHIM
    'upi': ('BHIM', 'NPCI'),

    // Amazon Pay
    'apl': ('Amazon Pay', 'Axis Bank'),
    'rapl': ('Amazon Pay', 'RBL Bank'),

    // WhatsApp Pay
    'waaxis': ('WhatsApp Pay', 'Axis Bank'),
    'wahdfc': ('WhatsApp Pay', 'HDFC Bank'),
    'waicici': ('WhatsApp Pay', 'ICICI Bank'),
    'wasbi': ('WhatsApp Pay', 'State Bank of India'),

    // CRED
    'axisbank': ('CRED / Axis Mobile', 'Axis Bank'),
    'yesbank': ('CRED / YES Bank', 'YES Bank'),

    // Neobanks & Fintechs
    'superyes': ('super.money', 'YES Bank'),
    'slice': ('Slice', 'Slice / North East SFB'),
    'jupiteraxis': ('Jupiter', 'Axis Bank'),
    'federal': ('Fi Money / Federal Bank', 'Federal Bank'),

    // Major Commercial Banks
    'hdfcbank': ('HDFC Mobile', 'HDFC Bank'),
    'icici': ('iMobile Pay', 'ICICI Bank'),
    'sbi': ('YONO SBI', 'State Bank of India'),
    'kotak': ('Kotak 811', 'Kotak Mahindra Bank'),
    'idfcbank': ('IDFC FIRST Mobile', 'IDFC FIRST Bank'),
    'indus': ('IndusInd Mobile', 'IndusInd Bank'),
    'barodampay': ('bob World', 'Bank of Baroda'),
    'pnb': ('PNB ONE', 'Punjab National Bank'),
    'canarabank': ('Canara ai1', 'Canara Bank'),
    'unionbank': ('Union Bank Mobile', 'Union Bank of India'),
  };

  /// Checks if [upiId] has a valid syntax format.
  static bool isValid(String? upiId) {
    if (upiId == null) return false;
    final cleaned = upiId.trim();
    return _upiRegex.hasMatch(cleaned);
  }

  /// Validates [upiId] and extracts user handle, PSP, and supporting bank.
  ///
  /// Examples:
  /// ```dart
  /// final result = BharatUpi.validate("john.doe@okaxis");
  /// print(result.pspName); // "Google Pay"
  /// print(result.bankName); // "Axis Bank"
  /// ```
  static UpiValidationResult validate(String? upiId) {
    if (upiId == null || upiId.trim().isEmpty) {
      return const UpiValidationResult(
        upiId: '',
        isValid: false,
        errorMessage: 'UPI ID cannot be empty',
      );
    }

    final cleaned = upiId.trim().toLowerCase();
    if (!isValid(cleaned)) {
      return UpiValidationResult(
        upiId: cleaned,
        isValid: false,
        errorMessage: 'Invalid UPI ID format (expected: username@bankhandle)',
      );
    }

    final parts = cleaned.split('@');
    final username = parts[0];
    final handle = parts[1];

    final known = _knownHandles[handle];
    if (known != null) {
      return UpiValidationResult(
        upiId: cleaned,
        isValid: true,
        username: username,
        handle: handle,
        pspName: known.$1,
        bankName: known.$2,
        isKnownHandle: true,
      );
    }

    return UpiValidationResult(
      upiId: cleaned,
      isValid: true,
      username: username,
      handle: handle,
      isKnownHandle: false,
    );
  }

  /// Returns the PSP name associated with a UPI handle (e.g. `okaxis` -> `Google Pay`).
  static String? getPsp(String handle) {
    final clean = handle.replaceAll('@', '').toLowerCase();
    return _knownHandles[clean]?.$1;
  }
}
