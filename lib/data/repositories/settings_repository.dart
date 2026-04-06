import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences keys — private to this class (no raw strings elsewhere).
const String _kUserName = 'user_name';
const String _kCurrencySymbol = 'currency_symbol';
const String _kIsOnboardingComplete = 'is_onboarding_complete';

// Default currency symbol.
const String _kDefaultCurrency = '\$';

/// Single Source of Truth (SSOT) for user preferences stored in
/// [SharedPreferences].
///
/// Unlike the Hive repositories, [SettingsRepository] receives a
/// pre-initialized [SharedPreferences] instance via constructor injection.
/// This makes it synchronous at the call site — no async/await needed
/// in the ViewModels.
///
/// The [SharedPreferences] instance is obtained once in [main()] and
/// injected into [MultiProvider] alongside the Hive repositories.
///
/// **Web dev analogy:** This is like a typed wrapper around localStorage
/// for settings that aren't big enough to need a full database.
class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // ── User Name ─────────────────────────────────────────────────────────

  /// Returns the stored user name, or null on first launch.
  String? getUserName() => _prefs.getString(_kUserName);

  /// Persists the display name shown in the Dashboard greeting.
  Future<void> setUserName(String name) async {
    await _prefs.setString(_kUserName, name.trim());
  }

  // ── Currency Symbol ───────────────────────────────────────────────────

  /// Returns the user's chosen currency symbol (e.g. '$', 'RM', '€').
  /// Defaults to '$' if never set.
  String getCurrencySymbol() =>
      _prefs.getString(_kCurrencySymbol) ?? _kDefaultCurrency;

  /// Persists the currency symbol chosen during onboarding or Settings.
  Future<void> setCurrencySymbol(String symbol) async {
    await _prefs.setString(_kCurrencySymbol, symbol.trim());
  }

  // ── Onboarding Flag ───────────────────────────────────────────────────

  /// True after the user completes the 3-page onboarding flow.
  ///
  /// Checked by the Splash screen to decide which route to push:
  ///   - false → /onboarding
  ///   - true  → /dashboard
  bool isOnboardingComplete() =>
      _prefs.getBool(_kIsOnboardingComplete) ?? false;

  /// Called at the end of the Onboarding flow ("Finish Setup" button).
  Future<void> setOnboardingComplete({bool value = true}) async {
    await _prefs.setBool(_kIsOnboardingComplete, value);
  }

  /// Resets the onboarding flag — used by the "Re-run Setup" option in
  /// Settings, handy for demos and testing.
  Future<void> resetOnboarding() async {
    await _prefs.remove(_kIsOnboardingComplete);
  }

  // ── Convenience ───────────────────────────────────────────────────────

  /// True if the user has completed onboarding AND has a stored name.
  bool get isFullyConfigured =>
      isOnboardingComplete() && getUserName() != null;
}
