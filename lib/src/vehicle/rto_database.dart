/// Complete registry of Indian States and Union Territories with vehicle registration codes.
class BharatRtoDatabase {
  /// All 36 State and Union Territory codes.
  static const Map<String, String> stateCodes = {
    'AN': 'Andaman and Nicobar Islands',
    'AP': 'Andhra Pradesh',
    'AR': 'Arunachal Pradesh',
    'AS': 'Assam',
    'BR': 'Bihar',
    'CG': 'Chhattisgarh',
    'CH': 'Chandigarh',
    'DD': 'Daman and Diu',
    'DL': 'Delhi',
    'DN': 'Dadra and Nagar Haveli',
    'GA': 'Goa',
    'GJ': 'Gujarat',
    'HP': 'Himachal Pradesh',
    'HR': 'Haryana',
    'JH': 'Jharkhand',
    'JK': 'Jammu and Kashmir',
    'KA': 'Karnataka',
    'KL': 'Kerala',
    'LA': 'Ladakh',
    'LD': 'Lakshadweep',
    'MH': 'Maharashtra',
    'ML': 'Meghalaya',
    'MN': 'Manipur',
    'MP': 'Madhya Pradesh',
    'MZ': 'Mizoram',
    'NL': 'Nagaland',
    'OD': 'Odisha',
    'OR': 'Odisha', // Legacy code
    'PB': 'Punjab',
    'PY': 'Puducherry',
    'RJ': 'Rajasthan',
    'SK': 'Sikkim',
    'TN': 'Tamil Nadu',
    'TR': 'Tripura',
    'TS': 'Telangana',
    'UA': 'Uttarakhand', // Legacy code
    'UK': 'Uttarakhand',
    'UP': 'Uttar Pradesh',
    'WB': 'West Bengal',
  };

  /// Common RTO location directory by state and RTO number.
  static const Map<String, String> rtoLocations = {
    // Delhi
    'DL01': 'Mall Road, North Delhi',
    'DL02': 'IP Depot, New Delhi',
    'DL03': 'Sheikh Sarai, South Delhi',
    'DL04': 'Janakpuri, West Delhi',
    'DL05': 'Loni Road, North East Delhi',
    'DL06': 'Sarai Kale Khan, Central Delhi',
    'DL07': 'Mayur Vihar, East Delhi',
    'DL08': 'Wazirpur, North West Delhi',
    'DL09': 'Palam, South West Delhi',
    'DL10': 'Raja Garden, West Delhi',
    'DL11': 'Rohini, North West Delhi',
    'DL12': 'Vasant Vihar, South West Delhi',
    'DL13': 'Surajmal Vihar, East Delhi',

    // Karnataka
    'KA01': 'Koramangala, Bengaluru Central',
    'KA02': 'Rajajinagar, Bengaluru West',
    'KA03': 'Indiranagar, Bengaluru East',
    'KA04': 'Yeshwanthpur, Bengaluru North',
    'KA05': 'Jayanagar, Bengaluru South',
    'KA09': 'Mysuru West',
    'KA19': 'Mangaluru',
    'KA20': 'Udupi',
    'KA22': 'Belagavi',
    'KA25': 'Dharwad',
    'KA50': 'Yelahanka, Bengaluru North',
    'KA51': 'Electronics City, Bengaluru South',
    'KA53': 'KR Puram, Bengaluru East',

    // Maharashtra
    'MH01': 'Mumbai South (Tardeo)',
    'MH02': 'Mumbai West (Andheri)',
    'MH03': 'Mumbai East (Wadala)',
    'MH04': 'Thane',
    'MH05': 'Kalyan',
    'MH12': 'Pune Central',
    'MH14': 'Pimpri-Chinchwad',
    'MH15': 'Nashik',
    'MH20': 'Chhatrapati Sambhajinagar (Aurangabad)',
    'MH31': 'Nagpur',
    'MH43': 'Navi Mumbai (Vashi)',
    'MH46': 'Panvel, Navi Mumbai',
    'MH47': 'Mumbai North (Borivali)',

    // Tamil Nadu
    'TN01': 'Chennai Central (Ayanavaram)',
    'TN02': 'Chennai North West (Anna Nagar)',
    'TN03': 'Chennai North East (Tondiarpet)',
    'TN04': 'Chennai East (Pulianthope)',
    'TN05': 'Chennai North (Kolathur)',
    'TN06': 'Chennai South East (Mandavelli)',
    'TN07': 'Chennai South (Thiruvanmiyur)',
    'TN09': 'Chennai West (KK Nagar)',
    'TN10': 'Chennai South West (Virugambakkam)',
    'TN22': 'Meenambakkam (Alandur)',
    'TN37': 'Coimbatore South',
    'TN38': 'Coimbatore North',
    'TN58': 'Madurai South',
    'TN59': 'Madurai North',

    // Telangana
    'TS07': 'Ranga Reddy (Attapur)',
    'TS08': 'Medchal-Malkajgiri',
    'TS09': 'Hyderabad Central (Khairatabad)',
    'TS10': 'Secunderabad',
    'TS11': 'Hyderabad East (Malakpet)',
    'TS12': 'Hyderabad South (Kishanbagh)',
    'TS13': 'Hyderabad West (Tolichowki)',

    // Uttar Pradesh
    'UP14': 'Ghaziabad',
    'UP16': 'Gautam Buddha Nagar (Noida)',
    'UP32': 'Lucknow Transport Nagar',
    'UP70': 'Prayagraj (Allahabad)',
    'UP78': 'Kanpur Nagar',
    'UP80': 'Agra',

    // Gujarat
    'GJ01': 'Ahmedabad West (Subhash Bridge)',
    'GJ02': 'Mehsana',
    'GJ03': 'Rajkot',
    'GJ05': 'Surat',
    'GJ06': 'Vadodara',
    'GJ18': 'Gandhinagar',
    'GJ27': 'Ahmedabad East (Vastral)',

    // West Bengal
    'WB01': 'Kolkata (Beltala - Two Wheelers)',
    'WB02': 'Kolkata (Beltala - Four Wheelers)',
    'WB06': 'Kolkata (Kasba - South)',
    'WB19': 'Alipore, South 24 Parganas',
    'WB20': 'Alipore (Commercial)',
    'WB24': 'Barrackpore, North 24 Parganas',
  };

  /// Looks up State name from 2-letter state code.
  static String? getStateName(String stateCode) {
    return stateCodes[stateCode.toUpperCase()];
  }

  /// Looks up RTO location from State and RTO code (e.g. "KA", "01").
  static String? getRtoLocation(String stateCode, String rtoCode) {
    final cleanState = stateCode.toUpperCase();
    final cleanRto = rtoCode.padLeft(2, '0').toUpperCase();
    return rtoLocations['$cleanState$cleanRto'];
  }
}
