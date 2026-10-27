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
  static final RegExp _upiRegex = RegExp(
    r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$',
  );

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
    'fam': ('FamPay', 'IDFC FIRST Bank'),
    'navi': ('Navi', 'Axis Bank'),
    'payzapp': ('PayZapp', 'HDFC Bank'),
    'freecharge': ('Freecharge', 'Axis Bank'),
    'airtel': ('Airtel Payments Bank', 'Airtel Payments Bank'),
    'postbank': ('India Post Payments Bank', 'IPPB'),
    'jio': ('Jio Payments Bank', 'Jio Payments Bank'),
    'fbl': ('Federal Bank', 'Federal Bank'),

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

  // Invisible characters and zero-width spaces commonly used in evasion attacks
  static final RegExp _invisibleCharsRegex = RegExp(
    r'[\u200B-\u200D\uFEFF\u00A0\u2060\u180E\u2000-\u200A]',
  );

  // Common Cyrillic & Greek homoglyphs mimicking Latin letters
  static final RegExp _homoglyphsRegex = RegExp(
    r'[\u0430\u0435\u043E\u0440\u0441\u0443\u0445\u0456\u0458\u0455\u03BF\u03C1]',
  );

  // Common phishing prefixes and patterns in Indian UPI scams
  static final List<String> _phishingPatterns = [
    'refund-',
    'refund.',
    'support-',
    'support.',
    'kyc-help',
    'kyc-update',
    'helpline-',
    'cashback-win',
    'reward-claim',
  ];

  /// Sanitizes a UPI ID by stripping invisible characters and zero-width spaces.
  static String sanitize(String? upiId) {
    if (upiId == null) return '';
    return upiId.replaceAll(_invisibleCharsRegex, '').trim();
  }

  /// Checks if [upiId] contains deceptive Unicode homoglyph characters
  /// (e.g. Cyrillic letters looking identical to Latin letters).
  static bool hasHomoglyphs(String? upiId) {
    if (upiId == null) return false;
    return _homoglyphsRegex.hasMatch(upiId);
  }

  /// Evaluates whether a UPI ID exhibits suspicious phishing patterns
  /// (e.g., impersonating customer care, fake KYC, or refund handles).
  static bool isSuspiciousPhishingHandle(String? upiId) {
    if (upiId == null) return false;
    final lower = sanitize(upiId).toLowerCase();
    for (final pattern in _phishingPatterns) {
      if (lower.contains(pattern)) return true;
    }
    return false;
  }

  /// Checks if [upiId] has a valid syntax format.
  static bool isValid(String? upiId) {
    if (upiId == null) return false;
    final cleaned = sanitize(upiId);
    if (hasHomoglyphs(cleaned)) return false;
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

    if (hasHomoglyphs(upiId)) {
      return UpiValidationResult(
        upiId: upiId,
        isValid: false,
        errorMessage:
            'Security Warning: UPI ID contains suspicious homoglyph characters',
      );
    }

    final cleaned = sanitize(upiId).toLowerCase();
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
    final clean = sanitize(handle).replaceAll('@', '').toLowerCase();
    return _knownHandles[clean]?.$1;
  }
}
