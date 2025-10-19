import 'package:flutter/material.dart';
import 'voting_tab.dart';
import 'profile_tab.dart';
// TODO: Turnuva özelliği gelecek güncellemede aktif edilecek
// import 'turnuva_tab.dart';
import 'settings_tab.dart';
import 'store_tab.dart';
// TODO: Leaderboard özelliği gelecek güncellemede aktif edilecek
// import 'leaderboard_tab.dart';
import 'notification_center_screen.dart';
import '../services/streak_service.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;
  final Function(String)? onThemeChanged;
  
  const HomeScreen({super.key, this.onLanguageChanged, this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _streakChecked = false;
  String _currentPage = 'home';

  @override
  void initState() {
    super.initState();
    _checkStreakOnLoad();
  }

  Future<void> _checkStreakOnLoad() async {
    if (!_streakChecked) {
      _streakChecked = true;
      await _checkDailyStreak();
    }
  }

  Future<void> _checkDailyStreak() async {
    try {
      final result = await StreakService.checkAndUpdateStreak();
      
      if (result['success'] && result['is_new_streak'] == true) {
        // Streak ödülü kazanıldı - dialog göster
        _showStreakRewardDialog(
          result['streak'],
          result['reward_coins'],
          result['message'],
        );
      }
    } catch (e) {
      // print('Error checking streak: $e');
    }
  }

  void _showStreakRewardDialog(int streak, int coins, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Streak emoji
            Text(
              _getStreakEmoji(streak),
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),
            
            // Başlık
            Text(
              AppLocalizations.of(context)!.dailyStreak,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 8),
            
            // Mesaj
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // Coin ödülü
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '+$coins Coin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Streak bilgisi
            Text(
              AppLocalizations.of(context)!.streakMessage(streak),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.great),
          ),
        ],
      ),
    );
  }

  String _getStreakEmoji(int streak) {
    if (streak == 1) return '🎉';
    if (streak == 2) return '🔥';
    if (streak == 3) return '⚡';
    if (streak == 4) return '💎';
    if (streak == 5) return '👑';
    if (streak == 6) return '🏆';
    if (streak >= 7) return '🌟';
    return '🎯';
  }


  void _refreshProfile() {
    setState(() {});
  }


  Future<void> _refreshAllData() async {
    await _checkDailyStreak();
    setState(() {});
  }

  Widget _getCurrentPage() {
    switch (_currentPage) {
      case 'home':
        return RefreshIndicator(
          onRefresh: _refreshAllData,
          child: VotingTab(onVoteCompleted: _refreshProfile),
        );
      case 'profile':
        return ProfileTab(onRefresh: _refreshProfile);
      // TODO: Turnuva özelliği gelecek güncellemede aktif edilecek
      // case 'tournament':
      //   return TurnuvaTab();
      // TODO: Leaderboard özelliği gelecek güncellemede aktif edilecek
      // case 'leaderboard':
      //   return const LeaderboardTab();
      case 'notifications':
        return const NotificationCenterScreen();
      case 'store':
        return const StoreTab();
      case 'settings':
        return SettingsTab(
          onLanguageChanged: widget.onLanguageChanged,
          onThemeChanged: widget.onThemeChanged,
        );
      default:
        return RefreshIndicator(
          onRefresh: _refreshAllData,
          child: VotingTab(onVoteCompleted: _refreshProfile),
        );
    }
  }


  Widget _buildNavigationButton({
    required IconData icon,
    required String page,
    required Color color,
  }) {
    final isActive = _currentPage == page;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive ? [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            _currentPage = page;
          });
        },
        icon: AnimatedScale(
          scale: isActive ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedRotation(
            turns: isActive ? 0.1 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon, 
              size: 24,
              color: isActive ? Colors.white : color,
            ),
          ),
        ),
        style: IconButton.styleFrom(
          backgroundColor: isActive 
            ? color
            : color.withValues(alpha: 0.15),
          foregroundColor: isActive ? Colors.white : color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isActive 
              ? BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
          ),
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.all(8),
          elevation: isActive ? 8 : 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavigationButton(
                    icon: Icons.how_to_vote,
                    page: 'home',
                    color: const Color(0xFFE55A2B), // Koyu turuncu ton
                  ),
                  _buildNavigationButton(
                    icon: Icons.person,
                    page: 'profile',
                    color: const Color(0xFFE55A2B), // Koyu turuncu ton
                  ),
                  // TODO: Turnuva özelliği gelecek güncellemede aktif edilecek
                  // _buildNavigationButton(
                  //   icon: Icons.emoji_events,
                  //   page: 'tournament',
                  //   color: const Color(0xFFE55A2B), // Koyu turuncu ton
                  // ),
                  // TODO: Leaderboard özelliği gelecek güncellemede aktif edilecek
                  // _buildNavigationButton(
                  //   icon: Icons.leaderboard,
                  //   page: 'leaderboard',
                  //   color: const Color(0xFFE55A2B), // Koyu turuncu ton
                  // ),
                  _buildNavigationButton(
                    icon: Icons.notifications,
                    page: 'notifications',
                    color: const Color(0xFFE55A2B), // Koyu turuncu ton
                  ),
                  _buildNavigationButton(
                    icon: Icons.store,
                    page: 'store',
                    color: const Color(0xFFE55A2B), // Koyu turuncu ton
                  ),
                  _buildNavigationButton(
                    icon: Icons.settings,
                    page: 'settings',
                    color: const Color(0xFFE55A2B), // Koyu turuncu ton
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _getCurrentPage(),
    );
  }
}
