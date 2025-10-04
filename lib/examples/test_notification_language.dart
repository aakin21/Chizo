import '../services/notification_service.dart';
import '../services/language_service.dart';
import 'package:flutter/material.dart';

/// Test notification language switching
class TestNotificationLanguage {
  
  /// Test notification in current language
  static Future<void> testCurrentLanguage() async {
    print('🧪 Testing notification in current language...');
    
    // Test different notification types
    await NotificationService.sendLocalizedNotification(
      type: 'tournament_update',
      data: {'tournament_name': 'Test Tournament'},
    );
    
    await NotificationService.sendLocalizedNotification(
      type: 'coin_reward',
      data: {'coins': '50'},
    );
    
    await NotificationService.sendLocalizedNotification(
      type: 'streak_reminder',
      data: {'streak': '7'},
    );
    
    print('✅ Current language test completed!');
  }

  /// Test notification in specific language
  static Future<void> testSpecificLanguage(String languageCode) async {
    print('🧪 Testing notification in $languageCode...');
    
    await NotificationService.sendLocalizedNotificationWithLanguage(
      type: 'tournament_update',
      language: languageCode,
      data: {'tournament_name': 'Test Tournament'},
    );
    
    print('✅ $languageCode test completed!');
  }

  /// Test all languages
  static Future<void> testAllLanguages() async {
    print('🧪 Testing all languages...');
    
    // Test Turkish
    await testSpecificLanguage('tr');
    
    // Test English
    await testSpecificLanguage('en');
    
    // Test German
    await testSpecificLanguage('de');
    
    // Test Spanish
    await testSpecificLanguage('es');
    
    print('✅ All languages test completed!');
  }

  /// Test language switching
  static Future<void> testLanguageSwitching() async {
    print('🧪 Testing language switching...');
    
    // Set to Turkish
    await LanguageService.setLanguage(const Locale('tr', 'TR'));
    await testCurrentLanguage();
    
    // Set to English
    await LanguageService.setLanguage(const Locale('en', 'US'));
    await testCurrentLanguage();
    
    // Set to German
    await LanguageService.setLanguage(const Locale('de', 'DE'));
    await testCurrentLanguage();
    
    // Set to Spanish
    await LanguageService.setLanguage(const Locale('es', 'ES'));
    await testCurrentLanguage();
    
    print('✅ Language switching test completed!');
  }
}
