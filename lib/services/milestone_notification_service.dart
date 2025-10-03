import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';

class MilestoneNotificationService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Check and send photo milestone notifications
  static Future<void> checkPhotoMilestones({
    required int photoId,
    required int newWinCount,
    required String photoName,
  }) async {
    try {
      // Foto milestone kontrolü: 100, 200, 300, 400, 500 ve katları
      final milestones = [100, 200, 300, 400, 500];
      
      for (int milestone in milestones) {
        if (newWinCount == milestone || (newWinCount > milestone && newWinCount % 100 == 0)) {
          await NotificationService.sendPhotoMilestoneNotification(
            photoId: photoId,
            winCount: newWinCount,
            photoName: photoName,
          );
          break; // Sadece bir milestone bildirimi gönder
        }
      }
    } catch (e) {
      print('❌ Failed to check photo milestones: $e');
    }
  }

  /// Check and send total milestone notifications
  static Future<void> checkTotalMilestones({
    required int newTotalWins,
  }) async {
    try {
      // Toplam milestone kontrolü: 500 ve katları
      if (newTotalWins >= 500 && newTotalWins % 500 == 0) {
        await NotificationService.sendTotalMilestoneNotification(
          totalWins: newTotalWins,
        );
      }
    } catch (e) {
      print('❌ Failed to check total milestones: $e');
    }
  }

  /// Check all milestones for a user
  static Future<void> checkAllMilestones({
    required String userId,
  }) async {
    try {
      // Kullanıcının tüm foto win sayılarını al
      final photosResponse = await _client
          .from('user_photos')
          .select('id, win_count, photo_name')
          .eq('user_id', userId);

      if (photosResponse.isNotEmpty) {
        for (var photo in photosResponse) {
          await checkPhotoMilestones(
            photoId: photo['id'],
            newWinCount: photo['win_count'] ?? 0,
            photoName: photo['photo_name'] ?? 'Foto',
          );
        }
      }

      // Toplam win sayısını al
      final userResponse = await _client
          .from('users')
          .select('total_wins')
          .eq('id', userId)
          .single();

      if (userResponse.isNotEmpty) {
        await checkTotalMilestones(
          newTotalWins: userResponse['total_wins'] ?? 0,
        );
      }
    } catch (e) {
      print('❌ Failed to check all milestones: $e');
    }
  }

  /// Send hot streak reward notification
  static Future<void> sendHotStreakRewardNotification({
    required int streakDays,
    required int coinReward,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: '🔥 Hot Streak Ödülü!',
        body: 'Tebrikler! $streakDays. gün hot streak ödülü: $coinReward coin!',
        type: NotificationTypes.coinReward,
        data: {
          'streak_days': streakDays,
          'coin_reward': coinReward,
        },
      );
    } catch (e) {
      print('❌ Failed to send hot streak reward notification: $e');
    }
  }

  /// Send daily login reward notification
  static Future<void> sendDailyLoginRewardNotification({
    required int coinReward,
    required int streakDays,
  }) async {
    try {
      await NotificationService.sendLocalNotification(
        title: '🎁 Günlük Giriş Ödülü!',
        body: 'Bugün $coinReward coin kazandınız! Hot streak: $streakDays gün',
        type: NotificationTypes.coinReward,
        data: {
          'coin_reward': coinReward,
          'streak_days': streakDays,
        },
      );
    } catch (e) {
      print('❌ Failed to send daily login reward notification: $e');
    }
  }
}