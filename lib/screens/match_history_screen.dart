import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/match_history_service.dart';
import '../services/user_service.dart';
import '../l10n/app_localizations.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  List<Map<String, dynamic>> matchHistory = [];
  bool isLoading = true;
  int unlockedMatches = 0; // 0 = none, 25 = first 25, 50 = all 50
  DateTime? unlockExpiry; // Unlock'un ne zaman sona ereceği
  bool hasWeeklyAccess = false; // 1 haftalık erişim var mı
  DateTime? weeklyAccessExpiry; // Haftalık erişimin ne zaman sona ereceği

  @override
  void initState() {
    super.initState();
    _loadSavedUnlockData();
    _loadMatchHistory();
  }

  Future<void> _loadMatchHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser != null) {
        // Load last 50 matches
        final history = await MatchHistoryService.getUserMatchHistory(currentUser.id);
        
        // Zaman kontrolü yap
        _checkUnlockExpiry();
        
        setState(() {
          matchHistory = history;
          isLoading = false;
        });
      }
    } catch (e) {
      // print('Error loading match history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadSavedUnlockData() async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) return;
      
      final userId = currentUser.id;
      final prefs = await SharedPreferences.getInstance();
      
      // Normal unlock verilerini yükle
      final savedUnlockedMatches = prefs.getInt('match_history_unlocked_matches_$userId') ?? 0;
      final savedUnlockExpiryString = prefs.getString('match_history_unlock_expiry_$userId');
      
      // Haftalık erişim verilerini yükle
      final savedHasWeeklyAccess = prefs.getBool('match_history_weekly_access_$userId') ?? false;
      final savedWeeklyExpiryString = prefs.getString('match_history_weekly_expiry_$userId');
      
      setState(() {
        unlockedMatches = savedUnlockedMatches;
        unlockExpiry = savedUnlockExpiryString != null 
            ? DateTime.tryParse(savedUnlockExpiryString) 
            : null;
        hasWeeklyAccess = savedHasWeeklyAccess;
        weeklyAccessExpiry = savedWeeklyExpiryString != null 
            ? DateTime.tryParse(savedWeeklyExpiryString) 
            : null;
      });
      
      print('📱 Loaded saved unlock data: $unlockedMatches matches, weekly: $hasWeeklyAccess');
    } catch (e) {
      print('❌ Error loading saved unlock data: $e');
    }
  }

  Future<void> _saveUnlockData() async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) return;
      
      final userId = currentUser.id;
      final prefs = await SharedPreferences.getInstance();
      
      // Normal unlock verilerini kaydet
      await prefs.setInt('match_history_unlocked_matches_$userId', unlockedMatches);
      if (unlockExpiry != null) {
        await prefs.setString('match_history_unlock_expiry_$userId', unlockExpiry!.toIso8601String());
      } else {
        await prefs.remove('match_history_unlock_expiry_$userId');
      }
      
      // Haftalık erişim verilerini kaydet
      await prefs.setBool('match_history_weekly_access_$userId', hasWeeklyAccess);
      if (weeklyAccessExpiry != null) {
        await prefs.setString('match_history_weekly_expiry_$userId', weeklyAccessExpiry!.toIso8601String());
      } else {
        await prefs.remove('match_history_weekly_expiry_$userId');
      }
      
      print('💾 Saved unlock data: $unlockedMatches matches, weekly: $hasWeeklyAccess');
    } catch (e) {
      print('❌ Error saving unlock data: $e');
    }
  }

  void _checkUnlockExpiry() {
    final now = DateTime.now();
    bool dataChanged = false;
    
    // Haftalık erişim kontrolü
    if (weeklyAccessExpiry != null && now.isAfter(weeklyAccessExpiry!)) {
      hasWeeklyAccess = false;
      weeklyAccessExpiry = null;
      dataChanged = true;
    }
    
    // Normal unlock kontrolü
    if (unlockExpiry != null && now.isAfter(unlockExpiry!)) {
      unlockedMatches = 0;
      unlockExpiry = null;
      dataChanged = true;
    }
    
    // Haftalık erişim varsa tüm maçları aç
    if (hasWeeklyAccess) {
      unlockedMatches = 50;
    }
    
    // Değişiklik varsa kaydet
    if (dataChanged) {
      _saveUnlockData();
    }
  }

  Future<void> _unlockMatches(int matchCount, int coinCost) async {
    try {
      final success = await UserService.updateCoins(-coinCost, 'spent', 'Son $matchCount maç görüntüleme özelliği açıldı (24 saat geçerli)');
      
      if (success) {
        setState(() {
          unlockedMatches = matchCount;
          unlockExpiry = DateTime.now().add(const Duration(hours: 24)); // 24 saat geçerli
        });
        
        // Veriyi kaydet
        await _saveUnlockData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $coinCost coin harcandı! Son $matchCount maçınız 24 saat boyunca görüntüleniyor.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.insufficientCoins),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  Future<void> _unlockWeeklyAccess() async {
    try {
      final success = await UserService.updateCoins(-400, 'spent', '1 hafta sınırsız maç görüntüleme özelliği açıldı (7 gün geçerli)');
      
      if (success) {
        setState(() {
          hasWeeklyAccess = true;
          weeklyAccessExpiry = DateTime.now().add(const Duration(days: 7)); // 1 hafta geçerli
          unlockedMatches = 50; // Tüm maçları aç
        });
        
        // Veriyi kaydet
        await _saveUnlockData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 400 coin harcandı! 1 hafta boyunca sınırsız erişim!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.insufficientCoins),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  void _showImageDialog(UserModel opponent) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Büyük fotoğraf
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: opponent.matchPhotos != null && 
                       opponent.matchPhotos!.isNotEmpty &&
                       opponent.matchPhotos!.first['photo_url'] != null
                    ? Image.network(
                        opponent.matchPhotos!.first['photo_url'],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            
            // Kullanıcı bilgileri
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      opponent.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.winRateColon(opponent.winRateString),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.matchesAndWins(opponent.totalMatches, opponent.wins),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Kapatma butonu
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> matchData, int index) {
    final opponent = matchData['opponent'] as UserModel;
    final isWinner = matchData['is_winner'] as bool;
    final completedAt = DateTime.parse(matchData['completed_at']);
    
    // Check if this match should be blurred
    final shouldBlur = (index >= unlockedMatches);

    Widget cardContent = Row(
      children: [
        // Rakip fotoğrafı - Lazy loading ile
        _buildLazyAvatar(opponent, shouldBlur),
        
        const SizedBox(width: 16),
        
        // Rakip bilgileri
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shouldBlur ? '●●●●●●●●' : opponent.username,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                shouldBlur ? '●●●●●●●●●●' : AppLocalizations.of(context)!.winRateColon(opponent.winRateString),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                shouldBlur ? '●●●●●●●●●●●●' : AppLocalizations.of(context)!.matchesAndWins(opponent.totalMatches, opponent.wins),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        
        // Sonuç
        Column(
          children: [
            Icon(
              isWinner ? Icons.emoji_events : Icons.close,
              color: isWinner ? Colors.amber : Colors.red,
              size: 30,
            ),
            const SizedBox(height: 4),
            Text(
              isWinner ? AppLocalizations.of(context)!.youWon : AppLocalizations.of(context)!.youLost,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isWinner ? Colors.green : Colors.red,
              ),
            ),
            Text(
              '${completedAt.day}/${completedAt.month}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: shouldBlur
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: cardContent,
              )
            : cardContent,
      ),
    );
  }

  Widget _buildUnlockButtons() {
    // Dinamik fiyatlandırma: 25 maç açıldıysa 50 maç fiyatı düşsün
    final fiftyMatchPrice = unlockedMatches >= 25 ? 50 : 75;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Haftalık erişim durumu
          if (hasWeeklyAccess && weeklyAccessExpiry != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎉 Haftalık Erişim Aktif!', 
                                   style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Bitiş: ${_formatDateTime(weeklyAccessExpiry!)}',
                             style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          
          if (!hasWeeklyAccess) ...[
            
            // 24 saatlik seçenekler
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: unlockedMatches >= 25 ? null : () => _unlockMatches(25, 50),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: unlockedMatches >= 25 ? Colors.green : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(unlockedMatches >= 25 ? '✅ Açık' : 'Son 25 Maç'),
                        Text(unlockedMatches >= 25 ? '24 saat' : '50 Coin', 
                             style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: unlockedMatches >= 50 ? null : () => _unlockMatches(50, fiftyMatchPrice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: unlockedMatches >= 50 ? Colors.green : Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(unlockedMatches >= 50 ? '✅ Açık' : 'Son 50 Maç'),
                        Text(unlockedMatches >= 50 ? '24 saat' : '$fiftyMatchPrice Coin', 
                             style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 1 haftalık seçenek
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _unlockWeeklyAccess(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🔥 1 HAFTA SINIRSIZ ERİŞİM %', 
                         style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('400 Coin - En İyi Değer!', 
                         style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeCounter(String label, DateTime expiryTime) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          Text(
            _formatTimeRemaining(expiryTime),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeRemaining(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Bitiyor';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün ${difference.inHours % 24} saat';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat ${difference.inMinutes % 60} dakika';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika';
    } else {
      return 'Bitiyor...';
    }
  }

  Widget _buildLazyAvatar(UserModel opponent, bool shouldBlur) {
    return FutureBuilder<UserModel?>(
      future: opponent.matchPhotos == null || opponent.matchPhotos!.isEmpty
          ? MatchHistoryService.loadUserPhotos(opponent)
          : Future.value(opponent),
      builder: (context, snapshot) {
        final user = snapshot.data ?? opponent;
        
        return GestureDetector(
          onTap: shouldBlur ? null : () => _showImageDialog(user),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: user.matchPhotos != null && 
                              user.matchPhotos!.isNotEmpty &&
                              user.matchPhotos!.first['photo_url'] != null
                ? NetworkImage(user.matchPhotos!.first['photo_url'])
                : null,
            child: user.matchPhotos == null || 
                   user.matchPhotos!.isEmpty ||
                   (user.matchPhotos!.isNotEmpty && user.matchPhotos!.first['photo_url'] == null)
                ? snapshot.connectionState == ConnectionState.waiting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person, size: 30)
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.matchHistory),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          if (hasWeeklyAccess && weeklyAccessExpiry != null)
            _buildTimeCounter('Bitiş:', weeklyAccessExpiry!)
          else if (!hasWeeklyAccess && unlockExpiry != null)
            _buildTimeCounter('Bitiş:', unlockExpiry!),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMatchHistory,
              child: ListView(
                children: [
                  // Unlock buttons
                  _buildUnlockButtons(),
                  
                  const SizedBox(height: 16),
                  
                  // Match list
                  if (matchHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.noMatchHistoryYet,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ...matchHistory.asMap().entries.map((entry) {
                      final index = entry.key;
                      final match = entry.value;
                      return _buildMatchCard(match, index);
                    }),
                ],
              ),
            ),
    );
  }
}
