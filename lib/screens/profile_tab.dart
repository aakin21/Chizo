import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/prediction_service.dart';
import '../services/photo_upload_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import '../widgets/country_selector.dart';
import '../widgets/gender_selector.dart';
import '../services/country_service.dart';
import '../models/country_model.dart';
import 'match_history_screen.dart';
import 'coin_purchase_screen.dart';
import 'country_ranking_screen.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dil değişiminde ülke ismini yeniden yükle
    if (currentUser?.countryCode != null) {
      _loadCountryName();
    }
  }

  Future<void> _loadCountryName() async {
    if (currentUser?.countryCode != null) {
      try {
        await CountryService.getCountryByCode(
          currentUser!.countryCode!,
          Localizations.localeOf(context).languageCode
        );
        if (mounted) {
          setState(() {
            // Country name loaded
          });
        }
      } catch (e) {
        print('Error loading country name: $e');
      }
    }
  }

  Future<String?> _getCountryName(String countryCode) async {
    try {
      final country = await CountryService.getCountryByCode(
        countryCode,
        Localizations.localeOf(context).languageCode
      );
      return country?.name;
    } catch (e) {
      print('Error loading country name: $e');
      return countryCode;
    }
  }

  Future<String?> _getGenderName(String genderCode) async {
    try {
      // Geçici olarak hardcoded gender names kullan
      final currentLanguage = Localizations.localeOf(context).languageCode;
      
      switch (genderCode) {
        case 'M':
          switch (currentLanguage) {
            case 'tr': return 'Erkek';
            case 'de': return 'Männlich';
            case 'es': return 'Masculino';
            default: return 'Male';
          }
        case 'F':
          switch (currentLanguage) {
            case 'tr': return 'Kadın';
            case 'de': return 'Weiblich';
            case 'es': return 'Femenino';
            default: return 'Female';
          }
        case 'O':
          switch (currentLanguage) {
            case 'tr': return 'Diğer';
            case 'de': return 'Andere';
            case 'es': return 'Otro';
            default: return 'Other';
          }
        default:
          return genderCode;
      }
    } catch (e) {
      print('Error loading gender name: $e');
      return genderCode;
    }
  }

  Future<void> loadUserData() async {
    setState(() => isLoading = true);
    
    try {
      final user = await UserService.getCurrentUser();
      final stats = await PredictionService.getUserPredictionStats();
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
        
        // Kullanıcının ülke ismini yükle
        if (user.countryCode != null) {
          try {
            await CountryService.getCountryByCode(
              user.countryCode!,
              Localizations.localeOf(context).languageCode
            );
          } catch (e) {
            print('Error loading country name: $e');
          }
        }
      }
      
      if (mounted) {
        setState(() {
          currentUser = user;
          predictionStats = stats;
          userPhotos = photos;
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
            content: Text('${AppLocalizations.of(context)!.error}: ${result['message']}'),
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
                      content: Text('${AppLocalizations.of(context)!.error}: ${result['message']}'),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? _buildProfileSkeletonScreen()
          : currentUser == null
              ? Center(child: Text(AppLocalizations.of(context)!.userInfoNotLoaded))
              : SingleChildScrollView(
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

                      // Kullanıcı Bilgileri
                      _buildEditableInfoCard(AppLocalizations.of(context)!.username, currentUser!.username, 'username'),
                      _buildEditableInfoCard(AppLocalizations.of(context)!.email, currentUser!.email, 'email'),

                      if (currentUser!.age != null)
                        _buildEditableInfoCard(AppLocalizations.of(context)!.age, '${currentUser!.age}', 'age'),
                      if (currentUser!.age == null)
                        _buildAddInfoButton(AppLocalizations.of(context)!.addAge, Icons.cake, Colors.orange, () => _showEditDialog('age', '')),

                      if (currentUser!.countryCode != null)
                        FutureBuilder<String?>(
                          future: _getCountryName(currentUser!.countryCode!),
                          builder: (context, snapshot) {
                            final countryName = snapshot.data ?? currentUser!.countryCode!;
                            return _buildEditableInfoCard(AppLocalizations.of(context)!.country, countryName, 'country');
                          },
                        ),
                      if (currentUser!.countryCode == null)
                        _buildAddInfoButton(AppLocalizations.of(context)!.addCountry, Icons.public, Colors.blue, () => _showEditDialog('country', '')),

                      if (currentUser!.genderCode != null)
                        FutureBuilder<String?>(
                          future: _getGenderName(currentUser!.genderCode!),
                          builder: (context, snapshot) {
                            final genderName = snapshot.data ?? currentUser!.genderCode!;
                            return _buildEditableInfoCard('Gender', genderName, 'gender');
                          },
                        ),
                      if (currentUser!.genderCode == null)
                        _buildAddInfoButton('Add Gender', Icons.person, Colors.purple, () => _showEditDialog('gender', '')),

                      // Coin Bilgisi ve İşlemleri - Gender'dan sonra
                      _buildInfoCard(AppLocalizations.of(context)!.coin, '${currentUser!.coins}'),

                      // Coin İşlemleri
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.local_activity,
                            color: Colors.amber,
                            size: 28,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.purchaseCoinPackage,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.purchaseCoinPackageSubtitle,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CoinPurchaseScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Instagram ve Meslek Bilgileri
                      if (currentUser!.instagramHandle != null)
                        _buildEditableInfoCard(AppLocalizations.of(context)!.instagramAccount, '@${currentUser!.instagramHandle!}', 'instagram'),
                      if (currentUser!.instagramHandle == null)
                        _buildAddInfoButton(AppLocalizations.of(context)!.addInstagram, Icons.camera_alt, Colors.pink, () => _showEditDialog('instagram', '')),

                      if (currentUser!.profession != null)
                        _buildEditableInfoCard(AppLocalizations.of(context)!.profession, currentUser!.profession!, 'profession'),
                      if (currentUser!.profession == null)
                        _buildAddInfoButton(AppLocalizations.of(context)!.addProfession, Icons.work, Colors.blue, () => _showEditDialog('profession', '')),

                      const SizedBox(height: 24),


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

                      const SizedBox(height: 16),

                      // Ülke Seçimi Butonu
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.public,
                            color: Colors.blue,
                            size: 28,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.countrySelection,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            currentUser!.countryPreferences != null 
                                ? AppLocalizations.of(context)!.countriesSelected(currentUser!.countryPreferences!.length)
                                : AppLocalizations.of(context)!.allCountriesSelected,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: isUpdating ? null : _showCountrySelectionDialog,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Yaş Aralığı Seçimi Butonu
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.cake,
                            color: Colors.orange,
                            size: 28,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.ageRangeSelection,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            currentUser!.ageRangePreferences != null 
                                ? AppLocalizations.of(context)!.ageRangesSelected(currentUser!.ageRangePreferences!.length)
                                : AppLocalizations.of(context)!.allAgeRangesSelected,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: isUpdating ? null : _showAgeRangeSelectionDialog,
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

  Widget _buildEditableInfoCard(String label, String value, String field) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _showEditDialog(field, value),
        ),
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
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
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
      case 'age':
        title = AppLocalizations.of(context)!.editAge;
        hint = AppLocalizations.of(context)!.enterAge;
        icon = Icons.cake;
        keyboardType = TextInputType.number;
        break;
      case 'country':
        title = AppLocalizations.of(context)!.selectCountry;
        hint = AppLocalizations.of(context)!.selectYourCountry;
        icon = Icons.public;
        break;
      case 'gender':
        title = 'Select Gender';
        hint = 'Select your gender';
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
            if (field == 'country')
              CountrySelector(
                key: ValueKey(Localizations.localeOf(context).languageCode),
                selectedCountryCode: currentValue.isNotEmpty ? currentValue : null,
                onCountrySelected: (countryCode) {
                  controller.text = countryCode ?? '';
                },
              )
            else if (field == 'gender')
              GenderSelector(
                key: ValueKey(Localizations.localeOf(context).languageCode),
                selectedGenderCode: currentValue.isNotEmpty ? currentValue : null,
                onGenderSelected: (genderCode) {
                  controller.text = genderCode ?? '';
                },
              )
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
        case 'age':
          final age = int.tryParse(value);
          if (age != null) {
            success = await UserService.updateProfile(age: age);
          }
          break;
        case 'country':
          success = await UserService.updateProfile(countryCode: value);
          break;
        case 'gender':
          success = await UserService.updateProfile(genderCode: value);
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

  // Ülke seçimi dialog'u
  Future<void> _showCountrySelectionDialog() async {
    if (currentUser == null) return;
    
    // Mevcut dilde ülke listesini al
    final countries = await CountryService.getCountriesByLanguage(
      Localizations.localeOf(context).languageCode
    );
    final countryCodes = countries.map((c) => c.code).toList();
    
    // Mevcut seçili ülkeleri al (eğer yoksa tüm ülkeler seçili olsun)
    List<String> selectedCountries = currentUser!.countryPreferences ?? countryCodes;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.countrySelection),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.countrySelection,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Country>>(
                    future: CountryService.getCountriesByLanguage(
                      Localizations.localeOf(context).languageCode
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (!snapshot.hasData) {
                        return const Center(child: Text('Ülkeler yüklenemedi'));
                      }
                      
                      final countries = snapshot.data!;
                      return ListView.builder(
                        itemCount: countries.length,
                        itemBuilder: (context, index) {
                          final country = countries[index];
                          final isSelected = selectedCountries.contains(country.code);
                          
                          return CheckboxListTile(
                            title: Text(country.name),
                            value: isSelected,
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedCountries.add(country.code);
                                } else {
                                  selectedCountries.remove(country.code);
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateCountryPreferences(selectedCountries);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  // Ülke tercihlerini güncelle
  Future<void> _updateCountryPreferences(List<String> countries) async {
    setState(() => isUpdating = true);
    
    try {
      final success = await UserService.updateCountryPreferences(countries);
      
      if (success) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.countryPreferencesUpdated),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.countryPreferencesUpdateFailed),
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

  // Yaş aralığı seçimi dialog'u
  Future<void> _showAgeRangeSelectionDialog() async {
    if (currentUser == null) return;
    
    // Mevcut seçili yaş aralıklarını al (eğer yoksa tüm yaş aralıkları seçili olsun)
    List<String> selectedAgeRanges = currentUser!.ageRangePreferences ?? AppConstants.ageRanges;
    
    // Mevcut seçili yaş aralıklarından min ve max yaşları hesapla
    int minAge = 18;
    int maxAge = 100;
    
    if (selectedAgeRanges.isNotEmpty && selectedAgeRanges.length < AppConstants.ageRanges.length) {
      // Seçili yaş aralıklarından min ve max hesapla
      List<int> selectedAges = [];
      for (String range in selectedAgeRanges) {
        if (range.contains('-')) {
          final parts = range.split('-');
          if (parts.length == 2) {
            final start = int.tryParse(parts[0].trim());
            final end = int.tryParse(parts[1].trim());
            if (start != null && end != null) {
              selectedAges.addAll(List.generate(end - start + 1, (i) => start + i));
            }
          }
        }
      }
      if (selectedAges.isNotEmpty) {
        selectedAges.sort();
        minAge = selectedAges.first;
        maxAge = selectedAges.last;
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.ageRangeSelection),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: Column(
              children: [
                Text(
                  'Seçmek istediğiniz yaş aralığını belirleyin',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('Min Yaş: $minAge', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Slider(
                            value: minAge.toDouble(),
                            min: 18,
                            max: 100,
                            divisions: 82,
                            onChanged: (value) {
                              setDialogState(() {
                                minAge = value.round();
                                if (minAge >= maxAge) {
                                  maxAge = minAge;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          Text('Max Yaş: $maxAge', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Slider(
                            value: maxAge.toDouble(),
                            min: 18,
                            max: 100,
                            divisions: 82,
                            onChanged: (value) {
                              setDialogState(() {
                                maxAge = value.round();
                                if (maxAge <= minAge) {
                                  minAge = maxAge;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Seçilen yaş aralığı: $minAge - $maxAge',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Yaş aralığını string listesine çevir
                List<String> newAgeRanges = [];
                for (int age = minAge; age <= maxAge; age++) {
                  newAgeRanges.add('$age-$age');
                }
                await _updateAgeRangePreferences(newAgeRanges);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  // Yaş aralığı tercihlerini güncelle
  Future<void> _updateAgeRangePreferences(List<String> ageRanges) async {
    setState(() => isUpdating = true);
    
    try {
      final success = await UserService.updateAgeRangePreferences(ageRanges);
      
      if (success) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.ageRangePreferencesUpdated),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.ageRangePreferencesUpdateFailed),
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
}