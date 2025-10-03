import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'coin_transaction_notification_service.dart';
import 'notification_service.dart';
import '../models/coin_transaction_model.dart';
import '../utils/constants.dart';

class UserService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Supabase client'ı public yap
  static SupabaseClient get client => _client;

  // Kullanıcı bilgilerini getir (basit ve temiz)
  static Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        // // print('No authenticated user');
        return null;
      }

      // // print('Getting current user - Auth ID: ${authUser.id}, Email: ${authUser.email}');

      // Auth ID ile kullanıcıyı bul
      final response = await _client
          .from('users')
          .select()
          .eq('auth_id', authUser.id)
          .maybeSingle();

      if (response == null) {
        // // print('User not found, creating new user record');
        // Yeni kullanıcı oluştur
        final newUserData = {
          'auth_id': authUser.id,
          'email': authUser.email!,
          'username': authUser.email!.split('@')[0],
          'coins': 100,
          'is_visible': true,
          'show_instagram': false,
          'show_profession': false,
          'total_matches': 0,
          'wins': 0,
          'country_preferences': AppConstants.countries,
          'age_range_preferences': AppConstants.ageRanges,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        final insertResponse = await _client
            .from('users')
            .insert(newUserData)
            .select()
            .single();
      
        // // print('New user created with ID: ${insertResponse['id']}');
        return UserModel.fromJson(insertResponse);
      }

      // // print('User found - ID: ${response['id']}, Matches: ${response['total_matches']}, Wins: ${response['wins']}');
      return UserModel.fromJson(response);
    } catch (e) {
      // // print('Error getting current user: $e');
      return null;
    }
  }

  // Kullanıcı profilini güncelle
  static Future<bool> updateProfile({
    String? username,
    int? age,
    String? countryCode,
    String? genderCode,
    String? instagramHandle,
    String? profession,
    bool? isVisible,
    bool? showInstagram,
    bool? showProfession,
  }) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) return false;

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updateData['username'] = username;
      if (age != null) updateData['age'] = age;
      if (countryCode != null) updateData['country_code'] = countryCode;
      if (genderCode != null) updateData['gender_code'] = genderCode;
      if (instagramHandle != null) updateData['instagram_handle'] = instagramHandle;
      if (profession != null) updateData['profession'] = profession;
      if (isVisible != null) updateData['is_visible'] = isVisible;
      if (showInstagram != null) updateData['show_instagram'] = showInstagram;
      if (showProfession != null) updateData['show_profession'] = showProfession;

      await _client
          .from('users')
          .update(updateData)
          .eq('auth_id', authUser.id);

      return true;
    } catch (e) {
      // // print('Error updating profile: $e');
      return false;
    }
  }

  // Premium bilgi görünürlüğünü güncelle
  static Future<bool> updatePremiumVisibility({
    bool? showInstagram,
    bool? showProfession,
  }) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) return false;

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (showInstagram != null) updateData['show_instagram'] = showInstagram;
      if (showProfession != null) updateData['show_profession'] = showProfession;

      await _client
          .from('users')
          .update(updateData)
          .eq('auth_id', authUser.id);

      return true;
    } catch (e) {
      // // print('Error updating premium visibility: $e');
      return false;
    }
  }

  // Coin ekle/çıkar
  static Future<bool> updateCoins(int amount, String type, String description) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) return false;

      // Kullanıcının mevcut coin sayısını al
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;

      final newCoinAmount = currentUser.coins + amount;
      if (newCoinAmount < 0) return false; // Yetersiz coin

      // Coin miktarını güncelle
      await _client
          .from('users')
          .update({'coins': newCoinAmount})
          .eq('auth_id', authUser.id);

      // Coin transaction kaydı ekle
      await _client.from('coin_transactions').insert({
        'user_id': currentUser.id,
        'amount': amount,
        'type': type,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Coin transaction bildirimi gönder
      await _sendCoinTransactionNotification(amount, type, description);

      // Bildirim gönder
      String notificationTitle;
      String notificationBody;
      
      if (amount > 0) {
        notificationTitle = '💰 Coin Kazandınız!';
        notificationBody = '+$amount coin kazandınız. $description';
      } else {
        notificationTitle = '💸 Coin Harcandı';
        notificationBody = '${amount.abs()} coin harcandı. $description';
      }
      
      // Send notification using auth_id
      await NotificationService.sendLocalNotification(
        title: notificationTitle,
        body: notificationBody,
        type: 'coin_reward',
        data: {
          'amount': amount,
          'type': type,
          'description': description,
        },
      );

      return true;
    } catch (e) {
      // // print('Error updating coins: $e');
      return false;
    }
  }

  // Kullanıcının coin transaction geçmişini getir
  static Future<List<CoinTransactionModel>> getCoinTransactions() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return [];

      final response = await _client
          .from('coin_transactions')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CoinTransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      // // print('Error getting coin transactions: $e');
      return [];
    }
  }

  // Ülke tercihlerini güncelle
  static Future<bool> updateCountryPreferences(List<String> countries) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) return false;

      await _client
          .from('users')
          .update({
            'country_preferences': countries,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('auth_id', authUser.id);

      return true;
    } catch (e) {
      // // print('Error updating country preferences: $e');
      return false;
    }
  }

  // Yaş aralığı tercihlerini güncelle
  static Future<bool> updateAgeRangePreferences(List<String> ageRanges) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) return false;

      await _client
          .from('users')
          .update({
            'age_range_preferences': ageRanges,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('auth_id', authUser.id);

      return true;
    } catch (e) {
      // // print('Error updating age range preferences: $e');
      return false;
    }
  }

  // Kullanıcı istatistiklerini güncelle (oy verdikten sonra)
  static Future<void> updateUserStats(String userId, bool isWinner) async {
    try {
      // // print('Updating stats for user: $userId, isWinner: $isWinner');
      
      // Mevcut istatistikleri al
      final currentUserResponse = await _client
          .from('users')
          .select('total_matches, wins')
          .eq('id', userId)
          .single();
      
      final currentMatches = currentUserResponse['total_matches'] ?? 0;
      final currentWins = currentUserResponse['wins'] ?? 0;
      
      // // print('Current user data: {total_matches: $currentMatches, wins: $currentWins}');
      
      // Yeni istatistikleri hesapla
      final newMatches = currentMatches + 1;
      final newWins = isWinner ? currentWins + 1 : currentWins;
      
      // // print('Current matches: $currentMatches, current wins: $currentWins');
      // // print('Updating with data: {total_matches: $newMatches, wins: $newWins, updated_at: ${DateTime.now().toIso8601String()}}');
      
      // İstatistikleri güncelle
      await _client
          .from('users')
          .update({
            'total_matches': newMatches,
            'wins': newWins,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
      
      // // print('Update result: $updateResult');
      // // print('User stats updated: $userId, matches: $newMatches, wins: $newWins');
    } catch (e) {
      // // print('Error updating user stats: $e');
    }
  }

  // ID ile kullanıcı bilgilerini getir
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserModel.fromJson(response);
    } catch (e) {
      // // print('Error getting user by ID: $e');
      return null;
    }
  }

  // Coin bildirimleri
  static Future<void> sendCoinRewardNotification(String userId, int coins, String reason) async {
    try {
      await NotificationService.sendLocalNotification(
        title: '💰 Coin Ödülü!',
        body: '$coins coin kazandınız: $reason',
        type: 'coin_reward',
        data: {
          'coins': coins,
          'reason': reason,
        },
      );
    } catch (e) {
      // // print('Error sending coin reward notification: $e');
    }
  }

  static Future<void> sendStreakRewardNotification(String userId, int streak, int coins) async {
    try {
      await NotificationService.sendLocalNotification(
        title: '🔥 Streak Ödülü!',
        body: '$streak günlük streak ile $coins coin kazandınız!',
        type: 'coin_reward',
        data: {
          'streak': streak,
          'coins': coins,
        },
      );
    } catch (e) {
      // // print('Error sending streak reward notification: $e');
    }
  }

  static Future<void> _sendNotificationToUser(String userId, String type, String title, String body) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': type,
        'title': title,
        'body': body,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // // print('Error sending notification to user: $e');
    }
  }

  /// Send coin transaction notification
  static Future<void> _sendCoinTransactionNotification(int amount, String type, String description) async {
    try {
      
      // Pozitif miktar = kazanılan, negatif miktar = harcanan
      if (amount > 0) {
        // Coin kazanıldı
        if (type == 'earned' || type == 'reward') {
          if (description.contains('tahmin')) {
            await CoinTransactionNotificationService.sendCoinEarnedFromPredictionNotification(
              coinAmount: amount,
              matchId: 'unknown',
              matchTitle: description,
            );
          } else if (description.contains('reklam')) {
            await CoinTransactionNotificationService.sendCoinEarnedFromAdNotification(
              coinAmount: amount,
            );
          } else if (description.contains('hot streak')) {
            await CoinTransactionNotificationService.sendCoinEarnedFromHotStreakNotification(
              coinAmount: amount,
              streakDays: 1, // Bu değer description'dan parse edilebilir
            );
          } else if (description.contains('günlük') || description.contains('giriş')) {
            await CoinTransactionNotificationService.sendCoinEarnedFromDailyLoginNotification(
              coinAmount: amount,
              streakDays: 1,
            );
          } else if (description.contains('maç')) {
            await CoinTransactionNotificationService.sendCoinEarnedFromMatchWinNotification(
              coinAmount: amount,
              opponentName: 'Rakip',
              matchId: 'unknown',
            );
          } else if (description.contains('turnuva')) {
            await CoinTransactionNotificationService.sendCoinEarnedFromTournamentNotification(
              coinAmount: amount,
              tournamentName: 'Turnuva',
              position: '1',
            );
          } else if (description.contains('oylama')) {
            await CoinTransactionNotificationService.sendCoinEarnedFromVotingNotification(
              coinAmount: amount,
              matchTitle: description,
            );
          } else if (description.contains('referans')) {
            await CoinTransactionNotificationService.sendCoinEarnedFromReferralNotification(
              coinAmount: amount,
              referredUserName: 'Kullanıcı',
            );
          } else if (description.contains('başarı')) {
            await CoinTransactionNotificationService.sendCoinEarnedFromAchievementNotification(
              coinAmount: amount,
              achievementName: description,
            );
          } else if (description.contains('bonus')) {
            await CoinTransactionNotificationService.sendCoinEarnedFromBonusNotification(
              coinAmount: amount,
              bonusType: description,
            );
          } else if (description.contains('etkinlik')) {
            await CoinTransactionNotificationService.sendCoinEarnedFromSpecialEventNotification(
              coinAmount: amount,
              eventName: description,
            );
          }
        }
      } else {
        // Coin harcandı (negatif miktar)
        print('💸 Sending spent notification for negative amount: ${amount.abs()}');
        await CoinTransactionNotificationService.sendCoinSpentNotification(
          coinAmount: amount.abs(),
          reason: type,
          itemName: description,
        );
      }
      
      // Ayrıca type 'spent' ise de harcama bildirimi gönder
      if (type == 'spent') {
        print('💸 Sending spent notification for type=spent: ${amount.abs()}');
        await CoinTransactionNotificationService.sendCoinSpentNotification(
          coinAmount: amount.abs(),
          reason: type,
          itemName: description,
        );
      }
    } catch (e) {
      print('❌ Failed to send coin transaction notification: $e');
    }
  }
}
