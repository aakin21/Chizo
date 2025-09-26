import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/leaderboard_service.dart';
import '../l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaderboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      print('Error loading leaderboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildUserCard(UserModel user, int rank, {String? subtitle}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: subtitle != null 
          ? Text(subtitle)
          : Text(AppLocalizations.of(context)!.winsAndMatches(user.wins, user.totalMatches)),
        trailing: user.matchPhotos != null && user.matchPhotos!.isNotEmpty
          ? CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(user.matchPhotos!.first['photo_url']),
            )
          : const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person),
            ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.blue;
    }
  }

  Widget _buildLeaderboardList(List<UserModel> users, String emptyMessage) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
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
            // En çok galibiyet - sadece win sayısı
            subtitle = '${user.wins} galibiyet';
          } else {
            // Kazanma oranı
            subtitle = AppLocalizations.of(context)!.winRateAndMatches(user.winRateString, user.totalMatches);
          }

          return _buildUserCard(user, rank, subtitle: subtitle);
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.leaderboardTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.mostWins),
            Tab(text: AppLocalizations.of(context)!.highestWinRate),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboardData,
          ),
        ],
      ),
      body: TabBarView(
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
    );
  }
}
