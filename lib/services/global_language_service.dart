import 'package:flutter/material.dart';
import 'language_service.dart';

class GlobalLanguageService {
  static final GlobalLanguageService _instance = GlobalLanguageService._internal();
  factory GlobalLanguageService() => _instance;
  GlobalLanguageService._internal();

  // Global dil değiştirme callback'i
  Function(Locale)? _onLanguageChanged;

  // Callback'i kaydet
  void setLanguageChangeCallback(Function(Locale) callback) {
    _onLanguageChanged = callback;
  }

  // Dil değiştir
  Future<void> changeLanguage(Locale locale) async {
    // Önce dil ayarını kaydet
    await LanguageService.setLanguage(locale);
    
    // Kısa bir gecikme - dil ayarının kaydedilmesi için
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Sonra global callback'i çağır
    if (_onLanguageChanged != null) {
      _onLanguageChanged!(locale);
    }
  }

  // Mevcut dili al
  Future<Locale> getCurrentLocale() async {
    return await LanguageService.getCurrentLocale();
  }
}
