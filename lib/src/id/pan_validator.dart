/// Entity category encoded by the 4th character of an Indian PAN card.
enum PanCategory {
  individual, // 'P'
  company, // 'C'
  huf, // 'H' - Hindu Undivided Family
  aop, // 'A' - Association of Persons
  boi, // 'B' - Body of Individuals
  trust, // 'T' - Trust
  localAuthority, // 'L'
  artificialJuridicalPerson, // 'J'
  government, // 'G' - Government Agency
  firm, // 'F' - Firm / LLP
  unknown,
}

/// Rich result of PAN Card validation.
class PanValidationResult {
  final String pan;
  final bool isValid;
  final PanCategory category;
  final String categoryDescription;
  final String? surnameOrNameInitial;
  final String? errorMessage;

  const PanValidationResult({
    required this.pan,
    required this.isValid,
    this.category = PanCategory.unknown,
    this.categoryDescription = 'Unknown',
    this.surnameOrNameInitial,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'PanValidationResult(pan: $pan, valid: $isValid, category: $categoryDescription)';
  }
}

/// Indian Permanent Account Number (PAN) validator and masker.
class BharatPan {
  static final RegExp _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  static const Map<String, (PanCategory, String)> _categoryMap = {
    'P': (PanCategory.individual, 'Individual (Person)'),
    'C': (PanCategory.company, 'Company'),
    'H': (PanCategory.huf, 'Hindu Undivided Family (HUF)'),
    'A': (PanCategory.aop, 'Association of Persons (AOP)'),
    'B': (PanCategory.boi, 'Body of Individuals (BOI)'),
    'T': (PanCategory.trust, 'Trust'),
    'L': (PanCategory.localAuthority, 'Local Authority'),
    'J': (PanCategory.artificialJuridicalPerson, 'Artificial Juridical Person'),
    'G': (PanCategory.government, 'Government Agency'),
    'F': (PanCategory.firm, 'Firm / Limited Liability Partnership (LLP)'),
  };

  /// Validates a PAN card string.
  ///
  /// Optionally verifies if the PAN belongs to a specific [expectedCategory]
  /// or if the 5th character matches the user's [surnameInitial].
  ///
  /// Examples:
  /// ```dart
  /// BharatPan.validate("ABCDE1234F"); // Checks basic structure
  /// BharatPan.validate("ABCPD1234F", expectedCategory: PanCategory.individual);
  /// ```
  static PanValidationResult validate(
    String? pan, {
    PanCategory? expectedCategory,
    String? surnameInitial,
  }) {
    if (pan == null || pan.trim().isEmpty) {
      return const PanValidationResult(
        pan: '',
        isValid: false,
        errorMessage: 'PAN cannot be empty',
      );
    }

    final cleaned = pan.trim().toUpperCase();

    if (cleaned.length != 10) {
      return PanValidationResult(
        pan: cleaned,
        isValid: false,
        errorMessage: 'PAN must be exactly 10 characters',
      );
    }

    if (!_panRegex.hasMatch(cleaned)) {
      return PanValidationResult(
        pan: cleaned,
        isValid: false,
        errorMessage: 'Invalid PAN structure. Expected: 5 letters, 4 digits, 1 letter',
      );
    }

    final fourthChar = cleaned[3];
    final fifthChar = cleaned[4];

    final categoryEntry = _categoryMap[fourthChar];
    if (categoryEntry == null) {
      return PanValidationResult(
        pan: cleaned,
        isValid: false,
        errorMessage: 'Invalid 4th character "$fourthChar" for PAN category',
      );
    }

    final (category, description) = categoryEntry;

    if (expectedCategory != null && category != expectedCategory) {
      return PanValidationResult(
        pan: cleaned,
        isValid: false,
        category: category,
        categoryDescription: description,
        surnameOrNameInitial: fifthChar,
        errorMessage:
            'PAN category is $description, but expected ${expectedCategory.name}',
      );
    }

    if (surnameInitial != null &&
        surnameInitial.isNotEmpty &&
        fifthChar != surnameInitial.toUpperCase()[0]) {
      return PanValidationResult(
        pan: cleaned,
        isValid: false,
        category: category,
        categoryDescription: description,
        surnameOrNameInitial: fifthChar,
        errorMessage:
            '5th character "$fifthChar" does not match expected surname initial "${surnameInitial[0]}"',
      );
    }

    return PanValidationResult(
      pan: cleaned,
      isValid: true,
      category: category,
      categoryDescription: description,
      surnameOrNameInitial: fifthChar,
    );
  }

  /// Determines the [PanCategory] from a PAN string.
  static PanCategory getCategory(String pan) {
    if (pan.length >= 4) {
      final fourthChar = pan[3].toUpperCase();
      return _categoryMap[fourthChar]?.$1 ?? PanCategory.unknown;
    }
    return PanCategory.unknown;
  }

  /// Masks a PAN card string, showing the digits and final letter (e.g. `XXXXX1234F`).
  static String mask(String pan, {String maskChar = 'X'}) {
    final cleaned = pan.trim().toUpperCase();
    if (cleaned.length != 10) return pan;
    return '${maskChar * 5}${cleaned.substring(5)}';
  }
}
