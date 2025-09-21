import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const Locale _defaultLocale = Locale('tr', 'TR');
  
  static final List<Locale> supportedLocales = [
    const Locale('tr', 'TR'), // Turkish
    const Locale('en', 'US'), // English
  ];

  // Mevcut dili al
  static Future<Locale> getCurrentLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      return Locale(languageCode);
    }
    
    return _defaultLocale;
  }

  // Dili kaydet
  static Future<void> setLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  // Desteklenen dillerin listesi
  static List<Map<String, dynamic>> getLanguageOptions() {
    return [
      {
        'code': 'tr',
        'name': 'Türkçe',
        'flag': '🇹🇷',
        'locale': const Locale('tr', 'TR'),
      },
      {
        'code': 'en',
        'name': 'English',
        'flag': '🇺🇸',
        'locale': const Locale('en', 'US'),
      },
    ];
  }

  // Dil adını al
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'Türkçe';
    }
  }

  // Dil adını context'e göre al
  static String getLanguageNameWithContext(BuildContext context, String languageCode) {
    final l10n = AppLocalizations.of(context);
    switch (languageCode) {
      case 'tr':
        return l10n.turkish;
      case 'en':
        return l10n.english;
      default:
        return l10n.turkish;
    }
  }

  // Dil bayrağını al
  static String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return '🇹🇷';
      case 'en':
        return '🇺🇸';
      default:
        return '🇹🇷';
    }
  }
}
