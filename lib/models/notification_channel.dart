/// Bildirim kanalları - Telefona push mu yoksa sadece app içi mi?
enum NotificationChannel {
  /// Telefona push notification gönder + Database'e kaydet
  PUSH,

  /// Sadece database'e kaydet (telefona gönderme)
  IN_APP_ONLY,
}

/// Bildirim tiplerinin kanal ayarları
class NotificationChannelConfig {
  static const Map<String, NotificationChannel> channels = {
    // 🔥 HOT STREAK - PUSH (Kritik!)
    'hotstreak_broken': NotificationChannel.PUSH,
    'hotstreak_milestone': NotificationChannel.PUSH,
    'hotstreak_reminder': NotificationChannel.PUSH,
    'hotstreak_reward': NotificationChannel.IN_APP_ONLY, // Coin ödülü, app içi
    'hotstreak_active': NotificationChannel.IN_APP_ONLY,

    // 🏆 TOURNAMENT - PUSH (Önemli!)
    'tournament_start': NotificationChannel.PUSH,
    'tournament_elimination_start': NotificationChannel.PUSH,
    'elimination_start': NotificationChannel.PUSH,
    'tournament_win': NotificationChannel.PUSH,
    'tournament_end': NotificationChannel.IN_APP_ONLY,
    'tournament_joined': NotificationChannel.IN_APP_ONLY,
    'tournament_reminder': NotificationChannel.IN_APP_ONLY,

    // 🎯 WIN MILESTONES - PUSH (Önemli başarılar!)
    'photo_milestone': NotificationChannel.PUSH, // 100, 200, 300... foto win
    'total_milestone': NotificationChannel.PUSH, // 500, 1000, 1500... total win

    // 📢 SİSTEM - PUSH
    'system_announcement': NotificationChannel.PUSH,
    'app_update': NotificationChannel.PUSH,
    'maintenance': NotificationChannel.PUSH,

    // 💰 COIN İŞLEMLERİ - IN_APP_ONLY (Hepsi)
    'coin_purchase': NotificationChannel.IN_APP_ONLY,
    'coin_spent': NotificationChannel.IN_APP_ONLY,
    'coin_reward': NotificationChannel.IN_APP_ONLY,
    'coin_earned': NotificationChannel.IN_APP_ONLY,

    // 🎯 PREDICTION - IN_APP_ONLY
    'prediction_won': NotificationChannel.IN_APP_ONLY,
    'prediction_lost': NotificationChannel.IN_APP_ONLY,
    'voting_reminder': NotificationChannel.IN_APP_ONLY,

    // ⚔️ MATCH - IN_APP_ONLY (Milestone hariç, o yukarıda)
    'match_win': NotificationChannel.IN_APP_ONLY,
    'match_loss': NotificationChannel.IN_APP_ONLY,
    'match_draw': NotificationChannel.IN_APP_ONLY,
    'match_result': NotificationChannel.IN_APP_ONLY,
  };

  /// Bildirim tipinin kanalını al (default: IN_APP_ONLY)
  static NotificationChannel getChannel(String type) {
    return channels[type] ?? NotificationChannel.IN_APP_ONLY;
  }

  /// Telefona push gönderilmeli mi?
  static bool shouldSendPush(String type) {
    return getChannel(type) == NotificationChannel.PUSH;
  }
}
