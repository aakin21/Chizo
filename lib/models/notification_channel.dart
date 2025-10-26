/// Bildirim kanalları - Telefona push mu yoksa sadece app içi mi?
enum NotificationChannel {
  /// Telefona push notification gönder + Database'e kaydet
  push,

  /// Sadece database'e kaydet (telefona gönderme)
  inAppOnly,
}

/// Bildirim tiplerinin kanal ayarları
class NotificationChannelConfig {
  static const Map<String, NotificationChannel> channels = {
    // 🔥 HOT STREAK - PUSH (Kritik!)
    'hotstreak_broken': NotificationChannel.push,
    'hotstreak_milestone': NotificationChannel.push,
    'hotstreak_reminder': NotificationChannel.push,
    'hotstreak_reward': NotificationChannel.inAppOnly, // Coin ödülü, app içi
    'hotstreak_active': NotificationChannel.inAppOnly,

    // 🏆 TOURNAMENT - PUSH (Önemli!)
    'tournament_start': NotificationChannel.push,
    'tournament_elimination_start': NotificationChannel.push,
    'elimination_start': NotificationChannel.push,
    'tournament_win': NotificationChannel.push,
    'tournament_end': NotificationChannel.inAppOnly,
    'tournament_joined': NotificationChannel.inAppOnly,
    'tournament_reminder': NotificationChannel.inAppOnly,

    // 🎯 WIN MILESTONES - PUSH (Önemli başarılar!)
    'photo_milestone': NotificationChannel.push, // 100, 200, 300... foto win
    'total_milestone': NotificationChannel.push, // 500, 1000, 1500... total win

    // 📢 SİSTEM - PUSH
    'system_announcement': NotificationChannel.push,
    'app_update': NotificationChannel.push,
    'maintenance': NotificationChannel.push,

    // 💰 COIN İŞLEMLERİ - IN_APP_ONLY (Hepsi)
    'coin_purchase': NotificationChannel.inAppOnly,
    'coin_spent': NotificationChannel.inAppOnly,
    'coin_reward': NotificationChannel.inAppOnly,
    'coin_earned': NotificationChannel.inAppOnly,

    // 🎯 PREDICTION - IN_APP_ONLY
    'prediction_won': NotificationChannel.inAppOnly,
    'prediction_lost': NotificationChannel.inAppOnly,
    'voting_reminder': NotificationChannel.inAppOnly,

    // ⚔️ MATCH - IN_APP_ONLY (Milestone hariç, o yukarıda)
    'match_win': NotificationChannel.inAppOnly,
    'match_loss': NotificationChannel.inAppOnly,
    'match_draw': NotificationChannel.inAppOnly,
    'match_result': NotificationChannel.inAppOnly,
  };

  /// Bildirim tipinin kanalını al (default: IN_APP_ONLY)
  static NotificationChannel getChannel(String type) {
    return channels[type] ?? NotificationChannel.inAppOnly;
  }

  /// Telefona push gönderilmeli mi?
  static bool shouldSendPush(String type) {
    return getChannel(type) == NotificationChannel.push;
  }
}
