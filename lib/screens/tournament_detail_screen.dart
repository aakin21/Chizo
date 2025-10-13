import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chizo/models/tournament_model.dart';
import 'package:chizo/services/tournament_service.dart';
import 'package:chizo/services/user_service.dart';
import 'package:chizo/models/user_model.dart';
import 'package:chizo/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class TournamentDetailScreen extends StatefulWidget {
  final TournamentModel tournament;

  const TournamentDetailScreen({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  UserModel? currentUser;
  bool isLoading = true;
  List<Map<String, dynamic>>? tournamentMatches;
  bool hasMatches = false;
  int currentParticipantCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      currentUser = await UserService.getCurrentUser();
      
      // Kullanıcının katılım durumunu kontrol et
      if (currentUser != null) {
        widget.tournament.isUserParticipating = await _checkUserParticipation(widget.tournament.id);
      }
      
      // Katılımcı sayısını güncelle
      currentParticipantCount = await _getParticipantCount(widget.tournament.id);
      
      // Eğer turnuva aktifse match'leri yükle
      if (widget.tournament.status == 'active') {
        if (widget.tournament.isPrivate) {
          tournamentMatches = await TournamentService.getPrivateTournamentMatchesForVoting(widget.tournament.id);
        } else {
          // Normal turnuvalar için match yükleme (şimdilik boş)
          tournamentMatches = [];
        }
        hasMatches = tournamentMatches != null && tournamentMatches!.isNotEmpty;
      }
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Kullanıcının turnuvaya katılıp katılmadığını kontrol et
  Future<bool> _checkUserParticipation(String tournamentId) async {
    try {
      if (currentUser == null) return false;
      
      final participation = await TournamentService.client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', currentUser!.id)
          .maybeSingle();
      
      return participation != null;
    } catch (e) {
      return false;
    }
  }

  // Turnuvadaki katılımcı sayısını al
  Future<int> _getParticipantCount(String tournamentId) async {
    try {
      final response = await TournamentService.client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId);
      
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  // Kullanıcının turnuva admini olup olmadığını kontrol et
  bool _isCurrentUserAdmin() {
    if (currentUser == null) return false;
    return widget.tournament.creatorId == currentUser!.id;
  }

  // Katılımcıyı turnuvadan at
  Future<void> _kickParticipant(Map<String, dynamic> participant) async {
    final participantName = participant['user']?['username'] ?? 'Bilinmeyen';
    
    // Onay dialog'u göster
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Katılımcıyı At',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '$participantName kullanıcısını turnuvadan atmak istediğinizden emin misiniz?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'İptal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'At',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // TournamentService'de kick fonksiyonu var mı kontrol et
      final success = await TournamentService.kickParticipant(
        widget.tournament.id,
        participant['user']['id'],
      );

      if (success) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$participantName turnuvadan atıldı'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Verileri yenile
        await _loadData();
      } else {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Katılımcı atma işlemi başarısız'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.purple),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.tournament.getLocalizedName(AppLocalizations.of(context)!),
          style: const TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Üst kısımda küçük ikonlar
          if (widget.tournament.status == 'active') ...[
            IconButton(
              icon: const Icon(Icons.leaderboard, color: Colors.blue),
              onPressed: () => _showLeaderboard(),
            ),
          ],
            // Private turnuva admin'i için tarih değiştirme butonu
          if (widget.tournament.isPrivate && 
              currentUser?.id == widget.tournament.creatorId &&
              widget.tournament.status == 'upcoming') ...[
            IconButton(
              icon: const Icon(Icons.schedule, color: Colors.blue),
              onPressed: () => _showUpdateDatesDialog(),
            ),
          ],
          // Private turnuva admin'i için silme butonu
          if (widget.tournament.isPrivate && 
              currentUser?.id == widget.tournament.creatorId &&
              (widget.tournament.status == 'upcoming' || widget.tournament.status == 'active')) ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTournament(),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.info, color: Colors.orange),
            onPressed: () => _showTournamentInfo(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Eğer turnuva aktifse ve match varsa direkt oylama göster
    if (widget.tournament.status == 'active' && hasMatches) {
      return _buildVotingInterface();
    }
    
    // Eğer turnuva aktifse ama match yoksa
    if (widget.tournament.status == 'active' && !hasMatches) {
      return _buildNoMatchesMessage();
    }
    
    // Registration aşamasındaki turnuvalar için büyük seçenekler
    return _buildRegistrationOptions();
  }

  Widget _buildVotingInterface() {
    return Column(
      children: [
        // Üst bilgi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                widget.tournament.isPrivate 
                    ? 'Private Turnuva Oylaması' 
                    : 'Turnuva Oylaması',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Hangi fotoğrafı tercih ediyorsunuz?',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        
        // Oylama alanı
        Expanded(
          child: _buildVotingArea(),
        ),
      ],
    );
  }

  Widget _buildVotingArea() {
    if (widget.tournament.isPrivate) {
      return _buildPrivateTournamentVoting();
    } else {
      return _buildNormalTournamentVoting();
    }
  }

  Widget _buildPrivateTournamentVoting() {
    int currentMatchIndex = 0;
    String? selectedWinner;
    int totalMatches = tournamentMatches?.length ?? 0;

    return StatefulBuilder(
      builder: (context, setState) {
        if (currentMatchIndex >= totalMatches) {
          return _buildNoMatchesMessage();
        }

        final currentMatch = tournamentMatches![currentMatchIndex];
        final user1 = currentMatch['user1'];
        final user2 = currentMatch['user2'];

        return Column(
          children: [
            // Ana oylama alanı - Alt-üst tasarım
            Expanded(
              child: Column(
                children: [
                  // Üst fotoğraf - User 1
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedWinner = user1['id'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedWinner == user1['id'] ? Colors.purple : Colors.transparent,
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              // Fotoğraf
                              SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: user1['tournament_photo_url'] != null
                                    ? Image.network(
                                        user1['tournament_photo_url'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[800],
                                            child: const Center(
                                              child: Icon(Icons.person, size: 80, color: Colors.white),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: Icon(Icons.person, size: 80, color: Colors.white),
                                        ),
                                      ),
                              ),
                              
                              // Seçim göstergesi
                              if (selectedWinner == user1['id'])
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.3),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.purple,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              
                              // Kullanıcı adı
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    user1['username'] ?? 'Bilinmeyen',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // VS sembolü - Güzel ikon
                  SizedBox(
                    height: 60,
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.purple,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.swap_horiz,
                            color: Colors.purple,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Alt fotoğraf - User 2
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedWinner = user2['id'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedWinner == user2['id'] ? Colors.purple : Colors.transparent,
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              // Fotoğraf
                              SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: user2['tournament_photo_url'] != null
                                    ? Image.network(
                                        user2['tournament_photo_url'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[800],
                                            child: const Center(
                                              child: Icon(Icons.person, size: 80, color: Colors.white),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: Icon(Icons.person, size: 80, color: Colors.white),
                                        ),
                                      ),
                              ),
                              
                              // Seçim göstergesi
                              if (selectedWinner == user2['id'])
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.3),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.purple,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              
                              // Kullanıcı adı
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    user2['username'] ?? 'Bilinmeyen',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Alt butonlar
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedWinner != null 
                          ? () async {
                              await _submitPrivateTournamentVote(currentMatch, selectedWinner!);
                              setState(() {
                                currentMatchIndex++;
                                selectedWinner = null;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedWinner != null ? Colors.purple : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(currentMatchIndex == totalMatches - 1 ? 'Bitir' : 'Devam'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNormalTournamentVoting() {
    return const Center(
      child: Text(
        'Normal turnuva oylaması buraya gelecek',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // Private turnuva oy verme
  Future<void> _submitPrivateTournamentVote(Map<String, dynamic> match, String winnerId) async {
    try {
      final user1 = match['user1'];
      final user2 = match['user2'];
      
      final loserId = winnerId == user1['id'] ? user2['id'] : user1['id'];
      
      await TournamentService.voteForPrivateTournamentMatch(
        widget.tournament.id,
        winnerId,
        loserId,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oyunuz kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oylama hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNoMatchesMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            'Oylanacak Match Kalmadı',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tüm match\'leri oyladınız!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _showLeaderboard(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35), // Turuncu arka plan
              foregroundColor: Colors.white, // Beyaz yazı
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Liderlik Tablosunu Gör'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationOptions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Turnuva bilgileri ve Key
            Row(
              children: [
                // Ana turnuva bilgi kartı
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.tournament.getLocalizedName(AppLocalizations.of(context)!),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                        '$currentParticipantCount/${widget.tournament.maxParticipants} katılımcı',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        if (!widget.tournament.isPrivate) ...[
                          const SizedBox(height: 5),
                          Text(
                            'Giriş: ${widget.tournament.entryFee} coin',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            'Ödül: ${widget.tournament.prizePool} coin',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Key kutusu - sadece private turnuva ve başlamadan önce
                if (widget.tournament.isPrivate && 
                    widget.tournament.privateKey != null && 
                    widget.tournament.status != 'active' && 
                    widget.tournament.status != 'completed') ...[
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Key',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              // Key'i kopyala
                              Clipboard.setData(ClipboardData(text: widget.tournament.privateKey!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Key kopyalandı!'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(
                                  widget.tournament.privateKey!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                const Icon(
                                  Icons.copy,
                                  color: Colors.purple,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Büyük seçenekler
            _buildBigOption(
              icon: Icons.people,
              title: 'Katılımcılar',
              subtitle: 'Turnuva katılımcılarını gör',
              color: Colors.blue,
              onTap: () => _showParticipants(),
            ),
            
            const SizedBox(height: 20),
            
            _buildBigOption(
              icon: Icons.rule,
              title: 'Turnuva Kuralları',
              subtitle: 'Kuralları ve detayları gör',
              color: Colors.orange,
              onTap: () => _showRules(),
            ),
            
            const SizedBox(height: 20),
            
            // Admin için tarih değiştirme seçeneği
            if (widget.tournament.isPrivate && 
                currentUser?.id == widget.tournament.creatorId &&
                widget.tournament.status == 'upcoming') ...[
              _buildBigOption(
                icon: Icons.schedule,
                title: 'Tarihleri Güncelle',
                subtitle: 'Turnuva başlangıç ve bitiş tarihlerini değiştir',
                color: Colors.blue,
                onTap: () => _showUpdateDatesDialog(),
              ),
              const SizedBox(height: 20),
            ],
            
            if (widget.tournament.isUserParticipating) ...[
              _buildBigOption(
                icon: Icons.exit_to_app,
                title: 'Turnuvadan Ayrıl',
                subtitle: 'Turnuvadan çık',
                color: Colors.red,
                onTap: () => _leaveTournament(),
              ),
            ] else if (widget.tournament.status == 'upcoming') ...[
              _buildBigOption(
                icon: Icons.login,
                title: 'Turnuvaya Katıl',
                subtitle: 'Turnuvaya katıl',
                color: Colors.green,
                onTap: () => _joinTournament(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBigOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withValues(alpha: 0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Fonksiyonlar
  void _showLeaderboard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Liderlik Tablosu',
          style: TextStyle(color: Color(0xFFFF6B35)), // Turuncu başlık rengi
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: widget.tournament.isPrivate 
                ? TournamentService.getPrivateTournamentLeaderboard(widget.tournament.id)
                : TournamentService.getTournamentLeaderboard(widget.tournament.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B35)), // Turuncu loading indicator
                );
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Hata: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              final leaderboard = snapshot.data ?? [];
              
              if (leaderboard.isEmpty) {
                return const Center(
                  child: Text(
                    'Henüz oylama yapılmamış',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final participant = leaderboard[index];
                  final rank = index + 1;
                  
                  // Private turnuvalar için wins_count, normal turnuvalar için score kullan
                  final score = widget.tournament.isPrivate 
                      ? participant['wins_count'] ?? 0
                      : participant['score'] ?? 0;
                  
                  // Kullanıcı adını doğru yerden al
                  final username = participant['profiles']?['username'] ?? 'Bilinmeyen';
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: rank <= 3 
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFF6B35).withValues(alpha: 0.1), // Hafif turuncu
                                const Color(0xFFFF8C42).withValues(alpha: 0.05), // Daha hafif turuncu
                              ],
                            )
                          : null,
                      color: rank > 3 ? Colors.grey[800] : null,
                      borderRadius: BorderRadius.circular(8),
                      border: rank <= 3 ? Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.3)) : null,
                    ),
                    child: Row(
                      children: [
                        // Sıralama
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: rank <= 3 
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFFF6B35), // Ana turuncu
                                      const Color(0xFFFF8C42), // Açık turuncu
                                    ],
                                  )
                                : null,
                            color: rank > 3 ? Colors.grey[600] : null,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Kullanıcı adı
                        Expanded(
                          child: Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Puan
                        Text(
                          widget.tournament.isPrivate 
                              ? '$score galibiyet'
                              : '$score puan',
                          style: TextStyle(
                            color: rank <= 3 ? const Color(0xFFFF6B35) : Colors.white70, // Turuncu puan rengi
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B35), // Turuncu yazı rengi
            ),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }


  void _showTournamentInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          widget.tournament.getLocalizedName(AppLocalizations.of(context)!),
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Durum', _getStatusText(widget.tournament.status)),
              _buildInfoRow('Tür', widget.tournament.isPrivate ? 'Özel' : 'Genel'),
              _buildInfoRow('Katılımcılar', '$currentParticipantCount/${widget.tournament.maxParticipants}'),
              if (!widget.tournament.isPrivate) ...[
                _buildInfoRow('Giriş Ücreti', '${widget.tournament.entryFee} coin'),
                _buildInfoRow('Ödül Havuzu', '${widget.tournament.prizePool} coin'),
              ],
              _buildInfoRow('Oluşturulma', _formatDate(widget.tournament.createdAt)),
              
              // 5000 coinlik turnuvalar için özel açıklama
              if (widget.tournament.entryFee == 5000) ...[
                _buildInfoRow('Başlangıç', '100 kişi dolduğunda başlar'),
                _buildInfoRow('Bitiş', '6 gün sürer (3 lig + 3 eleme)'),
                _buildInfoRow('Sayaç', '100 kişi dolduğunda 1 saat sayacı'),
              ] else ...[
                _buildInfoRow('Başlangıç', _formatDate(widget.tournament.startDate)),
                _buildInfoRow('Bitiş', _formatDate(widget.tournament.endDate)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Kapat',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }

  void _showParticipants() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Katılımcılar',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: TournamentService.getTournamentParticipants(widget.tournament.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.purple),
                );
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Hata: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              final participants = snapshot.data ?? [];
              
              if (participants.isEmpty) {
                return const Center(
                  child: Text(
                    'Henüz katılımcı yok',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Avatar - Turnuva fotoğrafını öncelikle göster
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.purple.withValues(alpha: 0.2),
                          child: (participant['tournament_photo_url'] != null)
                              ? ClipOval(
                                  child: Image.network(
                                    participant['tournament_photo_url'],
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Turnuva fotoğrafı yüklenemezse profil fotoğrafını göster
                                      return participant['user']?['profile_image_url'] != null
                                          ? ClipOval(
                                              child: Image.network(
                                                participant['user']['profile_image_url'],
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(Icons.person, color: Colors.white);
                                                },
                                              ),
                                            )
                                          : const Icon(Icons.person, color: Colors.white);
                                    },
                                  ),
                                )
                              : (participant['user']?['profile_image_url'] != null
                                  ? ClipOval(
                                      child: Image.network(
                                        participant['user']['profile_image_url'],
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.person, color: Colors.white);
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.person, color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        // Kullanıcı adı ve admin etiketi
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                participant['user']?['username'] ?? 'Bilinmeyen',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              // Admin etiketi
                              if (participant['user']?['id'] == widget.tournament.creatorId) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Katılım tarihi
                        Text(
                          _formatDateString(participant['joined_at']),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        // Admin ise atma butonu
                        if (_isCurrentUserAdmin() && participant['user']?['id'] != currentUser?.id) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _kickParticipant(participant),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.person_remove,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Kapat',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }

  void _showRules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Turnuva Kuralları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Genel Kurallar:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '• Her katılımcı sadece bir fotoğraf yükleyebilir\n'
                '• Fotoğraflar uygunsuz içerik içermemelidir\n'
                '• Oylama adil ve tarafsız yapılmalıdır\n'
                '• Turnuva kurallarına uymayan katılımcılar diskalifiye edilir',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              if (widget.tournament.isPrivate) ...[
                const Text(
                  'Özel Turnuva Kuralları:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '• Sadece davet edilen kullanıcılar katılabilir\n'
                  '• Turnuva oluşturucusu turnuvayı yönetebilir\n'
                  '• Özel turnuvalarda giriş ücreti yoktur',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ] else ...[
                const Text(
                  'Genel Turnuva Kuralları:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '• Giriş ücreti: ${widget.tournament.entryFee} coin\n'
                  '• Ödül havuzu: ${widget.tournament.prizePool} coin\n'
                  '• Kazanan tüm ödülü alır\n'
                  '• Giriş ücreti iade edilmez',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Kapat',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTournament() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Turnuvayı Sil',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Bu turnuvayı kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDeleteTournament();
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _leaveTournament() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Turnuvadan Ayrıl',
          style: TextStyle(color: Colors.orange),
        ),
        content: const Text(
          'Bu turnuvadan ayrılmak istediğinizden emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLeaveTournament();
            },
            child: const Text(
              'Ayrıl',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _joinTournament() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce giriş yapmalısınız!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.tournament.isUserParticipating) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zaten bu turnuvaya katılıyorsunuz!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (currentParticipantCount >= widget.tournament.maxParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turnuva dolu!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Fotoğraf yükleme popup'ı göster
    _showPhotoUploadDialog();
  }

  void _showPhotoUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Turnuva Fotoğrafı Yükle',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_camera,
              color: Colors.purple,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Turnuvaya katılmak için bir fotoğraf yüklemeniz gerekiyor.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu fotoğraf turnuva match\'lerinde ve liderlik tablosunda görünecek.',
              style: TextStyle(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _pickAndUploadPhoto();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Fotoğraf Seç'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image == null) {
        // Kullanıcı fotoğraf seçmedi
        return;
      }
      
      // Loading dialog göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          backgroundColor: Colors.grey,
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.purple),
              SizedBox(width: 16),
              Text(
                'Fotoğraf yükleniyor...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
      
      // Fotoğrafı yükle ve turnuvaya katıl
      final success = await _uploadPhotoAndJoinTournament(image);
      
      // Loading dialog'u kapat
      if (mounted) Navigator.pop(context);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Turnuvaya başarıyla katıldınız!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Verileri yenile
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotoğraf yükleme başarısız!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
    } catch (e) {
      // Loading dialog'u kapat
      if (mounted) Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf yükleme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _uploadPhotoAndJoinTournament(XFile imageFile) async {
    try {
      print('🎯 DEBUG: Starting photo upload and join process');
      
      // Önce turnuvaya katıl (fotoğraf olmadan)
      print('🎯 DEBUG: Joining tournament...');
      final joinSuccess = await TournamentService.joinTournament(widget.tournament.id);
      print('🎯 DEBUG: Join result: $joinSuccess');
      
      if (!joinSuccess) {
        print('❌ DEBUG: Failed to join tournament');
        return false;
      }
      
      // Fotoğrafı base64'e çevir (geçici çözüm)
      print('🎯 DEBUG: Converting photo to base64...');
      final bytes = await imageFile.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      print('🎯 DEBUG: Base64 length: ${base64Image.length}');
      
      // TournamentService'deki uploadTournamentPhoto fonksiyonunu kullan
      print('🎯 DEBUG: Uploading photo to tournament...');
      final uploadSuccess = await TournamentService.uploadTournamentPhoto(
        widget.tournament.id,
        base64Image,
      );
      print('🎯 DEBUG: Upload result: $uploadSuccess');
      
      if (uploadSuccess) {
        print('✅ DEBUG: Photo upload successful, refreshing data...');
        // Verileri yenile
        await _loadData();
        return true;
      } else {
        print('❌ DEBUG: Photo upload failed');
        return false;
      }
    } catch (e) {
      print('❌ DEBUG: Error uploading photo and joining tournament: $e');
      return false;
    }
  }

  // Yardımcı fonksiyonlar
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
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Yaklaşan';
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return 'Bilinmeyen';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return _formatDate(date);
    } catch (e) {
      return 'Tarih bilinmiyor';
    }
  }


  Future<void> _performDeleteTournament() async {
    try {
      await TournamentService.deletePrivateTournament(widget.tournament.id);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turnuva silindi!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Geri dön ve turnuva listesini yenile
      Navigator.pop(context, true); // true değeri ile turnuva silindiğini belirt
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _performLeaveTournament() async {
    try {
      await TournamentService.leaveTournament(widget.tournament.id);
      await _loadData(); // Verileri yenile
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turnuvadan ayrıldınız!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ayrılma hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Tarih değiştirme dialog'u
  void _showUpdateDatesDialog() {
    DateTime selectedStartDate = widget.tournament.startDate;
    DateTime selectedEndDate = widget.tournament.endDate;
    TimeOfDay selectedStartTime = TimeOfDay.fromDateTime(widget.tournament.startDate);
    TimeOfDay selectedEndTime = TimeOfDay.fromDateTime(widget.tournament.endDate);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Turnuva Tarihlerini Güncelle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mevcut tarihler bilgisi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mevcut Tarihler:',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Başlangıç: ${_formatDate(widget.tournament.startDate)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        'Bitiş: ${_formatDate(widget.tournament.endDate)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Başlangıç tarihi seçimi
                _buildDateSelector(
                  title: 'Başlangıç Tarihi',
                  selectedDate: selectedStartDate,
                  selectedTime: selectedStartTime,
                  onDateChanged: (date) {
                    setDialogState(() {
                      selectedStartDate = date;
                    });
                  },
                  onTimeChanged: (time) {
                    setDialogState(() {
                      selectedStartTime = time;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Bitiş tarihi seçimi
                _buildDateSelector(
                  title: 'Bitiş Tarihi',
                  selectedDate: selectedEndDate,
                  selectedTime: selectedEndTime,
                  onDateChanged: (date) {
                    setDialogState(() {
                      selectedEndDate = date;
                    });
                  },
                  onTimeChanged: (time) {
                    setDialogState(() {
                      selectedEndTime = time;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Uyarı mesajı
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tarih değişikliği sadece turnuva başlamadan önce yapılabilir.',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Tarih ve saati birleştir
                final finalStartDate = DateTime(
                  selectedStartDate.year,
                  selectedStartDate.month,
                  selectedStartDate.day,
                  selectedStartTime.hour,
                  selectedStartTime.minute,
                );
                final finalEndDate = DateTime(
                  selectedEndDate.year,
                  selectedEndDate.month,
                  selectedEndDate.day,
                  selectedEndTime.hour,
                  selectedEndTime.minute,
                );

                Navigator.pop(context);
                await _updateTournamentDates(finalStartDate, finalEndDate);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  // Tarih seçici widget'ı
  Widget _buildDateSelector({
    required String title,
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    required Function(DateTime) onDateChanged,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Tarih seçici
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                            surface: Colors.grey,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    onDateChanged(date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[600]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Saat seçici
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                            surface: Colors.grey,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    onTimeChanged(time);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[600]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tarih güncelleme işlemi
  Future<void> _updateTournamentDates(DateTime newStartDate, DateTime newEndDate) async {
    try {
      // Loading dialog göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          backgroundColor: Colors.grey,
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.blue),
              SizedBox(width: 16),
              Text(
                'Tarihler güncelleniyor...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      final result = await TournamentService.updatePrivateTournamentDates(
        tournamentId: widget.tournament.id,
        newStartDate: newStartDate,
        newEndDate: newEndDate,
      );

      // Loading dialog'u kapat
      if (mounted) Navigator.pop(context);

      if (result['success']) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Verileri yenile
        await _loadData();
      } else {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Loading dialog'u kapat
      if (mounted) Navigator.pop(context);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarih güncelleme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
