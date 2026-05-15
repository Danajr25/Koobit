import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Notifier that drives live locale changes across the whole app.
class LocaleNotifier extends ChangeNotifier {
  Locale _locale;

  LocaleNotifier(this._locale);

  Locale get locale => _locale;

  /// Call this before runApp to read the stored preference.
  static Future<LocaleNotifier> create() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.languageKey) ?? 'en';
    return LocaleNotifier(Locale(code));
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, languageCode);
    notifyListeners();
  }
}
