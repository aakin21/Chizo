import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tournament_model.dart';
import '../models/user_model.dart';
import '../services/tournament_service.dart';
import '../services/user_service.dart';
import '../services/photo_upload_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/beautiful_snackbar.dart';

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
      // Önce Supabase bağlantısını test et
      await TournamentService.testSupabaseConnection();
      
      // Turnuva fazlarını güncelle (status kontrolü)
      print('🔄 DEBUG: updateTournamentPhases çağrılıyor...');
      await TournamentService.updateTournamentPhases();
      print('✅ DEBUG: updateTournamentPhases tamamlandı');
      
      // Önce haftalık turnuvaları oluşturmayı dene
      await TournamentService.createWeeklyTournaments();
      
      // Kullanıcının diline göre turnuvaları getir
      final currentLanguage = Localizations.localeOf(context).languageCode;
      final activeTournaments = await TournamentService.getActiveTournaments(language: currentLanguage);
      final user = await UserService.getCurrentUser();
      
      if (!mounted) return;
      
      // Her turnuva için kullanıcının katılım durumunu kontrol et
      for (var tournament in activeTournaments) {
        tournament.isUserParticipating = await _checkUserParticipation(tournament.id);
      }
      
      setState(() {
        tournaments = activeTournaments;
        currentUser = user;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => isLoading = false);
      BeautifulSnackBar.showError(
        context,
        message: '${AppLocalizations.of(context)!.error}: $e',
      );
    }
  }

  // Kullanıcının turnuvaya katılıp katılmadığını kontrol et
  Future<bool> _checkUserParticipation(String tournamentId) async {
    try {
      // currentUser null ise tekrar al
      UserModel? user = currentUser;
      if (user == null) {
        user = await UserService.getCurrentUser();
        if (user == null) return false;
      }
      
      final participation = await TournamentService.client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', user.id)
          .maybeSingle();
      
      return participation != null;
    } catch (e) {
      return false;
    }
  }


  Future<void> _joinTournament(TournamentModel tournament) async {
    if (currentUser == null) return;

    // Zaten katılmış mı kontrolü
    if (tournament.isUserParticipating) {
      BeautifulSnackBar.showInfo(
        context,
        message: "Bu turnuvaya zaten katıldınız.",
      );
      return;
    }

    // Private turnuva için özel join fonksiyonu
    if (tournament.isPrivate) {
      await _joinPrivateTournamentById(tournament);
      return;
    }

    // Sistem turnuvaları için çarşamba günü kontrolü
    final now = DateTime.now();
    if (now.weekday >= 3) {
      BeautifulSnackBar.showWarning(
        context,
        message: "Çarşamba günü kayıtlar kapanmıştır. Gelecek hafta tekrar deneyin.",
      );
      return;
    }

    // Sistem turnuvaları için entry fee kontrolü
    if (currentUser!.coins < tournament.entryFee) {
      BeautifulSnackBar.showWarning(
        context,
        message: AppLocalizations.of(context)!.insufficientCoinsForTournament,
      );
      return;
    }

    // Sistem turnuvaları için normal join
    final success = await TournamentService.joinTournament(tournament.id);
    if (!mounted) return;
    
    if (success) {
      BeautifulSnackBar.showSuccess(
        context,
        message: AppLocalizations.of(context)!.joinedTournament,
      );
      
      // Turnuva durumunu güncelle
      tournament.isUserParticipating = true;
      
      // UI'yi güncelle
      setState(() {});
      
      // Turnuva fotoğrafı yükleme dialog'unu göster
      _showTournamentPhotoDialog(tournament.id);
    } else {
      BeautifulSnackBar.showError(
        context,
        message: "Turnuvaya katılım başarısız. Lütfen tekrar deneyin.",
      );
    }
  }

  // Private turnuva için özel join fonksiyonu
  Future<void> _joinPrivateTournamentById(TournamentModel tournament) async {
    final success = await TournamentService.joinPrivateTournamentById(tournament.id);
    if (!mounted) return;
    
    if (success) {
      BeautifulSnackBar.showSuccess(
        context,
        message: "Private turnuvaya başarıyla katıldınız!",
      );
      
      // Turnuva durumunu güncelle
      tournament.isUserParticipating = true;
      
      // UI'yi güncelle
      setState(() {});
      
      // Turnuva fotoğrafı yükleme dialog'unu göster
      _showTournamentPhotoDialog(tournament.id);
    } else {
      BeautifulSnackBar.showError(
        context,
        message: "Private turnuvaya katılım başarısız. Turnuva dolu olabilir veya kayıt süresi dolmuş olabilir.",
      );
    }
  }

  // Private turnuva silme dialog'u
  Future<void> _showDeleteTournamentDialog(TournamentModel tournament) async {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Turnuvayı Sil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${tournament.name} turnuvasını silmek istediğinizden emin misiniz?'),
            const SizedBox(height: 8),
            const Text(
              'Bu işlem geri alınamaz ve tüm katılımcılar turnuvadan çıkarılacaktır.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePrivateTournament(tournament);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // Private turnuva silme fonksiyonu
  Future<void> _deletePrivateTournament(TournamentModel tournament) async {
    try {
      final success = await TournamentService.deletePrivateTournament(tournament.id);
      if (!mounted) return;
      
      if (success) {
        BeautifulSnackBar.showSuccess(
          context,
          message: "Turnuva başarıyla silindi!",
        );
        
        // Turnuvaları yenile
        loadTournaments();
      } else {
        BeautifulSnackBar.showError(
          context,
          message: "Turnuva silinemedi. Sadece oluşturan kişi ve upcoming durumundaki turnuvalar silinebilir.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      BeautifulSnackBar.showError(
        context,
        message: "Hata: $e",
      );
    }
  }

  // Turnuvadan ayrılma dialog'u
  Future<void> _showLeaveTournamentDialog(TournamentModel tournament) async {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.exit_to_app, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Turnuvadan Ayrıl'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${tournament.name} turnuvasından ayrılmak istediğinizden emin misiniz?'),
            const SizedBox(height: 8),
            if (!tournament.isPrivate) ...[
              const Text(
                'Entry fee iadesi yapılacaktır.',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
            if (tournament.isPrivate) ...[
              const Text(
                'Private turnuvadan ayrıldıktan sonra tekrar göremezsiniz.',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _leaveTournament(tournament);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ayrıl'),
          ),
        ],
      ),
    );
  }

  // Turnuvadan ayrılma fonksiyonu
  Future<void> _leaveTournament(TournamentModel tournament) async {
    try {
      final success = await TournamentService.leaveTournament(tournament.id);
      if (!mounted) return;
      
      if (success) {
        BeautifulSnackBar.showSuccess(
          context,
          message: tournament.isPrivate 
              ? "Private turnuvadan ayrıldınız!"
              : "Turnuvadan ayrıldınız! Entry fee iadesi yapıldı.",
        );
        
        // Turnuva durumunu güncelle
        tournament.isUserParticipating = false;
        
        // UI'yi güncelle
        setState(() {});
        
        // Turnuvaları yenile (private turnuva görünmez olacak)
        loadTournaments();
      } else {
        BeautifulSnackBar.showError(
          context,
          message: "Turnuvadan ayrılamadı. Lütfen tekrar deneyin.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      BeautifulSnackBar.showError(
        context,
        message: "Hata: $e",
      );
    }
  }

  // Turnuva fotoğrafı yükleme dialog'u
  Future<void> _showTournamentPhotoDialog(String tournamentId) async {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.tournamentPhoto),
        content: Text(AppLocalizations.of(context)!.tournamentJoinedUploadPhoto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.uploadLater),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadTournamentPhoto(tournamentId);
            },
            child: Text(AppLocalizations.of(context)!.uploadPhoto),
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
          
          if (!mounted) return;
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.tournamentPhotoUploaded),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.photoUploadError),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.error}: $e'),
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
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noVotingForTournament)),
        );
        return;
      }

      // Oylama ekranını aç
      await _showTournamentVotingDialog(specificMatch);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.votingLoadError(e.toString()))),
      );
    }
  }



  Future<void> _showTournamentVotingDialog(Map<String, dynamic> tournamentMatch) async {
    if (!mounted) return;
    
    final user1 = tournamentMatch['user1'];
    final user2 = tournamentMatch['user2'];
    String? selectedWinner;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.how_to_vote, color: Colors.purple),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.tournamentVotingTitle),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.whichParticipantPrefer,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
              child: Text(AppLocalizations.of(context)!.cancel),
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
              child: Text(AppLocalizations.of(context)!.vote),
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
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.voteSavedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.votingError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadTournaments,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _showJoinPrivateTournamentDialog,
                  icon: const Icon(Icons.key, size: 16),
                  label: Text(AppLocalizations.of(context)!.joinWithKey),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showCreatePrivateTournamentDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(AppLocalizations.of(context)!.private),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (isLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (tournaments.isEmpty)
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noActiveTournament,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: tournaments.map((tournament) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTournamentCard(tournament),
                  ),
                ).toList(),
              ),
          ],
        ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTournamentName(tournament),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Creator name display
                      if (tournament.creatorId != null)
                        FutureBuilder<UserModel?>(
                          future: UserService.getUserById(tournament.creatorId!),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Text(
                                'Oluşturan: ${snapshot.data!.username}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                    ],
                  ),
                ),
                // Turnuva kuralları butonu
                TextButton(
                  onPressed: () => _showTournamentDetails(tournament),
                  child: const Text(
                    'Turnuva Kuralları',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                        ? AppLocalizations.of(context)!.active
                        : tournament.status == 'registration'
                        ? AppLocalizations.of(context)!.registration
                        : AppLocalizations.of(context)!.upcoming,
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
                // Sadece sistem turnuvaları için entry fee ve prize pool göster
                if (!tournament.isPrivate) ...[
                  _buildInfoChip(
                    Icons.monetization_on,
                    '${tournament.entryFee} coin',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.stars,
                    AppLocalizations.of(context)!.coinPrize(tournament.prizePool),
                  ),
                  const SizedBox(width: 8),
                ],
                // Katılımcı listesi butonu
                GestureDetector(
                  onTap: () => _showParticipantsList(tournament.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.list, size: 14, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Katılımcılar',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.startDate(_formatDate(tournament.startDate)),
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
                // Private turnuva creator kontrolü
                if (tournament.isPrivate && currentUser != null && tournament.creatorId == currentUser?.id) ...[
                  // Creator için hem join hem incele butonu
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _getJoinButtonEnabled(tournament)
                          ? () => _joinTournament(tournament)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getJoinButtonEnabled(tournament) 
                            ? Colors.green
                            : Colors.grey[300],
                        foregroundColor: _getJoinButtonEnabled(tournament) 
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                      child: Text(_getJoinButtonText(tournament)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Turnuvayı İncele butonu (Creator için)
                  ElevatedButton.icon(
                    onPressed: () => _showTournamentInspectDialog(tournament),
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('İncele'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Turnuvayı Sil butonu (Creator için)
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteTournamentDialog(tournament),
                    icon: const Icon(Icons.delete),
                    label: const Text('Sil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ] else ...[
                  // Katılım/Ayrılma butonu
                  if (tournament.isUserParticipating) ...[
                    // Ayrılma butonu (katıldıysa)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showLeaveTournamentDialog(tournament),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Turnuvadan Ayrıl'),
                      ),
                    ),
                  ] else ...[
                    // Katılım butonu (katılmadıysa)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _getJoinButtonEnabled(tournament)
                            ? () => _joinTournament(tournament)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getJoinButtonEnabled(tournament) 
                              ? null 
                              : Colors.grey[300],
                          foregroundColor: _getJoinButtonEnabled(tournament) 
                              ? null 
                              : Colors.grey[600],
                        ),
                        child: Text(_getJoinButtonText(tournament)),
                      ),
                    ),
                  ],
                ],
                const SizedBox(width: 8),
                if (tournament.status == 'active') ...[
                  // Turnuva oyla butonu - sadece aktif turnuvalar için
                  ElevatedButton.icon(
                    onPressed: () => _voteForSpecificTournament(tournament.id),
                    icon: const Icon(Icons.how_to_vote),
                    label: Text(AppLocalizations.of(context)!.vote),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sıralama butonu
                  ElevatedButton.icon(
                    onPressed: () => _showTournamentLeaderboard(tournament.id),
                    icon: const Icon(Icons.leaderboard),
                    label: Text(AppLocalizations.of(context)!.leaderboard),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ]
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

  // Turnuva format tooltip'leri
  String _getFormatTooltip(String format) {
    switch (format) {
      case 'league':
        return 'Lig Usulü: Herkes herkesle oynar, en yüksek win rate kazanır. Sınırsız katılımcı.';
      case 'elimination':
        return 'Eleme Usulü: Tek maçlık eleme sistemi. Maksimum 8 kişi (Çeyrek final, Yarı final, Final).';
      default:
        return 'Turnuva formatı seçin';
    }
  }

  // Private turnuva oluşturma dialog'u
  Future<void> _showCreatePrivateTournamentDialog() async {
    // Önce kullanıcının coin'ini kontrol et
    final currentUser = await UserService.getCurrentUser();
    if (currentUser == null) {
      BeautifulSnackBar.showError(
        context,
        message: 'Kullanıcı bilgileri alınamadı',
      );
      return;
    }

    const requiredCoins = 5000;
    if (currentUser.coins < requiredCoins) {
      BeautifulSnackBar.showWarning(
        context,
        message: 'Private turnuva oluşturmak için $requiredCoins coin gerekli. Mevcut coin: ${currentUser.coins}',
      );
      return;
    }

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final maxParticipantsController = TextEditingController(text: '8');
    
    String selectedFormat = 'league';
    String selectedGender = 'Erkek';
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.createPrivateTournament),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Private turnuva oluşturmak için 5000 coin gereklidir',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Turnuva adı
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.tournamentName,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.emoji_events),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Açıklama
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Max participants
                TextField(
                  controller: maxParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.maxParticipants,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.people),
                    // Private turnuvalar için eleme usulü sınırı yok
                  ),
                  onChanged: (value) {
                    // Private turnuvalar için eleme usulü sınırı yok
                  },
                ),
                const SizedBox(height: 16),
                
                // Turnuva formatı
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedFormat,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.tournamentFormat,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sports_esports),
                        ),
                        items: [
                          DropdownMenuItem(value: 'league', child: Text(AppLocalizations.of(context)!.leagueFormat)),
                          DropdownMenuItem(value: 'elimination', child: Text(AppLocalizations.of(context)!.eliminationFormat)),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedFormat = value!;
                            // Private turnuvalar için eleme usulü sınırı yok
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: _getFormatTooltip(selectedFormat),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Cinsiyet
                DropdownButtonFormField<String>(
                  initialValue: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Cinsiyet',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                    DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedGender = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Başlangıç tarihi
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Başlangıç Tarihi'),
                  subtitle: Text('${startDate.day}/${startDate.month}/${startDate.year}'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        startDate = date;
                      });
                    }
                  },
                ),
                
                // Bitiş tarihi
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Bitiş Tarihi'),
                  subtitle: Text('${endDate.day}/${endDate.month}/${endDate.year}'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: startDate,
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        endDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || 
                    descriptionController.text.isEmpty ||
                    maxParticipantsController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen tüm alanları doldurun'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Private turnuvalar için eleme usulü sınırı yok
                
                Navigator.pop(context);
                await _createPrivateTournament(
                  name: nameController.text,
                  description: descriptionController.text,
                  maxParticipants: int.parse(maxParticipantsController.text),
                  startDate: startDate,
                  endDate: endDate,
                  tournamentFormat: selectedFormat,
                  gender: selectedGender,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  // Private turnuva oluştur
  Future<void> _createPrivateTournament({
    required String name,
    required String description,
    required int maxParticipants,
    required DateTime startDate,
    required DateTime endDate,
    required String tournamentFormat,
    required String gender,
  }) async {
    try {
      // Kullanıcının diline göre private turnuva oluştur
      final currentLanguage = Localizations.localeOf(context).languageCode;
      final result = await TournamentService.createPrivateTournament(
        name: name,
        description: description,
        maxParticipants: maxParticipants,
        startDate: startDate,
        endDate: endDate,
        tournamentFormat: tournamentFormat,
        gender: gender,
        language: currentLanguage,
      );

      if (result['success']) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Private Key: ${result['private_key']}',
              textColor: Colors.white,
              onPressed: () {
                // Private key'i kopyala
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Private Key: ${result['private_key']}'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          ),
        );
        
        // Turnuvaları yenile
        loadTournaments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
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

  // Private key ile katılma dialog'u
  Future<void> _showJoinPrivateTournamentDialog() async {
    final keyController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.key, color: Colors.orange),
            SizedBox(width: 8),
            Text('Private Key ile Katıl'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Private Key',
                hintText: 'ABCD1234',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
            ),
            const SizedBox(height: 16),
            const Text(
              'Turnuva oluşturan kişiden private key\'i alın',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (keyController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen private key girin'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              await _joinPrivateTournament(keyController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.join),
          ),
        ],
      ),
    );
  }

  // Turnuva inceleme dialog'u (Admin için)
  Future<void> _showTournamentInspectDialog(TournamentModel tournament) async {
    try {
      // Turnuva detaylarını ve katılımcıları getir
      final leaderboard = await TournamentService.getTournamentLeaderboard(tournament.id);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Colors.purple),
              const SizedBox(width: 8),
              const Text('Turnuva İnceleme'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Turnuva bilgileri
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Turnuva Bilgileri',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Ad', tournament.name),
                          _buildInfoRow('Açıklama', tournament.description),
                          _buildInfoRow('Durum', _getStatusText(tournament.status)),
                          _buildInfoRow('Aşama', _getPhaseText(tournament.currentPhase)),
                          _buildInfoRow('Katılımcı', '${tournament.currentParticipants}/${tournament.maxParticipants}'),
                          // Sadece sistem turnuvaları için entry fee ve prize pool göster
                          if (!tournament.isPrivate) ...[
                            _buildInfoRow('Entry Fee', '${tournament.entryFee} coin'),
                            _buildInfoRow('Ödül Havuzu', '${tournament.prizePool} coin'),
                          ],
                          _buildInfoRow('Format', _getFormatText(tournament.tournamentFormat)),
                          if (tournament.customRules != null && tournament.customRules!.isNotEmpty)
                            _buildInfoRow('Özel Kurallar', tournament.customRules!),
                          const SizedBox(height: 12),
                          // Private Key
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.purple),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Private Key',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tournament.privateKey ?? 'N/A',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // Private key'i kopyala
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Private Key kopyalandı: ${tournament.privateKey}'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.copy, color: Colors.purple),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Katılımcı listesi
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Katılımcılar (${leaderboard.length})',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          if (leaderboard.isEmpty)
                            const Text('Henüz katılımcı yok')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: leaderboard.length,
                              itemBuilder: (context, index) {
                                final participant = leaderboard[index];
                                final rank = index + 1;
                                
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: rank <= 3 ? Colors.amber : Colors.grey,
                                    child: Text(
                                      rank.toString(),
                                      style: TextStyle(
                                        color: rank <= 3 ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(participant['profiles']['username'] ?? 'Bilinmeyen'),
                                  subtitle: Text('Skor: ${participant['score']}'),
                                  trailing: participant['is_eliminated'] 
                                      ? const Icon(Icons.close, color: Colors.red)
                                      : const Icon(Icons.check, color: Colors.green),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Turnuva detayları yüklenirken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Yardımcı metodlar
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming': return 'Yaklaşan';
      case 'active': return 'Aktif';
      case 'completed': return 'Tamamlandı';
      default: return status;
    }
  }

  String _getPhaseText(String phase) {
    switch (phase) {
      case 'registration': return 'Kayıt';
      case 'qualifying': return 'Elemeler';
      case 'quarter_final': return 'Çeyrek Final';
      case 'semi_final': return 'Yarı Final';
      case 'final': return 'Final';
      case 'completed': return 'Tamamlandı';
      default: return phase;
    }
  }

  String _getFormatText(String format) {
    switch (format) {
      case 'league': return 'Lig Usulü';
      case 'elimination': return 'Eleme Usulü';
      default: return format;
    }
  }

  // Turnuva sıralamasını göster
  Future<void> _showTournamentLeaderboard(String tournamentId) async {
    try {
      final leaderboard = await TournamentService.getTournamentLeaderboard(tournamentId);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Turnuva Sıralaması'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final participant = leaderboard[index];
                final rank = index + 1;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rank <= 3 ? Colors.amber : Colors.grey,
                    child: Text(
                      rank.toString(),
                      style: TextStyle(
                        color: rank <= 3 ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(participant['profiles']['username'] ?? 'Bilinmeyen'),
                  subtitle: Text('Skor: ${participant['score']}'),
                  trailing: participant['is_eliminated'] 
                      ? const Icon(Icons.close, color: Colors.red)
                      : const Icon(Icons.check, color: Colors.green),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sıralama yüklenirken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }




  // Private turnuvaya katıl
  Future<void> _joinPrivateTournament(String privateKey) async {
    try {
      final result = await TournamentService.joinPrivateTournament(privateKey);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Turnuvaları yenile
        loadTournaments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
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

  // Turnuva detaylarını göster
  Future<void> _showTournamentDetails(TournamentModel tournament) async {
    try {
      // Turnuva detaylarını ve katılımcıları getir
      final leaderboard = await TournamentService.getTournamentLeaderboard(tournament.id);
      final creator = tournament.creatorId != null 
          ? await UserService.getUserById(tournament.creatorId!)
          : null;
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Turnuva Detayları'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Turnuva bilgileri
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Turnuva Bilgileri',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Ad', tournament.name),
                          _buildInfoRow('Açıklama', tournament.description),
                          _buildInfoRow('Durum', _getStatusText(tournament.status)),
                          _buildInfoRow('Aşama', _getPhaseText(tournament.currentPhase)),
                          _buildInfoRow('Katılımcı', '${tournament.currentParticipants}/${tournament.maxParticipants}'),
                          // Sadece sistem turnuvaları için entry fee ve prize pool göster
                          if (!tournament.isPrivate) ...[
                            _buildInfoRow('Entry Fee', '${tournament.entryFee} coin'),
                            _buildInfoRow('Ödül Havuzu', '${tournament.prizePool} coin'),
                          ],
                          _buildInfoRow('Format', _getFormatText(tournament.tournamentFormat)),
                          if (tournament.customRules != null && tournament.customRules!.isNotEmpty)
                            _buildInfoRow('Özel Kurallar', tournament.customRules!),
                          if (creator != null)
                            _buildInfoRow('Oluşturan', creator.username),
                          const SizedBox(height: 12),
                          // Private Key (sadece oluşturan için)
                          if (tournament.isPrivate && currentUser != null && tournament.creatorId == currentUser?.id) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.purple),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Private Key',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tournament.privateKey ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Private key'i kopyala
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Private Key kopyalandı: ${tournament.privateKey}'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.copy, color: Colors.purple),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Zaman kuralları
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Turnuva Zaman Kuralları',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildTimeRule('Pazartesi 00:01', 'Kayıtlar açılır'),
                          _buildTimeRule('Çarşamba 00:01', 'Kayıtlar kapanır, turnuva başlar'),
                          _buildTimeRule('Cuma 00:01', 'Çeyrek final'),
                          _buildTimeRule('Cumartesi 00:01', 'Yarı final'),
                          _buildTimeRule('Pazar 00:01', 'Final'),
                          _buildTimeRule('Pazartesi 00:01', 'Yeni turnuvalar açılır'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Turnuva programı ve sıralama
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Turnuva Programı ve Sıralama',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          
                          // Turnuva formatına göre farklı bilgiler göster
                          if (tournament.tournamentFormat == 'league') ...[
                            // Sadece lig usulü - sıralama göster
                            Text(
                              'Lig Usulü Turnuva',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            const SizedBox(height: 8),
                            Text('Herkes herkesle oynar. En yüksek win rate kazanır.'),
                            const SizedBox(height: 12),
                            if (leaderboard.isNotEmpty) ...[
                              Text(
                                'Anlık Sıralama (${leaderboard.length} katılımcı)',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: leaderboard.length,
                                itemBuilder: (context, index) {
                                  final participant = leaderboard[index];
                                  final rank = index + 1;
                                  
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: rank <= 3 ? Colors.amber : Colors.grey,
                                      child: Text(
                                        rank.toString(),
                                        style: TextStyle(
                                          color: rank <= 3 ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(participant['profiles']['username'] ?? 'Bilinmeyen'),
                                    subtitle: Text('Skor: ${participant['score']}'),
                                    trailing: participant['is_eliminated'] 
                                        ? const Icon(Icons.close, color: Colors.red)
                                        : const Icon(Icons.check, color: Colors.green),
                                  );
                                },
                              ),
                            ],
                          ] else if (tournament.tournamentFormat == 'elimination') ...[
                            // Sadece eleme usulü - program göster
                            Text(
                              'Eleme Usulü Turnuva',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            Text('Tek maçlık eleme sistemi. Maksimum 8 kişi.'),
                            const SizedBox(height: 12),
                            _buildScheduleInfo('Çeyrek Final', tournament.startDate),
                            _buildScheduleInfo('Yarı Final', tournament.startDate.add(const Duration(days: 1))),
                            _buildScheduleInfo('Final', tournament.startDate.add(const Duration(days: 2))),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Turnuva detayları yüklenirken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildScheduleInfo(String phase, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$phase:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(_formatDate(date)),
        ],
      ),
    );
  }

  Widget _buildTimeRule(String time, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Katılım butonunun aktif olup olmadığını kontrol et
  bool _getJoinButtonEnabled(TournamentModel tournament) {
    // Eğer kullanıcı zaten katılmışsa buton pasif
    if (tournament.isUserParticipating) return false;
    
    // Çarşamba günü kayıtlar kapalı (sadece sistem turnuvaları için)
    final now = DateTime.now();
    if (!tournament.isPrivate && now.weekday >= 3) return false; // Çarşamba ve sonrası
    
    // Private turnuvalar için start date kontrolü
    if (tournament.isPrivate && tournament.status == 'upcoming') {
      if (now.isAfter(tournament.startDate)) return false; // Start date geçmiş
    }
    
    // Turnuva durumu kontrolü
    if (tournament.status != 'upcoming') return false;
    
    // Turnuva dolu mu kontrol et
    if (tournament.currentParticipants >= tournament.maxParticipants) return false;
    
    return true;
  }

  // Katılım butonunun metnini getir
  String _getJoinButtonText(TournamentModel tournament) {
    // Eğer kullanıcı zaten katılmışsa
    if (tournament.isUserParticipating) {
      return "Katıldınız";
    }
    
    // Private turnuva creator için özel metin
    if (tournament.isPrivate && currentUser != null && tournament.creatorId == currentUser?.id) {
      return "Turnuvaya Katıl";
    }
    
    // Private turnuvalar için start date kontrolü
    if (tournament.isPrivate && tournament.status == 'upcoming') {
      final now = DateTime.now();
      if (now.isAfter(tournament.startDate)) {
        return "Kayıt Kapalı";
      }
    }
    
    // Çarşamba günü kayıtlar kapalı (sadece sistem turnuvaları için)
    final now = DateTime.now();
    if (!tournament.isPrivate && now.weekday >= 3) {
      return "Kayıt Kapalı";
    }
    
    // Turnuva durumuna göre metin
    if (tournament.status == 'completed') {
      return AppLocalizations.of(context)!.completed;
    } else if (tournament.status == 'active') {
      return "Turnuva Başladı";
    } else if (tournament.currentParticipants >= tournament.maxParticipants) {
      return AppLocalizations.of(context)!.tournamentFull;
    } else {
      return AppLocalizations.of(context)!.join;
    }
  }

  // Katılımcı listesini göster
  Future<void> _showParticipantsList(String tournamentId) async {
    try {
      final participants = await TournamentService.getTournamentParticipants(tournamentId);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.people, color: Colors.blue),
              SizedBox(width: 8),
              Text('Turnuva Katılımcıları'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: participants.isEmpty
                ? const Center(
                    child: Text('Henüz katılımcı yok'),
                  )
                : ListView.builder(
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final participant = participants[index];
                      final user = participant['user'];
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['profile_image_url'] != null 
                              ? NetworkImage(user['profile_image_url']) 
                              : null,
                          child: user['profile_image_url'] == null 
                              ? const Icon(Icons.person) 
                              : null,
                        ),
                        title: Text(user['username'] ?? 'Bilinmeyen'),
                        subtitle: Text('Katılım: ${_formatDate(DateTime.parse(participant['joined_at']))}'),
                        trailing: participant['is_eliminated'] 
                            ? const Icon(Icons.close, color: Colors.red)
                            : const Icon(Icons.check, color: Colors.green),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Katılımcı listesi yüklenirken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Turnuva adını getir (sistem turnuvaları için localization)
  String _getTournamentName(TournamentModel tournament) {
    if (tournament.isSystemTournament && tournament.nameKey != null) {
      // Sistem turnuvası için localization key kullan
      final l10n = AppLocalizations.of(context)!;
      switch (tournament.nameKey) {
        case 'weeklyMaleTournament1000':
          return l10n.weeklyMaleTournament1000;
        case 'weeklyMaleTournament10000':
          return l10n.weeklyMaleTournament10000;
        case 'weeklyFemaleTournament1000':
          return l10n.weeklyFemaleTournament1000;
        case 'weeklyFemaleTournament10000':
          return l10n.weeklyFemaleTournament10000;
        default:
          return tournament.name;
      }
    }
    return tournament.name;
  }


}
