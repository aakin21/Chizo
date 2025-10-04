import '../services/notification_service.dart';

/// Basit bildirim örnekleri
class SimpleNotificationExample {
  
  /// Turnuva güncellemesi bildirimi gönder
  static Future<void> sendTournamentUpdate() async {
    await NotificationService.sendLocalizedNotification(
      type: 'tournament_update',
      data: {
        'tournament_name': 'Haftalık Erkek Turnuvası',
      },
    );
  }

  /// Coin ödülü bildirimi gönder
  static Future<void> sendCoinReward() async {
    await NotificationService.sendLocalizedNotification(
      type: 'coin_reward',
      data: {
        'coins': '50',
      },
    );
  }

  /// Streak hatırlatması bildirimi gönder
  static Future<void> sendStreakReminder() async {
    await NotificationService.sendLocalizedNotification(
      type: 'streak_reminder',
      data: {
        'streak': '7',
      },
    );
  }

  /// Maç kazanma bildirimi gönder
  static Future<void> sendMatchWon() async {
    await NotificationService.sendLocalizedNotification(
      type: 'match_won',
    );
  }

  /// Oylama sonucu bildirimi gönder
  static Future<void> sendVotingResult() async {
    await NotificationService.sendLocalizedNotification(
      type: 'voting_result',
    );
  }

  /// Sistem duyurusu bildirimi gönder
  static Future<void> sendSystemAnnouncement() async {
    await NotificationService.sendLocalizedNotification(
      type: 'system_announcement',
      data: {
        'message': 'Hoş geldiniz! Chizo\'ya başlamak için ilk maçınızı yapın.',
      },
    );
  }

  /// Belirli dilde bildirim gönder
  static Future<void> sendNotificationInLanguage(String language) async {
    await NotificationService.sendLocalizedNotificationWithLanguage(
      type: 'tournament_update',
      language: language,
      data: {
        'tournament_name': 'Test Tournament',
      },
    );
  }

  /// Tüm dillerde test bildirimi gönder
  static Future<void> testAllLanguages() async {
    print('🧪 Testing notifications in all languages...');
    
    // Türkçe
    print('🇹🇷 Testing Turkish...');
    await sendNotificationInLanguage('tr');
    
    // İngilizce
    print('🇺🇸 Testing English...');
    await sendNotificationInLanguage('en');
    
    // Almanca
    print('🇩🇪 Testing German...');
    await sendNotificationInLanguage('de');
    
    // İspanyolca
    print('🇪🇸 Testing Spanish...');
    await sendNotificationInLanguage('es');
    
    print('✅ All language tests completed!');
  }
}
