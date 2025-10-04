import '../services/language_service.dart';

class NotificationLanguageService {
  /// Get localized notification content based on current language
  static Future<Map<String, String>> getLocalizedContent({
    required String type,
    Map<String, dynamic>? data,
  }) async {
    // Get current language
    final currentLanguage = await _getCurrentLanguageCode();
    
    switch (type) {
      case 'tournament_update':
        return _getTournamentUpdateContent(currentLanguage, data);
      case 'coin_reward':
        return _getCoinRewardContent(currentLanguage, data);
      case 'coin_purchase':
        return _getCoinPurchaseContent(currentLanguage, data);
      case 'coin_spent':
        return _getCoinSpentContent(currentLanguage, data);
      case 'streak_reminder':
        return _getStreakReminderContent(currentLanguage, data);
      case 'hotstreak_reward':
        return _getHotStreakRewardContent(currentLanguage, data);
      case 'hotstreak_reminder':
        return _getHotStreakReminderContent(currentLanguage, data);
      case 'match_won':
        return _getMatchWonContent(currentLanguage, data);
      case 'voting_result':
        return _getVotingResultContent(currentLanguage, data);
      case 'system_announcement':
        return _getSystemAnnouncementContent(currentLanguage, data);
      default:
        return _getDefaultContent(currentLanguage, data);
    }
  }

  /// Get localized notification content with specific language
  static Map<String, String> getLocalizedContentWithLanguage({
    required String type,
    required String language,
    Map<String, dynamic>? data,
  }) {
    switch (type) {
      case 'tournament_update':
        return _getTournamentUpdateContent(language, data);
      case 'coin_reward':
        return _getCoinRewardContent(language, data);
      case 'coin_purchase':
        return _getCoinPurchaseContent(language, data);
      case 'coin_spent':
        return _getCoinSpentContent(language, data);
      case 'streak_reminder':
        return _getStreakReminderContent(language, data);
      case 'hotstreak_reward':
        return _getHotStreakRewardContent(language, data);
      case 'hotstreak_reminder':
        return _getHotStreakReminderContent(language, data);
      case 'match_won':
        return _getMatchWonContent(language, data);
      case 'voting_result':
        return _getVotingResultContent(language, data);
      case 'system_announcement':
        return _getSystemAnnouncementContent(language, data);
      default:
        return _getDefaultContent(language, data);
    }
  }

  /// Get current language code
  static Future<String> _getCurrentLanguageCode() async {
    try {
      // Get current language from language service
      final locale = await LanguageService.getCurrentLocale();
      return locale.languageCode;
    } catch (e) {
      return 'tr'; // Default to Turkish
    }
  }

  /// Tournament Update Content
  static Map<String, String> _getTournamentUpdateContent(String language, Map<String, dynamic>? data) {
    final tournamentName = data?['tournament_name'] ?? 'Turnuva';
    
    switch (language) {
      case 'en':
        return {
          'title': '🏆 Tournament Update',
          'body': 'There\'s a new update in the $tournamentName tournament!',
        };
      case 'de':
        return {
          'title': '🏆 Turnier-Update',
          'body': 'Es gibt ein neues Update im $tournamentName Turnier!',
        };
      case 'es':
        return {
          'title': '🏆 Actualización del Torneo',
          'body': '¡Hay una nueva actualización en el torneo $tournamentName!',
        };
      default: // Turkish
        return {
          'title': '🏆 Turnuva Güncellemesi',
          'body': '$tournamentName turnuvasında yeni bir güncelleme var!',
        };
    }
  }

  /// Coin Reward Content
  static Map<String, String> _getCoinRewardContent(String language, Map<String, dynamic>? data) {
    final coins = data?['coins'] ?? '1';
    
    switch (language) {
      case 'en':
        return {
          'title': '💰 Coin Reward',
          'body': 'Congratulations! You earned $coins coins!',
        };
      case 'de':
        return {
          'title': '💰 Münzen-Belohnung',
          'body': 'Herzlichen Glückwunsch! Sie haben $coins Münzen verdient!',
        };
      case 'es':
        return {
          'title': '💰 Recompensa de Monedas',
          'body': '¡Felicidades! ¡Ganaste $coins monedas!',
        };
      default: // Turkish
        return {
          'title': '💰 Coin Ödülü',
          'body': 'Tebrikler! $coins coin kazandınız!',
        };
    }
  }

  /// Coin Purchase Content
  static Map<String, String> _getCoinPurchaseContent(String language, Map<String, dynamic>? data) {
    final coins = data?['coin_amount'] ?? '1';
    final price = data?['price'] ?? '0';
    final currency = data?['currency'] ?? 'TL';
    
    switch (language) {
      case 'en':
        return {
          'title': '💰 Coins Purchased!',
          'body': 'You purchased $coins coins ($price $currency)',
        };
      case 'de':
        return {
          'title': '💰 Münzen gekauft!',
          'body': 'Sie haben $coins Münzen gekauft ($price $currency)',
        };
      case 'es':
        return {
          'title': '💰 ¡Monedas Compradas!',
          'body': 'Compraste $coins monedas ($price $currency)',
        };
      default: // Turkish
        return {
          'title': '💰 Coin Satın Alındı!',
          'body': '$coins coin satın aldınız ($price $currency)',
        };
    }
  }

  /// Coin Spent Content
  static Map<String, String> _getCoinSpentContent(String language, Map<String, dynamic>? data) {
    final coins = data?['coins'] ?? '1';
    final description = data?['description'] ?? '';
    
    switch (language) {
      case 'en':
        return {
          'title': '💸 Coins Spent',
          'body': '$coins coins spent. $description',
        };
      case 'de':
        return {
          'title': '💸 Münzen ausgegeben',
          'body': '$coins Münzen ausgegeben. $description',
        };
      case 'es':
        return {
          'title': '💸 Monedas Gastadas',
          'body': '$coins monedas gastadas. $description',
        };
      default: // Turkish
        return {
          'title': '💸 Coin Harcandı',
          'body': '$coins coin harcandı. $description',
        };
    }
  }

  /// Streak Reminder Content
  static Map<String, String> _getStreakReminderContent(String language, Map<String, dynamic>? data) {
    final streak = data?['streak'] ?? '1';
    
    switch (language) {
      case 'en':
        return {
          'title': '🔥 Streak Reminder',
          'body': 'You have a $streak day streak! Keep it up!',
        };
      case 'de':
        return {
          'title': '🔥 Streak-Erinnerung',
          'body': 'Sie haben einen $streak-Tage-Streak! Machen Sie weiter!',
        };
      case 'es':
        return {
          'title': '🔥 Recordatorio de Racha',
          'body': '¡Tienes una racha de $streak días! ¡Sigue así!',
        };
      default: // Turkish
        return {
          'title': '🔥 Streak Hatırlatması',
          'body': '$streak günlük streak\'iniz var! Devam edin!',
        };
    }
  }

  /// Hot Streak Reward Content
  static Map<String, String> _getHotStreakRewardContent(String language, Map<String, dynamic>? data) {
    final streak = data?['streak_days'] ?? data?['streak'] ?? '1';
    final coins = data?['coin_reward'] ?? data?['coins'] ?? '50';
    
    switch (language) {
      case 'en':
        return {
          'title': '🔥 Hot Streak Reward!',
          'body': 'Congratulations! $streak day streak reward: $coins coins!',
        };
      case 'de':
        return {
          'title': '🔥 Hot Streak Belohnung!',
          'body': 'Herzlichen Glückwunsch! $streak Tage Streak Belohnung: $coins Münzen!',
        };
      case 'es':
        return {
          'title': '🔥 ¡Recompensa de Racha Caliente!',
          'body': '¡Felicidades! Recompensa de racha de $streak días: $coins monedas!',
        };
      default: // Turkish
        return {
          'title': '🔥 Hot Streak Ödülü!',
          'body': 'Tebrikler! $streak. gün hot streak ödülü: $coins coin!',
        };
    }
  }

  /// Hot Streak Reminder Content
  static Map<String, String> _getHotStreakReminderContent(String language, Map<String, dynamic>? data) {
    final streak = data?['streak'] ?? '1';
    
    switch (language) {
      case 'en':
        return {
          'title': '🔥 Hot Streak Reminder!',
          'body': 'Don\'t forget to log in today! Don\'t break your $streak day streak!',
        };
      case 'de':
        return {
          'title': '🔥 Hot Streak Erinnerung!',
          'body': 'Vergessen Sie nicht, sich heute anzumelden! Brechen Sie nicht Ihren $streak-Tage-Streak!',
        };
      case 'es':
        return {
          'title': '🔥 ¡Recordatorio de Racha Caliente!',
          'body': '¡No olvides iniciar sesión hoy! ¡No rompas tu racha de $streak días!',
        };
      default: // Turkish
        return {
          'title': '🔥 Hot Streak Hatırlatması!',
          'body': 'Bu gün girmeyi unutma! $streak. gün hot streakini kaçırma!',
        };
    }
  }

  /// Match Won Content
  static Map<String, String> _getMatchWonContent(String language, Map<String, dynamic>? data) {
    switch (language) {
      case 'en':
        return {
          'title': '🎉 Match Won',
          'body': 'Congratulations! You won the match!',
        };
      case 'de':
        return {
          'title': '🎉 Match gewonnen',
          'body': 'Herzlichen Glückwunsch! Sie haben das Match gewonnen!',
        };
      case 'es':
        return {
          'title': '🎉 Partido Ganado',
          'body': '¡Felicidades! ¡Ganaste el partido!',
        };
      default: // Turkish
        return {
          'title': '🎉 Maç Kazandınız',
          'body': 'Tebrikler! Maçı kazandınız!',
        };
    }
  }

  /// Voting Result Content
  static Map<String, String> _getVotingResultContent(String language, Map<String, dynamic>? data) {
    switch (language) {
      case 'en':
        return {
          'title': '🗳️ Voting Result',
          'body': 'Voting results have been announced! Check the results.',
        };
      case 'de':
        return {
          'title': '🗳️ Abstimmungsergebnis',
          'body': 'Die Abstimmungsergebnisse wurden bekannt gegeben! Prüfen Sie die Ergebnisse.',
        };
      case 'es':
        return {
          'title': '🗳️ Resultado de Votación',
          'body': '¡Los resultados de la votación han sido anunciados! Revisa los resultados.',
        };
      default: // Turkish
        return {
          'title': '🗳️ Oylama Sonucu',
          'body': 'Oylama sonuçları açıklandı! Sonuçları kontrol edin.',
        };
    }
  }

  /// System Announcement Content
  static Map<String, String> _getSystemAnnouncementContent(String language, Map<String, dynamic>? data) {
    final message = data?['message'] ?? 'System announcement';
    
    switch (language) {
      case 'en':
        return {
          'title': '📢 System Announcement',
          'body': message,
        };
      case 'de':
        return {
          'title': '📢 System-Ankündigung',
          'body': message,
        };
      case 'es':
        return {
          'title': '📢 Anuncio del Sistema',
          'body': message,
        };
      default: // Turkish
        return {
          'title': '📢 Sistem Duyurusu',
          'body': message,
        };
    }
  }

  /// Default Content
  static Map<String, String> _getDefaultContent(String language, Map<String, dynamic>? data) {
    switch (language) {
      case 'en':
        return {
          'title': '🔔 Notification',
          'body': 'You have a new notification!',
        };
      case 'de':
        return {
          'title': '🔔 Benachrichtigung',
          'body': 'Sie haben eine neue Benachrichtigung!',
        };
      case 'es':
        return {
          'title': '🔔 Notificación',
          'body': '¡Tienes una nueva notificación!',
        };
      default: // Turkish
        return {
          'title': '🔔 Bildirim',
          'body': 'Yeni bir bildiriminiz var!',
        };
    }
  }
}
