import 'package:flutter/material.dart';
import 'package:pashu_swasthya/utils/app_strings.dart';

class LocalizationService with ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
  }

  String translate(String key) {
    final String languageCode = _locale.languageCode;
    if (AppStrings.translations.containsKey(languageCode)) {
      return AppStrings.translations[languageCode]?[key] ?? key;
    }
    // Fallback to English if translation not found
    return AppStrings.translations['en']?[key] ?? key;
  }
}
