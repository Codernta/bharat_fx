import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../currency/bharat_currency.dart';
import '../currency/bharat_money.dart';
import '../id/aadhaar_validator.dart';
import '../id/bank_account_validator.dart';
import '../id/card_validator.dart';
import '../id/corporate_id_validator.dart';
import '../id/driving_license_validator.dart';
import '../id/gstin_validator.dart';
import '../id/id_formatters.dart';
import '../id/ifsc_validator.dart';
import '../id/pan_validator.dart';
import '../id/passport_validator.dart';
import '../id/phone_validator.dart';
import '../id/upi_validator.dart';
import '../id/vid_validator.dart';
import '../id/voter_id_validator.dart';
import '../input/pin_code_data.dart';
import '../input/pin_code_formatter.dart';
import '../input/pin_code_validator.dart';
import '../security/input_security.dart';
import '../text/indian_scripts.dart';
import '../text/phonetic_formatter.dart';
import '../text/script_formatter.dart';
import '../vehicle/vehicle_formatter.dart';
import '../vehicle/vehicle_types.dart';
import '../vehicle/vehicle_validator.dart';

/// Preset input types tailored for Indian apps, payments, and data fields.
enum BharatTextFieldType {
  aadhaar,
  vid,
  pan,
  upi,
  pinCode,
  currency,
  money,
  card,
  cvv,
  bankAccount,
  vehiclePlate,
  phone,
  gstin,
  ifsc,
  drivingLicense,
  voterId,
  passport,
  cin,
  tan,
  din,
  vernacularPhonetic,
  vernacularRestricted,
  custom,
}

/// A pre-configured, batteries-included [TextFormField] optimized for Indian inputs,
/// hardened with enterprise fintech security policies (anti-keylogger, clipboard protection,
/// and live validation).
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

  // Specific resolvers & options
  final IndianScript vernacularScript;
  final ValueChanged<PinCodeInfo>? onPinCodeResolved;
  final ValueChanged<VehiclePlateInfo>? onVehiclePlateResolved;
  final ValueChanged<UpiValidationResult>? onUpiResolved;
  final ValueChanged<CardValidationResult>? onCardResolved;
  final ValueChanged<BankAccountValidationResult>? onBankAccountResolved;
  final ValueChanged<BharatMoney>? onMoneyResolved;
  final ValueChanged<DrivingLicenseValidationResult>? onDrivingLicenseResolved;
  final ValueChanged<CinValidationResult>? onCinResolved;
  final bool showLiveValidationIndicator;

  // Fintech Security options
  final String? bankCode;
  final bool? obscureText;
  final bool showObscureToggle;
  final bool? allowCopy;
  final bool? allowPaste;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final FintechInputSecurityConfig? securityConfig;

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
    this.onCardResolved,
    this.onBankAccountResolved,
    this.onMoneyResolved,
    this.onDrivingLicenseResolved,
    this.onCinResolved,
    this.showLiveValidationIndicator = true,
    this.bankCode,
    this.obscureText,
    this.showObscureToggle = false,
    this.allowCopy,
    this.allowPaste,
    this.enableSuggestions,
    this.autocorrect,
    this.securityConfig,
  });

  @override
  State<BharatTextField> createState() => _BharatTextFieldState();
}

class _BharatTextFieldState extends State<BharatTextField> {
  late TextEditingController _controller;
  bool _isValid = false;
  String? _helperText;
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _controller.addListener(_handleTextChange);

    final config = widget.securityConfig;
    if (widget.obscureText != null) {
      _isObscured = widget.obscureText!;
    } else if (config != null) {
      _isObscured = config.obscureSensitive;
    } else {
      _isObscured = widget.type == BharatTextFieldType.cvv;
    }

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
      case BharatTextFieldType.vid:
        valid = BharatVid.validate(text);
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
          if (ifscResult.isMergedOrDefunct) {
            helper = ifscResult.warningMessage;
          }
        }
        break;
      case BharatTextFieldType.card:
        final cardResult = BharatCard.validate(text);
        valid = cardResult.isValid;
        if (valid) {
          helper = cardResult.cardTypeName;
          widget.onCardResolved?.call(cardResult);
        }
        break;
      case BharatTextFieldType.cvv:
        valid = BharatCard.validateCvv(text);
        break;
      case BharatTextFieldType.bankAccount:
        final accResult = BharatBankAccount.validate(
          text,
          bankCode: widget.bankCode,
        );
        valid = accResult.isValid;
        if (valid) {
          widget.onBankAccountResolved?.call(accResult);
        }
        break;
      case BharatTextFieldType.currency:
        valid = text.isNotEmpty;
        break;
      case BharatTextFieldType.money:
        final money = BharatMoney.parse(text);
        valid = money != null && money.isPositive;
        if (valid) {
          widget.onMoneyResolved?.call(money);
        }
        break;
      case BharatTextFieldType.drivingLicense:
        final dlResult = BharatDrivingLicense.validate(text);
        valid = dlResult.isValid;
        if (valid) {
          helper =
              '${dlResult.stateName ?? ""} ${dlResult.rtoName ?? ""} (${dlResult.issueYear ?? ""})'
                  .trim();
          widget.onDrivingLicenseResolved?.call(dlResult);
        }
        break;
      case BharatTextFieldType.voterId:
        final voterResult = BharatVoterId.validate(text);
        valid = voterResult.isValid;
        break;
      case BharatTextFieldType.passport:
        final passResult = BharatPassport.validate(text);
        valid = passResult.isValid;
        break;
      case BharatTextFieldType.cin:
        final cinResult = BharatCin.validate(text);
        valid = cinResult.isValid;
        if (valid) {
          helper =
              '${cinResult.companyTypeDescription ?? ""} (${cinResult.stateName ?? ""})';
          widget.onCinResolved?.call(cinResult);
        }
        break;
      case BharatTextFieldType.tan:
        final tanResult = BharatTan.validate(text);
        valid = tanResult.isValid;
        break;
      case BharatTextFieldType.din:
        final dinResult = BharatDin.validate(text);
        valid = dinResult.isValid;
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

  bool _computeEffectiveAllowCopy() {
    if (widget.allowCopy != null) return widget.allowCopy!;
    if (widget.securityConfig != null) return widget.securityConfig!.allowCopy;
    // Default: block copying for sensitive financial/identification credentials
    return switch (widget.type) {
      BharatTextFieldType.aadhaar => false,
      BharatTextFieldType.vid => false,
      BharatTextFieldType.pan => false,
      BharatTextFieldType.card => false,
      BharatTextFieldType.cvv => false,
      BharatTextFieldType.bankAccount => false,
      _ => true,
    };
  }

  bool _computeEffectiveAllowPaste() {
    if (widget.allowPaste != null) return widget.allowPaste!;
    if (widget.securityConfig != null) return widget.securityConfig!.allowPaste;
    // Disallow pasting into CVV fields to guard against automated clipboard injection
    return widget.type != BharatTextFieldType.cvv;
  }

  bool _computeEffectiveSuggestions() {
    if (widget.enableSuggestions != null) return widget.enableSuggestions!;
    if (widget.securityConfig != null) {
      return !widget.securityConfig!.disableSuggestions;
    }
    // Prevent cloud prediction keyboards from harvesting financial IDs
    return switch (widget.type) {
      BharatTextFieldType.aadhaar => false,
      BharatTextFieldType.vid => false,
      BharatTextFieldType.pan => false,
      BharatTextFieldType.card => false,
      BharatTextFieldType.cvv => false,
      BharatTextFieldType.bankAccount => false,
      BharatTextFieldType.pinCode => false,
      BharatTextFieldType.drivingLicense => false,
      BharatTextFieldType.voterId => false,
      BharatTextFieldType.passport => false,
      BharatTextFieldType.cin => false,
      BharatTextFieldType.tan => false,
      BharatTextFieldType.din => false,
      _ => true,
    };
  }

  bool _computeEffectiveAutocorrect() {
    if (widget.autocorrect != null) return widget.autocorrect!;
    if (widget.securityConfig != null) {
      return !widget.securityConfig!.disableAutocorrect;
    }
    return switch (widget.type) {
      BharatTextFieldType.aadhaar => false,
      BharatTextFieldType.vid => false,
      BharatTextFieldType.pan => false,
      BharatTextFieldType.card => false,
      BharatTextFieldType.cvv => false,
      BharatTextFieldType.bankAccount => false,
      BharatTextFieldType.drivingLicense => false,
      BharatTextFieldType.voterId => false,
      BharatTextFieldType.passport => false,
      BharatTextFieldType.cin => false,
      BharatTextFieldType.tan => false,
      BharatTextFieldType.din => false,
      _ => true,
    };
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

      case BharatTextFieldType.vid:
        keyboardType = TextInputType.number;
        formatters = [
          FilteringTextInputFormatter.digitsOnly,
          BharatVidInputFormatter(),
        ];
        label = 'Virtual ID (VID)';
        hint = 'XXXX XXXX XXXX XXXX';
        prefixIcon = const Icon(Icons.shield_outlined);
        break;

      case BharatTextFieldType.pan:
        keyboardType = TextInputType.text;
        formatters = [BharatPanInputFormatter()];
        label = 'PAN Card Number';
        hint = 'ABCDE1234F';
        prefixIcon = const Icon(Icons.credit_card_outlined);
        break;

      case BharatTextFieldType.card:
        keyboardType = TextInputType.number;
        formatters = [
          FilteringTextInputFormatter.digitsOnly,
          BharatCardInputFormatter(),
        ];
        label = 'Card Number (RuPay / Visa / MC)';
        hint = 'XXXX XXXX XXXX XXXX';
        prefixIcon = const Icon(Icons.credit_card);
        break;

      case BharatTextFieldType.cvv:
        keyboardType = TextInputType.number;
        formatters = [
          FilteringTextInputFormatter.digitsOnly,
          BharatCvvInputFormatter(),
        ];
        label = 'CVV';
        hint = '•••';
        prefixIcon = const Icon(Icons.lock_outline);
        break;

      case BharatTextFieldType.bankAccount:
        keyboardType = TextInputType.number;
        formatters = [
          FilteringTextInputFormatter.digitsOnly,
          BharatBankAccountInputFormatter(),
        ];
        label = 'Bank Account Number';
        hint = '9 to 18 digits';
        prefixIcon = const Icon(Icons.account_balance_outlined);
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
      case BharatTextFieldType.money:
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

      case BharatTextFieldType.drivingLicense:
        keyboardType = TextInputType.text;
        formatters = [BharatDrivingLicenseInputFormatter()];
        label = 'Driving License (DL)';
        hint = 'DL-01-2020-0012345';
        prefixIcon = const Icon(Icons.drive_eta_outlined);
        break;

      case BharatTextFieldType.voterId:
        keyboardType = TextInputType.text;
        formatters = [BharatVoterIdInputFormatter()];
        label = 'Voter ID (EPIC)';
        hint = 'ABC1234567';
        prefixIcon = const Icon(Icons.how_to_vote_outlined);
        break;

      case BharatTextFieldType.passport:
        keyboardType = TextInputType.text;
        formatters = [BharatPassportInputFormatter()];
        label = 'Passport Number';
        hint = 'A1234567';
        prefixIcon = const Icon(Icons.flight_takeoff_outlined);
        break;

      case BharatTextFieldType.cin:
        keyboardType = TextInputType.text;
        formatters = [BharatCinInputFormatter()];
        label = 'Corporate CIN';
        hint = 'U72200KA2020PTC123456';
        prefixIcon = const Icon(Icons.domain_outlined);
        break;

      case BharatTextFieldType.tan:
        keyboardType = TextInputType.text;
        formatters = [BharatTanInputFormatter()];
        label = 'TAN Number';
        hint = 'DELA12345B';
        prefixIcon = const Icon(Icons.description_outlined);
        break;

      case BharatTextFieldType.din:
        keyboardType = TextInputType.number;
        formatters = [
          FilteringTextInputFormatter.digitsOnly,
          BharatDinInputFormatter(),
        ];
        label = 'Director DIN';
        hint = '00123456';
        prefixIcon = const Icon(Icons.person_pin_outlined);
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

    Widget? suffixIcon;
    if (widget.showObscureToggle) {
      suffixIcon = IconButton(
        icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      );
    } else if (widget.showLiveValidationIndicator && _isValid) {
      suffixIcon = const Icon(Icons.check_circle, color: Colors.green);
    }

    final defaultDecoration = InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      helperText: _helperText,
      border: const OutlineInputBorder(),
    );

    final effectiveAllowCopy = _computeEffectiveAllowCopy();
    final effectiveAllowPaste = _computeEffectiveAllowPaste();

    return TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      obscureText: _isObscured,
      enableSuggestions: _computeEffectiveSuggestions(),
      autocorrect: _computeEffectiveAutocorrect(),
      contextMenuBuilder: (context, editableTextState) {
        final buttonItems = editableTextState.contextMenuButtonItems;
        if (!effectiveAllowCopy) {
          buttonItems
              .removeWhere((item) => item.type == ContextMenuButtonType.copy);
          buttonItems
              .removeWhere((item) => item.type == ContextMenuButtonType.cut);
        }
        if (!effectiveAllowPaste) {
          buttonItems
              .removeWhere((item) => item.type == ContextMenuButtonType.paste);
        }
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: buttonItems,
        );
      },
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
        case BharatTextFieldType.vid:
          return BharatVid.validate(value)
              ? null
              : 'Please enter a valid 16-digit Virtual ID (VID)';
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
        case BharatTextFieldType.card:
          final c = BharatCard.validate(value);
          return c.isValid ? null : c.errorMessage;
        case BharatTextFieldType.cvv:
          return BharatCard.validateCvv(value)
              ? null
              : 'Please enter a valid 3 or 4 digit CVV';
        case BharatTextFieldType.bankAccount:
          final b =
              BharatBankAccount.validate(value, bankCode: widget.bankCode);
          return b.isValid ? null : b.errorMessage;
        case BharatTextFieldType.currency:
          return null;
        case BharatTextFieldType.money:
          final m = BharatMoney.parse(value);
          return m != null && m.isPositive
              ? null
              : 'Please enter a valid monetary amount';
        case BharatTextFieldType.drivingLicense:
          final dl = BharatDrivingLicense.validate(value);
          return dl.isValid ? null : dl.errorMessage;
        case BharatTextFieldType.voterId:
          final v = BharatVoterId.validate(value);
          return v.isValid ? null : v.errorMessage;
        case BharatTextFieldType.passport:
          final pass = BharatPassport.validate(value);
          return pass.isValid ? null : pass.errorMessage;
        case BharatTextFieldType.cin:
          final cin = BharatCin.validate(value);
          return cin.isValid ? null : cin.errorMessage;
        case BharatTextFieldType.tan:
          final tan = BharatTan.validate(value);
          return tan.isValid ? null : tan.errorMessage;
        case BharatTextFieldType.din:
          final din = BharatDin.validate(value);
          return din.isValid ? null : din.errorMessage;
        case BharatTextFieldType.vernacularPhonetic:
        case BharatTextFieldType.vernacularRestricted:
        case BharatTextFieldType.custom:
          return null;
      }
    };
  }
}
