import 'dart:typed_data';
import 'timing_safe.dart';

/// A secure memory wrapper for sensitive fintech data (MPIN, CVV, Card Number,
/// unmasked Aadhaar, Bank Account Numbers, Netbanking credentials, or Tokens).
///
/// Addresses OWASP MASVS-STORAGE and MASVS-PRIVACY:
/// 1. Prevents accidental leaks in logs: [toString] never outputs raw values.
/// 2. Prevents accidental JSON serialization into crash logs or analytics.
/// 3. Provides explicit, scoped unwrapping via [use] or [reveal].
/// 4. Provides [zeroize] to wipe memory buffers as soon as data is no longer needed.
class SensitiveValue<T> {
  T? _value;
  bool _isDisposed = false;
  final String _label;

  /// Creates a sensitive wrapper around [value].
  ///
  /// Optionally provides a debug [label] (e.g., 'CVV', 'MPIN', 'Aadhaar')
  /// which will be safely included in redacted representations.
  SensitiveValue(T value, {String label = 'FINANCIAL_DATA'})
      : _value = value,
        _label = label;

  /// Returns whether this sensitive container has been wiped or disposed.
  bool get isDisposed => _isDisposed;

  /// Label indicating the nature of the enclosed data (non-sensitive).
  String get label => _label;

  /// Executes [action] with the raw sensitive value within a controlled closure.
  ///
  /// Throws [StateError] if the container has already been zeroized/disposed.
  R use<R>(R Function(T value) action) {
    _checkDisposed();
    return action(_value as T);
  }

  /// Explicitly retrieves the sensitive value.
  ///
  /// Use only at the final point of submission to secured gateways or encryption APIs.
  /// Throws [StateError] if the container has already been zeroized/disposed.
  T reveal() {
    _checkDisposed();
    return _value as T;
  }

  /// Securely clears and zeroes the underlying data buffer in memory.
  ///
  /// For [Uint8List] or [List<int>], bytes are overwritten with zeroes.
  /// For [String] or other objects, the internal reference is cleared immediately.
  void zeroize() {
    if (_isDisposed) return;

    if (_value is Uint8List) {
      final bytes = _value as Uint8List;
      for (int i = 0; i < bytes.length; i++) {
        bytes[i] = 0;
      }
    } else if (_value is List<int>) {
      final list = _value as List<int>;
      for (int i = 0; i < list.length; i++) {
        list[i] = 0;
      }
    }

    _value = null;
    _isDisposed = true;
  }

  /// Alias for [zeroize] to fit Flutter disposable conventions.
  void dispose() => zeroize();

  void _checkDisposed() {
    if (_isDisposed || _value == null) {
      throw StateError(
        'SensitiveValue($_label) has already been disposed or zeroized.',
      );
    }
  }

  /// Safe, non-leaking string representation. Never outputs raw content.
  @override
  String toString() {
    return _isDisposed ? '[DISPOSED_$_label]' : '[PROTECTED_$_label]';
  }

  /// Guards against unintended JSON serialization in telemetry or API logs.
  dynamic toJson() {
    return '[PROTECTED_$_label]';
  }

  /// Compares with another [SensitiveValue] using constant-time equality.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SensitiveValue<T>) return false;
    if (_isDisposed || other._isDisposed) return false;

    final myVal = _value;
    final otherVal = other._value;

    if (myVal is String && otherVal is String) {
      return TimingSafe.equals(myVal, otherVal);
    } else if (myVal is List<int> && otherVal is List<int>) {
      return TimingSafe.bytesEquals(myVal, otherVal);
    }

    return myVal == otherVal;
  }

  @override
  int get hashCode => _label.hashCode ^ (_isDisposed ? 0 : 1);
}
