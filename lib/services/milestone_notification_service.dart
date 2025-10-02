import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class MilestoneNotificationService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Fotoğraf milestone bildirimi gönder
  static Future<void> checkPhotoMilestone(String photoId, int photoWins) async {
    try {
      // 100'ün katları kontrol et (100, 200, 300, 400, 500...)
      if (photoWins > 0 && photoWins % 100 == 0) {
        await _createPhotoMilestoneNotification(photoId, photoWins);
      }
    } catch (e) {
      print('❌ Failed to check photo milestone: $e');
    }
  }

  // Total profil milestone bildirimi gönder
  static Future<void> checkTotalMilestone(int totalWins) async {
    try {
      // 500'ün katları kontrol et (500, 1000, 1500, 2000...)
      if (totalWins > 0 && totalWins % 500 == 0) {
        await _createTotalMilestoneNotification(totalWins);
      }
    } catch (e) {
      print('❌ Failed to check total milestone: $e');
    }
  }

  // Fotoğraf milestone bildirimi oluştur
  static Future<void> _createPhotoMilestoneNotification(String photoId, int wins) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      // Fotoğraf bilgisini al
      final photoResponse = await _client
          .from('user_photos')
          .select('photo_url')
          .eq('id', photoId)
          .single();

      final photoUrl = photoResponse['photo_url'] as String?;
      final photoNumber = await _getPhotoNumber(photoId);

      await _client.from('notifications').insert({
        'user_id': user.id,
        'type': NotificationTypes.photoMilestone,
        'title': 'Fotoğraf Milestone! 🎉',
        'body': '$photoNumber. fotoğrafın $wins. matchini kazandı!',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'data': {
          'photo_id': photoId,
          'photo_url': photoUrl,
          'wins': wins,
          'photo_number': photoNumber,
        },
      });

      print('✅ Photo milestone notification created: $photoNumber. fotoğraf $wins wins');
    } catch (e) {
      print('❌ Failed to create photo milestone notification: $e');
    }
  }

  // Total milestone bildirimi oluştur
  static Future<void> _createTotalMilestoneNotification(int totalWins) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      await _client.from('notifications').insert({
        'user_id': user.id,
        'type': NotificationTypes.totalMilestone,
        'title': 'Toplam Milestone! 🏆',
        'body': 'Toplam $totalWins. matchini kazandın!',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'data': {
          'total_wins': totalWins,
        },
      });

      print('✅ Total milestone notification created: $totalWins total wins');
    } catch (e) {
      print('❌ Failed to create total milestone notification: $e');
    }
  }

  // Fotoğraf numarasını al
  static Future<int> _getPhotoNumber(String photoId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 1;

      final response = await _client
          .from('user_photos')
          .select('created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      final photos = response as List;
      for (int i = 0; i < photos.length; i++) {
        if (photos[i]['id'] == photoId) {
          return i + 1;
        }
      }
      return 1;
    } catch (e) {
      print('❌ Failed to get photo number: $e');
      return 1;
    }
  }

  // Match kazanma bildirimi gönder (sadece milestone değilse)
  static Future<void> sendMatchWinNotification(String photoId, int photoWins, int totalWins) async {
    try {
      // Milestone kontrolü yap
      await checkPhotoMilestone(photoId, photoWins);
      await checkTotalMilestone(totalWins);

      // Normal match kazanma bildirimi (milestone değilse)
      if (photoWins % 100 != 0 && totalWins % 500 != 0) {
        await _createMatchWinNotification(photoId, photoWins);
      }
    } catch (e) {
      print('❌ Failed to send match win notification: $e');
    }
  }

  // Normal match kazanma bildirimi oluştur
  static Future<void> _createMatchWinNotification(String photoId, int photoWins) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      final photoNumber = await _getPhotoNumber(photoId);

      await _client.from('notifications').insert({
        'user_id': user.id,
        'type': NotificationTypes.matchWon,
        'title': 'Match Kazandın! 🎉',
        'body': '$photoNumber. fotoğrafın $photoWins. matchini kazandı!',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'data': {
          'photo_id': photoId,
          'wins': photoWins,
          'photo_number': photoNumber,
        },
      });

      print('✅ Match win notification created: $photoNumber. fotoğraf $photoWins wins');
    } catch (e) {
      print('❌ Failed to create match win notification: $e');
    }
  }
}
