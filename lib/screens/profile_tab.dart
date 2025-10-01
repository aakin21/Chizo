import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/photo_upload_service.dart';
import '../l10n/app_localizations.dart';
import 'match_history_screen.dart';
import 'country_ranking_screen.dart';
import '../widgets/country_selector.dart';
import '../widgets/gender_selector.dart';
import '../services/country_service.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback? onRefresh;
  
  const ProfileTab({super.key, this.onRefresh});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserModel? currentUser;
  bool isLoading = true;
  bool isUpdating = false;
  List<Map<String, dynamic>> userPhotos = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget güncellendiğinde veriyi yeniden yükle
    if (oldWidget.onRefresh != widget.onRefresh) {
      loadUserData();
    }
  }




  Future<void> loadUserData() async {
    setState(() => isLoading = true);
    
    try {
      final user = await UserService.getCurrentUser();
      List<Map<String, dynamic>> photos = [];
      
      if (user != null) {
        // Get photos with win rate stats
        final userPhotoStats = await PhotoUploadService.getUserPhotoStats(user.id);
        
        // Sort photos by win rate (highest to lowest)
        photos = userPhotoStats;
        photos.sort((a, b) {
          final aWinRate = double.tryParse(a['win_rate']?.toString() ?? '0') ?? 0;
          final bWinRate = double.tryParse(b['win_rate']?.toString() ?? '0') ?? 0;
          return bWinRate.compareTo(aWinRate);
        });
        
      }
      
      if (mounted) {
        setState(() {
          currentUser = user;
          userPhotos = photos;
          isLoading = false;
        });
      }
    } catch (e) {
      // // print('ProfileTab: Error loading user data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  int _calculateWinRate(int totalMatches, int wins) {
    if (totalMatches == 0) return 0;
    return ((wins / totalMatches) * 100).round();
  }

  Future<void> _showPhotoUploadDialog() async {
    if (currentUser == null) return;
    final l10n = AppLocalizations.of(context)!;

    final nextSlot = await PhotoUploadService.getNextAvailableSlot(currentUser!.id);
    if (nextSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.allPhotoSlotsFull)),
      );
      return;
    }

    final canUploadResult = await PhotoUploadService.canUploadPhoto(nextSlot);
    if (!canUploadResult['canUpload']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(canUploadResult['message'])),
      );
      return;
    }

    final requiredCoins = canUploadResult['requiredCoins'] as int;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.photoUploadSlot(nextSlot)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.coinsRequiredForSlot(requiredCoins)),
            const SizedBox(height: 16),
            Text(l10n.currentCoins(currentUser!.coins)),
            if (requiredCoins > currentUser!.coins) ...[
              const SizedBox(height: 8),
              Text(
                l10n.insufficientCoinsForUpload,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          if (requiredCoins <= currentUser!.coins)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _uploadPhotoToSlot(nextSlot);
              },
              child: Text(l10n.upload(requiredCoins)),
            ),
        ],
      ),
    );
  }

  Future<void> _uploadPhotoToSlot(int slot) async {
    setState(() => isUpdating = true);
    
    try {
      final result = await PhotoUploadService.uploadPhoto(slot);
      
      if (result['success']) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${AppLocalizations.of(context)!.photoUploaded(result['coinsSpent'])}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  Future<void> _deletePhoto(int slot) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletePhoto),
        content: Text(AppLocalizations.of(context)!.confirmDeletePhoto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isUpdating = true);
              
              try {
                final result = await PhotoUploadService.deletePhoto(slot);
                
                if (result['success']) {
                  await loadUserData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.photoDeleted),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${AppLocalizations.of(context)!.error}: ${result['message']}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${AppLocalizations.of(context)!.error}: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() => isUpdating = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? _buildProfileSkeletonScreen()
          : currentUser == null
              ? Center(child: Text(AppLocalizations.of(context)!.userInfoNotLoaded))
              : RefreshIndicator(
                  onRefresh: loadUserData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fotoğraf Yönetimi (5 Slot)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.myPhotos(userPhotos.length),
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      if (userPhotos.length < 5)
                                        ElevatedButton.icon(
                                          onPressed: isUpdating ? null : _showPhotoUploadDialog,
                                          icon: const Icon(Icons.add, size: 16),
                                          label: Text(AppLocalizations.of(context)!.addPhoto),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.photoCostInfo,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              
                              // Fotoğraf Grid
                              if (userPhotos.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.photo_camera, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppLocalizations.of(context)!.noAdditionalPhotos,
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppLocalizations.of(context)!.secondPhotoCost,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                _buildPhotoGrid(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // İstatistikler
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.statistics,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '${currentUser!.totalMatches}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text(AppLocalizations.of(context)!.totalMatches),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${currentUser!.wins}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(AppLocalizations.of(context)!.wins),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${_calculateWinRate(currentUser!.totalMatches, currentUser!.wins)}%',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      Text(AppLocalizations.of(context)!.winRatePercentage),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Kullanıcı Adı
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 28,
                          ),
                          title: Text(AppLocalizations.of(context)!.username),
                          subtitle: Text(currentUser!.username),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditDialog('username', currentUser!.username),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // E-posta
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.email,
                            color: Colors.green,
                            size: 28,
                          ),
                          title: Text(AppLocalizations.of(context)!.email),
                          subtitle: Text(currentUser!.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditDialog('email', currentUser!.email),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Coin Bilgisi
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 28,
                          ),
                          title: Text(AppLocalizations.of(context)!.coin),
                          subtitle: Text('${currentUser!.coins}'),
                          trailing: const Icon(Icons.info_outline),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Yaş Seçimi
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.cake,
                            color: Colors.orange,
                            size: 28,
                          ),
                          title: const Text('Yaş'),
                          subtitle: Text(currentUser!.age?.toString() ?? 'Yaşınızı seçin'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showAgeSelector(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ülke Seçimi
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.public,
                            color: Colors.blue,
                            size: 28,
                          ),
                          title: const Text('Ülke'),
                          subtitle: FutureBuilder<String?>(
                            future: _getCountryName(currentUser!.countryCode),
                            builder: (context, snapshot) {
                              return Text(snapshot.data ?? 'Ülkenizi seçin');
                            },
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showCountrySelector(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Cinsiyet Seçimi
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.purple,
                            size: 28,
                          ),
                          title: const Text('Cinsiyet'),
                          subtitle: FutureBuilder<String?>(
                            future: _getGenderName(currentUser!.genderCode),
                            builder: (context, snapshot) {
                              return Text(snapshot.data ?? 'Cinsiyetinizi seçin');
                            },
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showGenderSelector(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Instagram Hesabı
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.camera_alt,
                            color: Colors.pink,
                            size: 28,
                          ),
                          title: Text(AppLocalizations.of(context)!.instagramAccount),
                          subtitle: Text(currentUser!.instagramHandle != null ? '@${currentUser!.instagramHandle!}' : 'Instagram hesabınızı ekleyin'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: _getFieldVisibility('instagram'),
                                onChanged: (value) => _toggleFieldVisibility('instagram', value),
                                activeColor: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditDialog('instagram', currentUser!.instagramHandle ?? ''),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Meslek
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.work,
                            color: Colors.blue,
                            size: 28,
                          ),
                          title: Text(AppLocalizations.of(context)!.profession),
                          subtitle: Text(currentUser!.profession ?? 'Mesleğinizi ekleyin'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: _getFieldVisibility('profession'),
                                onChanged: (value) => _toggleFieldVisibility('profession', value),
                                activeColor: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditDialog('profession', currentUser!.profession ?? ''),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),



                      const SizedBox(height: 24),

                      // Match History Butonu
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.history,
                            color: Colors.purple,
                            size: 28,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.matchHistory,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.viewLastFiveMatches,
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MatchHistoryScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ülke Sıralaması Butonu
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.flag,
                            color: Colors.blue,
                            size: 28,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.countryRanking,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.countryRankingSubtitle,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CountryRankingScreen(),
                              ),
                            );
                          },
                        ),
                      ),


                      const SizedBox(height: 24),

                    ],
                  ),
                ),
              ),
    );
  }



  // Instagram ve meslek görünürlük durumunu kontrol et
  bool _getFieldVisibility(String field) {
    if (field == 'instagram') {
      return currentUser?.showInstagram ?? false;
    } else if (field == 'profession') {
      return currentUser?.showProfession ?? false;
    }
    return true;
  }

  // Instagram ve meslek görünürlüğünü değiştir
  Future<void> _toggleFieldVisibility(String field, bool value) async {
    try {
      setState(() {
        isUpdating = true;
      });

      if (field == 'instagram') {
        await UserService.updateProfile(showInstagram: value);
        setState(() {
          currentUser = currentUser?.copyWith(showInstagram: value);
        });
      } else if (field == 'profession') {
        await UserService.updateProfile(showProfession: value);
        setState(() {
          currentUser = currentUser?.copyWith(showProfession: value);
        });
      }

      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? '${field == 'instagram' ? 'Instagram' : 'Meslek'} bilgisi matchlerde görünür' : '${field == 'instagram' ? 'Instagram' : 'Meslek'} bilgisi matchlerde gizli'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isUpdating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Güncelleme sırasında hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    final l10n = AppLocalizations.of(context)!;
    
    String title = '';
    String hint = '';
    IconData icon = Icons.edit;
    TextInputType keyboardType = TextInputType.text;
    
    switch (field) {
      case 'username':
        title = AppLocalizations.of(context)!.editUsername;
        hint = AppLocalizations.of(context)!.enterUsername;
        icon = Icons.person;
        break;
      case 'instagram':
        title = AppLocalizations.of(context)!.editInstagram;
        hint = AppLocalizations.of(context)!.enterInstagram;
        icon = Icons.camera_alt;
        break;
      case 'profession':
        title = AppLocalizations.of(context)!.editProfession;
        hint = AppLocalizations.of(context)!.enterProfession;
        icon = Icons.work;
        break;
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            if (field == 'country' || field == 'gender')
              const Text('Bu özellik ayarlar sayfasından yönetilebilir')
            else
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: hint,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(icon),
                ),
                keyboardType: keyboardType,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await _updateUserInfo(field, controller.text.trim());
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _updateUserInfo(String field, String value) async {
    try {
      bool success = false;
      
      switch (field) {
        case 'username':
          success = await UserService.updateProfile(username: value);
          break;
        case 'instagram':
          success = await UserService.updateProfile(instagramHandle: value);
          break;
        case 'profession':
          success = await UserService.updateProfile(profession: value);
          break;
      }
      
      if (success) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.infoUpdated),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.updateFailed),
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


  /// Show photo statistics modal
  Future<void> _showPhotoStats(String photoId) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Check if user has enough coins
    final canView = await PhotoUploadService.canViewPhotoStats();
    if (!canView) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.insufficientCoinsForStats),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.photoStats),
        content: Text(l10n.photoStatsCost),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('${l10n.pay} 50 ${l10n.coins}'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    // Pay for viewing stats
    final paymentSuccess = await PhotoUploadService.payForPhotoStatsView();
    if (!paymentSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.error),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get photo statistics
    final photoStats = await PhotoUploadService.getPhotoStats(photoId);
    if (photoStats == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.photoStatsLoadError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show statistics modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.photoStats),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${l10n.wins}: ${photoStats['wins']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.totalMatches}: ${photoStats['total_matches']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.winRate}: ${photoStats['total_matches'] > 0 ? ((photoStats['wins'] as int) / (photoStats['total_matches'] as int) * 100).toStringAsFixed(1) : '0.0'}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );

    // Refresh user data to update coin balance
    await loadUserData();
  }




  /// Build photo grid showing only existing photos and next available slot
  Widget _buildPhotoGrid() {
    // Find the next available slot
    final nextSlot = userPhotos.length + 1;
    
    // If all 5 slots are full, don't show add button
    if (nextSlot > 5) {
      // Show only existing photos
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: userPhotos.length,
        itemBuilder: (context, index) {
          final photo = userPhotos[index];
          final slot = photo['photo_order'] as int;
          return _buildPhotoSlot(photo, slot);
        },
      );
    }
    
    // Show existing photos + next available slot
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: userPhotos.length + 1, // +1 for next slot
      itemBuilder: (context, index) {
        if (index < userPhotos.length) {
          // Show existing photo
          final photo = userPhotos[index];
          final slot = photo['photo_order'] as int;
          return _buildPhotoSlot(photo, slot);
        } else {
          // Show next available slot
          return _buildNextSlotButton(nextSlot);
        }
      },
    );
  }

  /// Build individual photo slot
  Widget _buildPhotoSlot(Map<String, dynamic> photo, int slot) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: CachedNetworkImageProvider(photo['photo_url']),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _deletePhoto(slot),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
        // İstatistik Gör butonu
        Positioned(
          bottom: 4,
          right: 4,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showPhotoStats(photo['id']),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.analytics,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.viewStats,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              AppLocalizations.of(context)!.slot(slot),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build next available slot button
  Widget _buildNextSlotButton(int slot) {
    final cost = PhotoUploadService.getPhotoUploadCost(slot);
    
    return GestureDetector(
      onTap: isUpdating ? null : _showPhotoUploadDialog,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              '$cost coin',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build animated skeleton loading screen for profile tab
  Widget _buildProfileSkeletonScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surface,
            highlightColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile photo skeleton
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
                const SizedBox(height: 16),
                // Name and user info skeletons
                Container(
                  width: 200,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Stats section skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(3, (index) => 
                    Column(
                      children: [
                        Container(
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 50,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Photo management skeleton
          Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surface,
            highlightColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    Container(
                      width: 150,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Photo slots grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: 6, // 5 photo slots + 1 grid title
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Yaş seçici
  void _showAgeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yaşınızı Seçin'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView.builder(
            itemCount: 50,
            itemBuilder: (context, index) {
              final age = index + 18;
              return ListTile(
                title: Text('$age yaş'),
                selected: currentUser?.age == age,
                onTap: () async {
                  Navigator.pop(context);
                  await _updateAge(age);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Ülke seçici
  void _showCountrySelector() {
    showDialog(
      context: context,
      builder: (context) => CountrySelector(
        onCountrySelected: (country) async {
          Navigator.pop(context);
          await _updateCountry(country ?? '');
        },
      ),
    );
  }

  // Cinsiyet seçici
  void _showGenderSelector() {
    showDialog(
      context: context,
      builder: (context) => GenderSelector(
        onGenderSelected: (gender) async {
          Navigator.pop(context);
          await _updateGender(gender ?? '');
        },
      ),
    );
  }

  // Yaş güncelleme
  Future<void> _updateAge(int age) async {
    try {
      final success = await UserService.updateProfile(age: age);
      if (success) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yaş bilgisi güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme sırasında hata oluştu')),
      );
    }
  }

  // Ülke güncelleme
  Future<void> _updateCountry(String countryCode) async {
    try {
      final success = await UserService.updateProfile(countryCode: countryCode);
      if (success) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ülke bilgisi güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme sırasında hata oluştu')),
      );
    }
  }

  // Cinsiyet güncelleme
  Future<void> _updateGender(String genderCode) async {
    try {
      final success = await UserService.updateProfile(genderCode: genderCode);
      if (success) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cinsiyet bilgisi güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme sırasında hata oluştu')),
      );
    }
  }

  // Ülke adını getir
  Future<String?> _getCountryName(String? countryCode) async {
    if (countryCode == null) return null;
    try {
      final country = await CountryService.getCountryByCode(countryCode, 'tr');
      return country?.name ?? countryCode;
    } catch (e) {
      return countryCode;
    }
  }

  // Cinsiyet adını getir
  Future<String?> _getGenderName(String? genderCode) async {
    if (genderCode == null) return null;
    switch (genderCode) {
      case 'M':
        return 'Erkek';
      case 'F':
        return 'Kadın';
      case 'O':
        return 'Diğer';
      default:
        return genderCode;
    }
  }
}
