import 'package:flutter/material.dart';
import 'profile_tab.dart';
import 'turnuva_tab.dart';
import 'settings_tab.dart';
import 'voting_tab.dart';
import 'leaderboard_tab.dart';
import '../services/streak_service.dart';
import '../services/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;
  
  const HomeScreen({super.key, this.onLanguageChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _profileRefreshKey = 0;
  bool _streakChecked = false;

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
      print('Error checking streak: $e');
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
              AppLocalizations.of(context).dailyStreak,
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
              '$streak günlük streak!',
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
            child: const Text('Harika!'),
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

  void _openPage(BuildContext context, Widget page, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: BackButton(
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: page,
        ),
      ),
    );
  }

  void _refreshProfile() {
    setState(() {
      _profileRefreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ana Sayfa"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Üstte 4 buton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _openPage(context, ProfileTab(key: ValueKey(_profileRefreshKey), onRefresh: _refreshProfile), "Profil"),
                  child: const Text('Profil'),
                ),
                ElevatedButton(
                  onPressed: () => _openPage(context, const TurnuvaTab(), "Turnuva"),
                  child: const Text('Turnuva'),
                ),
                ElevatedButton(
                  onPressed: () => _openPage(context, const LeaderboardTab(), "Liderlik Tablosu"),
                  child: const Text('🏆 Liderlik'),
                ),
                ElevatedButton(
                  onPressed: () => _openPage(context, SettingsTab(onLanguageChanged: widget.onLanguageChanged), "Ayarlar"),
                  child: const Text('Ayarlar'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Altta tam ekran Voting
          Expanded(
            child: VotingTab(onVoteCompleted: _refreshProfile),
          ),
        ],
      ),
    );
  }
}
