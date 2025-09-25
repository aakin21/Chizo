import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../models/user_model.dart';
import '../services/match_service.dart';
import '../services/user_service.dart';
import '../services/prediction_service.dart';
import '../services/photo_upload_service.dart';
import '../l10n/app_localizations.dart';

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
  bool showPredictionSlider = false;
  UserModel? selectedWinner;
  double sliderValue = 50.0;

  @override
  void initState() {
    super.initState();
    loadMatches();
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
    
      if (mounted) {
        setState(() {
          matches = votableMatches;
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
    if (currentMatchIndex >= matches.length) return;

    final currentMatch = matches[currentMatchIndex];
    final success = await MatchService.voteForMatch(currentMatch.id, winnerId);
    
    if (success) {
      // Update photo statistics for both users
      await _updatePhotoStatsForMatch(currentMatch, winnerId);
      
      // Kazanan kullanıcıyı bul ve slider'ı göster
      final winner = await _getWinnerUser(winnerId);
      if (winner != null) {
        if (mounted) {
          setState(() {
            selectedWinner = winner;
            showPredictionSlider = true;
            sliderValue = 50.0; // Başlangıç değeri
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.votingError)),
      );
    }
  }

  Future<UserModel?> _getWinnerUser(String winnerId) async {
    try {
      // Match'teki kullanıcıları getir
      final users = await _getMatchUsers(matches[currentMatchIndex]);
      return users.firstWhere((user) => user.id == winnerId);
    } catch (e) {
      print('Error getting winner user: $e');
      return null;
    }
  }

  Future<void> _submitPrediction() async {
    if (selectedWinner == null) return;

    // Slider değerini aralığa çevir
    int minRange, maxRange;
    if (sliderValue <= 10) {
      minRange = 0; maxRange = 10;
    } else if (sliderValue <= 20) {
      minRange = 11; maxRange = 20;
    } else if (sliderValue <= 30) {
      minRange = 21; maxRange = 30;
    } else if (sliderValue <= 40) {
      minRange = 31; maxRange = 40;
    } else if (sliderValue <= 50) {
      minRange = 41; maxRange = 50;
    } else if (sliderValue <= 60) {
      minRange = 51; maxRange = 60;
    } else if (sliderValue <= 70) {
      minRange = 61; maxRange = 70;
    } else if (sliderValue <= 80) {
      minRange = 71; maxRange = 80;
    } else if (sliderValue <= 90) {
      minRange = 81; maxRange = 90;
    } else {
      minRange = 91; maxRange = 100;
    }

    try {
      final result = await PredictionService.submitPrediction(
        winnerId: selectedWinner!.id,
        minRange: minRange,
        maxRange: maxRange,
        actualWinRate: selectedWinner!.winRate,
      );

      if (result['success']) {
        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
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
        matches.removeAt(currentMatchIndex);
        if (currentMatchIndex >= matches.length) {
          currentMatchIndex = 0;
        }
      });
    }

    // Eğer match kalmadıysa yeni match'ler oluştur
    if (matches.isEmpty) {
      loadMatches();
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
          Text(
            AppLocalizations.of(context)!.voting,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 20),
          
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (matches.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.noMatchesAvailable,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          else if (currentMatchIndex >= matches.length)
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
          return Center(
            child: Text(AppLocalizations.of(context)!.matchInfoNotLoaded),
          );
        }
        
        final users = snapshot.data!;
        final user1 = users[0];
        final user2 = users[1];
        
        return Column(
          children: [
            if (!showPredictionSlider) ...[
              Text(
                AppLocalizations.of(context)!.whichDoYouPrefer,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              // Prediction slider
              _buildPredictionSlider(),
              const SizedBox(height: 20),
            ],
            
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
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                    ),
                                    child: _buildUserPhotoDisplay(user1, match.id),
                                  ),
                                  // Premium bilgi butonları
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Column(
                                      children: [
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
                                      ],
                                    ),
                                  ),
                                ],
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
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.vs,
                      style: const TextStyle(
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
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                    ),
                                    child: _buildUserPhotoDisplay(user2, match.id),
                                  ),
                                  // Premium bilgi butonları
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Column(
                                      children: [
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
                                      ],
                                    ),
                                  ),
                                ],
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
          country: user.country,
          gender: user.gender,
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
      print('Error getting match users with photos: $e');
      return [];
    }
  }

  Widget _buildUserPhotoDisplay(UserModel user, String matchId) {
    // Çoklu fotoğraf varsa carousel göster, yoksa profil fotoğrafını göster
    if (user.matchPhotos != null && user.matchPhotos!.isNotEmpty) {
      return _buildPhotoCarousel(user.matchPhotos!, user.id, matchId);
    } else if (user.matchPhotos != null && user.matchPhotos!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: user.matchPhotos!.first['photo_url'],
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
      );
    } else {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.person, size: 50),
      );
    }
  }

  Widget _buildPhotoCarousel(List<Map<String, dynamic>> photos, String userId, String matchId) {
    // Her match için farklı fotoğraf seç ama aynı match içinde sabit kalsın
    // User ID + Match ID + fotoğraf sayısı kullanarak daha iyi dağıtım
    final combinedHash = (userId.hashCode.abs() + matchId.hashCode.abs() + photos.length * 23) % photos.length;
    final photoIndex = photos.length > 1 ? combinedHash : 0;
    
    final selectedPhoto = photos[photoIndex];
    
    return CachedNetworkImage(
      imageUrl: selectedPhoto['photo_url'],
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
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
        title: Text('💎 $type Bilgisi'),
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
      final success = await UserService.updateCoins(-5, 'spent', '$type bilgisi görüntüleme');
      
      if (success) {
        // Bilgiyi göster
        _showPremiumInfoResult(info, type);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Yeterli coin yok!'),
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
        title: Text('💎 $type Bilgisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
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
              '✅ 5 coin harcandı',
              style: TextStyle(
                color: Colors.green[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionSlider() {
    if (selectedWinner == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: selectedWinner!.matchPhotos != null && selectedWinner!.matchPhotos!.isNotEmpty
                    ? CachedNetworkImageProvider(selectedWinner!.matchPhotos!.first['photo_url'])
                    : null,
                child: selectedWinner!.matchPhotos == null || selectedWinner!.matchPhotos!.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.predictWinRate(selectedWinner!.username),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.correctPrediction,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Slider
          Column(
            children: [
              Text(
                '${AppLocalizations.of(context)!.winRate}: ${_getRangeLabel(sliderValue)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: sliderValue,
                min: 0,
                max: 100,
                divisions: 10,
                label: _getRangeLabel(sliderValue),
                onChanged: (value) {
                  setState(() {
                    sliderValue = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              
              // Aralık göstergeleri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i <= 10; i++)
                    Container(
                      width: 2,
                      height: 8,
                      color: Colors.grey[400],
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i <= 10; i++)
                    Text(
                      '${i * 10}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tahmin gönder butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitPrediction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.submitPrediction,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRangeLabel(double value) {
    if (value <= 10) return '0-10%';
    if (value <= 20) return '11-20%';
    if (value <= 30) return '21-30%';
    if (value <= 40) return '31-40%';
    if (value <= 50) return '41-50%';
    if (value <= 60) return '51-60%';
    if (value <= 70) return '61-70%';
    if (value <= 80) return '71-80%';
    if (value <= 90) return '81-90%';
    return '91-100%';
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
      print('Error updating photo stats for match: $e');
    }
  }

  /// Get the photo that was displayed for a user in a specific match
  Map<String, dynamic>? _getDisplayedPhotoForUser(UserModel user, String matchId) {
    if (user.matchPhotos == null || user.matchPhotos!.isEmpty) {
      print('Warning: No match photos for user ${user.id}');
      return null;
    }

    // Use the same algorithm as _buildPhotoCarousel to determine which photo was shown
    final photos = user.matchPhotos!;
    final combinedHash = (user.id.hashCode.abs() + matchId.hashCode.abs() + photos.length * 23) % photos.length;
    final photoIndex = photos.length > 1 ? combinedHash : 0;
    
    final selectedPhoto = photos[photoIndex];
    
    // Debug için fotoğraf bilgilerini yazdır
    print('Selected photo for user ${user.id}: ${selectedPhoto['photo_url']}');
    print('Photo ID: ${selectedPhoto['id']}');
    print('Photo order: ${selectedPhoto['photo_order']}');
    
    return selectedPhoto;
  }
}
