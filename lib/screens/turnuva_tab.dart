import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      // Önce Supabase bağlantısını test et
      await TournamentService.testSupabaseConnection();
      
      // Önce haftalık turnuvaları oluşturmayı dene
      await TournamentService.createWeeklyTournaments();
      
      final activeTournaments = await TournamentService.getActiveTournaments();
      final user = await UserService.getCurrentUser();
      
      // Debug: Kullanıcı bilgilerini yazdır
      if (user != null) {
        print('🔍 USER DEBUG:');
        print('  Username: ${user.username}');
        print('  GenderCode: ${user.genderCode}');
        print('  Email: ${user.email}');
        print('  Coins: ${user.coins}');
      } else {
        print('❌ USER DEBUG: User is null!');
      }
      
      setState(() {
        tournaments = activeTournaments;
        currentUser = user;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  // Kullanıcının turnuvaya katılıp katılmadığını kontrol et
  Future<bool> _isUserJoinedTournament(String tournamentId) async {
    if (currentUser == null) return false;
    
    try {
      final response = await Supabase.instance.client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUser!.id)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      print('Error checking tournament participation: $e');
      return false;
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

    // Coin ödeme onayı dialog'u göster
    final shouldProceed = await _showCoinPaymentConfirmation(tournament);
    if (!shouldProceed) return;

    // Cinsiyet kontrolü kaldırıldı - herkes tüm turnuvalara katılabilir

    final success = await TournamentService.joinTournament(tournament.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.joinedTournament)),
      );
      await loadTournaments();
      
      // Coin ödeme başarılı olduktan sonra turnuva fotoğrafı yükleme dialog'unu göster (iptal seçeneği ile)
      _showTournamentPhotoDialogWithCancel(tournament.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.tournamentJoinFailed)),
      );
    }
  }

  // Coin ödeme onayı dialog'u
  Future<bool> _showCoinPaymentConfirmation(TournamentModel tournament) async {
    bool shouldProceed = false;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.amber),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.tournamentEntryFee),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${tournament.name} turnuvasına katılmak için ${tournament.entryFee} coin ödemeniz gerekiyor.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mevcut coininiz: ${currentUser?.coins ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
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
            onPressed: () {
              shouldProceed = true;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            child: Text('${tournament.entryFee} Coin Öde'),
          ),
        ],
      ),
    );
    
    return shouldProceed;
  }

  // Turnuva fotoğrafı yükleme dialog'u (iptal seçeneği ile)
  Future<void> _showTournamentPhotoDialogWithCancel(String tournamentId) async {
    
    await showDialog(
      context: context,
      barrierDismissible: false, // Dışarı tıklayarak kapatılamaz
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.photo_camera, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Turnuva Fotoğrafı Yükle'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fotoğrafı Çarşamba\'ya kadar yükleyebilirsiniz',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final imagePicker = ImagePicker();
                      final XFile? image = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 85,
                      );

                      if (image != null) {
                        // Fotoğraf yükleme işlemi
                        final photoUrl = await PhotoUploadService.uploadTournamentPhoto(image);
                        if (photoUrl != null) {
                          final success = await TournamentService.uploadTournamentPhoto(tournamentId, photoUrl);
                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Fotoğraf yüklendi'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Fotoğraf yüklenemedi'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Fotoğraf yüklenemedi'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.photo_library),
                    label: Text('Fotoğraf Seç'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // İptal durumunda coin iadesi
                      print('🔄 UI: User cancelled tournament, starting refund...');
                      final refundSuccess = await TournamentService.refundTournamentEntry(tournamentId);
                      if (refundSuccess) {
                        print('✅ UI: Refund successful, closing dialog');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Turnuva iptal edildi, coinleriniz iade edildi'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        await loadTournaments(); // Turnuva listesini yenile
                      } else {
                        print('❌ UI: Refund failed');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('İade işlemi başarısız. Lütfen destek ekibi ile iletişime geçin.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.cancel),
                    label: Text('İptal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    return Padding(
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
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (tournaments.isEmpty)
            Expanded(
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
            
            const SizedBox(height: 8),
            
            // Cinsiyet göstergesi
            Row(
              children: [
                _buildGenderChip(tournament.gender),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.schedule,
                  AppLocalizations.of(context)!.startDate(_formatDate(tournament.startDate)),
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
            
            FutureBuilder<bool>(
              future: _isUserJoinedTournament(tournament.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final isJoined = snapshot.data ?? false;
                
                return Column(
                  children: [
                    // Ana buton satırı
                    Row(
                      children: [
                        Expanded(
                          child: _buildMainTournamentButton(tournament, isJoined),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    
                    // İkinci buton satırı (aktif turnuvalar için)
                    if (tournament.status == 'active') ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _voteForSpecificTournament(tournament.id),
                              icon: const Icon(Icons.how_to_vote),
                              label: Text(AppLocalizations.of(context)!.vote),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showTournamentLeaderboard(tournament.id),
                              icon: const Icon(Icons.leaderboard),
                              label: Text(AppLocalizations.of(context)!.leaderboard),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Turnuva görüntüleme butonu (katılımcılar için)
                    if (isJoined) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showTournamentParticipants(tournament.id),
                          icon: const Icon(Icons.visibility),
                          label: Text(AppLocalizations.of(context)!.viewTournament),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Ana turnuva butonunu oluştur
  Widget _buildMainTournamentButton(TournamentModel tournament, bool isJoined) {
    if (isJoined) {
      // Kullanıcı zaten katılmış
      return ElevatedButton(
        onPressed: null, // Buton devre dışı
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.grey[600],
        ),
        child: Text(AppLocalizations.of(context)!.alreadyJoinedTournament),
      );
    } else if (tournament.status == 'completed') {
      // Turnuva tamamlanmış
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.grey[600],
        ),
        child: Text(AppLocalizations.of(context)!.completed),
      );
    } else if (tournament.currentParticipants >= tournament.maxParticipants) {
      // Turnuva dolu
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[300],
          foregroundColor: Colors.red[700],
        ),
        child: Text(AppLocalizations.of(context)!.tournamentFull),
      );
    } else if (tournament.status == 'active') {
      // Turnuva aktif ama kullanıcı katılmamış
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[300],
          foregroundColor: Colors.orange[700],
        ),
        child: Text(AppLocalizations.of(context)!.tournamentStarted),
      );
    } else if (!_canUserJoinTournament(tournament)) {
      // Cinsiyet uyumsuzluğu
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink[300],
          foregroundColor: Colors.pink[700],
        ),
        child: Text(AppLocalizations.of(context)!.genderMismatch),
      );
    } else {
      // Katılım mümkün
      return ElevatedButton(
        onPressed: () => _joinTournament(tournament),
        child: Text(AppLocalizations.of(context)!.join),
      );
    }
  }

  // Kullanıcının turnuvaya katılıp katılamayacağını kontrol et
  bool _canUserJoinTournament(TournamentModel tournament) {
    if (currentUser == null) return false;
    
    // Debug: Cinsiyet bilgilerini yazdır
    print('🔍 GENDER CHECK:');
    print('  User genderCode: ${currentUser!.genderCode}');
    print('  Tournament gender: ${tournament.gender}');
    print('  Tournament name: ${tournament.name}');
    
    // Cinsiyet kontrolü - M/F ile Erkek/Kadın karşılaştırması
    if (tournament.gender != 'all') {
      if (currentUser!.genderCode == null) {
        print('❌ GENDER MISMATCH: User gender is null, cannot join ${tournament.gender} tournament');
        return false;
      }
      
      // M/F ile Erkek/Kadın karşılaştırması
      bool canJoin = false;
      if (currentUser!.genderCode == 'M' && tournament.gender == 'Erkek') {
        canJoin = true;
      } else if (currentUser!.genderCode == 'F' && tournament.gender == 'Kadın') {
        canJoin = true;
      }
      
      print('  Gender comparison: User ${currentUser!.genderCode} vs Tournament ${tournament.gender} = $canJoin');
      
      if (!canJoin) {
        print('❌ GENDER MISMATCH: User ${currentUser!.genderCode} cannot join ${tournament.gender} tournament');
        return false;
      }
    }
    
    print('✅ GENDER CHECK PASSED');
    return true;
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

  Widget _buildGenderChip(String gender) {
    Color chipColor;
    Color textColor;
    IconData icon;
    
    if (gender == 'Erkek') {
      chipColor = Colors.blue[100]!;
      textColor = Colors.blue[800]!;
      icon = Icons.male;
    } else if (gender == 'Kadın') {
      chipColor = Colors.pink[100]!;
      textColor = Colors.pink[800]!;
      icon = Icons.female;
    } else {
      chipColor = Colors.grey[200]!;
      textColor = Colors.grey[700]!;
      icon = Icons.people;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            gender,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
          title: const Row(
            children: [
              Icon(Icons.add_circle, color: Colors.purple),
              SizedBox(width: 8),
              Text('Private Turnuva Oluştur'),
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
                  decoration: const InputDecoration(
                    labelText: 'Turnuva Adı',
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
                          labelText: 'Max Katılımcı',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.people),
                          suffixIcon: selectedFormat == 'elimination' 
                            ? const Tooltip(
                                message: 'Eleme usulü için maksimum 8 kişi',
                                child: Icon(Icons.warning, color: Colors.orange, size: 16),
                              )
                            : null,
                        ),
                        onChanged: (value) {
                          // Eleme usulü için maksimum 8 kişi kontrolü
                          if (selectedFormat == 'elimination' && int.tryParse(value) != null && int.parse(value) > 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Eleme usulü için maksimum 8 kişi olabilir'),
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
                        decoration: const InputDecoration(
                          labelText: 'Turnuva Formatı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sports_esports),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'league', child: Text('Lig Usulü')),
                          DropdownMenuItem(value: 'elimination', child: Text('Eleme Usulü')),
                          DropdownMenuItem(value: 'hybrid', child: Text('Lig + Eleme')),
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

  // Turnuva katılımcılarını göster
  Future<void> _showTournamentParticipants(String tournamentId) async {
    try {
      final participants = await TournamentService.getTournamentParticipants(tournamentId);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.tournamentParticipants),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
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
                  subtitle: Text('${user['coins'] ?? 0} coin'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (participant['tournament_photo_url'] != null) ...[
                        IconButton(
                          onPressed: () => _showParticipantPhoto(participant['tournament_photo_url']),
                          icon: const Icon(Icons.photo, color: Colors.blue),
                          tooltip: AppLocalizations.of(context)!.viewParticipantPhoto,
                        ),
                        const Icon(Icons.check_circle, color: Colors.green),
                      ] else
                        const Icon(Icons.pending, color: Colors.orange),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Katılımcılar yüklenirken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Katılımcı fotoğrafını göster
  void _showParticipantPhoto(String photoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(AppLocalizations.of(context)!.viewParticipantPhoto),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, size: 100, color: Colors.red),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (participant['tournament_photo_url'] != null) ...[
                        IconButton(
                          onPressed: () => _showParticipantPhoto(participant['tournament_photo_url']),
                          icon: const Icon(Icons.photo, color: Colors.blue),
                          tooltip: AppLocalizations.of(context)!.viewParticipantPhoto,
                        ),
                      ],
                      participant['is_eliminated'] 
                          ? const Icon(Icons.close, color: Colors.red)
                          : const Icon(Icons.check, color: Colors.green),
                    ],
                  ),
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
