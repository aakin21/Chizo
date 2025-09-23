import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/image_service.dart';
import '../services/prediction_service.dart';
import '../services/photo_upload_service.dart';
import '../l10n/app_localizations.dart';
import 'match_history_screen.dart';

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
  Map<String, dynamic> predictionStats = {};
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
    print('ProfileTab: Loading user data...');
    setState(() => isLoading = true);
    
    try {
      final user = await UserService.getCurrentUser();
      final stats = await PredictionService.getUserPredictionStats();
      final photos = user != null ? await PhotoUploadService.getUserPhotos(user.id) : [];
      print('ProfileTab: User loaded - totalMatches: ${user?.totalMatches}, wins: ${user?.wins}');
      
      if (mounted) {
        setState(() {
          currentUser = user;
          predictionStats = stats;
          userPhotos = List<Map<String, dynamic>>.from(photos);
          isLoading = false;
        });
      }
    } catch (e) {
      print('ProfileTab: Error loading user data: $e');
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
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
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
                      content: Text('❌ ${result['message']}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
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

  Future<void> _pickAndUploadImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.selectFromGallery),
              onTap: () async {
                Navigator.pop(context);
                await _uploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.takeFromCamera),
              onTap: () async {
                Navigator.pop(context);
                await _uploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage(ImageSource source) async {
    setState(() => isUpdating = true);

    try {
      XFile? imageFile;
      if (source == ImageSource.gallery) {
        imageFile = await ImageService.pickImageFromGallery();
      } else {
        imageFile = await ImageService.pickImageFromCamera();
      }

      if (imageFile != null) {
        print('Image file selected: ${imageFile.path}');
        final imageUrl = await ImageService.uploadImage(imageFile, 'profile.jpg');
        print('Image URL received: $imageUrl');
        
        if (imageUrl != null) {
          final success = await UserService.updateProfile(profileImageUrl: imageUrl);
          if (success) {
            await loadUserData();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.imageUpdated)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.updateFailed)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.imageUpdateFailed)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.selectImage)),
        );
      }
    } catch (e) {
      print('Error in _uploadImage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await loadUserData();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentUser == null
              ? Center(child: Text(AppLocalizations.of(context)!.userInfoNotLoaded))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profil Fotoğrafı
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: currentUser!.profileImageUrl != null
                                  ? CachedNetworkImageProvider(currentUser!.profileImageUrl!)
                                  : null,
                              child: currentUser!.profileImageUrl == null
                                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: isUpdating ? null : _pickAndUploadImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: isUpdating
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Çoklu Fotoğraf Yönetimi
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
                                    AppLocalizations.of(context)!.additionalMatchPhotos,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  if (userPhotos.length < 4)
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
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.additionalPhotosDescription(userPhotos.length),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              
                              // Fotoğraf Grid
                              if (userPhotos.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.photo_camera, size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppLocalizations.of(context)!.noAdditionalPhotos,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppLocalizations.of(context)!.secondPhotoCost,
                                        style: TextStyle(
                                          color: Colors.orange[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: 4, // Always show 4 slots (2-5)
                                  itemBuilder: (context, index) {
                                    final slot = index + 2; // Slots 2-5
                                    final photo = userPhotos.firstWhere(
                                      (p) => p['photo_order'] == slot,
                                      orElse: () => {},
                                    );
                                    
                                    if (photo.isEmpty) {
                                      // Empty slot
                                      return GestureDetector(
                                        onTap: isUpdating ? null : _showPhotoUploadDialog,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                color: Colors.grey[400],
                                                size: 24,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                AppLocalizations.of(context)!.slot(slot),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Text(
                                                '${PhotoUploadService.getPhotoUploadCost(slot)} coin',
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      // Photo slot
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
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Kullanıcı Bilgileri
                      _buildInfoCard(AppLocalizations.of(context)!.username, currentUser!.username),
                      _buildInfoCard(AppLocalizations.of(context)!.email, currentUser!.email),
                      _buildInfoCard(AppLocalizations.of(context)!.coin, '${currentUser!.coins}'),

                      if (currentUser!.age != null)
                        _buildInfoCard(AppLocalizations.of(context)!.age, '${currentUser!.age}'),

                      if (currentUser!.country != null)
                        _buildInfoCard(AppLocalizations.of(context)!.country, currentUser!.country!),

                      if (currentUser!.gender != null)
                        _buildInfoCard(AppLocalizations.of(context)!.gender, currentUser!.gender!),

                      const SizedBox(height: 24),

                      // Instagram ve Meslek Ekleme
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📱 ${AppLocalizations.of(context)!.premiumFeatures}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context)!.premiumInfoDescription,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              
                              // Instagram Ekleme
                              if (currentUser!.instagramHandle == null)
                                _buildAddInfoButton(
                                  AppLocalizations.of(context)!.addInstagram,
                                  Icons.camera_alt,
                                  Colors.pink,
                                  () => _showAddInfoDialog('Instagram', 'instagram'),
                                ),
                              
                              // Meslek Ekleme
                              if (currentUser!.profession == null)
                                _buildAddInfoButton(
                                  AppLocalizations.of(context)!.addProfession,
                                  Icons.work,
                                  Colors.blue,
                                  () => _showAddInfoDialog('Meslek', 'profession'),
                                ),
                              
                              if (currentUser!.instagramHandle != null || currentUser!.profession != null)
                                Text(
                                  AppLocalizations.of(context)!.premiumInfoAdded,
                                  style: TextStyle(fontSize: 12, color: Colors.green),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Premium Bilgi Görünürlük Ayarları
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.premiumInfoVisibility,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context)!.premiumInfoDescription,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              
                              // Instagram Görünürlük
                              if (currentUser!.instagramHandle != null)
                                SwitchListTile(
                                  title: Text(AppLocalizations.of(context)!.instagramAccount),
                                  subtitle: Text('@${currentUser!.instagramHandle}'),
                                  value: currentUser!.showInstagram,
                                  onChanged: (value) async {
                                    await UserService.updatePremiumVisibility(showInstagram: value);
                                    await loadUserData();
                                  },
                                  secondary: const Icon(Icons.camera_alt, color: Colors.pink),
                                ),
                              
                              // Meslek Görünürlük
                              if (currentUser!.profession != null)
                                SwitchListTile(
                                  title: Text(AppLocalizations.of(context)!.profession),
                                  subtitle: Text(currentUser!.profession!),
                                  value: currentUser!.showProfession,
                                  onChanged: (value) async {
                                    await UserService.updatePremiumVisibility(showProfession: value);
                                    await loadUserData();
                                  },
                                  secondary: const Icon(Icons.work, color: Colors.blue),
                                ),
                              
                              if (currentUser!.instagramHandle == null && currentUser!.profession == null)
                                Text(
                                  AppLocalizations.of(context)!.addInstagramFromSettings,
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
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
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
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

                      // Prediction İstatistikleri
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.predictionStatistics,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '${predictionStats['total_predictions'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                      Text(AppLocalizations.of(context)!.totalPredictions),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${predictionStats['correct_predictions'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(AppLocalizations.of(context)!.correctPredictions),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${(predictionStats['accuracy'] ?? 0.0).toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      Text(AppLocalizations.of(context)!.accuracy),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.monetization_on, color: Colors.amber),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.coinsEarnedFromPredictions(predictionStats['total_coins_earned'] ?? 0),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

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

                      const SizedBox(height: 24),

                      // Matchlere Açık Toggle
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.visibleInMatches,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Switch(
                                value: currentUser?.isVisible ?? false,
                                onChanged: (value) async {
                                  final success = await UserService.updateProfile(isVisible: value);
                                  if (success) {
                                    await loadUserData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          value
                                            ? AppLocalizations.of(context)!.nowVisibleInMatches
                                            : AppLocalizations.of(context)!.removedFromMatches
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Premium Bilgiler
                      if (currentUser!.instagramHandle != null || currentUser!.profession != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '💎 ${AppLocalizations.of(context)!.premiumInfo}',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                if (currentUser!.instagramHandle != null)
                                  _buildInfoCard(AppLocalizations.of(context)!.instagramAccount, currentUser!.instagramHandle!),
                                if (currentUser!.profession != null)
                                  _buildInfoCard(AppLocalizations.of(context)!.profession, currentUser!.profession!),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildAddInfoButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  void _showAddInfoDialog(String type, String field) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addInfo(type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterInfo(type)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: type,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(field == 'instagram' ? Icons.camera_alt : Icons.work),
              ),
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
                await _addPremiumInfo(field, controller.text.trim());
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  Future<void> _addPremiumInfo(String field, String value) async {
    try {
      bool success;
      if (field == 'instagram') {
        success = await UserService.updateProfile(instagramHandle: value);
      } else {
        success = await UserService.updateProfile(profession: value);
      }
      
      if (success) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.infoAdded(field == 'instagram' ? 'Instagram' : 'Meslek')),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorAddingInfo),
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
}