import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/photo_upload_service.dart';
import '../l10n/app_localizations.dart';
import '../services/global_theme_service.dart';
import 'match_history_screen.dart';
import 'country_ranking_screen.dart';
import 'store_tab.dart';
import '../widgets/country_selector.dart';
import '../widgets/gender_selector.dart';
import '../widgets/profile_avatar_widget.dart';
import '../services/country_service.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback? onRefresh;
  
  const ProfileTab({super.key, this.onRefresh});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserModel? currentUser;
  bool isLoading = true;
  bool isUpdating = false;
  List<Map<String, dynamic>> userPhotos = [];
  String _currentTheme = 'Koyu';
  // Theme callback'ini sakla
  late final Function(String) _themeCallback;

  @override
  void initState() {
    super.initState();
    loadUserData();
    _loadCurrentTheme();

    // Global theme service'e callback kaydet ve referansını sakla
    _themeCallback = (theme) {
      if (mounted) {
        setState(() {
          _currentTheme = theme;
        });
      }
    };
    GlobalThemeService().setThemeChangeCallback(_themeCallback);
  }

  @override
  void dispose() {
    // Sadece kendi callback'ini temizle
    GlobalThemeService().removeThemeChangeCallback(_themeCallback);
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

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget güncellendiğinde veriyi yeniden yükle
    if (oldWidget.onRefresh != widget.onRefresh) {
      loadUserData();
    }
  }




  Future<void> loadUserData() async {
    setState(() => isLoading = true);
    
    try {
      final user = await UserService.getCurrentUser();
      List<Map<String, dynamic>> photos = [];
      
      if (user != null) {
        // Get photos with win rate stats
        final userPhotoStats = await PhotoUploadService.getUserPhotoStats(user.id);
        
        // Sort photos by win rate (highest to lowest)
        photos = userPhotoStats;
        photos.sort((a, b) {
          final aWinRate = double.tryParse(a['win_rate']?.toString() ?? '0') ?? 0;
          final bWinRate = double.tryParse(b['win_rate']?.toString() ?? '0') ?? 0;
          return bWinRate.compareTo(aWinRate);
        });
        
      }
      
      if (mounted) {
        setState(() {
          currentUser = user;
          userPhotos = photos;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  int _calculateWinRate(int totalMatches, int wins) {
    if (totalMatches == 0) return 0;
    return ((wins / totalMatches) * 100).round();
  }

  Widget _buildStatItem(String value, String label, Color color) {
    final isDarkTheme = _currentTheme == 'Koyu';
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkTheme ? Colors.white70 : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _showPhotoUploadDialog() async {
    if (currentUser == null) return;
    final l10n = AppLocalizations.of(context)!;

    // Debug existing photos first
    await PhotoUploadService.debugUserPhotos(currentUser!.id);
    
    final nextSlot = await PhotoUploadService.getNextAvailableSlot(currentUser!.id);
    print('DEBUG: Next available slot: $nextSlot');
    if (nextSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.allPhotoSlotsFull)),
      );
      return;
    }

    final canUploadResult = await PhotoUploadService.canUploadPhoto(nextSlot);
    print('DEBUG: Can upload result: $canUploadResult');
    if (!canUploadResult['canUpload']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(canUploadResult['message'])),
      );
      return;
    }

    final requiredCoins = canUploadResult['requiredCoins'] as int;
    print('DEBUG: Required coins for slot $nextSlot: $requiredCoins');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.photoUploadSlot(nextSlot)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.coinsRequiredForSlot(requiredCoins)),
            const SizedBox(height: 16),
            Text(l10n.currentCoins(currentUser!.coins)),
            if (requiredCoins > currentUser!.coins) ...[
              const SizedBox(height: 8),
              Text(
                l10n.insufficientCoinsForUpload,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          if (requiredCoins <= currentUser!.coins)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _uploadPhotoToSlot(nextSlot);
              },
              child: Text(l10n.upload(requiredCoins)),
            ),
        ],
      ),
    );
  }

  Future<void> _uploadPhotoToSlot(int slot) async {
    setState(() => isUpdating = true);
    
    try {
      final result = await PhotoUploadService.uploadPhoto(slot, context: context);
      
      if (result['success']) {
        await loadUserData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${AppLocalizations.of(context)!.photoUploaded(result['coinsSpent'])}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDarkTheme = _currentTheme == 'Koyu';
    
    return Container(
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
          ? _buildProfileSkeletonScreen()
          : currentUser == null
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.userInfoNotLoaded,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : null,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadUserData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar ve Progress Bar Sistemi
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
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
                            borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fotoğraflarım',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkTheme ? Colors.white : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Avatar ve Progress Bar Listesi
                              _buildProfileAvatarList(),
                            ],
                          ),
                        ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // İstatistikler
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
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
                            borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.statistics,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkTheme ? Colors.white : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    '${currentUser!.totalMatches}',
                                    AppLocalizations.of(context)!.totalMatches,
                                    const Color(0xFFFF8C42), // Açık turuncu ton
                                  ),
                                  _buildStatItem(
                                    '${currentUser!.wins}',
                                    AppLocalizations.of(context)!.wins,
                                    const Color(0xFFFF6B35), // Ana turuncu ton
                                  ),
                                  _buildStatItem(
                                    '${_calculateWinRate(currentUser!.totalMatches, currentUser!.wins)}%',
                                    AppLocalizations.of(context)!.winRatePercentage,
                                    const Color(0xFFE55A2B), // Koyu turuncu ton
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Match History Butonu
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
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
                            borderRadius: BorderRadius.circular(16),
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
                          child: ListTile(
                          contentPadding: const EdgeInsets.all(20),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withValues(alpha: 0.1), // Ana turuncu ton
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.history,
                              color: Color(0xFFFF6B35), // Ana turuncu ton
                              size: 24,
                            ),
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.matchHistory,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? Colors.white : null,
                            ),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.viewRecentMatches,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkTheme ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MatchHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ülke Sıralaması Butonu
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
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
                            borderRadius: BorderRadius.circular(16),
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
                          child: ListTile(
                          contentPadding: const EdgeInsets.all(20),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8C42).withValues(alpha: 0.1), // Açık turuncu ton
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.flag,
                              color: Color(0xFFFF8C42), // Açık turuncu ton
                              size: 24,
                            ),
                          ),
                          title: Text(
                            'Ülkelere Göre İstatistikler',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? Colors.white : null,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CountryRankingScreen(),
                              ),
                            );
                          },
                        ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Kullanıcı Adı
                      Card(
                        elevation: 0,
                        child: Container(
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
                          child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Color(0xFFFF6B35), // Ana turuncu ton
                            size: 28,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.username,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white : null,
                            ),
                          ),
                          subtitle: Text(
                            currentUser!.username,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white70 : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Coin icon and cost
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      color: const Color(0xFFFFD700),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '50',
                                      style: TextStyle(
                                        color: isDarkTheme ? Colors.white : const Color(0xFFD4AF37),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showUsernameChangeDialog(),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // E-posta
                      Card(
                        elevation: 0,
                        child: Container(
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
                          child: ListTile(
                          leading: const Icon(
                            Icons.email,
                            color: Color(0xFFFF8C42), // Açık turuncu ton
                            size: 28,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.email,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white : null,
                            ),
                          ),
                          subtitle: Text(
                            currentUser!.email,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white70 : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditDialog('email', currentUser!.email),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Coin Bilgisi
                      Card(
                        elevation: 0,
                        child: Container(
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
                          child: ListTile(
                          leading: const Icon(
                            Icons.monetization_on,
                            color: Color(0xFFE55A2B), // Koyu turuncu ton
                            size: 28,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.coin,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white : null,
                            ),
                          ),
                          subtitle: Text(
                            '${currentUser!.coins}',
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white70 : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.store),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      title: Text(AppLocalizations.of(context)!.store),
                                      leading: BackButton(
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    body: const StoreTab(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Yaş Seçimi
                      Card(
                        elevation: 0,
                        child: Container(
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
                          child: ListTile(
                          leading: const Icon(
                            Icons.cake,
                            color: Color(0xFFFF6B35), // Ana turuncu ton
                            size: 28,
                          ),
                          title: Text(
                            'Yaş',
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white : null,
                            ),
                          ),
                          subtitle: Text(
                            currentUser!.age?.toString() ?? 'Yaşınızı seçin',
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white70 : null,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showAgeSelector(),
                        ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ülke Seçimi (Readonly - sadece kayıtta değiştirilebilir)
                      Card(
                        elevation: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isDarkTheme
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF1E1E1E).withValues(alpha: 0.5), // Soluk koyu gri
                                      const Color(0xFF2D2D2D).withValues(alpha: 0.5), // Soluk daha koyu gri
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.7),
                                      const Color(0xFFFFF8F5).withValues(alpha: 0.5), // Soluk açık turuncu ton
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkTheme
                                  ? const Color(0xFFFF6B35).withValues(alpha: 0.15)
                                  : const Color(0xFFFF6B35).withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                          enabled: false, // Disable interaction
                          leading: Icon(
                            Icons.public,
                            color: const Color(0xFFFF8C42).withValues(alpha: 0.5), // Soluk turuncu
                            size: 28,
                          ),
                          title: Text(
                            'Ülke',
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white.withValues(alpha: 0.5) : Colors.grey,
                            ),
                          ),
                          subtitle: FutureBuilder<String?>(
                            future: _getCountryName(currentUser!.countryCode),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'Ülkenizi seçin',
                                style: TextStyle(
                                  color: isDarkTheme ? Colors.white.withValues(alpha: 0.4) : Colors.grey[600],
                                ),
                              );
                            },
                          ),
                          trailing: Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                        ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Cinsiyet Seçimi (Readonly - sadece kayıtta değiştirilebilir)
                      Card(
                        elevation: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isDarkTheme
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF1E1E1E).withValues(alpha: 0.5), // Soluk koyu gri
                                      const Color(0xFF2D2D2D).withValues(alpha: 0.5), // Soluk daha koyu gri
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.7),
                                      const Color(0xFFFFF8F5).withValues(alpha: 0.5), // Soluk açık turuncu ton
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkTheme
                                  ? const Color(0xFFFF6B35).withValues(alpha: 0.15)
                                  : const Color(0xFFFF6B35).withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                          enabled: false, // Disable interaction
                          leading: Icon(
                            Icons.person,
                            color: const Color(0xFFE55A2B).withValues(alpha: 0.5), // Soluk koyu turuncu
                            size: 28,
                          ),
                          title: Text(
                            'Cinsiyet',
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white.withValues(alpha: 0.5) : Colors.grey,
                            ),
                          ),
                          subtitle: FutureBuilder<String?>(
                            future: _getGenderName(currentUser!.genderCode),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'Cinsiyetinizi seçin',
                                style: TextStyle(
                                  color: isDarkTheme ? Colors.white.withValues(alpha: 0.4) : Colors.grey[600],
                                ),
                              );
                            },
                          ),
                          trailing: Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                        ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Instagram Hesabı
                      Card(
                        elevation: 0,
                        child: Container(
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
                          child: ListTile(
                          leading: const Icon(
                            Icons.camera_alt,
                            color: Color(0xFFFF6B35), // Ana turuncu ton
                            size: 28,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.instagramAccount,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white : null,
                            ),
                          ),
                          subtitle: Text(
                            currentUser!.instagramHandle != null ? '@${currentUser!.instagramHandle!}' : 'Instagram hesabınızı ekleyin',
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white70 : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: _getFieldVisibility('instagram'),
                                onChanged: (value) => _toggleFieldVisibility('instagram', value),
                                activeThumbColor: const Color(0xFFFF6B35), // Ana turuncu ton
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditDialog('instagram', currentUser!.instagramHandle ?? ''),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Meslek
                      Card(
                        elevation: 0,
                        child: Container(
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
                          child: ListTile(
                          leading: const Icon(
                            Icons.work,
                            color: Color(0xFFFF8C42), // Açık turuncu ton
                            size: 28,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.profession,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white : null,
                            ),
                          ),
                          subtitle: Text(
                            currentUser!.profession ?? 'Mesleğinizi ekleyin',
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white70 : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: _getFieldVisibility('profession'),
                                onChanged: (value) => _toggleFieldVisibility('profession', value),
                                activeThumbColor: const Color(0xFFFF6B35), // Ana turuncu ton
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditDialog('profession', currentUser!.profession ?? ''),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ),

                      const SizedBox(height: 24),

                    ],
                    ),
                  ),
                ),
    );
  }



  // Instagram ve meslek görünürlük durumunu kontrol et
  bool _getFieldVisibility(String field) {
    if (field == 'instagram') {
      return currentUser?.showInstagram ?? false;
    } else if (field == 'profession') {
      return currentUser?.showProfession ?? false;
    }
    return true;
  }

  // Instagram ve meslek görünürlüğünü değiştir
  Future<void> _toggleFieldVisibility(String field, bool value) async {
    try {
      setState(() {
        isUpdating = true;
      });

      if (field == 'instagram') {
        await UserService.updateProfile(showInstagram: value);
        setState(() {
          currentUser = currentUser?.copyWith(showInstagram: value);
        });
      } else if (field == 'profession') {
        await UserService.updateProfile(showProfession: value);
        setState(() {
          currentUser = currentUser?.copyWith(showProfession: value);
        });
      }

      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? '${field == 'instagram' ? 'Instagram' : 'Meslek'} bilgisi matchlerde görünür' : '${field == 'instagram' ? 'Instagram' : 'Meslek'} bilgisi matchlerde gizli'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isUpdating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Güncelleme sırasında hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    final l10n = AppLocalizations.of(context)!;
    
    String title = '';
    String hint = '';
    IconData icon = Icons.edit;
    TextInputType keyboardType = TextInputType.text;
    
    switch (field) {
      case 'username':
        title = AppLocalizations.of(context)!.editUsername;
        hint = AppLocalizations.of(context)!.enterUsername;
        icon = Icons.person;
        break;
      case 'instagram':
        title = AppLocalizations.of(context)!.editInstagram;
        hint = AppLocalizations.of(context)!.enterInstagram;
        icon = Icons.camera_alt;
        break;
      case 'profession':
        title = AppLocalizations.of(context)!.editProfession;
        hint = AppLocalizations.of(context)!.enterProfession;
        icon = Icons.work;
        break;
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            if (field == 'country' || field == 'gender')
              const Text('Bu özellik ayarlar sayfasından yönetilebilir')
            else
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: hint,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(icon),
                ),
                keyboardType: keyboardType,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await _updateUserInfo(field, controller.text.trim());
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
        ),
      ),
    );
  }

  // Kullanıcı adı değiştirme (50 coin)
  void _showUsernameChangeDialog() {
    final controller = TextEditingController(text: currentUser!.username);
    const requiredCoins = 50;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('Kullanıcı Adı Değiştir'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Color(0xFFFFD700),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$requiredCoins',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Yeni kullanıcı adı',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mevcut coinleriniz: ${currentUser!.coins}',
              style: TextStyle(
                color: currentUser!.coins >= requiredCoins ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (currentUser!.coins < requiredCoins) ...[
              const SizedBox(height: 8),
              const Text(
                'Yetersiz coin! Mağazadan coin satın alabilirsiniz.',
                style: TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          if (currentUser!.coins >= requiredCoins)
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty && controller.text.trim() != currentUser!.username) {
                  Navigator.pop(context);
                  await _updateUsernameWithCoins(controller.text.trim(), requiredCoins);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
              ),
              child: const Text('Değiştir'),
            ),
        ],
      ),
    );
  }

  Future<void> _updateUsernameWithCoins(String newUsername, int cost) async {
    try {
      setState(() => isUpdating = true);

      // First update username
      final success = await UserService.updateProfile(username: newUsername);

      if (success) {
        // Then deduct coins
        await UserService.updateCoins(-cost, 'spent', 'Kullanıcı adı değişikliği');

        await loadUserData();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Kullanıcı adınız güncellendi ($cost coin harcandı)'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanıcı adı güncellenemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  Future<void> _updateUserInfo(String field, String value) async {
    try {
      bool success = false;

      switch (field) {
        case 'username':
          success = await UserService.updateProfile(username: value);
          break;
        case 'instagram':
          success = await UserService.updateProfile(instagramHandle: value);
          break;
        case 'profession':
          success = await UserService.updateProfile(profession: value);
          break;
      }

      if (success) {
        await loadUserData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.infoUpdated),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.updateFailed),
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






  /// Build profile avatar list showing photos with winrate bars
  Widget _buildProfileAvatarList() {
    List<Widget> avatarWidgets = [];
    
    // Mevcut fotoğrafları ekle
    for (final photo in userPhotos) {
      avatarWidgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ProfileAvatarWidget(
            user: currentUser!,
            photoData: photo,
            size: 60,
            showWinRateBar: true,
            canChangePhoto: true,
            onPhotoChanged: loadUserData,
            showStatsUnlockButton: true,
          ),
        ),
      );
    }
    
    // Boş slotları ekle (maksimum 5 fotoğraf)
    for (int i = userPhotos.length; i < 5; i++) {
      avatarWidgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildEmptyAvatarSlot(i + 1),
        ),
      );
    }
    
    return Column(children: avatarWidgets);
  }
  
  /// Build empty avatar slot with plus icon
  Widget _buildEmptyAvatarSlot(int slot) {
    final cost = PhotoUploadService.getPhotoUploadCost(slot);
    final isDarkTheme = _currentTheme == 'Koyu';
    
    return GestureDetector(
      onTap: isUpdating ? null : _showPhotoUploadDialog,
      child: Row(
        children: [
          // Empty avatar with plus icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.add,
              color: Colors.grey[500],
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Progress bar placeholder
          Expanded(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '$cost coin',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.black : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  /// Build animated skeleton loading screen for profile tab
  Widget _buildProfileSkeletonScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surface,
            highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile photo skeleton
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
                const SizedBox(height: 16),
                // Name and user info skeletons
                Container(
                  width: 200,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Stats section skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(3, (index) => 
                    Column(
                      children: [
                        Container(
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 50,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Photo management skeleton
          Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surface,
            highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    Container(
                      width: 150,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Photo slots grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: 6, // 5 photo slots + 1 grid title
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Yaş seçici
  void _showAgeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yaşınızı Seçin'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView.builder(
            itemCount: 50,
            itemBuilder: (context, index) {
              final age = index + 18;
              return ListTile(
                title: Text('$age yaş'),
                selected: currentUser?.age == age,
                onTap: () async {
                  Navigator.pop(context);
                  await _updateAge(age);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Ülke seçici
  void _showCountrySelector() {
    showDialog(
      context: context,
      builder: (context) => CountrySelector(
        onCountrySelected: (country) async {
          Navigator.pop(context);
          await _updateCountry(country ?? '');
        },
      ),
    );
  }

  // Cinsiyet seçici
  void _showGenderSelector() {
    showDialog(
      context: context,
      builder: (context) => GenderSelector(
        onGenderSelected: (gender) async {
          Navigator.pop(context);
          await _updateGender(gender ?? '');
        },
      ),
    );
  }

  // Yaş güncelleme
  Future<void> _updateAge(int age) async {
    try {
      final success = await UserService.updateProfile(age: age);
      if (success) {
        await loadUserData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yaş bilgisi güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme sırasında hata oluştu')),
      );
    }
  }

  // Ülke güncelleme
  Future<void> _updateCountry(String countryCode) async {
    try {
      final success = await UserService.updateProfile(countryCode: countryCode);
      if (success) {
        await loadUserData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ülke bilgisi güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme sırasında hata oluştu')),
      );
    }
  }

  // Cinsiyet güncelleme
  Future<void> _updateGender(String genderCode) async {
    try {
      final success = await UserService.updateProfile(genderCode: genderCode);
      if (success) {
        await loadUserData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cinsiyet bilgisi güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme sırasında hata oluştu')),
      );
    }
  }

  // Ülke adını getir
  Future<String?> _getCountryName(String? countryCode) async {
    if (countryCode == null) return null;
    try {
      final country = await CountryService.getCountryByCode(countryCode, 'tr');
      return country?.name ?? countryCode;
    } catch (e) {
      return countryCode;
    }
  }

  // Cinsiyet adını getir
  Future<String?> _getGenderName(String? genderCode) async {
    if (genderCode == null) return null;
    switch (genderCode) {
      case 'M':
        return 'Erkek';
      case 'F':
        return 'Kadın';
      case 'O':
        return 'Diğer';
      default:
        return genderCode;
    }
  }
}
