import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pin_code_data.dart';
import 'pin_code_formatter.dart';
import 'pin_code_validator.dart';

/// A specialized Flutter [TextFormField] that validates 6-digit Indian PIN codes
/// locally and triggers real-time autofill of State and District.
class BharatPinCodeFormField extends StatefulWidget {
  final TextEditingController? controller;
  final TextEditingController? stateController;
  final TextEditingController? districtController;
  final ValueChanged<PinCodeInfo>? onResolved;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final String? initialValue;
  final FocusNode? focusNode;
  final bool showResolvedInfoInline;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  const BharatPinCodeFormField({
    super.key,
    this.controller,
    this.stateController,
    this.districtController,
    this.onResolved,
    this.onChanged,
    this.decoration,
    this.initialValue,
    this.focusNode,
    this.showResolvedInfoInline = false,
    this.validator,
    this.enabled = true,
  });

  @override
  State<BharatPinCodeFormField> createState() => _BharatPinCodeFormFieldState();
}

class _BharatPinCodeFormFieldState extends State<BharatPinCodeFormField> {
  late TextEditingController _controller;
  PinCodeInfo? _resolvedInfo;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _controller.addListener(_handleTextChange);

    if (_controller.text.isNotEmpty) {
      _resolvePinCode(_controller.text);
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
    _resolvePinCode(_controller.text);
  }

  void _resolvePinCode(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 6) {
      final info = BharatPinCode.lookup(digits);
      setState(() {
        _resolvedInfo = info;
      });

      if (info.isValid) {
        if (widget.stateController != null && info.state != null) {
          widget.stateController!.text = info.state!;
        }
        if (widget.districtController != null && info.district != null) {
          widget.districtController!.text = info.district!;
        }
        widget.onResolved?.call(info);
      }
    } else {
      if (_resolvedInfo != null) {
        setState(() {
          _resolvedInfo = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultDecoration = InputDecoration(
      labelText: 'PIN Code',
      hintText: 'e.g. 560001',
      prefixIcon: const Icon(Icons.location_on_outlined),
      suffixIcon: _resolvedInfo?.isValid == true
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      helperText: (widget.showResolvedInfoInline &&
              _resolvedInfo != null &&
              _resolvedInfo!.isValid)
          ? '${_resolvedInfo!.district}, ${_resolvedInfo!.state}'
          : null,
      border: const OutlineInputBorder(),
    );

    return TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
        BharatPinCodeInputFormatter(),
      ],
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a PIN code';
            }
            if (!BharatPinCode.isValid(value)) {
              return 'Please enter a valid 6-digit Indian PIN code';
            }
            return null;
          },
      onChanged: widget.onChanged,
      decoration: widget.decoration ?? defaultDecoration,
    );
  }
}
