import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/leaderboard_service.dart';
import '../l10n/app_localizations.dart';
import '../services/global_theme_service.dart';
import 'user_profile_screen.dart';

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> with TickerProviderStateMixin {
  late TabController _tabController;
  List<UserModel> _topWinners = [];
  List<UserModel> _topWinRate = [];
  bool _isLoading = true;
  String _currentTheme = 'Koyu';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaderboardData();
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
  void dispose() {
    _tabController.dispose();
    // Callback'i temizle
    GlobalThemeService().clearAllCallbacks();
    super.dispose();
  }

  Future<void> _loadLeaderboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Paralel olarak tüm verileri yükle
      final results = await Future.wait([
        LeaderboardService.getTopWinners(),
        LeaderboardService.getTopWinRate(),
      ]);

      setState(() {
        _topWinners = results[0];
        _topWinRate = results[1];
        _isLoading = false;
      });
    } catch (e) {
      // print('Error loading leaderboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildUserCard(UserModel user, int rank, {String? subtitle}) {
    final isDarkTheme = _currentTheme == 'Koyu';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: _getRankColor(rank),
          child: Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkTheme ? Colors.white : null,
          ),
        ),
        subtitle: subtitle != null 
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : null,
              ),
            )
          : Text(
              AppLocalizations.of(context)!.winsAndMatches(user.wins, user.totalMatches),
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : null,
              ),
            ),
         trailing: GestureDetector(
           onTap: () {
             // print('🎯 Avatar tapped for user: ${user.username}');
             _navigateToUserProfile(user);
           },
           child: user.matchPhotos != null && user.matchPhotos!.isNotEmpty
             ? CircleAvatar(
                 radius: 20,
                 backgroundImage: NetworkImage(user.matchPhotos!.first['photo_url']),
               )
             : const CircleAvatar(
                 radius: 20,
                 child: Icon(Icons.person),
               ),
         ),
        ),
      ),
    );
  }

  void _navigateToUserProfile(UserModel user) {
    // print('🎯 Navigating to profile for user: ${user.username}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(user: user),
      ),
    );
  }


  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFF6B35); // Ana turuncu ton - 1. sıra
      case 2:
        return const Color(0xFFFF8C42); // Açık turuncu ton - 2. sıra
      case 3:
        return const Color(0xFFE55A2B); // Koyu turuncu ton - 3. sıra
      default:
        return const Color(0xFFFF6B35).withValues(alpha: 0.7); // Ana turuncu ton (şeffaf) - diğer sıralar
    }
  }

  Widget _buildLeaderboardList(List<UserModel> users, String emptyMessage) {
    final isDarkTheme = _currentTheme == 'Koyu';
    
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isDarkTheme ? const Color(0xFFFF6B35) : null,
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: isDarkTheme ? Colors.white70 : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: isDarkTheme ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboardData,
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final rank = index + 1;
          
          String subtitle;
          if (_tabController.index == 0) {
            // En çok galibiyet - win sayısı ve toplam maç
            subtitle = AppLocalizations.of(context)!.winsAndMatches(user.wins, user.totalMatches);
          } else {
            // Kazanma oranı
            subtitle = AppLocalizations.of(context)!.winRateAndMatches(user.totalMatches, user.winRateString);
          }

          return _buildUserCard(user, rank, subtitle: subtitle);
        },
      ),
    );
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
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFFF6B35), // Ana turuncu ton
            labelColor: const Color(0xFFFF6B35), // Ana turuncu ton
            unselectedLabelColor: isDarkTheme ? Colors.white70 : Colors.grey[600],
            tabs: [
              Tab(text: AppLocalizations.of(context)!.mostWins),
              Tab(text: AppLocalizations.of(context)!.highestWinRate),
            ],
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLeaderboardList(
                _topWinners,
                AppLocalizations.of(context)!.noWinsYet,
              ),
              _buildLeaderboardList(
                _topWinRate,
                AppLocalizations.of(context)!.noWinRateYet,
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}
