import '../services/notification_service.dart';
import '../services/language_service.dart';
import 'package:flutter/material.dart';

/// Dil düzeltmesi testi
class TestLanguageFix {
  
  /// Dil değiştirme testi
  static Future<void> testLanguageChange() async {
    print('🧪 Testing language change...');
    
    // Türkçe
    print('🇹🇷 Testing Turkish...');
    await LanguageService.setLanguage(const Locale('tr', 'TR'));
    await NotificationService.sendLocalizedNotification(
      type: 'coin_reward',
      data: {'coins': '250'},
    );
    
    // İngilizce
    print('🇺🇸 Testing English...');
    await LanguageService.setLanguage(const Locale('en', 'US'));
    await NotificationService.sendLocalizedNotification(
      type: 'coin_reward',
      data: {'coins': '250'},
    );
    
    // Almanca
    print('🇩🇪 Testing German...');
    await LanguageService.setLanguage(const Locale('de', 'DE'));
    await NotificationService.sendLocalizedNotification(
      type: 'coin_reward',
      data: {'coins': '250'},
    );
    
    // İspanyolca
    print('🇪🇸 Testing Spanish...');
    await LanguageService.setLanguage(const Locale('es', 'ES'));
    await NotificationService.sendLocalizedNotification(
      type: 'coin_reward',
      data: {'coins': '250'},
    );
    
    print('✅ Language change test completed!');
  }

  /// Coin satın alma testi
  static Future<void> testCoinPurchase() async {
    print('🧪 Testing coin purchase...');
    
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

  /// Coin harcama testi
  static Future<void> testCoinSpent() async {
    print('🧪 Testing coin spent...');
    
    await NotificationService.sendLocalizedNotification(
      type: 'coin_spent',
      data: {
        'coins': '50',
        'description': 'Maç girişi',
      },
    );
    
    print('✅ Coin spent test completed!');
  }

  /// Ana test metodu
  static Future<void> runAllTests() async {
    print('🚀 Starting language fix tests...');
    
    await testLanguageChange();
    await testCoinPurchase();
    await testCoinSpent();
    
    print('✅ All language fix tests completed!');
  }
}
