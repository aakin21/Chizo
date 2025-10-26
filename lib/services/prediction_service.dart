import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/user_service.dart';

class PredictionService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Win rate prediction'ı kaydet ve coin ödülü ver
  static Future<Map<String, dynamic>> submitPrediction({
    required String winnerId,
    required int minRange,
    required int maxRange,
    required double actualWinRate,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        return {'success': false, 'message': 'Kullanıcı giriş yapmamış'};
      }

      // users tablosundan gerçek user_id al
      final userRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', currentUser.id)
          .maybeSingle();

      if (userRecord == null) {
        return {'success': false, 'message': 'Kullanıcı bulunamadı'};
      }

      final userId = userRecord['id'];

      // Tahmin doğru mu kontrol et
      final isCorrect = actualWinRate >= minRange && actualWinRate <= maxRange;

      // Coin ödülü hesapla - sadece 1 coin
      int rewardCoins = 0;
      if (isCorrect) {
        rewardCoins = 1; // Her zaman 1 coin

        // Coin'i kullanıcıya ekle
        final success = await UserService.updateCoins(
          rewardCoins,
          'earned',
          'Win rate tahmini doğru'
        );

        if (!success) {
          return {'success': false, 'message': 'Coin eklenirken hata oluştu'};
        }
      }

      // Prediction'ı veritabanına kaydet (gerçek user_id ile)
      await _client.from('winrate_predictions').insert({
        'user_id': userId, // ✅ Gerçek user_id kullan (auth_id değil!)
        'winner_id': winnerId,
        'predicted_min': minRange,
        'predicted_max': maxRange,
        'actual_winrate': actualWinRate,
        'is_correct': isCorrect,
        'reward_coins': rewardCoins,
        'created_at': DateTime.now().toIso8601String(),
      });

      return {
        'success': true,
        'is_correct': isCorrect,
        'reward_coins': rewardCoins,
        'actual_winrate': actualWinRate,
        'message': isCorrect
            ? 'Tebrikler! Doğru tahmin ettin ve 1 coin kazandın!'
            : 'Maalesef yanlış tahmin ettin. Gerçek kazanma oranı: ${actualWinRate.toStringAsFixed(1)}%',
      };
    } catch (e, stackTrace) {
      debugPrint('❌ Error submitting prediction: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return {'success': false, 'message': 'Tahmin kaydedilirken hata oluştu: $e'};
    }
  }


  // Kullanıcının prediction geçmişini getir
  static Future<List<Map<String, dynamic>>> getUserPredictions({int limit = 10}) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];

      // users tablosundan gerçek user_id al
      final userRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', currentUser.id)
          .maybeSingle();

      if (userRecord == null) return [];

      final userId = userRecord['id'];

      final response = await _client
          .from('winrate_predictions')
          .select('''
            *,
            winner:users!winrate_predictions_winner_id_fkey(username, profile_image_url)
          ''')
          .eq('user_id', userId) // ✅ Gerçek user_id kullan
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      // debugPrint('Error getting user predictions: $e');
      return [];
    }
  }

  // Kullanıcının prediction istatistiklerini getir
  static Future<Map<String, dynamic>> getUserPredictionStats() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        return {'total_predictions': 0, 'correct_predictions': 0, 'total_coins_earned': 0, 'accuracy': 0.0};
      }

      // users tablosundan gerçek user_id al
      final userRecord = await _client
          .from('users')
          .select('id')
          .eq('auth_id', currentUser.id)
          .maybeSingle();

      if (userRecord == null) {
        return {'total_predictions': 0, 'correct_predictions': 0, 'total_coins_earned': 0, 'accuracy': 0.0};
      }

      final userId = userRecord['id'];

      final response = await _client
          .from('winrate_predictions')
          .select('is_correct, reward_coins')
          .eq('user_id', userId); // ✅ Gerçek user_id kullan

      int totalPredictions = response.length;
      int correctPredictions = response.where((p) => p['is_correct'] == true).length;
      int totalCoinsEarned = response.fold(0, (sum, p) => sum + (p['reward_coins'] as int? ?? 0));
      double accuracy = totalPredictions > 0 ? (correctPredictions / totalPredictions) * 100 : 0.0;

      return {
        'total_predictions': totalPredictions,
        'correct_predictions': correctPredictions,
        'total_coins_earned': totalCoinsEarned,
        'accuracy': accuracy,
      };
    } catch (e) {
      // debugPrint('Error getting prediction stats: $e');
      return {'total_predictions': 0, 'correct_predictions': 0, 'total_coins_earned': 0, 'accuracy': 0.0};
    }
  }

  // En iyi prediction yapan kullanıcıları getir
  static Future<List<Map<String, dynamic>>> getTopPredictors({int limit = 10}) async {
    try {
      final response = await _client
          .from('winrate_predictions')
          .select('''
            user_id,
            users!winrate_predictions_user_id_fkey(username, profile_image_url)
          ''')
          .eq('is_correct', true);

      // Kullanıcıları grupla ve doğru tahmin sayısına göre sırala
      Map<String, Map<String, dynamic>> userStats = {};
      
      for (var prediction in response) {
        final userId = prediction['user_id'];
        final user = prediction['users'];
        
        if (!userStats.containsKey(userId)) {
          userStats[userId] = {
            'user_id': userId,
            'username': user['username'],
            'profile_image_url': user['profile_image_url'],
            'correct_predictions': 0,
          };
        }
        userStats[userId]!['correct_predictions'] = (userStats[userId]!['correct_predictions'] as int) + 1;
      }

      // Doğru tahmin sayısına göre sırala
      final sortedUsers = userStats.values.toList()
        ..sort((a, b) => (b['correct_predictions'] as int).compareTo(a['correct_predictions'] as int));

      return sortedUsers.take(limit).toList();
    } catch (e) {
      // debugPrint('Error getting top predictors: $e');
      return [];
    }
  }
}
