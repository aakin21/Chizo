import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/match_history_service.dart';
import '../services/user_service.dart';
import '../services/global_theme_service.dart';
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
  String _currentTheme = 'Koyu';

  @override
  void initState() {
    super.initState();
    _loadSavedUnlockData();
    _loadMatchHistory();
    _loadCurrentTheme();
    
    // Global theme service'e callback kaydet
    GlobalThemeService().setThemeChangeCallback((theme) {
      if (mounted) {
        setState(() {
          _currentTheme = theme;
        });
      }
    });
  }

  @override
  void dispose() {
    // Callback'i temizle
    GlobalThemeService().clearAllCallbacks();
    super.dispose();
  }

  Future<void> _loadCurrentTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString('selected_theme') ?? 'Koyu';
      if (mounted) {
        setState(() {
          _currentTheme = theme;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentTheme = 'Koyu';
        });
      }
    }
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
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $coinCost coin harcandı! Son $matchCount maçınız 24 saat boyunca görüntüleniyor.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.insufficientCoins),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  Future<void> _unlockWeeklyAccess() async {
    try {
      final success = await UserService.updateCoins(-500, 'spent', '1 hafta sınırsız maç görüntüleme özelliği açıldı (7 gün geçerli)');
      
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
            content: Text('✅ 500 coin harcandı! 1 hafta boyunca sınırsız erişim!'),
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
                  color: Colors.black.withValues(alpha: 0.7),
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
                    color: Colors.black.withValues(alpha: 0.5),
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
    final isDarkTheme = _currentTheme == 'Koyu';
    
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                shouldBlur ? '●●●●●●●●●●' : AppLocalizations.of(context)!.winRateColon(opponent.winRateString),
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkTheme ? Colors.white70 : Colors.grey[600],
                ),
              ),
              Text(
                shouldBlur ? '●●●●●●●●●●●●' : AppLocalizations.of(context)!.matchesAndWins(opponent.totalMatches, opponent.wins),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkTheme ? Colors.white60 : Colors.grey[500],
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
                color: isDarkTheme ? Colors.white60 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isDarkTheme 
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E1E1E), // Koyu gri
                  const Color(0xFF2D2D2D), // Daha koyu gri
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFFFFF8F5), // Çok açık turuncu ton
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkTheme 
              ? const Color(0xFFFF6B35).withValues(alpha: 0.3)
              : const Color(0xFFFF6B35).withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkTheme 
                ? const Color(0xFFFF6B35).withValues(alpha: 0.2)
                : const Color(0xFFFF6B35).withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: isDarkTheme 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
    final isDarkTheme = _currentTheme == 'Koyu';
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Haftalık erişim durumu
          if (hasWeeklyAccess && weeklyAccessExpiry != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Text(
                '1 HAFTA ERİŞİM %',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          
          if (!hasWeeklyAccess) ...[
            // 2 buton yan yana
            Row(
              children: [
                // Sol: 1 Gün
                Expanded(
                  child: ElevatedButton(
                    onPressed: unlockedMatches >= 50 ? null : () => _unlockMatches(50, 100),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkTheme 
                          ? const Color(0xFFFF6B35) // Ana turuncu ton
                          : const Color(0xFFFF6B35), // Ana turuncu ton
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 40),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(unlockedMatches >= 50 ? 'Açık' : '1 GÜN', 
                             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(unlockedMatches >= 50 ? '24 saat' : '100 Coin', 
                             style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Sağ: 1 Hafta
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _unlockWeeklyAccess(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkTheme 
                          ? const Color(0xFFFF6B35) // Ana turuncu ton
                          : const Color(0xFFFF6B35), // Ana turuncu ton
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 40),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('1 HAFTA', 
                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('500 Coin', 
                             style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
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


  Widget _buildLazyAvatar(UserModel opponent, bool shouldBlur) {
    final isDarkTheme = _currentTheme == 'Koyu';
    
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
            backgroundColor: isDarkTheme 
                ? const Color(0xFFFF6B35).withValues(alpha: 0.2) // Turuncu arka plan
                : const Color(0xFFFF6B35).withValues(alpha: 0.1), // Turuncu arka plan
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
                    : Icon(
                        Icons.person, 
                        size: 30,
                        color: const Color(0xFFFF6B35), // Turuncu ikon
                      )
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = _currentTheme == 'Koyu';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.matchHistory,
          style: TextStyle(
            color: isDarkTheme ? Colors.white : null,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDarkTheme ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(
          color: isDarkTheme ? Colors.white : null,
        ),
        actions: [
          if (hasWeeklyAccess && weeklyAccessExpiry != null)
            _buildTimeCounter('Bitiş:', weeklyAccessExpiry!)
          else if (!hasWeeklyAccess && unlockExpiry != null)
            _buildTimeCounter('Bitiş:', unlockExpiry!),
        ],
      ),
      body: Container(
        decoration: isDarkTheme 
            ? BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF121212), // Çok koyu gri
                    Color(0xFF1A1A1A), // Koyu gri
                  ],
                ),
              )
            : null,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: isDarkTheme ? const Color(0xFFFF6B35) : null,
                ),
              )
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
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkTheme ? Colors.white70 : Colors.grey,
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
      ),
    );
  }
}
