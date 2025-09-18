import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/image_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserModel? currentUser;
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() => isLoading = true);
    try {
      final user = await UserService.getCurrentUser();
      setState(() {
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
              const SnackBar(content: Text('Profil fotoğrafı güncellendi!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil güncellenirken hata oluştu')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fotoğraf yüklenemedi')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf seçilmedi')),
        );
      }
    } catch (e) {
      print('Error in _uploadImage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        leading: BackButton(onPressed: () {
          Navigator.pop(context); // HomeScreen'e döner
        }),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentUser == null
              ? const Center(child: Text('Kullanıcı bilgileri yüklenemedi'))
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
                      _buildInfoCard('Kullanıcı Adı', currentUser!.username),
                      _buildInfoCard('Email', currentUser!.email),
                      _buildInfoCard('Coin', '${currentUser!.coins}'),

                      if (currentUser!.age != null)
                        _buildInfoCard('Yaş', '${currentUser!.age}'),

                      if (currentUser!.country != null)
                        _buildInfoCard('Ülke', currentUser!.country!),

                      if (currentUser!.gender != null)
                        _buildInfoCard('Cinsiyet', currentUser!.gender!),

                      const SizedBox(height: 24),

                      // İstatistikler
                      FutureBuilder<Map<String, int>>(
                        future: UserService.getUserStats(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final stats = snapshot.data!;
                            return Card(
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
                                        _buildStatItem('Kazanma', '${stats['wins'] ?? 0}'),
                                        _buildStatItem('Toplam Maç', '${stats['totalMatches'] ?? 0}'),
                                        _buildStatItem('Kazanma Oranı', '%${stats['winRate'] ?? 0}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
