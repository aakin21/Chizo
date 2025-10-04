import '../services/notification_service.dart';
import '../services/language_service.dart';
import 'package:flutter/material.dart';

/// Düzeltilmiş bildirim sistemi testi
class FixedNotificationTest {
  
  /// Coin satın alma testi (duplicate olmamalı)
  static Future<void> testCoinPurchase() async {
    print('🧪 Testing coin purchase notification...');
    
    // Coin satın alma bildirimi gönder
    await NotificationService.sendLocalizedNotification(
      type: 'coin_purchase',
      data: {
        'coin_amount': '250',
        'price': '10.0',
        'currency': 'TL',
      },
    );
    
    print('✅ Coin purchase test completed!');
  }

  /// Dil değiştirme testi
  static Future<void> testLanguageSwitching() async {
    print('🧪 Testing language switching...');
    
    // Türkçe
    await LanguageService.setLanguage(const Locale('tr', 'TR'));
    await NotificationService.sendLocalizedNotification(
      type: 'coin_purchase',
      data: {
        'coin_amount': '250',
        'price': '10.0',
        'currency': 'TL',
      },
    );
    
    // İngilizce
    await LanguageService.setLanguage(const Locale('en', 'US'));
    await NotificationService.sendLocalizedNotification(
      type: 'coin_purchase',
      data: {
        'coin_amount': '250',
        'price': '10.0',
        'currency': 'TL',
      },
    );
    
    // Almanca
    await LanguageService.setLanguage(const Locale('de', 'DE'));
    await NotificationService.sendLocalizedNotification(
      type: 'coin_purchase',
      data: {
        'coin_amount': '250',
        'price': '10.0',
        'currency': 'TL',
      },
    );
    
    // İspanyolca
    await LanguageService.setLanguage(const Locale('es', 'ES'));
    await NotificationService.sendLocalizedNotification(
      type: 'coin_purchase',
      data: {
        'coin_amount': '250',
        'price': '10.0',
        'currency': 'TL',
      },
    );
    
    print('✅ Language switching test completed!');
  }

  /// Tüm bildirim türlerini test et
  static Future<void> testAllNotificationTypes() async {
    print('🧪 Testing all notification types...');
    
    final notificationTypes = [
      'tournament_update',
      'coin_reward',
      'coin_purchase',
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
    
    print('✅ All notification types test completed!');
  }

  /// Ana test metodu
  static Future<void> runAllTests() async {
    print('🚀 Starting fixed notification system tests...');
    
    await testCoinPurchase();
    await testLanguageSwitching();
    await testAllNotificationTypes();
    
    print('✅ All tests completed successfully!');
  }
}
