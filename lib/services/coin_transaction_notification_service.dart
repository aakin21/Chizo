import '../models/notification_model.dart';
import 'notification_service.dart';

class CoinTransactionNotificationService {

  /// Send coin purchase notification with language support
  static Future<void> sendCoinPurchaseNotification({
    required int coinAmount,
    required double price,
    required String currency,
  }) async {
    try {
      // Dil desteği ile bildirim gönder
      await NotificationService.sendLocalizedNotification(
        type: 'coin_purchase',
        data: {
          'transaction_type': 'purchase',
          'coin_amount': coinAmount,
          'price': price,
          'currency': currency,
        },
      );
    } catch (e) {
      print('❌ Failed to send coin purchase notification: $e');
    }
  }

  /// Send coin earned from prediction notification with language support
  static Future<void> sendCoinEarnedFromPredictionNotification({
    required int coinAmount,
    required String matchId,
    required String matchTitle,
  }) async {
    try {
      await NotificationService.sendLocalizedNotification(
        type: 'coin_reward',
        data: {
          'coins': coinAmount.toString(),
          'description': '$matchTitle tahmininden',
        },
      );
    } catch (e) {
      print('❌ Failed to send coin earned from prediction notification: $e');
    }
  }

  /// Send coin spent notification with language support
  static Future<void> sendCoinSpentNotification({
    required int coinAmount,
    required String reason,
    required String itemName,
  }) async {
    try {
      print('🪙 Sending coin spent notification: $coinAmount coins for $itemName ($reason)');
      
      await NotificationService.sendLocalizedNotification(
        type: 'coin_spent',
        data: {
          'coins': coinAmount.toString(),
          'description': '$itemName için ($reason)',
        },
      );
      
      print('✅ Coin spent notification sent successfully');
    } catch (e) {
      print('❌ Failed to send coin spent notification: $e');
    }
  }

  /// Send coin earned from ad notification with language support
  static Future<void> sendCoinEarnedFromAdNotification({
    required int coinAmount,
  }) async {
    try {
      await NotificationService.sendLocalizedNotification(
        type: 'coin_reward',
        data: {
          'coins': coinAmount.toString(),
          'description': 'Reklam izleyerek',
        },
      );
    } catch (e) {
      print('❌ Failed to send coin earned from ad notification: $e');
    }
  }

  /// Send coin earned from hot streak notification
  static Future<void> sendCoinEarnedFromHotStreakNotification({
    required int coinAmount,
    required int streakDays,
  }) async {
    try {
      await NotificationService.sendLocalizedNotification(
        type: 'hotstreak_reward',
        data: {
          'streak_days': streakDays,
          'coin_reward': coinAmount,
        },
      );
    } catch (e) {
      print('❌ Failed to send coin earned from hot streak notification: $e');
    }
  }

  /// Send coin earned from daily login notification
  static Future<void> sendCoinEarnedFromDailyLoginNotification({
    required int coinAmount,
    required int streakDays,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: 'Günlük Giriş Ödülü!',
        body: 'Günlük giriş ödülü: $coinAmount coin! (Hot streak: $streakDays gün)',
        type: NotificationTypes.coinReward,
        data: {
          'transaction_type': 'daily_login_earned',
          'coin_amount': coinAmount,
          'streak_days': streakDays,
        },
      );
    } catch (e) {
      print('❌ Failed to send coin earned from daily login notification: $e');
    }
  }

  /// Send coin earned from match win notification
  static Future<void> sendCoinEarnedFromMatchWinNotification({
    required int coinAmount,
    required String opponentName,
    required String matchId,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: 'Maç Kazanma Ödülü!',
        body: '$opponentName karşısında kazandınız! $coinAmount coin kazandınız!',
        type: NotificationTypes.coinReward,
        data: {
          'transaction_type': 'match_win_earned',
          'coin_amount': coinAmount,
          'opponent_name': opponentName,
          'match_id': matchId,
        },
      );
    } catch (e) {
      print('❌ Failed to send coin earned from match win notification: $e');
    }
  }

  /// Send coin earned from tournament notification
  static Future<void> sendCoinEarnedFromTournamentNotification({
    required int coinAmount,
    required String tournamentName,
    required String position,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: 'Turnuva Ödülü!',
        body: '$tournamentName turnuvasında $position. oldunuz! $coinAmount coin kazandınız!',
        type: NotificationTypes.coinReward,
        data: {
          'transaction_type': 'tournament_earned',
          'coin_amount': coinAmount,
          'tournament_name': tournamentName,
          'position': position,
        },
      );
    } catch (e) {
      print('❌ Failed to send coin earned from tournament notification: $e');
    }
  }

  /// Send coin earned from voting notification
  static Future<void> sendCoinEarnedFromVotingNotification({
    required int coinAmount,
    required String matchTitle,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: 'Oylama Ödülü!',
        body: '$matchTitle oylamasından $coinAmount coin kazandınız!',
        type: NotificationTypes.coinReward,
        data: {
          'transaction_type': 'voting_earned',
          'coin_amount': coinAmount,
          'match_title': matchTitle,
        },
      );
    } catch (e) {
      print('❌ Failed to send coin earned from voting notification: $e');
    }
  }

  /// Send coin earned from referral notification
  static Future<void> sendCoinEarnedFromReferralNotification({
    required int coinAmount,
    required String referredUserName,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: 'Referans Ödülü!',
        body: '$referredUserName kullanıcısını davet ettiniz! $coinAmount coin kazandınız!',
        type: NotificationTypes.coinReward,
        data: {
          'transaction_type': 'referral_earned',
          'coin_amount': coinAmount,
          'referred_user_name': referredUserName,
        },
      );
    } catch (e) {
      print('❌ Failed to send coin earned from referral notification: $e');
    }
  }

  /// Send coin earned from achievement notification
  static Future<void> sendCoinEarnedFromAchievementNotification({
    required int coinAmount,
    required String achievementName,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: 'Başarı Ödülü!',
        body: '$achievementName başarısını tamamladınız! $coinAmount coin kazandınız!',
        type: NotificationTypes.coinReward,
        data: {
          'transaction_type': 'achievement_earned',
          'coin_amount': coinAmount,
          'achievement_name': achievementName,
        },
      );
    } catch (e) {
      print('❌ Failed to send coin earned from achievement notification: $e');
    }
  }

  /// Send coin earned from bonus notification
  static Future<void> sendCoinEarnedFromBonusNotification({
    required int coinAmount,
    required String bonusType,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: 'Bonus Ödülü!',
        body: '$bonusType bonusundan $coinAmount coin kazandınız!',
        type: NotificationTypes.coinReward,
        data: {
          'transaction_type': 'bonus_earned',
          'coin_amount': coinAmount,
          'bonus_type': bonusType,
        },
      );
    } catch (e) {
      print('❌ Failed to send coin earned from bonus notification: $e');
    }
  }

  /// Send coin earned from special event notification
  static Future<void> sendCoinEarnedFromSpecialEventNotification({
    required int coinAmount,
    required String eventName,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: 'Özel Etkinlik Ödülü!',
        body: '$eventName etkinliğinden $coinAmount coin kazandınız!',
        type: NotificationTypes.coinReward,
        data: {
          'transaction_type': 'special_event_earned',
          'coin_amount': coinAmount,
          'event_name': eventName,
        },
      );
    } catch (e) {
      print('❌ Failed to send coin earned from special event notification: $e');
    }
  }
}
