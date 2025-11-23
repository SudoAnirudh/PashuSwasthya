import 'package:flutter/material.dart';
import 'package:pashu_swasthya/utils/app_strings.dart';
import 'package:pashu_swasthya/services/storage_service.dart';

class LocalizationService with ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  final StorageService _storageService = StorageService();

  LocalizationService() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    await _storageService.init();
    final languageCode = await _storageService.getLanguagePreference();
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    await _storageService.saveLanguagePreference(locale.languageCode);
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
