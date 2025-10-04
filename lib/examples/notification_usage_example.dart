import '../services/notification_service.dart';
import '../services/language_service.dart';
import 'package:flutter/material.dart';

/// Bildirim kullanım örnekleri
class NotificationUsageExample {
  
  /// Basit bildirim gönder
  static Future<void> sendSimpleNotification() async {
    // Mevcut dilde bildirim gönder
    await NotificationService.sendLocalizedNotification(
      type: 'tournament_update',
      data: {'tournament_name': 'Haftalık Turnuva'},
    );
  }

  /// Belirli dilde bildirim gönder
  static Future<void> sendNotificationInEnglish() async {
    await NotificationService.sendLocalizedNotificationWithLanguage(
      type: 'coin_reward',
      language: 'en',
      data: {'coins': '100'},
    );
  }

  /// Dil değiştir ve bildirim gönder
  static Future<void> changeLanguageAndSendNotification() async {
    // Dil değiştir
    await LanguageService.setLanguage(const Locale('en', 'US'));
    
    // Yeni dilde bildirim gönder
    await NotificationService.sendLocalizedNotification(
      type: 'streak_reminder',
      data: {'streak': '5'},
    );
  }

  /// Tüm bildirim türlerini test et
  static Future<void> testAllNotificationTypes() async {
    final notificationTypes = [
      'tournament_update',
      'coin_reward',
      'streak_reminder',
      'match_won',
      'voting_result',
      'system_announcement',
    ];

    for (final type in notificationTypes) {
      await NotificationService.sendLocalizedNotification(
        type: type,
        data: {'test': 'data'},
      );
    }
  }

  /// Dil değiştirince bildirimlerin değiştiğini test et
  static Future<void> testLanguageChange() async {
    print('🧪 Testing language change...');
    
    // Türkçe
    await LanguageService.setLanguage(const Locale('tr', 'TR'));
    await NotificationService.sendLocalizedNotification(
      type: 'tournament_update',
      data: {'tournament_name': 'Test Turnuvası'},
    );
    
    // İngilizce
    await LanguageService.setLanguage(const Locale('en', 'US'));
    await NotificationService.sendLocalizedNotification(
      type: 'tournament_update',
      data: {'tournament_name': 'Test Tournament'},
    );
    
    // Almanca
    await LanguageService.setLanguage(const Locale('de', 'DE'));
    await NotificationService.sendLocalizedNotification(
      type: 'tournament_update',
      data: {'tournament_name': 'Test Turnier'},
    );
    
    // İspanyolca
    await LanguageService.setLanguage(const Locale('es', 'ES'));
    await NotificationService.sendLocalizedNotification(
      type: 'tournament_update',
      data: {'tournament_name': 'Torneo de Prueba'},
    );
    
    print('✅ Language change test completed!');
  }
}
