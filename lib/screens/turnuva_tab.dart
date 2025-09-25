import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tournament_model.dart';
import '../models/user_model.dart';
import '../services/tournament_service.dart';
import '../services/user_service.dart';
import '../services/photo_upload_service.dart';
import '../l10n/app_localizations.dart';

class TurnuvaTab extends StatefulWidget {
  const TurnuvaTab({super.key});

  @override
  State<TurnuvaTab> createState() => _TurnuvaTabState();
}

class _TurnuvaTabState extends State<TurnuvaTab> {
  List<TournamentModel> tournaments = [];
  bool isLoading = true;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    loadTournaments();
  }

  Future<void> loadTournaments() async {
    setState(() => isLoading = true);
    try {
      final activeTournaments = await TournamentService.getActiveTournaments();
      final user = await UserService.getCurrentUser();
      setState(() {
        tournaments = activeTournaments;
        currentUser = user;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _joinTournament(TournamentModel tournament) async {
    if (currentUser == null) return;

    if (currentUser!.coins < tournament.entryFee) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.insufficientCoinsForTournament)),
      );
      return;
    }

    // Cinsiyet kontrolü kaldırıldı - herkes tüm turnuvalara katılabilir

    final success = await TournamentService.joinTournament(tournament.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.joinedTournament)),
      );
      await loadTournaments();
      
      // Turnuva fotoğrafı yükleme dialog'unu göster
      _showTournamentPhotoDialog(tournament.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.tournamentJoinFailed)),
      );
    }
  }

  // Turnuva fotoğrafı yükleme dialog'u
  Future<void> _showTournamentPhotoDialog(String tournamentId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🏆 Turnuva Fotoğrafı'),
        content: const Text('Turnuvaya katıldınız! Şimdi turnuva fotoğrafınızı yükleyin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sonra Yükle'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadTournamentPhoto(tournamentId);
            },
            child: const Text('Fotoğraf Yükle'),
          ),
        ],
      ),
    );
  }

  // Turnuva fotoğrafı yükle
  Future<void> _uploadTournamentPhoto(String tournamentId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Fotoğrafı Supabase'e yükle
        final photoUrl = await PhotoUploadService.uploadTournamentPhoto(image);
        
        if (photoUrl != null) {
          // Turnuva fotoğrafını kaydet
          final success = await TournamentService.uploadTournamentPhoto(tournamentId, photoUrl);
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Turnuva fotoğrafı yüklendi!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Fotoğraf yüklenirken hata oluştu!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Belirli turnuva için oylama
  Future<void> _voteForSpecificTournament(String tournamentId) async {
    try {
      // Belirli turnuva için oylama ekranını aç
      final tournamentMatches = await TournamentService.getTournamentMatchesForVoting();
      
      // Bu turnuva ID'sine sahip match'i bul
      Map<String, dynamic>? specificMatch;
      try {
        specificMatch = tournamentMatches.firstWhere(
          (match) => match['tournament_id'] == tournamentId,
        );
      } catch (e) {
        specificMatch = null;
      }
      
      if (specificMatch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu turnuva için oylama bulunamadı')),
        );
        return;
      }

      // Oylama ekranını aç
      await _showTournamentVotingDialog(specificMatch);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oylama yüklenirken hata: $e')),
      );
    }
  }



  Future<void> _showTournamentVotingDialog(Map<String, dynamic> tournamentMatch) async {
    final user1 = tournamentMatch['user1'];
    final user2 = tournamentMatch['user2'];
    String? selectedWinner;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.how_to_vote, color: Colors.purple),
              SizedBox(width: 8),
              Text('Turnuva Oylaması'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hangi katılımcıyı tercih ediyorsunuz?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              
              // Kullanıcı 1
              GestureDetector(
                onTap: () {
                  setDialogState(() {
                    selectedWinner = user1['id'];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedWinner == user1['id'] ? Colors.purple : Colors.grey,
                      width: selectedWinner == user1['id'] ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: selectedWinner == user1['id'] ? Colors.purple.withOpacity(0.1) : null,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: user1['photo_url'] != null 
                            ? NetworkImage(user1['photo_url']) 
                            : null,
                        child: user1['photo_url'] == null 
                            ? const Icon(Icons.person, size: 30) 
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user1['username'] ?? 'Bilinmeyen',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              const Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Kullanıcı 2
              GestureDetector(
                onTap: () {
                  setDialogState(() {
                    selectedWinner = user2['id'];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedWinner == user2['id'] ? Colors.purple : Colors.grey,
                      width: selectedWinner == user2['id'] ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: selectedWinner == user2['id'] ? Colors.purple.withOpacity(0.1) : null,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: user2['photo_url'] != null 
                            ? NetworkImage(user2['photo_url']) 
                            : null,
                        child: user2['photo_url'] == null 
                            ? const Icon(Icons.person, size: 30) 
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user2['username'] ?? 'Bilinmeyen',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: selectedWinner != null 
                  ? () async {
                      await _submitTournamentVote(tournamentMatch, selectedWinner!);
                      Navigator.of(context).pop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Oyla'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTournamentVote(Map<String, dynamic> tournamentMatch, String winnerId) async {
    try {
      final user1 = tournamentMatch['user1'];
      final user2 = tournamentMatch['user2'];
      
      final loserId = winnerId == user1['id'] ? user2['id'] : user1['id'];
      
      await TournamentService.voteForTournamentMatch(
        tournamentMatch['tournament_id'],
        winnerId,
        loserId,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oyunuz başarıyla kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oylama sırasında hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Turnuvalar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (tournaments.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Şu anda aktif turnuva bulunmuyor',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: tournaments.length,
                itemBuilder: (context, index) {
                  final tournament = tournaments[index];
                  return _buildTournamentCard(tournament);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTournamentCard(TournamentModel tournament) {
    // Cinsiyet filtrelemesi kaldırıldı - herkes tüm turnuvaları görebilir

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tournament.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tournament.status == 'active' 
                        ? Colors.green 
                        : tournament.status == 'registration'
                        ? Colors.blue
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tournament.status == 'active' 
                        ? 'Aktif' 
                        : tournament.status == 'registration'
                        ? 'Kayıt'
                        : 'Yaklaşıyor',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              tournament.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildInfoChip(
                  Icons.people,
                  '${tournament.currentParticipants}/${tournament.maxParticipants}',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.monetization_on,
                  '${tournament.entryFee} coin',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.stars,
                  '${tournament.prizePool} coin ödül',
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Başlangıç: ${_formatDate(tournament.startDate)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: tournament.status == 'registration' && tournament.currentParticipants < tournament.maxParticipants
                        ? () => _joinTournament(tournament)
                        : null,
                    child: Text(
                      tournament.status == 'completed'
                          ? 'Tamamlandı'
                          : tournament.status == 'active'
                          ? 'Devam Ediyor'
                          : tournament.currentParticipants >= tournament.maxParticipants
                      ? 'Turnuva Dolu'
                      : 'Katıl',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (tournament.status == 'registration' && tournament.currentParticipants < tournament.maxParticipants)
                  ElevatedButton.icon(
                    onPressed: () => _showTournamentPhotoDialog(tournament.id),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Fotoğraf'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(width: 8),
                // Turnuva oyla butonu - sadece aktif turnuvalar için
                if (tournament.status == 'active')
                  ElevatedButton.icon(
                    onPressed: () => _voteForSpecificTournament(tournament.id),
                    icon: const Icon(Icons.how_to_vote),
                    label: const Text('Oyla'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
