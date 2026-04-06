import 'package:flutter/foundation.dart';
import '../data/repositories/settings_repository.dart';

/// Manages user preferences: display name, currency symbol, and whether
/// the onboarding flow has been completed.
///
/// Because [SettingsRepository] wraps [SharedPreferences] synchronously,
/// all reads in this ViewModel are instant — no loading state needed.
///
/// **Key behaviour:**
///   - Loads settings immediately in the constructor.
///   - [isOnboardingComplete] is read by the Splash screen's routing logic.
///   - [completeOnboarding()] is called at the end of the 3-page onboarding.
class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repo;

  late String _userName;
  late String _currencySymbol;
  late bool _isOnboardingComplete;

  // Tracks whether an async save is in progress (for button loading states).
  bool _isSaving = false;

  SettingsViewModel({required SettingsRepository repository})
      : _repo = repository {
    _loadSettings();
  }

  // ── Public State ───────────────────────────────────────────────────────

  bool get isSaving => _isSaving;

  /// The name shown in the Dashboard greeting ("Hello, [userName]").
  /// Empty string before onboarding is complete.
  String get userName => _userName;

  /// Currency symbol prefixed to all monetary values (e.g. '$', 'RM', '€').
  String get currencySymbol => _currencySymbol;

  /// True once the user has finished the 3-page onboarding flow.
  bool get isOnboardingComplete => _isOnboardingComplete;

  /// True if the user has a name AND has finished onboarding.
  bool get isFullyConfigured => _isOnboardingComplete && _userName.isNotEmpty;

  /// Convenience: formats [amount] with the stored currency symbol.
  /// e.g.  formatAmount(12.5) → "$12.50"
  String formatAmount(double amount) =>
      '$_currencySymbol${amount.toStringAsFixed(2)}';

  // ── Commands ──────────────────────────────────────────────────────────

  /// Persists [name] and refreshes the greeting.
  Future<void> setUserName(String name) async {
    final trimmed = name.trim();
    if (trimmed == _userName) return;
    _isSaving = true;
    notifyListeners();

    await _repo.setUserName(trimmed);
    _userName = trimmed;

    _isSaving = false;
    notifyListeners();
  }

  /// Persists [symbol] and refreshes all currency displays.
  Future<void> setCurrencySymbol(String symbol) async {
    final trimmed = symbol.trim();
    if (trimmed == _currencySymbol) return;
    _isSaving = true;
    notifyListeners();

    await _repo.setCurrencySymbol(trimmed);
    _currencySymbol = trimmed;

    _isSaving = false;
    notifyListeners();
  }

  /// Called at the end of the Onboarding "Finish Setup" button.
  ///
  /// Persists name + currency (collected during onboarding) in one go,
  /// then sets [isOnboardingComplete] = true and navigates.
  Future<void> completeOnboarding({
    required String name,
    required String currencySymbol,
  }) async {
    _isSaving = true;
    notifyListeners();

    await _repo.setUserName(name.trim());
    await _repo.setCurrencySymbol(currencySymbol.trim());
    await _repo.setOnboardingComplete(value: true);

    _userName = name.trim();
    _currencySymbol = currencySymbol.trim();
    _isOnboardingComplete = true;

    _isSaving = false;
    notifyListeners();
  }

  /// Resets the onboarding flag so the flow re-runs on next launch.
  ///
  /// Exposed via the Settings screen "Re-run Setup" option (demo / testing).
  Future<void> resetOnboarding() async {
    await _repo.resetOnboarding();
    _isOnboardingComplete = false;
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────

  void _loadSettings() {
    _userName = _repo.getUserName() ?? '';
    _currencySymbol = _repo.getCurrencySymbol();
    _isOnboardingComplete = _repo.isOnboardingComplete();
    // No notifyListeners() here — this runs in the constructor before any
    // Consumer is attached.
  }
}
