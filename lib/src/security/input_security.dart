/// Configuration for securing text input fields against mobile keylogging,
/// clipboard snooping, and cloud prediction leaks.
class FintechInputSecurityConfig {
  /// Whether to disable keyboard autocorrect (prevents external dictionary logging).
  final bool disableAutocorrect;

  /// Whether to disable keyboard text suggestions (prevents cloud sync of sensitive inputs).
  final bool disableSuggestions;

  /// Whether to allow copying text from the field (prevents clipboard hijacking/snooping).
  final bool allowCopy;

  /// Whether to allow pasting text into the field (can be disabled for confirmation fields).
  final bool allowPaste;

  /// Whether the input characters should be masked on screen.
  final bool obscureSensitive;

  const FintechInputSecurityConfig({
    this.disableAutocorrect = true,
    this.disableSuggestions = true,
    this.allowCopy = false,
    this.allowPaste = true,
    this.obscureSensitive = false,
  });

  /// Preset for maximum security (e.g. CVV, MPIN, OTP, Account Confirmation).
  static const FintechInputSecurityConfig highSecurity =
      FintechInputSecurityConfig(
    disableAutocorrect: true,
    disableSuggestions: true,
    allowCopy: false,
    allowPaste: false,
    obscureSensitive: true,
  );

  /// Preset for sensitive identifiers (e.g. Aadhaar, PAN, Card Number, Bank Account).
  static const FintechInputSecurityConfig sensitiveId =
      FintechInputSecurityConfig(
    disableAutocorrect: true,
    disableSuggestions: true,
    allowCopy: false,
    allowPaste: true,
    obscureSensitive: false,
  );

  /// Preset for standard payment inputs (e.g. UPI ID, IFSC, Amount).
  static const FintechInputSecurityConfig standardPayment =
      FintechInputSecurityConfig(
    disableAutocorrect: true,
    disableSuggestions: false,
    allowCopy: true,
    allowPaste: true,
    obscureSensitive: false,
  );
}

/// In-memory sliding-window rate limiter to guard against brute-force attacks
/// on OTPs, MPINs, card CVVs, and checksum guessing.
class AntiBruteForceGuard {
  final int maxAttempts;
  final Duration window;
  final int maxTrackedKeys;
  final Map<String, List<DateTime>> _attempts = {};

  AntiBruteForceGuard({
    this.maxAttempts = 5,
    this.window = const Duration(minutes: 5),
    this.maxTrackedKeys = 10000,
  });

  /// Current number of tracked identifiers in memory.
  int get trackedKeyCount => _attempts.length;

  /// Completely clears all tracked rate limit state.
  void clear() => _attempts.clear();

  /// Records an attempt for [identifier] (e.g. user ID, session ID, or operation key).
  ///
  /// Returns `true` if the attempt is allowed, or `false` if blocked due to rate limit.
  bool recordAttempt(String identifier) {
    final now = DateTime.now();
    _cleanExpired(identifier, now);

    if (!_attempts.containsKey(identifier) &&
        _attempts.length >= maxTrackedKeys) {
      _pruneOldestEntries(now);
    }

    final list = _attempts.putIfAbsent(identifier, () => []);
    if (list.length >= maxAttempts) {
      return false;
    }

    list.add(now);
    return true;
  }

  /// Checks if [identifier] is currently blocked.
  bool isBlocked(String identifier) {
    final now = DateTime.now();
    _cleanExpired(identifier, now);
    final list = _attempts[identifier];
    return list != null && list.length >= maxAttempts;
  }

  /// Returns the remaining duration until [identifier] is unblocked, or `null` if not blocked.
  Duration? timeUntilUnblocked(String identifier) {
    final now = DateTime.now();
    _cleanExpired(identifier, now);

    final list = _attempts[identifier];
    if (list == null || list.length < maxAttempts) {
      return null;
    }

    final oldestAttempt = list.first;
    final expiresAt = oldestAttempt.add(window);
    final remaining = expiresAt.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Resets recorded attempts upon successful authentication or transaction.
  void reset(String identifier) {
    _attempts.remove(identifier);
  }

  void _cleanExpired(String identifier, DateTime now) {
    final list = _attempts[identifier];
    if (list == null) return;

    final cutoff = now.subtract(window);
    list.removeWhere((timestamp) => timestamp.isBefore(cutoff));

    if (list.isEmpty) {
      _attempts.remove(identifier);
    }
  }

  void _pruneOldestEntries(DateTime now) {
    // 1. Sweep all expired keys first
    final cutoff = now.subtract(window);
    _attempts.removeWhere((_, timestamps) {
      timestamps.removeWhere((ts) => ts.isBefore(cutoff));
      return timestamps.isEmpty;
    });

    // 2. If still at/over capacity, evict the oldest 10% of entries to prevent DoS
    if (_attempts.length >= maxTrackedKeys) {
      final keysToRemove =
          _attempts.keys.take((maxTrackedKeys * 0.1).ceil()).toList();
      for (final k in keysToRemove) {
        _attempts.remove(k);
      }
    }
  }
}
