import '../security/timing_safe.dart';

/// Validation result for Indian bank account numbers.
class BankAccountValidationResult {
  final String accountNumber;
  final bool isValid;
  final String? bankCode;
  final String? bankName;
  final String? errorMessage;

  const BankAccountValidationResult({
    required this.accountNumber,
    required this.isValid,
    this.bankCode,
    this.bankName,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'BankAccountValidationResult(account: $accountNumber, valid: $isValid, bank: $bankName)';
  }
}

/// Validator, masker, and confirmation matcher for Indian bank accounts (RBI guidelines).
class BharatBankAccount {
  static final RegExp _whitespaceRegex = RegExp(r'\s+');
  static final RegExp _digitsOnlyRegex = RegExp(r'^\d+$');

  /// Known standard account number lengths by 4-letter bank code.
  static const Map<String, List<int>> _bankLengths = {
    'SBIN': [11, 17], // State Bank of India
    'HDFC': [14], // HDFC Bank
    'ICIC': [12], // ICICI Bank
    'UTIB': [15], // Axis Bank
    'PUNB': [16], // Punjab National Bank
    'BARB': [14], // Bank of Baroda
    'CNRB': [13], // Canara Bank
    'KKBK': [10, 14], // Kotak Mahindra Bank
    'UBIN': [15], // Union Bank of India
    'IDFB': [10, 12], // IDFC FIRST Bank
    'INDB': [12], // IndusInd Bank
    'YESB': [15], // YES Bank
    'FDRL': [14], // Federal Bank
    'IDIB': [9, 10, 11], // Indian Bank
    'BKID': [15], // Bank of India
    'IOBA': [15], // Indian Overseas Bank
    'MAHB': [11], // Bank of Maharashtra
    'CBIN': [10], // Central Bank of India
  };

  /// Validates an Indian bank account number.
  ///
  /// Optionally validates against a 4-letter [bankCode] (e.g. `SBIN`, `HDFC`, `ICIC`).
  static BankAccountValidationResult validate(
    String? accountNumber, {
    String? bankCode,
  }) {
    if (accountNumber == null || accountNumber.trim().isEmpty) {
      return const BankAccountValidationResult(
        accountNumber: '',
        isValid: false,
        errorMessage: 'Account number cannot be empty',
      );
    }

    final digits = accountNumber.trim().replaceAll(_whitespaceRegex, '');

    if (!_digitsOnlyRegex.hasMatch(digits)) {
      return BankAccountValidationResult(
        accountNumber: digits,
        isValid: false,
        errorMessage: 'Bank account number must contain only digits',
      );
    }

    if (digits.length < 9 || digits.length > 18) {
      return BankAccountValidationResult(
        accountNumber: digits,
        isValid: false,
        errorMessage:
            'Bank account number must be between 9 and 18 digits (found ${digits.length})',
      );
    }

    if (bankCode != null && bankCode.trim().isNotEmpty) {
      final code = bankCode.trim().toUpperCase();
      final allowedLengths = _bankLengths[code];

      if (allowedLengths != null && !allowedLengths.contains(digits.length)) {
        return BankAccountValidationResult(
          accountNumber: digits,
          isValid: false,
          bankCode: code,
          errorMessage:
              'Invalid length for $code account. Expected ${allowedLengths.join(" or ")} digits, but got ${digits.length}',
        );
      }

      return BankAccountValidationResult(
        accountNumber: digits,
        isValid: true,
        bankCode: code,
      );
    }

    return BankAccountValidationResult(
      accountNumber: digits,
      isValid: true,
    );
  }

  /// Masks a bank account number, displaying only the last 3 or 4 digits.
  ///
  /// Examples:
  /// ```dart
  /// BharatBankAccount.mask("123456789012"); // "XXXXXXXX9012"
  /// BharatBankAccount.mask("123456789012", maskChar: '•'); // "••••••••9012"
  /// ```
  static String mask(
    String accountNumber, {
    String maskChar = 'X',
    int visibleDigits = 4,
  }) {
    final digits = accountNumber.replaceAll(_whitespaceRegex, '');
    if (digits.length <= visibleDigits) return accountNumber;

    final maskedLength = digits.length - visibleDigits;
    final lastDigits = digits.substring(maskedLength);
    return '${maskChar * maskedLength}$lastDigits';
  }

  /// Verifies whether the account number and confirmation account number match,
  /// executing comparison in constant time to prevent timing leaks.
  static bool match(String? account, String? confirmAccount) {
    if (account == null || confirmAccount == null) return false;
    final a = account.trim().replaceAll(_whitespaceRegex, '');
    final b = confirmAccount.trim().replaceAll(_whitespaceRegex, '');
    return TimingSafe.equals(a, b);
  }
}
