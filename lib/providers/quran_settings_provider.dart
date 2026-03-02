import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranSettingsProvider extends ChangeNotifier {
  static const _keyShowTranslation = 'show_translation';

  bool _showTranslation = true;

  bool get showTranslation => _showTranslation;

  QuranSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _showTranslation = prefs.getBool(_keyShowTranslation) ?? true;
    notifyListeners();
  }

  Future<void> setShowTranslation(bool value) async {
    _showTranslation = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowTranslation, value);
  }
}
