import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/image_service.dart';
import '../services/prediction_service.dart';
import '../services/app_localizations.dart';
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
      print('ProfileTab: User loaded - totalMatches: ${user?.totalMatches}, wins: ${user?.wins}');
      
      if (mounted) {
        setState(() {
          currentUser = user;
          predictionStats = stats;
          isLoading = false;
        });
      }
    } catch (e) {
      print('ProfileTab: Error loading user data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
      );
    }
  }

  int _calculateWinRate(int totalMatches, int wins) {
    if (totalMatches == 0) return 0;
    return ((wins / totalMatches) * 100).round();
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
              title: const Text('Galeriden Seç'),
              onTap: () async {
                Navigator.pop(context);
                await _uploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kameradan Çek'),
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
              SnackBar(content: Text(AppLocalizations.of(context).imageUpdated)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).updateFailed)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).imageUpdateFailed)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).selectImage)),
        );
      }
    } catch (e) {
      print('Error in _uploadImage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profile),
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
              ? Center(child: Text(AppLocalizations.of(context).userInfoNotLoaded))
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

                      const SizedBox(height: 24),

                      // Kullanıcı Bilgileri
                      _buildInfoCard(AppLocalizations.of(context).username, currentUser!.username),
                      _buildInfoCard(AppLocalizations.of(context).email, currentUser!.email),
                      _buildInfoCard(AppLocalizations.of(context).coin, '${currentUser!.coins}'),

                      if (currentUser!.age != null)
                        _buildInfoCard(AppLocalizations.of(context).age, '${currentUser!.age}'),

                      if (currentUser!.country != null)
                        _buildInfoCard(AppLocalizations.of(context).country, currentUser!.country!),

                      if (currentUser!.gender != null)
                        _buildInfoCard(AppLocalizations.of(context).gender, currentUser!.gender!),

                      const SizedBox(height: 24),

                      // Instagram ve Meslek Ekleme
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📱 ${AppLocalizations.of(context).premiumFeatures}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context).premiumInfoDescription,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              
                              // Instagram Ekleme
                              if (currentUser!.instagramHandle == null)
                                _buildAddInfoButton(
                                  AppLocalizations.of(context).addInstagram,
                                  Icons.camera_alt,
                                  Colors.pink,
                                  () => _showAddInfoDialog('Instagram', 'instagram'),
                                ),
                              
                              // Meslek Ekleme
                              if (currentUser!.profession == null)
                                _buildAddInfoButton(
                                  AppLocalizations.of(context).addProfession,
                                  Icons.work,
                                  Colors.blue,
                                  () => _showAddInfoDialog('Meslek', 'profession'),
                                ),
                              
                              if (currentUser!.instagramHandle != null || currentUser!.profession != null)
                                const Text(
                                  'Premium bilgileriniz eklendi! Görünürlük ayarlarını aşağıdan yapabilirsiniz.',
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
                              const Text(
                                '💎 Premium Bilgi Görünürlüğü',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Bu bilgileri diğer kullanıcılar coin harcayarak görebilir',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              
                              // Instagram Görünürlük
                              if (currentUser!.instagramHandle != null)
                                SwitchListTile(
                                  title: const Text('Instagram Hesabı'),
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
                                  title: const Text('Meslek'),
                                  subtitle: Text(currentUser!.profession!),
                                  value: currentUser!.showProfession,
                                  onChanged: (value) async {
                                    await UserService.updatePremiumVisibility(showProfession: value);
                                    await loadUserData();
                                  },
                                  secondary: const Icon(Icons.work, color: Colors.blue),
                                ),
                              
                              if (currentUser!.instagramHandle == null && currentUser!.profession == null)
                                const Text(
                                  'Instagram ve meslek bilgilerini ayarlardan ekleyerek bu özelliği kullanabilirsin',
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
                              const Text(
                                'İstatistikler',
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
                                      const Text('Toplam Match'),
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
                                      const Text('Kazanma'),
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
                                      const Text('Kazanma Oranı'),
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
                              const Text(
                                '🎯 Tahmin İstatistikleri',
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
                                      const Text('Toplam Tahmin'),
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
                                      const Text('Doğru Tahmin'),
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
                                      const Text('Başarı Oranı'),
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
                                      'Tahminlerden Kazanılan: ${predictionStats['total_coins_earned'] ?? 0} coin',
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
                          title: const Text(
                            '📊 Match Geçmişi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'Son 5 matchinizi ve rakiplerinizi görün (5 coin)',
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
                              const Text(
                                'Matchlere Açık',
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
                                            ? 'Artık matchlerde görüneceksiniz!'
                                            : 'Matchlerden çıkarıldınız!'
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
                                const Text(
                                  'Premium Bilgiler',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                if (currentUser!.instagramHandle != null)
                                  _buildInfoCard('Instagram', currentUser!.instagramHandle!),
                                if (currentUser!.profession != null)
                                  _buildInfoCard('Meslek', currentUser!.profession!),
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
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$type Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$type bilginizi girin:'),
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
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await _addPremiumInfo(field, controller.text.trim());
              }
            },
            child: const Text('Ekle'),
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
            content: Text('✅ ${field == 'instagram' ? 'Instagram' : 'Meslek'} bilgisi eklendi!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Bilgi eklenirken hata oluştu!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
      );
    }
  }
}