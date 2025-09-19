import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../models/user_model.dart';
import '../services/match_service.dart';

class VotingTab extends StatefulWidget {
  final VoidCallback? onVoteCompleted;
  
  const VotingTab({super.key, this.onVoteCompleted});

  @override
  State<VotingTab> createState() => _VotingTabState();
}

class _VotingTabState extends State<VotingTab> {
  List<MatchModel> matches = [];
  bool isLoading = true;
  int currentMatchIndex = 0;

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    setState(() => isLoading = true);
    try {
      // Yeni random match oluştur
      await MatchService.generateRandomMatches(matchCount: 1);
      
      // Oluşturulan match'leri yükle (otomatik temizlik dahil)
      final votableMatches = await MatchService.getVotableMatches();
    
      setState(() {
        matches = votableMatches;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _voteForUser(String winnerId) async {
    if (currentMatchIndex >= matches.length) return;

    final currentMatch = matches[currentMatchIndex];
    final success = await MatchService.voteForMatch(currentMatch.id, winnerId);
    
    if (success) {
      print('VotingTab: Vote successful, calling onVoteCompleted callback');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oyunuz kaydedildi!')),
      );
      
      // Profil sayfasını yenile
      widget.onVoteCompleted?.call();
      
      // Mevcut match'i listeden kaldır
      setState(() {
        matches.removeAt(currentMatchIndex);
        if (currentMatchIndex >= matches.length) {
          currentMatchIndex = 0;
        }
      });
      
      // Eğer match kalmadıysa yeni match'ler oluştur
      if (matches.isEmpty) {
        await loadMatches();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oylama sırasında hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Oylama',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 20),
          
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (matches.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Şu anda oylayabileceğiniz maç bulunmuyor',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else if (currentMatchIndex >= matches.length)
            const Expanded(
              child: Center(
                child: Text(
                  'Tüm maçları oyladınız!\nYeni maçlar için bekleyin...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            Expanded(
              child: _buildMatchCard(matches[currentMatchIndex]),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    return FutureBuilder<List<UserModel>>(
      future: _getMatchUsers(match),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.length < 2) {
          return const Center(
            child: Text('Maç bilgileri yüklenemedi'),
          );
        }
        
        final users = snapshot.data!;
        final user1 = users[0];
        final user2 = users[1];
        
        return Column(
          children: [
            Text(
              'Hangisini daha çok beğeniyorsunuz?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: Row(
                children: [
                  // İlk kullanıcı
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _voteForUser(user1.id),
                      child: Card(
                        elevation: 4,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                child: user1.profileImageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: user1.profileImageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.person, size: 80),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.person, size: 50),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                user1.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // VS yazısı
                  const Center(
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // İkinci kullanıcı
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _voteForUser(user2.id),
                      child: Card(
                        elevation: 6,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                child: user2.profileImageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: user2.profileImageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.person, size: 80),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.person, size: 50),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                user2.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              '${currentMatchIndex + 1} / ${matches.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<UserModel>> _getMatchUsers(MatchModel match) async {
    // Bu fonksiyon match'teki kullanıcıları getirmek için kullanılacak
    // Şimdilik basit bir implementasyon yapıyoruz
    try {
      final response = await MatchService.getMatchUsers(match.user1Id, match.user2Id);
      return response;
    } catch (e) {
      return [];
    }
  }
}
