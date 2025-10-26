import 'package:flutter/foundation.dart';
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
        return null;
      }


      // Auth ID ile kullanıcıyı bul
      final response = await _client
          .from('users')
          .select()
          .eq('auth_id', authUser.id)
          .maybeSingle();

      if (response == null) {
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
      
        return UserModel.fromJson(insertResponse);
      }

      return UserModel.fromJson(response);
    } catch (e) {
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
      return false;
    }
  }

  // ✅ SECURITY FIX: Coin ekle/çıkar (ATOMIC - Race condition fixed)
  // Uses database function to prevent race conditions during concurrent coin updates
  static Future<bool> updateCoins(int amount, String type, String description) async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        debugPrint('Error: No authenticated user for coin update');
        return false;
      }

      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        debugPrint('Error: Could not fetch current user for coin update');
        return false;
      }

      // Atomic database function kullan (race condition önlendi)
      // This function locks the user row during update to prevent concurrent modifications
      final response = await _client.rpc('update_user_coins', params: {
        'p_user_id': currentUser.id,
        'p_amount': amount,
        'p_transaction_type': type,
        'p_description': description,
      });

      // Check if the RPC function returned success
      if (response == false) {
        debugPrint('Error: update_user_coins RPC returned false');
        return false;
      }

      // Coin transaction bildirimi gönder (sadece bir kez)
      await _sendCoinTransactionNotification(amount, type, description);

      return true;
    } catch (e) {
      debugPrint('Error updating coins: $e');
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
      return false;
    }
  }

  // Kullanıcı istatistiklerini güncelle (oy verdikten sonra)
  static Future<void> updateUserStats(String userId, bool isWinner) async {
    try {
      
      // Mevcut istatistikleri al
      final currentUserResponse = await _client
          .from('users')
          .select('total_matches, wins')
          .eq('id', userId)
          .single();
      
      final currentMatches = currentUserResponse['total_matches'] ?? 0;
      final currentWins = currentUserResponse['wins'] ?? 0;
      
      
      // Yeni istatistikleri hesapla
      final newMatches = currentMatches + 1;
      final newWins = isWinner ? currentWins + 1 : currentWins;
      
      
      // İstatistikleri güncelle
      await _client
          .from('users')
          .update({
            'total_matches': newMatches,
            'wins': newWins,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
      
    } catch (e) {
      debugPrint('Error: $e');
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
      return null;
    }
  }

  // Coin bildirimleri
  static Future<void> sendCoinRewardNotification(String userId, int coins, String reason) async {
    try {
      await NotificationService.sendLocalNotification(
        title: 'Coin Ödülü!',
        body: '$coins coin kazandınız: $reason',
        type: 'coin_reward',
        data: {
          'coins': coins,
          'reason': reason,
        },
      );
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  static Future<void> sendStreakRewardNotification(String userId, int streak, int coins) async {
    try {
      await NotificationService.sendLocalNotification(
        title: 'Streak Ödülü!',
        body: '$streak günlük streak ile $coins coin kazandınız!',
        type: 'coin_reward',
        data: {
          'streak': streak,
          'coins': coins,
        },
      );
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // _sendNotificationToUser metodu kaldırıldı - dil desteği ile değiştirildi

  /// Send coin transaction notification
  static Future<void> _sendCoinTransactionNotification(int amount, String type, String description) async {
    try {
      
      // Pozitif miktar = kazanılan, negatif miktar = harcanan
      if (amount > 0) {
        // Coin kazanıldı veya satın alındı
        if (type == 'earned' || type == 'reward' || type == 'purchased') {
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
          } else if (description.contains('satın alma')) {
            // Coin satın alma bildirimi
            debugPrint('💳 Sending coin purchase notification: $amount coins');
            await CoinTransactionNotificationService.sendCoinPurchaseNotification(
              coinAmount: amount,
              price: 0.0, // Fiyat bilgisi description'dan parse edilebilir
              currency: 'USD',
            );
          } else if (description.contains('istatistik')) {
            await CoinTransactionNotificationService.sendCoinSpentNotification(
              coinAmount: amount.abs(),
              reason: 'photo_stats_view',
              itemName: 'Fotoğraf İstatistikleri',
            );
          } else {
            // Genel coin kazanıldı bildirimi (yukarıdaki hiçbir kelime eşleşmediyse)
            debugPrint('💰 Sending general coin reward notification: $amount coins');
            await NotificationService.sendLocalizedNotification(
              type: 'coin_reward',
              data: {
                'coins': amount.toString(),
                'description': description,
              },
            );
          }
        }
      } else {
        // Coin harcandı (negatif miktar)
        debugPrint('Sending spent notification for negative amount: ${amount.abs()}');
        await CoinTransactionNotificationService.sendCoinSpentNotification(
          coinAmount: amount.abs(),
          reason: type,
          itemName: description,
        );
      }

      // Ayrıca type 'spent' ise de harcama bildirimi gönder
      if (type == 'spent') {
        debugPrint('Sending spent notification for type=spent: ${amount.abs()}');
        await CoinTransactionNotificationService.sendCoinSpentNotification(
          coinAmount: amount.abs(),
          reason: type,
          itemName: description,
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to send coin transaction notification: $e');
    }
  }

  // Referral sistemi fonksiyonları
  
  /// Generate referral link for current user
  static String generateReferralLink() {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return '';
    
    // Basit referral link oluştur - gerçek uygulamada daha karmaşık olabilir
    return 'https://chizo.app/invite?ref=${authUser.id}';
  }
  
  /// Get referral statistics for current user
  static Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return {'totalReferrals': 0, 'coinsEarned': 0};
      
      // Referral istatistiklerini al
      final response = await _client
          .from('coin_transactions')
          .select()
          .eq('user_id', currentUser.id)
          .eq('type', 'earned')
          .like('description', '%referans%');
      
      int totalReferrals = 0;
      int coinsEarned = 0;
      
      for (var transaction in response) {
        if (transaction['description'].toString().contains('referans')) {
          totalReferrals++;
          coinsEarned += (transaction['amount'] as int?) ?? 0;
        }
      }
      
      return {
        'totalReferrals': totalReferrals,
        'coinsEarned': coinsEarned,
      };
    } catch (e) {
      debugPrint('Error getting referral stats: $e');
      return {'totalReferrals': 0, 'coinsEarned': 0};
    }
  }
  
  /// Process referral when new user signs up
  static Future<bool> processReferral(String referralCode) async {
    try {
      // Referral kodundan kullanıcı ID'sini al
      final referrerResponse = await _client
          .from('users')
          .select('id, username')
          .eq('auth_id', referralCode)
          .maybeSingle();
      
      if (referrerResponse == null) return false;
      
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;
      
      // Referral kaydı oluştur
      await _client.from('referrals').insert({
        'referrer_id': referrerResponse['id'],
        'referred_id': currentUser.id,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Her iki kullanıcıya da 100 coin ver
      // Referrer'a 100 coin
      await updateCoins(100, 'earned', 'Arkadaş davet etme referans ödülü');
      
      // Referred user'a 100 coin
      await _client
          .from('users')
          .update({'coins': currentUser.coins + 100})
          .eq('id', currentUser.id);
      
      // Referred user için coin transaction kaydı
      await _client.from('coin_transactions').insert({
        'user_id': currentUser.id,
        'amount': 100,
        'type': 'earned',
        'description': 'Davet linki ile katılım ödülü',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      debugPrint('Error processing referral: $e');
      return false;
    }
  }
}
