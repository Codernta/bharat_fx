import 'package:flutter/material.dart';
import 'package:bharat_fx/bharat_fx.dart';

void main() {
  runApp(const BharatFxShowcaseApp());
}

class BharatFxShowcaseApp extends StatelessWidget {
  const BharatFxShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bharat FX Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9933), // Saffron / Indian Orange
          brightness: Brightness.light,
        ),
      ),
      home: const ShowcaseHomeScreen(),
    );
  }
}

class ShowcaseHomeScreen extends StatefulWidget {
  const ShowcaseHomeScreen({super.key});

  @override
  State<ShowcaseHomeScreen> createState() => _ShowcaseHomeScreenState();
}

class _ShowcaseHomeScreenState extends State<ShowcaseHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    CurrencyShowcase(),
    PinCodeShowcase(),
    VernacularShowcase(),
    VehicleShowcase(),
    IdShowcase(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9933),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'BHARAT FX',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Indian Localization Toolkit',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        elevation: 2,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.currency_rupee),
            label: 'Currency',
          ),
          NavigationDestination(
            icon: Icon(Icons.pin_drop_outlined),
            label: 'PIN Code',
          ),
          NavigationDestination(
            icon: Icon(Icons.translate),
            label: 'Vernacular',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            label: 'Vehicle',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            label: 'Govt IDs',
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 1. Currency Showcase
// -------------------------------------------------------------
class CurrencyShowcase extends StatefulWidget {
  const CurrencyShowcase({super.key});

  @override
  State<CurrencyShowcase> createState() => _CurrencyShowcaseState();
}

class _CurrencyShowcaseState extends State<CurrencyShowcase> {
  final _amountController = TextEditingController(text: '1250000');
  BharatLanguage _selectedLanguage = BharatLanguage.english;
  num _currentAmount = 1250000;

  void _onAmountChanged(String val) {
    final parsed = BharatCurrency.parse(val) ?? 0;
    setState(() {
      _currentAmount = parsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '1. Indian Currency Formatter (BharatCurrency)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Automatically formats integers/doubles into the Indian Lakh/Crore numbering system '
          'and converts amounts to words across regional Indian languages.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [BharatCurrencyInputFormatter()],
          decoration: const InputDecoration(
            labelText: 'Type an Amount',
            prefixText: '₹ ',
            border: OutlineInputBorder(),
          ),
          onChanged: _onAmountChanged,
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Indian Grouping Format (Lakh / Crore):',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                BharatCurrencyText(
                  _currentAmount,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const Divider(height: 24),
                const Text('Compact Notation:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  'Short: ${BharatCurrency.compact(_currentAmount)}  |  Full: ${BharatCurrency.compact(_currentAmount, shortUnit: false)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Number in Words:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<BharatLanguage>(
                      value: _selectedLanguage,
                      items: BharatLanguage.values.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(lang.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (l) =>
                          setState(() => _selectedLanguage = l ?? BharatLanguage.english),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    BharatCurrency.toWords(
                      _currentAmount,
                      language: _selectedLanguage,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 2. PIN Code & Address Showcase
// -------------------------------------------------------------
class PinCodeShowcase extends StatefulWidget {
  const PinCodeShowcase({super.key});

  @override
  State<PinCodeShowcase> createState() => _PinCodeShowcaseState();
}

class _PinCodeShowcaseState extends State<PinCodeShowcase> {
  final _pinController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  PinCodeInfo? _info;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '2. Smart Indian Address & PIN Code Validator (BharatInput)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Instant local offline resolution of State, District, Postal Circle, and Zone '
          'the moment a user types a 6-digit PIN code. 100% offline, zero API latency.',
        ),
        const SizedBox(height: 16),
        BharatPinCodeFormField(
          controller: _pinController,
          stateController: _stateController,
          districtController: _districtController,
          showResolvedInfoInline: true,
          onResolved: (info) => setState(() => _info = info),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _districtController,
          decoration: const InputDecoration(
            labelText: 'District / Sorting Office (Auto-filled)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_city_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _stateController,
          decoration: const InputDecoration(
            labelText: 'State / Union Territory (Auto-filled)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.map_outlined),
          ),
        ),
        if (_info != null) ...[
          const SizedBox(height: 20),
          Card(
            color: Colors.green.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resolved Offline Details:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Zone: ${_info!.zone ?? "N/A"}'),
                  Text('Circle: ${_info!.circle ?? "N/A"}'),
                  Text('Army Postal: ${_info!.isArmyPostal ? "Yes (APS)" : "No"}'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// -------------------------------------------------------------
// 3. Vernacular Keyboard Showcase
// -------------------------------------------------------------
class VernacularShowcase extends StatefulWidget {
  const VernacularShowcase({super.key});

  @override
  State<VernacularShowcase> createState() => _VernacularShowcaseState();
}

class _VernacularShowcaseState extends State<VernacularShowcase> {
  final _phoneticController = TextEditingController();
  final _digitsController = TextEditingController(text: '1234567890');
  IndianScript _selectedScript = IndianScript.devanagari;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '3. Vernacular Keyboard & Input Filters (BharatText)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Type in English/Hinglish phonetically and have words automatically convert to '
          'Devanagari, Tamil, Telugu, etc., in real-time!',
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select Target Script:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<IndianScript>(
              value: _selectedScript,
              items: IndianScript.values.map((s) {
                return DropdownMenuItem(value: s, child: Text(s.name));
              }).toList(),
              onChanged: (s) => setState(() => _selectedScript = s ?? IndianScript.devanagari),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneticController,
          inputFormatters: [
            BharatPhoneticInputFormatter(
              targetScript: _selectedScript,
              convertOnSpace: true,
            ),
          ],
          decoration: InputDecoration(
            labelText: 'Type phonetically (press space to convert)',
            hintText: 'e.g. namaste, bharat, dost, shanti',
            border: const OutlineInputBorder(),
            helperText: 'Try typing: "namaste bharat mera desh mahan"',
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Indic Digits Converter:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _digitsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter standard digits (0-9)',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In ${_selectedScript.name} Numerals:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  BharatText.toIndicDigits(_digitsController.text, _selectedScript),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 4. Vehicle Plate Showcase
// -------------------------------------------------------------
class VehicleShowcase extends StatefulWidget {
  const VehicleShowcase({super.key});

  @override
  State<VehicleShowcase> createState() => _VehicleShowcaseState();
}

class _VehicleShowcaseState extends State<VehicleShowcase> {
  final _plateController = TextEditingController(text: 'DL 01 AB 1234');
  VehiclePlateCategory _category = VehiclePlateCategory.privateVehicle;
  VehiclePlateInfo? _plateInfo;

  @override
  void initState() {
    super.initState();
    _plateInfo = BharatVehicle.validate(_plateController.text);
  }

  void _onChanged(String val) {
    setState(() {
      _plateInfo = BharatVehicle.validate(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '4. Local Vehicle Number Plate Validator (BharatVehicle)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Validates all Indian vehicle registration formats (Standard State, BH series, '
          'Defense, Diplomatic) and renders authentic HSRP registration plates.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _plateController,
          inputFormatters: [BharatVehicleInputFormatter()],
          decoration: const InputDecoration(
            labelText: 'Vehicle Number',
            hintText: 'DL 01 AB 1234 or 21 BH 1234 AA',
            border: OutlineInputBorder(),
          ),
          onChanged: _onChanged,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Private (White)'),
              selected: _category == VehiclePlateCategory.privateVehicle,
              onSelected: (_) => setState(() => _category = VehiclePlateCategory.privateVehicle),
            ),
            ChoiceChip(
              label: const Text('Commercial (Yellow)'),
              selected: _category == VehiclePlateCategory.commercialVehicle,
              onSelected: (_) => setState(() => _category = VehiclePlateCategory.commercialVehicle),
            ),
            ChoiceChip(
              label: const Text('EV (Green)'),
              selected: _category == VehiclePlateCategory.electricVehicle,
              onSelected: (_) => setState(() => _category = VehiclePlateCategory.electricVehicle),
            ),
            ChoiceChip(
              label: const Text('Rental (Black)'),
              selected: _category == VehiclePlateCategory.rentalVehicle,
              onSelected: (_) => setState(() => _category = VehiclePlateCategory.rentalVehicle),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'HSRP Plate Preview:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: BharatVehiclePlateWidget(
            plateNumber: _plateController.text,
            category: _category,
            height: 60,
          ),
        ),
        if (_plateInfo != null && _plateInfo!.isValid) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Extracted Registration Details:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('State: ${_plateInfo!.stateName} (${_plateInfo!.stateCode})'),
                  if (_plateInfo!.rtoName != null)
                    Text('RTO: ${_plateInfo!.rtoName} (Code: ${_plateInfo!.rtoCode})'),
                  Text('Series: ${_plateInfo!.series ?? "None"}'),
                  Text('Number: ${_plateInfo!.registrationNumber}'),
                  Text('Plate Type: ${_plateInfo!.type.name}'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// -------------------------------------------------------------
// 5. Government IDs & Payments Showcase
// -------------------------------------------------------------
class IdShowcase extends StatefulWidget {
  const IdShowcase({super.key});

  @override
  State<IdShowcase> createState() => _IdShowcaseState();
}

class _IdShowcaseState extends State<IdShowcase> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '5. Indian Government ID Masker & Validator (BharatId)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pre-built input masks and algorithmic validators for Aadhaar (UIDAI Verhoeff algorithm), '
          'PAN Card (with entity category classification), and UPI IDs (with bank/PSP detection).',
        ),
        const SizedBox(height: 20),
        const Text('Aadhaar Card (12 Digits with Verhoeff Checksum):',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const BharatTextField(
          type: BharatTextFieldType.aadhaar,
        ),
        const SizedBox(height: 20),
        const Text('PAN Card (4th Char Entity Classifier):',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const BharatTextField(
          type: BharatTextFieldType.pan,
        ),
        const SizedBox(height: 20),
        const Text('UPI ID (Auto PSP & Bank Detector):',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const BharatTextField(
          type: BharatTextFieldType.upi,
        ),
        const SizedBox(height: 20),
        const Text('GSTIN (15 Alphanumeric Characters):',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const BharatTextField(
          type: BharatTextFieldType.gstin,
        ),
        const SizedBox(height: 20),
        const Text('Indian Mobile Number (+91):',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const BharatTextField(
          type: BharatTextFieldType.phone,
        ),
      ],
    );
  }
}
