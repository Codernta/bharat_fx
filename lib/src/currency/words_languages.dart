/// Supported Indian languages for number to words conversion.
enum BharatLanguage {
  english,
  hindi,
  tamil,
  telugu,
  kannada,
  marathi,
  gujarati,
  bengali,
}

/// Language definitions and dictionaries for Indian numbering scale to words.
class WordsDictionary {
  final String zero;
  final String one;
  final String hundred;
  final String thousand;
  final String lakh;
  final String crore;
  final String arab;
  final String rupeeSingular;
  final String rupeePlural;
  final String paiseSingular;
  final String paisePlural;
  final String andWord;
  final String onlyWord;
  final String Function(int n) getUnderHundred;

  const WordsDictionary({
    required this.zero,
    required this.one,
    required this.hundred,
    required this.thousand,
    required this.lakh,
    required this.crore,
    required this.arab,
    required this.rupeeSingular,
    required this.rupeePlural,
    required this.paiseSingular,
    required this.paisePlural,
    required this.andWord,
    required this.onlyWord,
    required this.getUnderHundred,
  });
}

/// Dictionary lookup implementation for all supported languages.
class BharatWordDictionaries {
  static const Map<int, String> _englishUnits = {
    0: 'Zero',
    1: 'One',
    2: 'Two',
    3: 'Three',
    4: 'Four',
    5: 'Five',
    6: 'Six',
    7: 'Seven',
    8: 'Eight',
    9: 'Nine',
    10: 'Ten',
    11: 'Eleven',
    12: 'Twelve',
    13: 'Thirteen',
    14: 'Fourteen',
    15: 'Fifteen',
    16: 'Sixteen',
    17: 'Seventeen',
    18: 'Eighteen',
    19: 'Nineteen',
  };

  static const Map<int, String> _englishTens = {
    2: 'Twenty',
    3: 'Thirty',
    4: 'Forty',
    5: 'Fifty',
    6: 'Sixty',
    7: 'Seventy',
    8: 'Eighty',
    9: 'Ninety',
  };

  static String _englishUnderHundred(int n) {
    if (n < 20) return _englishUnits[n] ?? '';
    final ten = n ~/ 10;
    final unit = n % 10;
    if (unit == 0) return _englishTens[ten] ?? '';
    return '${_englishTens[ten]}-${_englishUnits[unit]}';
  }

  static const WordsDictionary english = WordsDictionary(
    zero: 'Zero',
    one: 'One',
    hundred: 'Hundred',
    thousand: 'Thousand',
    lakh: 'Lakh',
    crore: 'Crore',
    arab: 'Arab',
    rupeeSingular: 'Rupee',
    rupeePlural: 'Rupees',
    paiseSingular: 'Paisa',
    paisePlural: 'Paise',
    andWord: 'and',
    onlyWord: 'Only',
    getUnderHundred: _englishUnderHundred,
  );

  static const List<String> _hindiNumbers = [
    'शून्य', 'एक', 'दो', 'तीन', 'चार', 'पाँच', 'छह', 'सात', 'आठ', 'नौ',
    'दस', 'ग्यारह', 'बारह', 'तेरह', 'चौदह', 'पंद्रह', 'सोलह', 'सत्रह', 'अठारह', 'उन्नीस',
    'बीस', 'इक्कीस', 'बाईस', 'तेईस', 'चौबीस', 'पच्चीस', 'छब्बीस', 'सत्ताईस', 'अट्ठाईस', 'उनतीस',
    'तीस', 'इकतीस', 'बत्तीस', 'तैंतीस', 'चौंतीस', 'पैंतीस', 'छत्तीस', 'सैंतीस', 'अड़तीस', 'उनतालीस',
    'चालीस', 'इकतालीस', 'बयालीस', 'तैंतालीस', 'चवालीस', 'पैंतालीस', 'छियालीस', 'सैंतालीस', 'अड़तालीस', 'उनचास',
    'पचास', 'इक्यावन', 'बावन', 'तिरेपन', 'चौवन', 'पचपन', 'छप्पन', 'सत्तावन', 'अट्ठावन', 'उनसठ',
    'साठ', 'इकसठ', 'बासठ', 'तिरसठ', 'चौंसठ', 'पैंसठ', 'छियासठ', 'सरसठ', 'अड़सठ', 'उनहत्तर',
    'सत्तर', 'इकहत्तर', 'बहत्तर', 'तिहत्तर', 'चौहत्तर', 'पचहत्तर', 'छिहत्तर', 'सतहत्तर', 'अठहत्तर', 'उनासी',
    'अस्सी', 'इक्यासी', 'बयासी', 'तिरासी', 'चौरासी', 'पचासी', 'छियासी', 'सत्तासी', 'अट्ठासी', 'नवासी',
    'नब्बे', 'इक्यानवे', 'बानवे', 'तिरानवे', 'चौरानवे', 'पंचानवे', 'छियानवे', 'सत्तानवे', 'अट्ठानवे', 'निन्यानवे'
  ];

  static String _hindiUnderHundred(int n) {
    if (n >= 0 && n < _hindiNumbers.length) return _hindiNumbers[n];
    return '';
  }

  static const WordsDictionary hindi = WordsDictionary(
    zero: 'शून्य',
    one: 'एक',
    hundred: 'सौ',
    thousand: 'हज़ार',
    lakh: 'लाख',
    crore: 'करोड़',
    arab: 'अरब',
    rupeeSingular: 'रुपया',
    rupeePlural: 'रुपये',
    paiseSingular: 'पैसा',
    paisePlural: 'पैसे',
    andWord: 'और',
    onlyWord: 'मात्र',
    getUnderHundred: _hindiUnderHundred,
  );

  static const List<String> _tamilNumbers = [
    'பூஜ்ஜியம்', 'ஒன்று', 'இரண்டு', 'மூன்று', 'நான்கு', 'ஐந்து', 'ஆறு', 'ஏழு', 'எட்டு', 'ஒன்பது',
    'பத்து', 'பதினொன்று', 'பன்னிரண்டு', 'பதின்மூன்று', 'பதினான்கு', 'பதினைந்து', 'பதினாறு', 'பதினேழு', 'பதினெட்டு', 'பத்தொன்பது',
    'இருபது', 'இருபத்து ஒன்று', 'இருபத்து இரண்டு', 'இருபத்து மூன்று', 'இருபத்து நான்கு', 'இருபத்து ஐந்து', 'இருபத்து ஆறு', 'இருபத்து ஏழு', 'இருபத்து எட்டு', 'இருபத்து ஒன்பது',
    'முப்பது', 'முப்பத்து ஒன்று', 'முப்பத்து இரண்டு', 'முப்பத்து மூன்று', 'முப்பத்து நான்கு', 'முப்பத்து ஐந்து', 'முப்பத்து ஆறு', 'முப்பத்து ஏழு', 'முப்பத்து எட்டு', 'முப்பத்து ஒன்பது',
    'நாற்பது', 'நாற்பத்து ஒன்று', 'நாற்பத்து இரண்டு', 'நாற்பத்து மூன்று', 'நாற்பத்து நான்கு', 'நாற்பத்து ஐந்து', 'நாற்பத்து ஆறு', 'நாற்பத்து ஏழு', 'நாற்பத்து எட்டு', 'நாற்பத்து ஒன்பது',
    'ஐம்பது', 'ஐம்பத்து ஒன்று', 'ஐம்பத்து இரண்டு', 'ஐம்பத்து மூன்று', 'ஐம்பத்து நான்கு', 'ஐம்பத்து ஐந்து', 'ஐம்பத்து ஆறு', 'ஐம்பத்து ஏழு', 'ஐம்பத்து எட்டு', 'ஐம்பத்து ஒன்பது',
    'அறுபது', 'அறுபத்து ஒன்று', 'அறுபத்து இரண்டு', 'அறுபத்து மூன்று', 'அறுபத்து நான்கு', 'அறுபத்து ஐந்து', 'அறுபத்து ஆறு', 'அறுபத்து ஏழு', 'அறுபத்து எட்டு', 'அறுபத்து ஒன்பது',
    'எழுபது', 'எழுபத்து ஒன்று', 'எழுபத்து இரண்டு', 'எழுபத்து மூன்று', 'எழுபத்து நான்கு', 'எழுபத்து ஐந்து', 'எழுபத்து ஆறு', 'எழுபத்து ஏழு', 'எழுபத்து எட்டு', 'எழுபத்து ஒன்பது',
    'எண்பது', 'எண்பத்து ஒன்று', 'எண்பத்து இரண்டு', 'எண்பத்து மூன்று', 'எண்பத்து நான்கு', 'எண்பத்து ஐந்து', 'எண்பத்து ஆறு', 'எண்பத்து ஏழு', 'எண்பத்து எட்டு', 'எண்பத்து ஒன்பது',
    'தொண்ணூறு', 'தொண்ணூற்று ஒன்று', 'தொண்ணூற்று இரண்டு', 'தொண்ணூற்று மூன்று', 'தொண்ணூற்று நான்கு', 'தொண்ணூற்று ஐந்து', 'தொண்ணூற்று ஆறு', 'தொண்ணூற்று ஏழு', 'தொண்ணூற்று எட்டு', 'தொண்ணூற்று ஒன்பது'
  ];

  static String _tamilUnderHundred(int n) {
    if (n >= 0 && n < _tamilNumbers.length) return _tamilNumbers[n];
    return '';
  }

  static const WordsDictionary tamil = WordsDictionary(
    zero: 'பூஜ்ஜியம்',
    one: 'ஒரு',
    hundred: 'நூறு',
    thousand: 'ஆயிரம்',
    lakh: 'லட்சம்',
    crore: 'கோடி',
    arab: 'அரபு',
    rupeeSingular: 'ரூபாய்',
    rupeePlural: 'ரூபாய்',
    paiseSingular: 'பைசா',
    paisePlural: 'பைசா',
    andWord: 'மற்றும்',
    onlyWord: 'மட்டும்',
    getUnderHundred: _tamilUnderHundred,
  );

  static const List<String> _teluguNumbers = [
    'సున్నా', 'ఒకటి', 'రెండు', 'మూడు', 'నాలుగు', 'ఐదు', 'ఆరు', 'ఏడు', 'ఎనిమిది', 'తొమ్మిది',
    'పది', 'పదకొండు', 'పన్నెండు', 'పదమూడు', 'పద్నాలుగు', 'పదిహేను', 'పదహారు', 'పదిహేడు', 'పద్దెనిమిది', 'పంతొమ్మిది',
    'ఇరవై', 'ఇరవై ఒకటి', 'ఇరవై రెండు', 'ఇరవై మూడు', 'ఇరవై నాలుగు', 'ఇరవై ఐదు', 'ఇరవై ఆరు', 'ఇరవై ఏడు', 'ఇరవై ఎనిమిది', 'ఇరవై తొమ్మిది',
    'ముప్పై', 'ముప్పై ఒకటి', 'ముప్పై రెండు', 'ముప్పై మూడు', 'ముప్పై నాలుగు', 'ముప్పై ఐదు', 'ముప్పై ఆరు', 'ముప్పై ఏడు', 'ముప్పై ఎనిమిది', 'ముప్పై తొమ్మిది',
    'నలభై', 'నలభై ఒకటి', 'నలభై రెండు', 'నలభై మూడు', 'నలభై నాలుగు', 'నలభై ఐదు', 'నలభై ఆరు', 'నలభై ఏడు', 'నలభై ఎనిమిది', 'నలభై తొమ్మిది',
    'యాభై', 'యాభై ఒకటి', 'యాభై రెండు', 'యాభై మూడు', 'యాభై నాలుగు', 'యాభై ఐదు', 'యాభై ఆరు', 'యాభై ఏడు', 'యాభై ఎనిమిది', 'యాభై తొమ్మిది',
    'అరవై', 'అరవై ఒకటి', 'అరవై రెండు', 'అరవై మూడు', 'అరవై నాలుగు', 'అరవై ఐదు', 'అరవై ఆరు', 'అరవై ఏడు', 'అరవై ఎనిమిది', 'అరవై తొమ్మిది',
    'డెబ్బై', 'డెబ్బై ఒకటి', 'డెబ్బై రెండు', 'డెబ్బై మూడు', 'డెబ్బై నాలుగు', 'డెబ్బై ఐదు', 'డెబ్బై ఆరు', 'డెబ్బై ఏడు', 'డెబ్బై ఎనిమిది', 'డెబ్బై తొమ్మిది',
    'ఎనభై', 'ఎనభై ఒకటి', 'ఎనభై రెండు', 'ఎనభై మూడు', 'ఎనభై నాలుగు', 'ఎనభై ఐదు', 'ఎనభై ఆరు', 'ఎనభై ఏడు', 'ఎనభై ఎనిమిది', 'ఎనభై తొమ్మిది',
    'తొంభై', 'తొంభై ఒకటి', 'తొంభై రెండు', 'తొంభై మూడు', 'తొంభై నాలుగు', 'తొంభై ఐదు', 'తొంభై ఆరు', 'తొంభై ఏడు', 'తొంభై ఎనిమిది', 'తొంభై తొమ్మిది'
  ];

  static String _teluguUnderHundred(int n) {
    if (n >= 0 && n < _teluguNumbers.length) return _teluguNumbers[n];
    return '';
  }

  static const WordsDictionary telugu = WordsDictionary(
    zero: 'సున్నా',
    one: 'ఒక',
    hundred: 'వంద',
    thousand: 'వేలు',
    lakh: 'లక్ష',
    crore: 'కోటి',
    arab: 'అరబ్',
    rupeeSingular: 'రూపాయి',
    rupeePlural: 'రూపాయలు',
    paiseSingular: 'పైసా',
    paisePlural: 'పైసలు',
    andWord: 'మరియు',
    onlyWord: 'మాత్రమే',
    getUnderHundred: _teluguUnderHundred,
  );

  static const List<String> _kannadaNumbers = [
    'ಸೊನ್ನೆ', 'ಒಂದು', 'ಎರಡು', 'ಮೂರು', 'ನಾಲ್ಕು', 'ಐದು', 'ಆರು', 'ಏಳು', 'ಎಂಟು', 'ಒಂಬತ್ತು',
    'ಹತ್ತು', 'ಹನ್ನೊಂದು', 'ಹನ್ನೆರಡು', 'ಹದಿಮೂರು', 'ಹದಿನಾಲ್ಕು', 'ಹದಿನೈದು', 'ಹದಿನಾರು', 'ಹದಿನೇಳು', 'ಹದಿನೆಂಟು', 'ಹತ್ತೊಂಬತ್ತು',
    'ಇಪ್ಪತ್ತು', 'ಇಪ್ಪತ್ತೊಂದು', 'ಇಪ್ಪತ್ತೆರಡು', 'ಇಪ್ಪತ್ಮೂರು', 'ಇಪ್ಪತ್ತನಾಲ್ಕು', 'ಇಪ್ಪತ್ತೈದು', 'ಇಪ್ಪತ್ತಾರು', 'ಇಪ್ಪತ್ತೇಳು', 'ಇಪ್ಪತ್ತೆಂಟು', 'ಇಪ್ಪತ್ತೊಂಬತ್ತು',
    'ಮೂವತ್ತು', 'ಮೂವತ್ತೊಂದು', 'ಮೂವತ್ತೆರಡು', 'ಮೂವತ್ಮೂರು', 'ಮೂವತ್ತನಾಲ್ಕು', 'ಮೂವತ್ತೈದು', 'ಮೂವತ್ತಾರು', 'ಮೂವತ್ತೇಳು', 'ಮೂವತ್ತೆಂಟು', 'ಮೂವತ್ತೊಂಬತ್ತು',
    'ನಲವತ್ತು', 'ನಲವತ್ತೊಂದು', 'ನಲವತ್ತೆರಡು', 'ನಲವತ್ಮೂರು', 'ನಲವತ್ತನಾಲ್ಕು', 'ನಲವತ್ತೈದು', 'ನಲವತ್ತಾರು', 'ನಲವತ್ತೇಳು', 'ನಲವತ್ತೆಂಟು', 'ನಲವತ್ತೊಂಬತ್ತು',
    'ಐವತ್ತು', 'ಐವತ್ತೊಂದು', 'ಐವತ್ತೆರಡು', 'ಐವತ್ಮೂರು', 'ಐವತ್ತನಾಲ್ಕು', 'ಐವತ್ತೈದು', 'ಐವತ್ತಾರು', 'ಐವತ್ತೇಳು', 'ಐವತ್ತೆಂಟು', 'ಐವತ್ತೊಂಬತ್ತು',
    'ಅರವತ್ತು', 'ಅರವತ್ತೊಂದು', 'ಅರವತ್ತೆರಡು', 'ಅರವತ್ಮೂರು', 'ಅರವತ್ತನಾಲ್ಕು', 'ಅರವತ್ತೈದು', 'ಅರವತ್ತಾರು', 'ಅರವತ್ತೇಳು', 'ಅರವತ್ತೆಂಟು', 'ಅರವತ್ತೊಂಬತ್ತು',
    'ಎಪ್ಪತ್ತು', 'ಎಪ್ಪತ್ತೊಂದು', 'ಎಪ್ಪತ್ತೆರಡು', 'ಎಪ್ಪತ್ಮೂರು', 'ಎಪ್ಪತ್ತನಾಲ್ಕು', 'ಎಪ್ಪತ್ತೈದು', 'ಎಪ್ಪತ್ತಾರು', 'ಎಪ್ಪತ್ತೇಳು', 'ಎಪ್ಪತ್ತೆಂಟು', 'ಎಪ್ಪತ್ತೊಂಬತ್ತು',
    'ಎಂಬತ್ತು', 'ಎಂಬತ್ತೊಂದು', 'ಎಂಬತ್ತೆರಡು', 'ಎಂಬತ್ಮೂರು', 'ಎಂಬತ್ತನಾಲ್ಕು', 'ಎಂಬತ್ತೈದು', 'ಎಂಬತ್ತಾರು', 'ಎಂಬತ್ತೇಳು', 'ಎಂಬತ್ತೆಂಟು', 'ಎಂಬತ್ತೊಂಬತ್ತು',
    'ತೊಂಬತ್ತು', 'ತೊಂಬತ್ತೊಂದು', 'ತೊಂಬತ್ತೆರಡು', 'ತೊಂಬತ್ಮೂರು', 'ತೊಂಬತ್ತನಾಲ್ಕು', 'ತೊಂಬತ್ತೈದು', 'ತೊಂಬತ್ತಾರು', 'ತೊಂಬತ್ತೇಳು', 'ತೊಂಬತ್ತೆಂಟು', 'ತೊಂಬತ್ತೊಂಬತ್ತು'
  ];

  static String _kannadaUnderHundred(int n) {
    if (n >= 0 && n < _kannadaNumbers.length) return _kannadaNumbers[n];
    return '';
  }

  static const WordsDictionary kannada = WordsDictionary(
    zero: 'ಸೊನ್ನೆ',
    one: 'ಒಂದು',
    hundred: 'ನೂರು',
    thousand: 'ಸಾವಿರ',
    lakh: 'ಲಕ್ಷ',
    crore: 'ಕೋಟಿ',
    arab: 'ಅರಬ್',
    rupeeSingular: 'ರೂಪಾಯಿ',
    rupeePlural: 'ರೂಪಾಯಿಗಳು',
    paiseSingular: 'ಪೈಸೆ',
    paisePlural: 'ಪೈಸೆಗಳು',
    andWord: 'ಮತ್ತು',
    onlyWord: 'ಮಾತ್ರ',
    getUnderHundred: _kannadaUnderHundred,
  );

  static const List<String> _marathiNumbers = [
    'शून्य', 'एक', 'दोन', 'तीन', 'चार', 'पाच', 'सहा', 'सात', 'आठ', 'नऊ',
    'दहा', 'अकरा', 'बारा', 'तेरा', 'चौदा', 'पंधरा', 'सोळा', 'सतरा', 'अठरा', 'एकोणीस',
    'वीस', 'एकवीस', 'बावीस', 'तेवीस', 'चोवीस', 'पंचवीस', 'सव्वीस', 'सत्तावीस', 'अठ्ठावीस', 'एकोणतीस',
    'तीस', 'एकतीस', 'बत्तीस', 'तेहेतीस', 'चौतीस', 'पस्तीस', 'छत्तीस', 'सदतीस', 'अडतीस', 'एकेचाळीस',
    'चाळीस', 'एक्केचाळीस', 'बेचाळीस', 'त्रेचाळीस', 'चव्वेचाळीस', 'पंचेचाळीस', 'शेहेचाळीस', 'सत्तेचाळीस', 'अठ्ठेचाळीस', 'एकोणपन्नास',
    'पन्नास', 'एक्कावन्न', 'बावन्न', 'त्रेपन्न', 'चौपन्न', 'पंचावन्न', 'छप्पन्न', 'सत्तावन्न', 'अठ्ठावन्न', 'एकोणसाठ',
    'साठ', 'एकसष्ठ', 'बासष्ठ', 'त्रेसष्ठ', 'चौसष्ठ', 'पासष्ठ', 'सहासष्ठ', 'सदुसष्ठ', 'अडुसष्ठ', 'एकोणसत्तर',
    'सत्तर', 'एकाहत्तर', 'बाहत्तर', 'त्र्याहत्तर', 'चौर्‍याहत्तर', 'पंच्याहत्तर', 'शहात्तर', 'सत्त्याहत्तर', 'अठ्ठ्याहत्तर', 'एकोणऐंशी',
    'ऐंशी', 'एक्क्यांशी', 'ब्यांशी', 'त्र्यांशी', 'चौऱ्यांशी', 'पंच्यांशी', 'शहांशी', 'सत्त्यांशी', 'अठ्ठ्यांशी', 'एकोणनव्वद',
    'नव्वद', 'एक्क्याण्णव', 'ब्याण्णव', 'त्र्याण्णव', 'चौऱ्याण्णव', 'पंच्याण्णव', 'शहाण्णव', 'सत्त्याण्णव', 'अठ्ठ्याण्णव', 'नव्व्याण्णव'
  ];

  static String _marathiUnderHundred(int n) {
    if (n >= 0 && n < _marathiNumbers.length) return _marathiNumbers[n];
    return '';
  }

  static const WordsDictionary marathi = WordsDictionary(
    zero: 'शून्य',
    one: 'एक',
    hundred: 'शे',
    thousand: 'हजार',
    lakh: 'लाख',
    crore: 'कोटी',
    arab: 'अब्ज',
    rupeeSingular: 'रुपया',
    rupeePlural: 'रुपये',
    paiseSingular: 'पैसा',
    paisePlural: 'पैसे',
    andWord: 'आणि',
    onlyWord: 'फक्त',
    getUnderHundred: _marathiUnderHundred,
  );

  static const List<String> _gujaratiNumbers = [
    'શૂન્ય', 'એક', 'બે', 'ત્રણ', 'ચાર', 'પાંચ', 'છ', 'સાત', 'આઠ', 'નવ',
    'દસ', 'અગિયાર', 'બાર', 'તેર', 'ચૌદ', 'પંદર', 'સોળ', 'સત્તર', 'અઢાર', 'ઓગણિસ',
    'વીસ', 'એકવીસ', 'બાવીસ', 'તેવીસ', 'ચોવીસ', 'પચ્ચીસ', 'છવ્વીસ', 'સત્તાવીસ', 'અઠ્ઠાવીસ', 'ઓગણત્રીસ',
    'ત્રીસ', 'એકત્રીસ', 'બત્રીસ', 'તેત્રીસ', 'ચોત્રીસ', 'પાંત્રીસ', 'છત્રીસ', 'સાડત્રીસ', 'ઓડત્રીસ', 'ઓગણચાલીસ',
    'ચાલીસ', 'એકતાલીસ', 'બેતાલીસ', 'તેતાલીસ', 'ચુંમાલીસ', 'પિસ્તાલીસ', 'છેતાલીસ', 'સુડતાલીસ', 'અડતાલીસ', 'ઓગણપચાસ',
    'પચાસ', 'એકાવન', 'બાવન', 'ત્રેપન', 'ચોપન', 'પંચાવન', 'છપ્પન', 'સત્તાવન', 'અઠ્ઠાવન', 'ઓગણસાઠ',
    'સાઠ', 'એકસઠ', 'બાસઠ', 'ત્રેસઠ', 'ચોસઠ', 'પાંસઠ', 'છાસઠ', 'સડસઠ', 'અડસઠ', 'અગણોસિત્તેર',
    'સિત્તેર', 'એકોતેર', 'બોતેર', 'તોતેર', 'ચોતેર', 'પંચોતેર', 'છોતેર', 'સંતોતેર', 'ઇઠોતેર', 'ઓગણાએંસી',
    'એંસી', 'એક્યાસી', 'બ્યાસી', 'ત્યાસી', 'ચોર્યાસી', 'પંચાસી', 'છ્યાસી', 'સિત્યાસી', 'અઠ્યાસી', 'નેવ્યાસી',
    'નેવું', 'એકાણું', 'બાણું', 'ત્રાણું', 'ચોરાણું', 'પંચાણું', 'છન્નું', 'સત્તાણું', 'અઠ્ઠાણું', 'નવ્વાણું'
  ];

  static String _gujaratiUnderHundred(int n) {
    if (n >= 0 && n < _gujaratiNumbers.length) return _gujaratiNumbers[n];
    return '';
  }

  static const WordsDictionary gujarati = WordsDictionary(
    zero: 'શૂન્ય',
    one: 'એક',
    hundred: 'સો',
    thousand: 'હજાર',
    lakh: 'લાખ',
    crore: 'કરોડ',
    arab: 'અબજ',
    rupeeSingular: 'રૂપિયો',
    rupeePlural: 'રૂપિયા',
    paiseSingular: 'પૈસો',
    paisePlural: 'પૈસા',
    andWord: 'અને',
    onlyWord: 'માત્ર',
    getUnderHundred: _gujaratiUnderHundred,
  );

  static const List<String> _bengaliNumbers = [
    'শূন্য', 'এক', 'দুই', 'তিন', 'চার', 'পাঁচ', 'ছয়', 'সাত', 'আট', 'নয়',
    'দশ', 'এগারো', 'বারো', 'তেরো', 'চোদ্দ', 'পনেরো', 'ষোলো', 'সতেরো', 'আঠারো', 'উনিশ',
    'কুড়ি', 'একুশ', 'বাইশ', 'তেইশ', 'চব্বিশ', 'পঁচিশ', 'ছাব্বিশ', 'সাতাশ', 'আঠাশ', 'উনত্রিশ',
    'ত্রিশ', 'একত্রিশ', 'বত্রিশ', 'তেত্রিশ', 'চৌত্রিশ', 'পঁয়ত্রিশ', 'ছত্রিশ', 'সাঁইত্রিশ', 'আটত্রিশ', 'উনচল্লিশ',
    'চল্লিশ', 'একচল্লিশ', 'বিয়াল্লিশ', 'তেতাল্লিশ', 'চুয়াল্লিশ', 'পঁয়তাল্লিশ', 'ছেচল্লিশ', 'সাতচল্লিশ', 'আটচল্লিশ', 'উনপঞ্চাশ',
    'পঞ্চাশ', 'একান্ন', 'বায়ান্ন', 'তিপ্পান্ন', 'চুয়ান্ন', 'পঞ্চান্ন', 'ছাপ্পান্ন', 'সাতান্ন', 'আটান্ন', 'উনষাট',
    'ষাট', 'একষট্টি', 'বাষট্টি', 'তেষট্টি', 'চৌষট্টি', 'পঁয়ষট্টি', 'ছেষট্টি', 'সাতষট্টি', 'আটষট্টি', 'উনসত্তর',
    'সত্তর', 'একাত্তর', 'বাহাত্তর', 'তিয়াত্তর', 'চুয়াত্তর', 'পঁচাত্তর', 'ছিয়াত্তর', 'সাতাত্তর', 'আটাত্তর', 'ঊনআশি',
    'আশি', 'একাশি', 'বিরাশি', 'তিরাশি', 'চুরাশি', 'পঁচাশি', 'ছিয়াশি', 'সাতাশি', 'আটাশি', 'ঊননব্বই',
    'নব্বই', 'একানব্বই', 'বানব্বই', 'তিরানব্বই', 'চুরানব্বই', 'পঁচানব্বই', 'ছিয়ানব্বই', 'সাতানব্বই', 'আটানব্বই', 'নিরানব্বই'
  ];

  static String _bengaliUnderHundred(int n) {
    if (n >= 0 && n < _bengaliNumbers.length) return _bengaliNumbers[n];
    return '';
  }

  static const WordsDictionary bengali = WordsDictionary(
    zero: 'শূন্য',
    one: 'এক',
    hundred: 'শত',
    thousand: 'হাজার',
    lakh: 'লাখ',
    crore: 'কোটি',
    arab: 'আরব',
    rupeeSingular: 'টাকা',
    rupeePlural: 'টাকা',
    paiseSingular: 'পয়সা',
    paisePlural: 'পয়সা',
    andWord: 'এবং',
    onlyWord: 'মাত্র',
    getUnderHundred: _bengaliUnderHundred,
  );

  static WordsDictionary get(BharatLanguage language) {
    switch (language) {
      case BharatLanguage.english:
        return english;
      case BharatLanguage.hindi:
        return hindi;
      case BharatLanguage.tamil:
        return tamil;
      case BharatLanguage.telugu:
        return telugu;
      case BharatLanguage.kannada:
        return kannada;
      case BharatLanguage.marathi:
        return marathi;
      case BharatLanguage.gujarati:
        return gujarati;
      case BharatLanguage.bengali:
        return bengali;
    }
  }
}
