import 'package:flutter/material.dart';
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
  Map<String, dynamic> matchStats = {};
  bool isLoading = true;
  bool hasPaid = false;

  @override
  void initState() {
    super.initState();
    _loadMatchHistory();
  }

  Future<void> _loadMatchHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser != null) {
        final history = await MatchHistoryService.getUserMatchHistory(currentUser.id);
        final stats = await MatchHistoryService.getUserMatchStats(currentUser.id);
        
        setState(() {
          matchHistory = history;
          matchStats = stats;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading match history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _purchaseMatchHistory() async {
    try {
      // 5 coin harca
      final success = await UserService.updateCoins(-5, 'spent', AppLocalizations.of(context)!.matchHistoryViewing);
      
      if (success) {
        setState(() {
          hasPaid = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.fiveCoinsSpentForHistory),
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
                child: opponent.matchPhotos != null && opponent.matchPhotos!.isNotEmpty
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

  Widget _buildMatchCard(Map<String, dynamic> matchData) {
    final opponent = matchData['opponent'] as UserModel;
    final isWinner = matchData['is_winner'] as bool;
    final completedAt = DateTime.parse(matchData['completed_at']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rakip fotoğrafı - Tıklanabilir
            GestureDetector(
              onTap: () => _showImageDialog(opponent),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: opponent.matchPhotos != null && opponent.matchPhotos!.isNotEmpty
                    ? NetworkImage(opponent.matchPhotos!.first['photo_url'])
                    : null,
                child: opponent.matchPhotos == null || opponent.matchPhotos!.isEmpty
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Rakip bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opponent.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.winRateColon(opponent.winRateString),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.matchesAndWins(opponent.totalMatches, opponent.wins),
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
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.lastFiveMatchStats,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  AppLocalizations.of(context)!.total,
                  '${matchStats['total_matches']}',
                  Icons.sports,
                  Colors.blue,
                ),
                _buildStatItem(
                  AppLocalizations.of(context)!.wins,
                  '${matchStats['wins']}',
                  Icons.emoji_events,
                  Colors.green,
                ),
                _buildStatItem(
                  AppLocalizations.of(context)!.losses,
                  '${matchStats['losses']}',
                  Icons.close,
                  Colors.red,
                ),
                _buildStatItem(
                  AppLocalizations.of(context)!.rate,
                  '${(matchStats['win_rate'] as double).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.matchHistory),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasPaid
              ? RefreshIndicator(
                  onRefresh: _loadMatchHistory,
                  child: ListView(
                    children: [
                      _buildStatsCard(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)!.lastFiveMatches,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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
                        ...matchHistory.map((match) => _buildMatchCard(match)),
                    ],
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context)!.premiumFeature,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.spendFiveCoinsForHistory,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _purchaseMatchHistory,
                          icon: const Icon(Icons.monetization_on),
                          label: Text(AppLocalizations.of(context)!.spendFiveCoins),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
