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
      
      // Önce haftalık turnuvaları oluşturmayı dene
      await TournamentService.createWeeklyTournaments();
      
      // Kullanıcının diline göre turnuvaları getir
      final currentLanguage = Localizations.localeOf(context).languageCode;
      final activeTournaments = await TournamentService.getActiveTournaments(language: currentLanguage);
      final user = await UserService.getCurrentUser();
      setState(() {
        tournaments = activeTournaments;
        currentUser = user;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      BeautifulSnackBar.showError(
        context,
        message: '${AppLocalizations.of(context)!.error}: $e',
      );
    }
  }


  Future<void> _joinTournament(TournamentModel tournament) async {
    if (currentUser == null) return;

    if (currentUser!.coins < tournament.entryFee) {
      BeautifulSnackBar.showWarning(
        context,
        message: AppLocalizations.of(context)!.insufficientCoinsForTournament,
      );
      return;
    }

    // Cinsiyet kontrolü kaldırıldı - herkes tüm turnuvalara katılabilir

    final success = await TournamentService.joinTournament(tournament.id);
    if (success) {
      BeautifulSnackBar.showSuccess(
        context,
        message: AppLocalizations.of(context)!.joinedTournament,
      );
      await loadTournaments();
      
      // Turnuva fotoğrafı yükleme dialog'unu göster
      _showTournamentPhotoDialog(tournament.id);
    } else {
      BeautifulSnackBar.showError(
        context,
        message: AppLocalizations.of(context)!.tournamentJoinFailed,
      );
    }
  }

  // Turnuva fotoğrafı yükleme dialog'u
  Future<void> _showTournamentPhotoDialog(String tournamentId) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noVotingForTournament)),
        );
        return;
      }

      // Oylama ekranını aç
      await _showTournamentVotingDialog(specificMatch);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.votingLoadError(e.toString()))),
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.voteSavedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
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
                _buildInfoChip(
                  Icons.monetization_on,
                  '${tournament.entryFee} coin',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.stars,
                  AppLocalizations.of(context)!.coinPrize(tournament.prizePool),
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
                // Admin kontrolü - sadece turnuva oluşturan kişi için
                if (tournament.isPrivate && currentUser != null && tournament.creatorId == currentUser?.id) ...[
                  // Turnuvayı İncele butonu (Admin için)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showTournamentInspectDialog(tournament),
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Turnuvayı İncele'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  // Normal katılım butonu
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (tournament.status == 'upcoming' || tournament.status == 'active') && tournament.currentParticipants < tournament.maxParticipants
                          ? () => _joinTournament(tournament)
                          : null,
                      child: Text(
                        tournament.status == 'completed'
                            ? AppLocalizations.of(context)!.completed
                            : tournament.status == 'active'
                            ? AppLocalizations.of(context)!.ongoing
                            : tournament.status == 'upcoming'
                            ? AppLocalizations.of(context)!.join
                            : tournament.currentParticipants >= tournament.maxParticipants
                        ? AppLocalizations.of(context)!.tournamentFull
                        : AppLocalizations.of(context)!.join,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                if ((tournament.status == 'upcoming' || tournament.status == 'active') && tournament.currentParticipants < tournament.maxParticipants)
                  ElevatedButton.icon(
                    onPressed: () => _showTournamentPhotoDialog(tournament.id),
                    icon: const Icon(Icons.photo_camera),
                    label: Text(AppLocalizations.of(context)!.photo),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
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
      case 'hybrid':
        return 'Lig + Eleme: Önce lig usulü, sonra en iyi 8 kişi eleme usulü. Maksimum 8 kişi eleme aşaması için.';
      default:
        return 'Turnuva formatı seçin';
    }
  }

  // Private turnuva oluşturma dialog'u
  Future<void> _showCreatePrivateTournamentDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final entryFeeController = TextEditingController(text: '1000');
    final maxParticipantsController = TextEditingController(text: '8');
    final customRulesController = TextEditingController();
    
    String selectedFormat = 'league';
    String selectedGender = 'Erkek';
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.add_circle, color: Colors.purple),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.createPrivateTournament),
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
                
                // Entry fee ve max participants
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entryFeeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Entry Fee (Coin)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.monetization_on),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: maxParticipantsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.maxParticipants,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.people),
                          suffixIcon: selectedFormat == 'elimination' 
                            ? Tooltip(
                                message: AppLocalizations.of(context)!.eliminationMaxParticipants,
                                child: Icon(Icons.warning, color: Colors.orange, size: 16),
                              )
                            : null,
                        ),
                        onChanged: (value) {
                          // Eleme usulü için maksimum 8 kişi kontrolü
                          if (selectedFormat == 'elimination' && int.tryParse(value) != null && int.parse(value) > 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.eliminationMaxParticipantsWarning),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            maxParticipantsController.text = '8';
                          }
                        },
                      ),
                    ),
                  ],
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
                          DropdownMenuItem(value: 'hybrid', child: Text(AppLocalizations.of(context)!.hybridFormat)),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedFormat = value!;
                            // Eleme usulü seçilirse maksimum 8 kişi
                            if (value == 'elimination' && int.parse(maxParticipantsController.text) > 8) {
                              maxParticipantsController.text = '8';
                            }
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
                const SizedBox(height: 16),
                
                // Özel kurallar
                TextField(
                  controller: customRulesController,
                  decoration: const InputDecoration(
                    labelText: 'Özel Kurallar (Opsiyonel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.rule),
                  ),
                  maxLines: 2,
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
                    entryFeeController.text.isEmpty ||
                    maxParticipantsController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen tüm alanları doldurun'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Eleme usulü için maksimum 8 kişi kontrolü
                final maxParticipants = int.tryParse(maxParticipantsController.text);
                if (selectedFormat == 'elimination' && (maxParticipants == null || maxParticipants > 8)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Eleme usulü için maksimum 8 kişi olabilir'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                Navigator.pop(context);
                await _createPrivateTournament(
                  name: nameController.text,
                  description: descriptionController.text,
                  entryFee: int.parse(entryFeeController.text),
                  maxParticipants: int.parse(maxParticipantsController.text),
                  startDate: startDate,
                  endDate: endDate,
                  tournamentFormat: selectedFormat,
                  customRules: customRulesController.text.isEmpty ? null : customRulesController.text,
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
    required int entryFee,
    required int maxParticipants,
    required DateTime startDate,
    required DateTime endDate,
    required String tournamentFormat,
    String? customRules,
    required String gender,
  }) async {
    try {
      // Kullanıcının diline göre private turnuva oluştur
      final currentLanguage = Localizations.localeOf(context).languageCode;
      final result = await TournamentService.createPrivateTournament(
        name: name,
        description: description,
        entryFee: entryFee,
        maxParticipants: maxParticipants,
        startDate: startDate,
        endDate: endDate,
        tournamentFormat: tournamentFormat,
        customRules: customRules,
        gender: gender,
        language: currentLanguage,
      );

      if (result['success']) {
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
                          _buildInfoRow('Entry Fee', '${tournament.entryFee} coin'),
                          _buildInfoRow('Ödül Havuzu', '${tournament.prizePool} coin'),
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
      case 'hybrid': return 'Lig + Eleme';
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

}
