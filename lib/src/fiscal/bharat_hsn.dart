/// Result of Indian HSN (Harmonized System of Nomenclature) code validation.
class HsnValidationResult {
  /// Cleaned numeric HSN code.
  final String code;

  /// Whether the code is a syntactically and structurally valid HSN code.
  final bool isValid;

  /// Number of digits (2, 4, 6, or 8).
  final int length;

  /// 2-digit chapter code (e.g., "85" for Electrical Machinery).
  final String? chapterCode;

  /// Official description of the 2-digit chapter, if recognized.
  final String? chapterDescription;

  /// 4-digit heading prefix (e.g., "8517").
  final String? headingCode;

  /// Explanation if validation fails.
  final String? errorMessage;

  const HsnValidationResult({
    required this.code,
    required this.isValid,
    this.length = 0,
    this.chapterCode,
    this.chapterDescription,
    this.headingCode,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'HsnValidationResult(code: $code, valid: $isValid, len: $length, chapter: $chapterDescription)';
  }
}

/// Result of Indian SAC (Services Accounting Code) validation.
class SacValidationResult {
  /// Cleaned 6-digit SAC code.
  final String code;

  /// Whether the code is a valid 6-digit SAC code starting with 99.
  final bool isValid;

  /// 4-digit service heading (e.g., "9983").
  final String? headingCode;

  /// Service category description for the 4-digit heading.
  final String? serviceCategory;

  /// Explanation if validation fails.
  final String? errorMessage;

  const SacValidationResult({
    required this.code,
    required this.isValid,
    this.headingCode,
    this.serviceCategory,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'SacValidationResult(code: $code, valid: $isValid, category: $serviceCategory)';
  }
}

/// Indian HSN (Harmonized System of Nomenclature) Code Validator & Offline Chapter Lookup.
///
/// HSN codes classify physical goods under Indian GST and international customs:
/// - 2 digits: Chapter level.
/// - 4 digits: Heading level (mandated for B2B supplies with turnover <= ₹5 Cr).
/// - 6 digits: Subheading level (mandated for all supplies with turnover > ₹5 Cr).
/// - 8 digits: National Tariff Item level (mandated for export/import & specific chemicals).
class BharatHsn {
  static final RegExp _digitsOnly = RegExp(r'^[0-9]+$');

  /// Validates an HSN code.
  ///
  /// Checks:
  /// - Only numeric digits.
  /// - Allowed lengths: 2, 4, 6, or 8 digits.
  /// - Chapter (first 2 digits) between 01 and 98 (Chapter 99 is reserved for SAC).
  static HsnValidationResult validate(String? hsnCode) {
    if (hsnCode == null || hsnCode.trim().isEmpty) {
      return const HsnValidationResult(
        code: '',
        isValid: false,
        errorMessage: 'HSN code cannot be empty',
      );
    }

    final cleaned = hsnCode.trim();

    if (!_digitsOnly.hasMatch(cleaned)) {
      return HsnValidationResult(
        code: cleaned,
        isValid: false,
        errorMessage: 'HSN code must contain only numeric digits',
      );
    }

    final len = cleaned.length;
    if (len != 2 && len != 4 && len != 6 && len != 8) {
      return HsnValidationResult(
        code: cleaned,
        isValid: false,
        length: len,
        errorMessage:
            'HSN code must be exactly 2, 4, 6, or 8 digits (got $len digits)',
      );
    }

    final chapter = cleaned.substring(0, 2);
    if (chapter == '99') {
      return HsnValidationResult(
        code: cleaned,
        isValid: false,
        length: len,
        chapterCode: chapter,
        errorMessage:
            'Code starts with 99, which is reserved for SAC (Services Accounting Code), not HSN goods',
      );
    }

    final chapterNum = int.tryParse(chapter) ?? 0;
    if (chapterNum < 1 || chapterNum > 98) {
      return HsnValidationResult(
        code: cleaned,
        isValid: false,
        length: len,
        chapterCode: chapter,
        errorMessage:
            'Invalid HSN Chapter "$chapter". Valid chapters are 01 to 98',
      );
    }

    final chapterDesc = chapters[chapter];
    final heading = len >= 4 ? cleaned.substring(0, 4) : null;

    return HsnValidationResult(
      code: cleaned,
      isValid: true,
      length: len,
      chapterCode: chapter,
      chapterDescription: chapterDesc,
      headingCode: heading,
    );
  }

  /// Verifies if an HSN code meets statutory Indian GST compliance based on the taxpayer's annual turnover.
  ///
  /// Compliance Rules (Notification No. 78/2020 - Central Tax):
  /// - Aggregate Turnover <= ₹5 Crores:
  ///   - B2B invoices: Minimum 4 digits required.
  ///   - B2C invoices: Optional (0 or 4 digits).
  /// - Aggregate Turnover > ₹5 Crores:
  ///   - All B2B & B2C invoices: Minimum 6 digits mandatory.
  /// - Export / Import transactions: 8 digits mandatory.
  static bool isTurnoverCompliant({
    required String? hsnCode,
    required double turnoverInCrores,
    bool isB2b = true,
    bool isExportOrImport = false,
  }) {
    if (isExportOrImport) {
      final res = validate(hsnCode);
      return res.isValid && res.length == 8;
    }

    final res = validate(hsnCode);
    if (!res.isValid) return false;

    if (turnoverInCrores > 5.0) {
      // Must be at least 6 digits
      return res.length >= 6;
    } else {
      // Turnover <= 5 Crores
      if (isB2b) {
        return res.length >= 4;
      }
      return true; // Optional for B2C
    }
  }

  /// Official 2-digit Indian GST HSN Chapters dictionary.
  static const Map<String, String> chapters = {
    '01': 'Live animals',
    '02': 'Meat and edible meat offal',
    '03': 'Fish and crustaceans, molluscs and other aquatic invertebrates',
    '04':
        'Dairy produce; birds eggs; natural honey; edible products of animal origin',
    '05': 'Products of animal origin, not elsewhere specified or included',
    '06': 'Live trees and other plants; bulbs, roots and the like; cut flowers',
    '07': 'Edible vegetables and certain roots and tubers',
    '08': 'Edible fruit and nuts; peel of citrus fruit or melons',
    '09': 'Coffee, tea, maté and spices',
    '10': 'Cereals',
    '11':
        'Products of the milling industry; malt; starches; inulin; wheat gluten',
    '12':
        'Oil seeds and oleaginous fruits; miscellaneous grains, seeds and fruit',
    '13': 'Lac; gums, resins and other vegetable saps and extracts',
    '14':
        'Vegetable plaiting materials; vegetable products not elsewhere specified',
    '15': 'Animal or vegetable fats and oils and their cleavage products',
    '16': 'Preparations of meat, of fish or of crustaceans, molluscs',
    '17': 'Sugars and sugar confectionery',
    '18': 'Cocoa and cocoa preparations',
    '19':
        'Preparations of cereals, flour, starch or milk; pastrycooks products',
    '20': 'Preparations of vegetables, fruit, nuts or other parts of plants',
    '21': 'Miscellaneous edible preparations',
    '22': 'Beverages, spirits and vinegar',
    '23': 'Residues and waste from the food industries; prepared animal fodder',
    '24': 'Tobacco and manufactured tobacco substitutes',
    '25':
        'Salt; sulphur; earths and stone; plastering materials, lime and cement',
    '26': 'Ores, slag and ash',
    '27':
        'Mineral fuels, mineral oils and products of their distillation; bituminous substances',
    '28':
        'Inorganic chemicals; organic or inorganic compounds of precious metals',
    '29': 'Organic chemicals',
    '30': 'Pharmaceutical products',
    '31': 'Fertilisers',
    '32':
        'Tanning or dyeing extracts; tannins and their derivatives; dyes, pigments',
    '33':
        'Essential oils and resinoids; perfumery, cosmetic or toilet preparations',
    '34':
        'Soap, organic surface-active agents, washing preparations, lubricating preparations',
    '35': 'Albuminoidal substances; modified starches; glues; enzymes',
    '36': 'Explosives; pyrotechnic products; matches; pyrophoric alloys',
    '37': 'Photographic or cinematographic goods',
    '38': 'Miscellaneous chemical products',
    '39': 'Plastics and articles thereof',
    '40': 'Rubber and articles thereof',
    '41': 'Raw hides and skins (other than furskins) and leather',
    '42': 'Articles of leather; saddlery and harness; travel goods, handbags',
    '43': 'Furskins and artificial fur; manufactures thereof',
    '44': 'Wood and articles of wood; wood charcoal',
    '45': 'Cork and articles of cork',
    '46':
        'Manufactures of straw, of esparto or of other plaiting materials; basketware',
    '47':
        'Pulp of wood or of other fibrous cellulosic material; recovered paper or paperboard',
    '48':
        'Paper and paperboard; articles of paper pulp, of paper or of paperboard',
    '49':
        'Printed books, newspapers, pictures and other products of the printing industry',
    '50': 'Silk',
    '51': 'Wool, fine or coarse animal hair; horsehair yarn and woven fabric',
    '52': 'Cotton',
    '53':
        'Other vegetable textile fibres; paper yarn and woven fabrics of paper yarn',
    '54':
        'Man-made filaments; strip and the like of man-made textile materials',
    '55': 'Man-made staple fibres',
    '56':
        'Wadding, felt and nonwovens; special yarns; twine, cordage, ropes and cables',
    '57': 'Carpets and other textile floor coverings',
    '58':
        'Special woven fabrics; tufted textile fabrics; lace; tapestries; trimmings; embroidery',
    '59':
        'Impregnated, coated, covered or laminated textile fabrics; textile articles for industrial use',
    '60': 'Knitted or crocheted fabrics',
    '61': 'Articles of apparel and clothing accessories, knitted or crocheted',
    '62':
        'Articles of apparel and clothing accessories, not knitted or crocheted',
    '63':
        'Other made up textile articles; sets; worn clothing and worn textile articles; rags',
    '64': 'Footwear, gaiters and the like; parts of such articles',
    '65': 'Headgear and parts thereof',
    '66':
        'Umbrellas, sun umbrellas, walking-sticks, seat-sticks, whips, riding-crops and parts thereof',
    '67':
        'Prepared feathers and down and articles made of feathers or of down; artificial flowers',
    '68':
        'Articles of stone, plaster, cement, asbestos, mica or similar materials',
    '69': 'Ceramic products',
    '70': 'Glass and glassware',
    '71':
        'Natural or cultured pearls, precious or semi-precious stones, precious metals',
    '72': 'Iron and steel',
    '73': 'Articles of iron or steel',
    '74': 'Copper and articles thereof',
    '75': 'Nickel and articles thereof',
    '76': 'Aluminium and articles thereof',
    '78': 'Lead and articles thereof',
    '79': 'Zinc and articles thereof',
    '80': 'Tin and articles thereof',
    '81': 'Other base metals; cermets; articles thereof',
    '82':
        'Tools, implements, cutlery, spoons and forks, of base metal; parts thereof',
    '83': 'Miscellaneous articles of base metal',
    '84':
        'Nuclear reactors, boilers, machinery and mechanical appliances; parts thereof',
    '85':
        'Electrical machinery and equipment and parts thereof; sound recorders and reproducers',
    '86':
        'Railway or tramway locomotives, rolling-stock and parts thereof; track fixtures and fittings',
    '87':
        'Vehicles other than railway or tramway rolling-stock, and parts and accessories thereof',
    '88': 'Aircraft, spacecraft, and parts thereof',
    '89': 'Ships, boats and floating structures',
    '90':
        'Optical, photographic, cinematographic, measuring, checking, precision, medical or surgical instruments',
    '91': 'Clocks and watches and parts thereof',
    '92': 'Musical instruments; parts and accessories of such articles',
    '93': 'Arms and ammunition; parts and accessories thereof',
    '94':
        'Furniture; bedding, mattresses, mattress supports, cushions; lamps and lighting fittings',
    '95': 'Toys, games and sports requisites; parts and accessories thereof',
    '96': 'Miscellaneous manufactured articles',
    '97': 'Works of art, collectors pieces and antiques',
    '98':
        'Project imports; laboratory chemicals; passengers baggage; postal articles',
  };
}

/// Indian SAC (Services Accounting Code) Validator & Offline Heading Lookup.
///
/// In Indian GST, all services are categorized under Chapter 99 and have a standard 6-digit structure:
/// - First 2 digits: Always "99".
/// - Next 2 digits: Heading / Major Service Section (e.g., "83" for Information Technology & Consulting).
/// - Last 2 digits: Specific service line detail.
class BharatSac {
  static final RegExp _sacRegex = RegExp(r'^99[0-9]{4}$');

  /// Validates a 6-digit Indian SAC code.
  static SacValidationResult validate(String? sacCode) {
    if (sacCode == null || sacCode.trim().isEmpty) {
      return const SacValidationResult(
        code: '',
        isValid: false,
        errorMessage: 'SAC code cannot be empty',
      );
    }

    final cleaned = sacCode.trim();

    if (cleaned.length != 6) {
      return SacValidationResult(
        code: cleaned,
        isValid: false,
        errorMessage:
            'SAC code must be exactly 6 digits (got ${cleaned.length} digits)',
      );
    }

    if (!cleaned.startsWith('99')) {
      return SacValidationResult(
        code: cleaned,
        isValid: false,
        errorMessage:
            'SAC code must start with "99" (Chapter 99 represents Services under Indian GST)',
      );
    }

    if (!_sacRegex.hasMatch(cleaned)) {
      return SacValidationResult(
        code: cleaned,
        isValid: false,
        errorMessage: 'SAC code must contain only numeric digits',
      );
    }

    final heading = cleaned.substring(0, 4);
    final category = headings[heading];

    return SacValidationResult(
      code: cleaned,
      isValid: true,
      headingCode: heading,
      serviceCategory: category,
    );
  }

  /// Official SAC 4-digit major service headings under Chapter 99.
  static const Map<String, String> headings = {
    '9954': 'Construction services',
    '9961': 'Services in wholesale trade',
    '9962': 'Services in retail trade',
    '9963': 'Accommodation, food and beverage services',
    '9964': 'Passenger transport services',
    '9965': 'Goods transport services',
    '9966': 'Rental services of transport vehicles with or without operator',
    '9967': 'Supporting and auxiliary transport services',
    '9968': 'Postal and courier services',
    '9969': 'Electricity, gas, water and other distribution services',
    '9971': 'Financial and related services (Banking, Insurance, Investments)',
    '9972': 'Real estate services',
    '9973': 'Leasing or rental services with or without operator',
    '9981': 'Research and development services',
    '9982': 'Legal and accounting services',
    '9983':
        'Other professional, technical and business services (Information Technology, Consulting, Advertising)',
    '9984': 'Telecommunications, broadcasting and information supply services',
    '9985': 'Support services (Employment, Security, Cleaning, Travel Agency)',
    '9986':
        'Support services to agriculture, hunting, forestry, fishing, mining and utilities',
    '9987':
        'Maintenance, repair and installation (except construction) services',
    '9988':
        'Manufacturing services on physical inputs owned by others (Job work)',
    '9989':
        'Other manufacturing services; publishing, printing and reproduction services',
    '9991':
        'Public administration and other services to the community as a whole',
    '9992': 'Education services',
    '9993': 'Human health and social care services',
    '9994':
        'Sewage and waste collection, treatment and disposal and other environmental protection services',
    '9995': 'Services of membership organisations',
    '9996': 'Recreational, cultural and sporting services',
    '9997': 'Other miscellaneous services (Washing, Hairdressing, Funeral)',
    '9999': 'Services provided by extraterritorial organisations and bodies',
  };
}
