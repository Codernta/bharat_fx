import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../currency/bharat_currency.dart';
import '../id/aadhaar_validator.dart';
import '../id/gstin_validator.dart';
import '../id/id_formatters.dart';
import '../id/ifsc_validator.dart';
import '../id/pan_validator.dart';
import '../id/phone_validator.dart';
import '../id/upi_validator.dart';
import '../input/pin_code_data.dart';
import '../input/pin_code_formatter.dart';
import '../input/pin_code_validator.dart';
import '../text/indian_scripts.dart';
import '../text/phonetic_formatter.dart';
import '../text/script_formatter.dart';
import '../vehicle/vehicle_formatter.dart';
import '../vehicle/vehicle_types.dart';
import '../vehicle/vehicle_validator.dart';

/// Preset input types tailored for Indian apps and data fields.
enum BharatTextFieldType {
  aadhaar,
  pan,
  upi,
  pinCode,
  currency,
  vehiclePlate,
  phone,
  gstin,
  ifsc,
  vernacularPhonetic,
  vernacularRestricted,
  custom,
}

/// A pre-configured, batteries-included [TextFormField] optimized for Indian inputs.
class BharatTextField extends StatefulWidget {
  final BharatTextFieldType type;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;

  // Specific options
  final IndianScript vernacularScript;
  final ValueChanged<PinCodeInfo>? onPinCodeResolved;
  final ValueChanged<VehiclePlateInfo>? onVehiclePlateResolved;
  final ValueChanged<UpiValidationResult>? onUpiResolved;
  final bool showLiveValidationIndicator;

  const BharatTextField({
    super.key,
    required this.type,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.vernacularScript = IndianScript.devanagari,
    this.onPinCodeResolved,
    this.onVehiclePlateResolved,
    this.onUpiResolved,
    this.showLiveValidationIndicator = true,
  });

  @override
  State<BharatTextField> createState() => _BharatTextFieldState();
}

class _BharatTextFieldState extends State<BharatTextField> {
  late TextEditingController _controller;
  bool _isValid = false;
  String? _helperText;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _controller.addListener(_handleTextChange);
    if (_controller.text.isNotEmpty) {
      _checkValidity(_controller.text);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_handleTextChange);
    }
    super.dispose();
  }

  void _handleTextChange() {
    _checkValidity(_controller.text);
  }

  void _checkValidity(String text) {
    bool valid = false;
    String? helper;

    switch (widget.type) {
      case BharatTextFieldType.aadhaar:
        valid = BharatAadhaar.validate(text);
        break;
      case BharatTextFieldType.pan:
        final panResult = BharatPan.validate(text);
        valid = panResult.isValid;
        if (valid) {
          helper = panResult.categoryDescription;
        }
        break;
      case BharatTextFieldType.upi:
        final upiResult = BharatUpi.validate(text);
        valid = upiResult.isValid;
        if (valid && upiResult.pspName != null) {
          helper = '${upiResult.pspName} (${upiResult.bankName ?? ""})';
          widget.onUpiResolved?.call(upiResult);
        }
        break;
      case BharatTextFieldType.pinCode:
        final digits = text.replaceAll(RegExp(r'\D'), '');
        if (digits.length == 6) {
          final pinInfo = BharatPinCode.lookup(digits);
          valid = pinInfo.isValid;
          if (valid) {
            helper = '${pinInfo.district}, ${pinInfo.state}';
            widget.onPinCodeResolved?.call(pinInfo);
          }
        }
        break;
      case BharatTextFieldType.vehiclePlate:
        final vInfo = BharatVehicle.validate(text);
        valid = vInfo.isValid;
        if (valid) {
          helper = '${vInfo.stateName} ${vInfo.rtoName ?? ""}';
          widget.onVehiclePlateResolved?.call(vInfo);
        }
        break;
      case BharatTextFieldType.phone:
        final phoneResult = BharatPhone.validate(text);
        valid = phoneResult.isValid;
        break;
      case BharatTextFieldType.gstin:
        final gstinResult = BharatGstin.validate(text);
        valid = gstinResult.isValid;
        break;
      case BharatTextFieldType.ifsc:
        final ifscResult = BharatIfsc.validate(text);
        valid = ifscResult.isValid;
        if (valid) {
          helper = ifscResult.bankName;
        }
        break;
      case BharatTextFieldType.currency:
        valid = text.isNotEmpty;
        break;
      case BharatTextFieldType.vernacularPhonetic:
      case BharatTextFieldType.vernacularRestricted:
      case BharatTextFieldType.custom:
        valid = text.isNotEmpty;
        break;
    }

    if (mounted && (_isValid != valid || _helperText != helper)) {
      setState(() {
        _isValid = valid;
        _helperText = helper;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextInputType keyboardType;
    List<TextInputFormatter> formatters = [];
    String label;
    String hint;
    Widget? prefixIcon;

    switch (widget.type) {
      case BharatTextFieldType.aadhaar:
        keyboardType = TextInputType.number;
        formatters = [
          FilteringTextInputFormatter.digitsOnly,
          BharatAadhaarInputFormatter(),
        ];
        label = 'Aadhaar Number';
        hint = 'XXXX XXXX XXXX';
        prefixIcon = const Icon(Icons.badge_outlined);
        break;

      case BharatTextFieldType.pan:
        keyboardType = TextInputType.text;
        formatters = [BharatPanInputFormatter()];
        label = 'PAN Card Number';
        hint = 'ABCDE1234F';
        prefixIcon = const Icon(Icons.credit_card_outlined);
        break;

      case BharatTextFieldType.upi:
        keyboardType = TextInputType.emailAddress;
        formatters = [BharatUpiInputFormatter()];
        label = 'UPI ID / VPA';
        hint = 'username@okhdfcbank';
        prefixIcon = const Icon(Icons.account_balance_wallet_outlined);
        break;

      case BharatTextFieldType.pinCode:
        keyboardType = TextInputType.number;
        formatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
          BharatPinCodeInputFormatter(),
        ];
        label = 'PIN Code';
        hint = '560001';
        prefixIcon = const Icon(Icons.location_on_outlined);
        break;

      case BharatTextFieldType.vehiclePlate:
        keyboardType = TextInputType.text;
        formatters = [BharatVehicleInputFormatter()];
        label = 'Vehicle Number';
        hint = 'DL 01 AB 1234 or 21 BH 1234 AA';
        prefixIcon = const Icon(Icons.directions_car_outlined);
        break;

      case BharatTextFieldType.currency:
        keyboardType = const TextInputType.numberWithOptions(decimal: true);
        formatters = [BharatCurrencyInputFormatter()];
        label = 'Amount (₹)';
        hint = '1,50,000';
        prefixIcon = const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            widthFactor: 1,
            child: Text(
              '₹',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
        break;

      case BharatTextFieldType.phone:
        keyboardType = TextInputType.phone;
        formatters = [
          FilteringTextInputFormatter.digitsOnly,
          BharatPhoneInputFormatter(),
        ];
        label = 'Mobile Number';
        hint = '98765 43210';
        prefixIcon = const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            widthFactor: 1,
            child: Text('+91', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
        break;

      case BharatTextFieldType.gstin:
        keyboardType = TextInputType.text;
        formatters = [BharatGstinInputFormatter()];
        label = 'GSTIN';
        hint = '27AAPFU0939F1ZV';
        prefixIcon = const Icon(Icons.receipt_long_outlined);
        break;

      case BharatTextFieldType.ifsc:
        keyboardType = TextInputType.text;
        formatters = [BharatIfscInputFormatter()];
        label = 'IFSC Code';
        hint = 'SBIN0000123';
        prefixIcon = const Icon(Icons.account_balance_outlined);
        break;

      case BharatTextFieldType.vernacularPhonetic:
        keyboardType = TextInputType.text;
        formatters = [
          BharatPhoneticInputFormatter(
            targetScript: widget.vernacularScript,
            convertOnSpace: true,
          ),
        ];
        label = 'Type phonetically in ${widget.vernacularScript.name}';
        hint = 'e.g. namaste, bharat';
        prefixIcon = const Icon(Icons.translate);
        break;

      case BharatTextFieldType.vernacularRestricted:
        keyboardType = TextInputType.text;
        formatters = [
          BharatScriptInputFormatter.single(widget.vernacularScript),
        ];
        label = 'Input in ${widget.vernacularScript.name} only';
        hint = 'Native characters';
        prefixIcon = const Icon(Icons.language);
        break;

      case BharatTextFieldType.custom:
        keyboardType = TextInputType.text;
        label = 'Input';
        hint = '';
        break;
    }

    final suffixIcon = widget.showLiveValidationIndicator && _isValid
        ? const Icon(Icons.check_circle, color: Colors.green)
        : null;

    final defaultDecoration = InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      helperText: _helperText,
      border: const OutlineInputBorder(),
    );

    return TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator ?? _buildDefaultValidator(),
      decoration: widget.decoration ?? defaultDecoration,
    );
  }

  FormFieldValidator<String>? _buildDefaultValidator() {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;

      switch (widget.type) {
        case BharatTextFieldType.aadhaar:
          return BharatAadhaar.validate(value)
              ? null
              : 'Please enter a valid 12-digit Aadhaar number';
        case BharatTextFieldType.pan:
          final res = BharatPan.validate(value);
          return res.isValid ? null : res.errorMessage;
        case BharatTextFieldType.upi:
          return BharatUpi.isValid(value)
              ? null
              : 'Please enter a valid UPI ID (e.g. name@okaxis)';
        case BharatTextFieldType.pinCode:
          return BharatPinCode.isValid(value)
              ? null
              : 'Please enter a valid 6-digit PIN code';
        case BharatTextFieldType.vehiclePlate:
          final v = BharatVehicle.validate(value);
          return v.isValid ? null : v.errorMessage;
        case BharatTextFieldType.phone:
          final p = BharatPhone.validate(value);
          return p.isValid ? null : p.errorMessage;
        case BharatTextFieldType.gstin:
          final g = BharatGstin.validate(value);
          return g.isValid ? null : g.errorMessage;
        case BharatTextFieldType.ifsc:
          final i = BharatIfsc.validate(value);
          return i.isValid ? null : i.errorMessage;
        case BharatTextFieldType.currency:
        case BharatTextFieldType.vernacularPhonetic:
        case BharatTextFieldType.vernacularRestricted:
        case BharatTextFieldType.custom:
          return null;
      }
    };
  }
}
