import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';
import '../models/match_model.dart';
import '../models/user_model.dart';
import '../services/match_service.dart';
import '../services/user_service.dart';
import '../services/prediction_service.dart';
import '../services/photo_upload_service.dart';
import '../l10n/app_localizations.dart';
import '../services/tournament_service.dart';
import '../services/report_service.dart';
import '../services/global_theme_service.dart';
import '../widgets/vs_image_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class VotingTab extends StatefulWidget {
  final VoidCallback? onVoteCompleted;
  
  const VotingTab({super.key, this.onVoteCompleted});

  @override
  State<VotingTab> createState() => _VotingTabState();
}

class _VotingTabState extends State<VotingTab> with WidgetsBindingObserver {
  List<MatchModel> matches = [];
  List<Map<String, dynamic>> votableItems = []; // Normal match'ler + turnuva match'leri
  bool isLoading = true;
  int currentMatchIndex = 0;
  bool showPredictionSlider = false;
  UserModel? selectedWinner;
  UserModel? selectedUserForPrediction; // Prediciton için seçilen kullanıcı
  UserModel? previewUser; // Sadece önizleme için seçilen kullanıcı
  bool showSinglePhotoPreview = false; // Tek fotoğraf preview durumu
  double sliderValue = 50.0;
  double _tempSliderValue = 50.0; // Slider kaydırma için local variable
  // bool _sliderIsDragging = false; // Drag durumunu track et - DRAFT USAGE
  bool isCurrentTournamentMatch = false; // Mevcut oylama turnuva oylaması mı?
  DateTime? lastTapTime; // Son tık zamanını takip et
  bool _isSliderDragging = false; // Tutulma durumu
  int selectedPhotoOrder = 1; // Seçilen fotoğrafın sırası
  String _currentTheme = 'Beyaz'; // Mevcut theme'i takip et

  // Yüzdeye göre renk hesaplama - Advanced Spectrum Transparent->Solid
  Color _getSliderColorFromPercentage(double percentage) {
    // Glacial interpolasyon coefficients  
    final t = percentage / 100.0; // normalized 0..1
    
    // RGB lerp intermediate calculations 
    Color baseColor;
    if (t <= 0.33) {
      // %0-%33: Yeşil -> Sarı
      final factor = t / 0.33; 
      baseColor = Color.fromRGBO(255, (factor * 255 + (1-factor) * 34).round(), 0, 1.0);
    } else if (t <= 0.66) {  
      // %33-%66: Sarı -> Turuncu
      final factor = (t - 0.33) / 0.33;
      baseColor = Color.fromRGBO(255, (255 - factor * 90).round(), 0, 1.0); 
    } else { 
      // %66-%100: Turuncu -> Kırmızı
      final factor = (t - 0.66) / 0.34; 
      baseColor = Color.fromRGBO(255, (165 - factor * 165).round(), 0, 1.0);
    }
    
    // Dragging durumuna göre transparency
    final alpha = _isSliderDragging ? 0.85 : 0.35; 
    return baseColor.withValues(alpha: alpha);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentTheme();
    loadMatches();
    
    // Global theme service'e callback kaydet
    GlobalThemeService().setThemeChangeCallback((theme) {
      if (mounted) {
        setState(() {
          _currentTheme = theme;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Callback'i temizle
    GlobalThemeService().clearAllCallbacks();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Theme değişikliklerini dinle
    if (state == AppLifecycleState.resumed) {
      _loadCurrentTheme();
    }
  }

  Future<void> _loadCurrentTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString('selected_theme') ?? 'Beyaz';
      
      if (theme != _currentTheme && mounted) {
        setState(() {
          _currentTheme = theme;
        });
      }
    } catch (e) {
      print('Error in _loadMatches: $e');
    }
  }

  Future<void> loadMatches() async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    try {
      // Yeni random match oluştur
      await MatchService.generateRandomMatches(matchCount: 1);
      
      // Oluşturulan match'leri yükle (otomatik temizlik dahil)
      final votableMatches = await MatchService.getVotableMatches();
      
      // Turnuva entegrasyonu için votableItems oluştur
      final items = <Map<String, dynamic>>[];
      for (var match in votableMatches) {
        items.add({
          'match': match,
          'is_tournament': false,
        });
      }
      
      // Her 4 oylamadan 1'ini turnuva oylaması yap
      if (items.length >= 4) {
        final tournamentMatches = await TournamentService.getTournamentMatchesForVoting();
        if (tournamentMatches.isNotEmpty) {
          // Random pozisyonda turnuva match'i ekle
          final insertIndex = Random().nextInt(items.length);
          final tournamentMatch = tournamentMatches.first;
          items.insert(insertIndex, {
            'tournament_match': tournamentMatch,
            'is_tournament': true,
          });
        }
      }
    
      if (mounted) {
        setState(() {
          matches = votableMatches;
          votableItems = items;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  Future<void> _voteForUser(String winnerId) async {
    if (currentMatchIndex >= votableItems.length) return;

    final currentItem = votableItems[currentMatchIndex];
    final isTournament = currentItem['is_tournament'] as bool;
    
    if (isTournament) {
      // Turnuva oylaması
      final tournamentMatch = currentItem['tournament_match'] as Map<String, dynamic>;
      final user1 = tournamentMatch['user1'];
      final user2 = tournamentMatch['user2'];
      final loserId = winnerId == user1['id'] ? user2['id'] : user1['id'];
      
      final success = await TournamentService.voteForTournamentMatch(
        tournamentMatch['tournament_id'],
        winnerId,
        loserId,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.tournamentVotingSaved),
            backgroundColor: Colors.purple,
          ),
        );
        _nextMatch();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.tournamentVotingFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

      // Seçilen kullanıcının fotoğraf sırasını kaydet
    final selectedUser = await _getWinnerUser(winnerId);
    if (selectedUser != null && selectedUser.matchPhotos != null && selectedUser.matchPhotos!.isNotEmpty) {
      // İlk fotoğrafı seç (photo_order = 1)
      final sortedPhotos = List<Map<String, dynamic>>.from(selectedUser.matchPhotos!);
      sortedPhotos.sort((a, b) {
        final orderA = a['photo_order'] as int? ?? 0;
        final orderB = b['photo_order'] as int? ?? 0;
        return orderA.compareTo(orderB);
      });
      
      // Seçilen fotoğrafın sırasını kaydet
      selectedPhotoOrder = sortedPhotos.first['photo_order'] as int? ?? 1;
    }

    // Tek tık - direkt oy verme + slider
    await _performActualVote(winnerId, currentItem);
  }

  Future<void> _showSinglePhotoPreview(String userId) async {
    final selectedUser = await _getWinnerUser(userId);
    if (selectedUser != null && mounted) {
      setState(() {
        previewUser = selectedUser;
        showSinglePhotoPreview = true;
      });
    }
  }

  Future<void> _performActualVote(String winnerId, Map<String, dynamic> currentItem) async {
    final match = currentItem['match'] as MatchModel;
    final success = await MatchService.voteForMatch(match.id, winnerId);
    
    if (success) {
      // Update photo statistics for both users
      await _updatePhotoStatsForMatch(match, winnerId);
      
      // Kazanan kullanıcıyı bul ve slider'ı göster
      final winner = await _getWinnerUser(winnerId);
      if (winner != null && mounted) {
        setState(() {
          selectedWinner = winner;
          selectedUserForPrediction = null;
          previewUser = null;
          showSinglePhotoPreview = false;
          showPredictionSlider = true;
          sliderValue = 50.0;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.votingError(''))),
      );
    }
  }

  Future<UserModel?> _getWinnerUser(String winnerId) async {
    try {
      // Match'teki kullanıcıları getir
      final currentItem = votableItems[currentMatchIndex];
      final isTournament = currentItem['is_tournament'] as bool;
      
      if (isTournament) {
        // Turnuva match'i için kullanıcıları getir
        final tournamentMatch = currentItem['tournament_match'] as Map<String, dynamic>;
        final user1Data = tournamentMatch['user1'] as Map<String, dynamic>;
        final user2Data = tournamentMatch['user2'] as Map<String, dynamic>;
        
        // UserModel oluştur
        final user1 = UserModel.fromJson(user1Data);
        final user2 = UserModel.fromJson(user2Data);
        
        return winnerId == user1.id ? user1 : user2;
      } else {
        // Normal match için
        final match = currentItem['match'] as MatchModel;
        final users = await _getMatchUsers(match);
        return users.firstWhere((user) => user.id == winnerId);
      }
    } catch (e) {
      // // print('Error getting winner user: $e');
      return null;
    }
  }

  Future<void> _submitPrediction() async {
    final targetUser = selectedUserForPrediction ?? selectedWinner;
    if (targetUser == null) return;

    // Final değer al ve commit
    final finalValue = _tempSliderValue;
    setState(() {
      sliderValue = _tempSliderValue;
    });
    
    // Kullanıcının seçtiği hassas değeri %10'luk aralığa dönüştür
    int minRange, maxRange;
    if (finalValue <= 10) {
      minRange = 0; maxRange = 10;
    } else if (finalValue <= 20) {
      minRange = 11; maxRange = 20;
    } else if (finalValue <= 30) {
      minRange = 21; maxRange = 30;
    } else if (finalValue <= 40) {
      minRange = 31; maxRange = 40;
    } else if (finalValue <= 50) {
      minRange = 41; maxRange = 50;
    } else if (finalValue <= 60) {
      minRange = 51; maxRange = 60;
    } else if (finalValue <= 70) {
      minRange = 61; maxRange = 70;
    } else if (finalValue <= 80) {
      minRange = 71; maxRange = 80;
    } else if (finalValue <= 90) {
      minRange = 81; maxRange = 90;
    } else {
      minRange = 91; maxRange = 100;
    }

    try {
      final result = await PredictionService.submitPrediction(
        winnerId: targetUser.id,
        minRange: minRange,
        maxRange: maxRange,
        actualWinRate: targetUser.winRate,
      );

      if (result['success']) {
        // Başarı mesajı göster
        String message;
        if (result['is_correct']) {
          message = AppLocalizations.of(context)!.correctPredictionMessage;
        } else {
          message = AppLocalizations.of(context)!.wrongPredictionMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: result['is_correct'] ? Colors.green : Colors.orange,
          ),
        );

        // Profil sayfasını yenile
        widget.onVoteCompleted?.call();

        // Match'i tamamla ve yeni match'e geç
        _completeMatchAndMoveNext();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  void _completeMatchAndMoveNext() {
    if (mounted) {
      setState(() {
        showPredictionSlider = false;
        selectedWinner = null;
        selectedUserForPrediction = null;
        previewUser = null;
        showSinglePhotoPreview = false;
        votableItems.removeAt(currentMatchIndex);
        if (currentMatchIndex >= votableItems.length) {
          currentMatchIndex = 0;
        }
      });
    }

    // Eğer match kalmadıysa yeni match'ler oluştur
    if (votableItems.isEmpty) {
      loadMatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          if (isLoading)
            Expanded(
              child: _buildVotingSkeletonScreen(),
            )
          else if (votableItems.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.noMatchesAvailable,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          else if (currentMatchIndex >= votableItems.length)
            Expanded(
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.allMatchesVoted,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            Expanded(
              child: _buildVotableItemCard(votableItems[currentMatchIndex]),
            ),
        ],
      ),
    );
  }

  void _nextMatch() {
    setState(() {
      currentMatchIndex++;
      showPredictionSlider = false;
      selectedWinner = null;
      selectedUserForPrediction = null;
      previewUser = null;
      showSinglePhotoPreview = false;
      sliderValue = 50.0;
      selectedPhotoOrder = 1; // Reset photo order
    });
    
    // Eğer tüm oylamalar bittiyse yeni match'ler yükle
    if (currentMatchIndex >= votableItems.length) {
      loadMatches();
    }
  }

  Widget _buildVotableItemCard(Map<String, dynamic> item) {
    final isTournament = item['is_tournament'] as bool;
    
    if (isTournament) {
      return _buildTournamentMatchCard(item['tournament_match']);
    } else {
      return _buildMatchCard(item['match'] as MatchModel);
    }
  }

  Widget _buildTournamentMatchCard(Map<String, dynamic> tournamentMatch) {
    final user1 = tournamentMatch['user1'];
    final user2 = tournamentMatch['user2'];
    
    return Column(
      children: [
        // Turnuva başlığı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AppLocalizations.of(context)!.tournamentVoting,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        Text(
          AppLocalizations.of(context)!.whichTournamentParticipant,
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
                  onTap: () => _voteForUser(user1['id']),
                  child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              image: user1['profile_image_url'] != null
                                  ? DecorationImage(
                                      image: NetworkImage(user1['profile_image_url']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: user1['profile_image_url'] == null ? Colors.grey[300] : null,
                            ),
                            child: user1['profile_image_url'] == null
                                ? const Icon(Icons.person, size: 80, color: Colors.grey)
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text(
                                user1['username'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.ageYears(user1['age'], user1['country']),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // İkinci kullanıcı
              Expanded(
                child: GestureDetector(
                  onTap: () => _voteForUser(user2['id']),
                  child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              image: user2['profile_image_url'] != null
                                  ? DecorationImage(
                                      image: NetworkImage(user2['profile_image_url']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: user2['profile_image_url'] == null ? Colors.grey[300] : null,
                            ),
                            child: user2['profile_image_url'] == null
                                ? const Icon(Icons.person, size: 80, color: Colors.grey)
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text(
                                user2['username'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.ageYears(user2['age'], user2['country']),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
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
        
        // İlerleme göstergesi
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < votableItems.length; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == currentMatchIndex ? Colors.purple : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ],
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
          return Center(
            child: Text(AppLocalizations.of(context)!.matchInfoNotLoaded),
          );
        }
        
        final users = snapshot.data!;
        final user1 = users[0];
        final user2 = users[1];
        
        // Eğer prediction slider aktifse, sadece seçilen fotoğrafı tek olarak göster
        if (showPredictionSlider && (selectedUserForPrediction != null || selectedWinner != null)) {
          return _buildPredictionSlider();
        }

        // Eğer single photo preview aktifse, sadece onu göster
        if (showSinglePhotoPreview && previewUser != null) {
          return _buildSinglePhotoPreview();
        }

        return Column(
          children: [
            // İlk kullanıcı
            Expanded(
              child: GestureDetector(
                      onTap: () => _voteForUser(user1.id),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: _buildUserPhotoDisplay(user1, match.id),
                              ),
                            // Zoom butonu ve premium bilgi butonları
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Column(
                                children: [
                                  // Zoom butonu
                                  _buildOverlayButton(
                                    Icons.zoom_in,
                                    Colors.black,
                                    () => _showSinglePhotoPreview(user1.id)
                                  ),
                                  if (user1.showInstagram && user1.instagramHandle != null)
                                    _buildOverlayButton(
                                      Icons.camera_alt,
                                      Colors.pink,
                                      () => _showPremiumInfo(user1.instagramHandle!, AppLocalizations.of(context)!.instagramAccount),
                                    ),
                                  if (user1.showProfession && user1.profession != null)
                                    _buildOverlayButton(
                                      Icons.work,
                                      Colors.blue,
                                      () => _showPremiumInfo(user1.profession!, AppLocalizations.of(context)!.profession),
                                    ),
                                  // Report button
                                  _buildOverlayButton(
                                    Icons.report,
                                    Colors.red,
                                    () => _showReportDialog(user1.id, match.id),
                                  ),
                                ],
                              ),
                            ),
                            // Kullanıcı ismi sağ alt köşede
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFF6B35), // Ana turuncu ton
                                      Color(0xFFFF8C42), // Açık turuncu ton
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  user1.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
                  
                  const SizedBox(height: 8),
                  
                  // VS Image
                  _buildVSImage(),
                  
            const SizedBox(height: 8),
            
            // İkinci kullanıcı
            Expanded(
              child: GestureDetector(
                      onTap: () => _voteForUser(user2.id),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: _buildUserPhotoDisplay(user2, match.id),
                              ),
                            // Zoom butonu ve premium bilgi butonları
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Column(
                                children: [
                                  // Zoom butonu
                                  _buildOverlayButton(
                                    Icons.zoom_in,
                                    Colors.black,
                                    () => _showSinglePhotoPreview(user2.id)
                                  ),
                                  if (user2.showInstagram && user2.instagramHandle != null)
                                    _buildOverlayButton(
                                      Icons.camera_alt,
                                      Colors.pink,
                                      () => _showPremiumInfo(user2.instagramHandle!, AppLocalizations.of(context)!.instagramAccount),
                                    ),
                                  if (user2.showProfession && user2.profession != null)
                                    _buildOverlayButton(
                                      Icons.work,
                                      Colors.blue,
                                      () => _showPremiumInfo(user2.profession!, AppLocalizations.of(context)!.profession),
                                    ),
                                  // Report button
                                  _buildOverlayButton(
                                    Icons.report,
                                    Colors.red,
                                    () => _showReportDialog(user2.id, match.id),
                                  ),
                                ],
                              ),
                            ),
                            // Kullanıcı ismi sağ alt köşede
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFF6B35), // Ana turuncu ton
                                      Color(0xFFFF8C42), // Açık turuncu ton
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  user2.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
        );
      },
    );
  }

  Future<List<UserModel>> _getMatchUsers(MatchModel match) async {
    // Match'teki kullanıcıları çoklu fotoğraflarla birlikte getir
    try {
      final users = await MatchService.getMatchUsers(match.user1Id, match.user2Id);
      
      // Her kullanıcı için çoklu fotoğrafları yükle
      final usersWithPhotos = <UserModel>[];
      for (var user in users) {
        final photos = await PhotoUploadService.getUserPhotos(user.id);
        
        // Tüm fotoğrafları kullan (artık profil fotoğrafı yok)
        final allPhotos = List<Map<String, dynamic>>.from(photos);
        
        // UserModel'e çoklu fotoğrafları ekle
        final userWithPhotos = UserModel(
          id: user.id,
          username: user.username,
          email: user.email,
          coins: user.coins,
          age: user.age,
          countryCode: user.countryCode,
          genderCode: user.genderCode,
          instagramHandle: user.instagramHandle,
          profession: user.profession,
          isVisible: user.isVisible,
          showInstagram: user.showInstagram,
          showProfession: user.showProfession,
          totalMatches: user.totalMatches,
          wins: user.wins,
          currentStreak: user.currentStreak,
          totalStreakDays: user.totalStreakDays,
          lastLoginDate: user.lastLoginDate,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          matchPhotos: allPhotos,
        );
        
        usersWithPhotos.add(userWithPhotos);
      }
      
      return usersWithPhotos;
    } catch (e) {
      // // print('Error getting match users with photos: $e');
      return [];
    }
  }

  Widget _buildUserPhotoDisplay(UserModel user, String matchId) {
    // Çoklu fotoğraf varsa carousel göster, yoksa profil fotoğrafını göster
    if (user.matchPhotos != null && user.matchPhotos!.isNotEmpty) {
      return _buildPhotoCarousel(user.matchPhotos!, user.id, matchId);
    } else {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.person, size: 50),
      );
    }
  }

  Widget _buildPhotoCarousel(List<Map<String, dynamic>> photos, String userId, String matchId) {
    // Seçilen fotoğraf sırasını bul
    final selectedPhoto = photos.firstWhere(
      (photo) => (photo['photo_order'] as int? ?? 0) == selectedPhotoOrder,
      orElse: () => photos.first, // Bulunamazsa ilk fotoğrafı kullan
    );
    
    return CachedNetworkImage(
      imageUrl: selectedPhoto['photo_url'],
      fit: BoxFit.contain,
      placeholder: (context, url) => _buildImageLoadingShimmer(),
      errorWidget: (context, url, error) => _buildImageErrorWidget(),
    );
  }

  Widget _buildOverlayButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showPremiumInfo(String info, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.premiumInfo(type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.spendFiveCoins,
              style: TextStyle(color: Colors.grey[600]),
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
              Navigator.pop(context);
              await _purchasePremiumInfo(info, type);
            },
            child: const Text('5 Coin Harca'),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePremiumInfo(String info, String type) async {
    try {
      // 5 coin harca
      final success = await UserService.updateCoins(-5, 'spent', AppLocalizations.of(context)!.matchHistoryViewing);
      
      if (success) {
        // Bilgiyi göster
        _showPremiumInfoResult(info, type);
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

  void _showPremiumInfoResult(String info, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.premiumInfo(type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: type == AppLocalizations.of(context)!.instagramAccount
                  ? GestureDetector(
                      onTap: () => _openInstagramProfile(info),
                      child: Text(
                        '@$info',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Text(
                      info,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.fiveCoinsSpent,
              style: TextStyle(
                color: Colors.green[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            if (type == AppLocalizations.of(context)!.instagramAccount) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.clickToOpenInstagram,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (type == AppLocalizations.of(context)!.instagramAccount)
            ElevatedButton.icon(
              onPressed: () => _openInstagramProfile(info),
              icon: const Icon(Icons.camera_alt),
              label: Text(AppLocalizations.of(context)!.openInstagram),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  // Instagram profilini aç
  Future<void> _openInstagramProfile(String username) async {
    try {
      // @ işaretini kaldır
      final cleanUsername = username.replaceAll('@', '');
      
      // Instagram URL'lerini dene (hem app hem web)
      final instagramUrls = [
        'instagram://user?username=$cleanUsername', // Instagram app
        'https://www.instagram.com/$cleanUsername/', // Web browser
      ];

      bool launched = false;
      
      for (String url in instagramUrls) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      }

      if (!launched) {
        // Eğer hiçbir URL açılamazsa, web browser ile dene
        final webUrl = Uri.parse('https://www.instagram.com/$cleanUsername/');
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.instagramCannotBeOpened),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.instagramOpenError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSinglePhotoPreview() {
    if (previewUser == null) return const SizedBox.shrink();

    return Expanded(
      child: Stack(
        children: [
          // Seçilen kullanıcının tam ekran fotoğrafı
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildUserPhotoDisplay(previewUser!, 'preview'),
            ),
          ),
          
          // Exit / Çarpı butonu - Sol üstte
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showSinglePhotoPreview = false;
                  previewUser = null;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
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
    );
  }

  Widget _buildPredictionSlider() {
    final targetUser = selectedUserForPrediction ?? selectedWinner;
    if (targetUser == null) return const SizedBox.shrink();

    return Expanded(
      child: Stack(
        children: [
          // Seçilen kullanıcının tam ekran fotoğrafı
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildUserPhotoDisplay(targetUser, 'prediction'),
            ),
          ),
          
          // Sağ tarafta dikey slider ve kullanıcı bilgileri
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Kullanıcı adı
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF6B35), // Ana turuncu ton
                            Color(0xFFFF8C42), // Açık turuncu ton
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        targetUser.username,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // YENİ: Büyütülmüş Dikey Slider - Uzunluğu artırıldı
                    Expanded(
                      flex: 3, // Daha çok alan kullan
                      child: StatefulBuilder(
                        builder: (context, setLocalState) {
                          return Column(
                            children: [
                              Expanded( // Bu slider containerı full height kullanır
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: RotatedBox(
                                    quarterTurns: -1,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 8, // Thicker track
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15),
                                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                                        activeTrackColor: _getSliderColorFromPercentage(_tempSliderValue),
                                        inactiveTrackColor: Colors.grey.withValues(alpha: _isSliderDragging ? 0.8 : 0.3),
                                        thumbColor: _getSliderColorFromPercentage(_tempSliderValue),
                                        overlayColor: _getSliderColorFromPercentage(_tempSliderValue).withValues(alpha: 0.3),
                                      ),
                                      child: Slider(
                                        value: _tempSliderValue,
                                        min: 0,
                                        max: 100,
                                        divisions: null,
                                        label: '${_tempSliderValue.round()}%',
                                        onChangeStart: (_) {
                                          setLocalState(() {
                                            _isSliderDragging = true;
                                          });
                                        },
                                        onChanged: (value) {
                                          // Sadece local islate update - NO GLOBAL setState!
                                          setLocalState(() {
                                            _tempSliderValue = value.clamp(0.0, 100.0);
                                          });
                                        },
                                        onChangeEnd: (_) {
                                          setLocalState(() {
                                            _isSliderDragging = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Live percentage display - Dynamic Color
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${_tempSliderValue.round()}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getSliderColorFromPercentage(_tempSliderValue),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    
                    // Alt kısım - Referenced for id dragon
                    const SizedBox(height: 10),
                    
                    // Submit butonu
                    Container(
                      constraints: const BoxConstraints(maxWidth: 80),
                      child: RotatedBox(
                        quarterTurns: 0,
                        child: ElevatedButton(
                          onPressed: _submitPrediction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'TAMAM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  /// Update photo statistics for both users in a match
  Future<void> _updatePhotoStatsForMatch(MatchModel match, String winnerId) async {
    try {
      // Get match users with their photos
      final users = await _getMatchUsers(match);
      if (users.length != 2) return;

      final user1 = users[0];
      final user2 = users[1];

      // Determine which user won
      final winner = user1.id == winnerId ? user1 : user2;
      final loser = user1.id == winnerId ? user2 : user1;

      // Update photo statistics for winner's displayed photo
      if (winner.matchPhotos != null && winner.matchPhotos!.isNotEmpty) {
        // Find the photo that was displayed in this match
        final displayedPhoto = _getDisplayedPhotoForUser(winner, match.id);
        if (displayedPhoto != null && displayedPhoto['id'] != null) {
          await PhotoUploadService.updatePhotoStats(displayedPhoto['id'], isWin: true);
        }
      }

      // Update photo statistics for loser's displayed photo
      if (loser.matchPhotos != null && loser.matchPhotos!.isNotEmpty) {
        // Find the photo that was displayed in this match
        final displayedPhoto = _getDisplayedPhotoForUser(loser, match.id);
        if (displayedPhoto != null && displayedPhoto['id'] != null) {
          await PhotoUploadService.updatePhotoStats(displayedPhoto['id'], isWin: false);
        }
      }
    } catch (e) {
      // // print('Error updating photo stats for match: $e');
    }
  }

  /// Get the photo that was displayed for a user in a specific match
  Map<String, dynamic>? _getDisplayedPhotoForUser(UserModel user, String matchId) {
    if (user.matchPhotos == null || user.matchPhotos!.isEmpty) {
      // // print('Warning: No match photos for user ${user.id}');
      return null;
    }

    // Use the same algorithm as _buildPhotoCarousel to determine which photo was shown
    final photos = user.matchPhotos!;
    final combinedHash = (user.id.hashCode.abs() + matchId.hashCode.abs() + photos.length * 23) % photos.length;
    final photoIndex = photos.length > 1 ? combinedHash : 0;
    
    final selectedPhoto = photos[photoIndex];
    
    // Debug için fotoğraf bilgilerini yazdır
    // // print('Selected photo for user ${user.id}: ${selectedPhoto['photo_url']}');
    // // print('Photo ID: ${selectedPhoto['id']}');
    // // print('Photo order: ${selectedPhoto['photo_order']}');
    
    return selectedPhoto;
  }

  /// Build animated skeleton loading screen for voting tab
  Widget _buildVotingSkeletonScreen() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surface,
            highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            child: Column(
              children: [
                // Two skeleton photo containers
                Row(
                  children: [
                    // Left skeleton photo
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 350,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Right skeleton photo
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 350,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Usernames skeleton
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // VS text skeleton
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                const SizedBox(height: 40),
                // Action buttons skeleton
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build shimmer loading widget for image loading states
  Widget _buildImageLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surface,
      highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Build error placeholder widget for failed image loads
  Widget _buildImageErrorWidget() {
    return Container(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              'Image unavailable',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build VS image based on current theme
  Widget _buildVSImage() {
    VSTheme theme;
    
    
    // Check if we're in a tournament match (always use pink theme)
    if (currentMatchIndex < votableItems.length) {
      final currentItem = votableItems[currentMatchIndex];
      final isTournament = currentItem['is_tournament'] as bool;
      if (isTournament) {
        theme = VSTheme.pink;
      } else {
        // For normal matches, use theme based on saved theme preference
        theme = _getVSThemeFromAppTheme(_currentTheme);
      }
    } else {
      // Default theme based on saved theme preference
      theme = _getVSThemeFromAppTheme(_currentTheme);
    }
    
    return Container(
      key: ValueKey('vs_container_$_currentTheme'), // Theme değişikliğinde container'ı yenile
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getVSContainerBackgroundColor(_currentTheme),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _getVSContainerBorderColor(_currentTheme),
          width: 1,
        ),
      ),
      child: VSImageWidget(
        key: ValueKey('vs_${theme.name}_$_currentTheme'), // Theme değişikliğinde widget'ı yenile
        theme: theme,
        width: 60,
        height: 30,
      ),
    );
  }

  /// Convert app theme string to VS theme enum
  VSTheme _getVSThemeFromAppTheme(String appTheme) {
    switch (appTheme) {
      case 'Koyu':
        return VSTheme.dark;
      case 'Pembemsi':
        return VSTheme.pink;
      case 'Beyaz':
      default:
        return VSTheme.white;
    }
  }

  /// Get VS container background color based on theme
  Color _getVSContainerBackgroundColor(String appTheme) {
    Color color;
    switch (appTheme) {
      case 'Koyu':
        color = Colors.black.withValues(alpha: 0.8);
        break;
      case 'Pembemsi':
        color = const Color(0xFFC2185B).withValues(alpha: 0.1);
        break;
      case 'Beyaz':
      default:
        color = Colors.white; // Beyaz arka plan
        break;
    }
    return color;
  }

  /// Get VS container border color based on theme
  Color _getVSContainerBorderColor(String appTheme) {
    Color color;
    switch (appTheme) {
      case 'Koyu':
        color = Colors.white;
        break;
      case 'Pembemsi':
        color = const Color(0xFFC2185B);
        break;
      case 'Beyaz':
      default:
        color = const Color(0xFFFF6B35); // Ana turuncu ton
        break;
    }
    return color;
  }

  // Report Dialog
  void _showReportDialog(String reportedUserId, String matchId) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        reportedUserId: reportedUserId,
        matchId: matchId,
        onReportSubmitted: (success) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Bildirim başarıyla gönderildi'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Bildirim gönderilemedi'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

}

// Report Dialog Widget
class ReportDialog extends StatefulWidget {
  final String reportedUserId;
  final String matchId;
  final Function(bool) onReportSubmitted;

  const ReportDialog({
    super.key,
    required this.reportedUserId,
    required this.matchId,
    required this.onReportSubmitted,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportReasons = ReportService.getReportReasons();
    
    return AlertDialog(
      title: const Text('Uygunsuz İçerik Bildir'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Bildirim Sebebi'),
          const SizedBox(height: 16),
          
          // Reason selection
          ...reportReasons.map((reason) => RadioListTile<String>(
            title: Text(reason['name']!),
            value: reason['key']!,
            groupValue: selectedReason,
            onChanged: (value) {
              setState(() {
                selectedReason = value;
              });
            },
          )),
          
          const SizedBox(height: 16),
          
          // Description field
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Additional details (optional)',
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || selectedReason == null 
            ? null 
            : _submitReport,
          child: _isSubmitting 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Gönder'),
        ),
      ],
    );
  }

  Future<void> _submitReport() async {
    if (selectedReason == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await ReportService.reportMatch(
        matchId: widget.matchId,
        reportedUserId: widget.reportedUserId,
        reason: selectedReason!,
        description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      );

      Navigator.pop(context);
      widget.onReportSubmitted(success);
    } catch (e) {
      Navigator.pop(context);
      widget.onReportSubmitted(false);
    }
  }
}
