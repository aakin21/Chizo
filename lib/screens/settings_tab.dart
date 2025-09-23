import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/coin_transaction_model.dart';
import '../services/user_service.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import '../widgets/language_selector.dart';
import 'coin_purchase_screen.dart';
import 'login_screen.dart';

class SettingsTab extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;
  
  const SettingsTab({super.key, this.onLanguageChanged});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  UserModel? currentUser;
  bool isLoading = true;
  bool isUpdating = false;

  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  String? _selectedCountry;


  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    setState(() => isLoading = true);
    try {
      final user = await UserService.getCurrentUser();
      setState(() {
        currentUser = user;
        isLoading = false;
      });
      
      if (user != null) {
        _usernameController.text = user.username;
        _ageController.text = user.age?.toString() ?? '';
        _selectedCountry = user.country;
        _genderController.text = user.gender ?? '';
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  Future<void> _updateProfile() async {
    setState(() => isUpdating = true);
    
    try {
      final success = await UserService.updateProfile(
        username: _usernameController.text.trim(),
        age: _ageController.text.trim().isNotEmpty 
            ? int.tryParse(_ageController.text.trim()) 
            : null,
        country: _selectedCountry,
        gender: _genderController.text.trim().isNotEmpty 
            ? _genderController.text.trim() 
            : null,
      );
      
      if (success) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdateFailed)),
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentUser == null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.userInfoNotLoaded),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.profileSettings,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Temel Bilgiler
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.basicInfo,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.username,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.age,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedCountry != null && AppConstants.countries.contains(_selectedCountry) 
                        ? _selectedCountry 
                        : null,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.country,
                      border: const OutlineInputBorder(),
                    ),
                    items: AppConstants.countries.map((country) => 
                      DropdownMenuItem(value: country, child: Text(country))
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _genderController.text.isNotEmpty ? _genderController.text : null,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.gender,
                      border: const OutlineInputBorder(),
                    ),
                    items: AppConstants.genders.map((gender) => 
                      DropdownMenuItem(value: gender, child: Text(gender))
                    ).toList(),
                    onChanged: (value) {
                      _genderController.text = value ?? '';
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Premium Bilgiler
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.premiumInfoSettings,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.premiumInfoDescriptionSettings,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Coin Bilgileri
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.coinInfo,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '${AppLocalizations.of(context)!.currentCoins}: ${currentUser!.coins}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CoinPurchaseScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: Text(AppLocalizations.of(context)!.purchaseCoins),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Reklam İzle
                  Card(
                    color: Colors.purple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.play_circle, color: Colors.purple),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.watchAd,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.dailyAdLimit,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(AppLocalizations.of(context)!.coinsPerAd),
                              const Spacer(),
                              FutureBuilder<int>(
                                future: _getTodayAdCount(),
                                builder: (context, snapshot) {
                                  final adCount = snapshot.data ?? 0;
                                  final remainingAds = 5 - adCount;
                                  return Text(
                                    '${AppLocalizations.of(context)!.remaining}: $remainingAds/5',
                                    style: TextStyle(
                                      color: remainingAds > 0 ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FutureBuilder<int>(
                              future: _getTodayAdCount(),
                              builder: (context, snapshot) {
                                final adCount = snapshot.data ?? 0;
                                final canWatchAd = adCount < 5;
                                
                                return ElevatedButton.icon(
                                  onPressed: canWatchAd ? _watchAd : null,
                                  icon: const Icon(Icons.play_arrow),
                                  label: Text(canWatchAd ? AppLocalizations.of(context)!.watchAdButton : AppLocalizations.of(context)!.dailyLimitReached),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canWatchAd ? Colors.purple : Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  FutureBuilder<List<CoinTransactionModel>>(
                    future: UserService.getCoinTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.recentTransactions,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...snapshot.data!.take(3).map((transaction) => 
                              ListTile(
                                leading: Icon(
                                  transaction.type == 'earned' 
                                      ? Icons.add_circle 
                                      : Icons.remove_circle,
                                  color: transaction.type == 'earned' 
                                      ? Colors.green 
                                      : Colors.red,
                                ),
                                title: Text(transaction.description),
                                subtitle: Text(
                                  '${transaction.amount > 0 ? '+' : ''}${transaction.amount} coin',
                                  style: TextStyle(
                                    color: transaction.amount > 0 
                                        ? Colors.green 
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  _formatDate(transaction.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return Text(AppLocalizations.of(context)!.noTransactionHistory);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Hesap Ayarları
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.accountSettings,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Şifre Değiştir
                  ListTile(
                    leading: const Icon(Icons.lock_reset, color: Colors.blue),
                    title: Text(AppLocalizations.of(context)!.passwordReset),
                    subtitle: Text(AppLocalizations.of(context)!.passwordResetSubtitle),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showPasswordResetDialog,
                  ),
                  
                  const Divider(),
                  
                  // Dil Seçimi
                  FutureBuilder<Locale>(
                    future: LanguageService.getCurrentLocale(),
                    builder: (context, snapshot) {
                      final currentLocale = snapshot.data ?? const Locale('tr', 'TR');
                      final languageName = LanguageService.getLanguageNameWithContext(context, currentLocale.languageCode);
                      final languageFlag = LanguageService.getLanguageFlag(currentLocale.languageCode);
                      
                      return ListTile(
                        leading: const Icon(Icons.language, color: Colors.green),
                        title: Text(AppLocalizations.of(context)!.language),
                        subtitle: Text('$languageFlag $languageName'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _showLanguageDialog,
                      );
                    },
                  ),
                  
                  const Divider(),
                  
                  // Çıkış Yap
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.orange),
                    title: Text(AppLocalizations.of(context)!.logout),
                    subtitle: Text(AppLocalizations.of(context)!.logoutSubtitle),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showLogoutDialog,
                  ),
                  
                  const Divider(),
                  
                  // Hesabı Sil
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: Text(AppLocalizations.of(context)!.deleteAccount),
                    subtitle: Text(AppLocalizations.of(context)!.deleteAccountSubtitle),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showDeleteAccountDialog,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Güncelle Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isUpdating ? null : _updateProfile,
              child: isUpdating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(AppLocalizations.of(context)!.updateProfile),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Şifre sıfırlama dialog'u
  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.passwordResetTitle),
          content: Text(AppLocalizations.of(context)!.passwordResetMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _sendPasswordResetEmail();
              },
              child: Text(AppLocalizations.of(context)!.send),
            ),
          ],
        );
      },
    );
  }

  // E-posta ile şifre sıfırlama gönder
  Future<void> _sendPasswordResetEmail() async {
    try {
      if (currentUser?.email != null) {
        await Supabase.instance.client.auth.resetPasswordForEmail(
          currentUser!.email,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordResetSent),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.emailNotFound),
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
    }
  }

  // Dil seçimi dialog'u
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.language),
          content: SizedBox(
            width: double.maxFinite,
            child: LanguageSelector(
              onLanguageChanged: (locale) {
                Navigator.of(context).pop();
                // Dil değişikliğini uygula
                widget.onLanguageChanged?.call(locale);
                _restartApp();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.success),
            ),
          ],
        );
      },
    );
  }

  // Uygulamayı yeniden başlat
  void _restartApp() {
    // Bu basit bir restart - gerçek uygulamada daha gelişmiş restart mekanizması kullanılabilir
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.success),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Çıkış yap dialog'u
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logout),
          content: Text(
            AppLocalizations.of(context)!.logoutConfirmation,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
        );
      },
    );
  }

  // Çıkış yap
  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.logoutError}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hesap silme dialog'u
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteAccount),
          content: Text(
            AppLocalizations.of(context)!.deleteAccountConfirmation,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _showDeleteAccountConfirmation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.deleteAccount),
            ),
          ],
        );
      },
    );
  }

  // Hesap silme onay dialog'u
  Future<void> _showDeleteAccountConfirmation() async {
    final TextEditingController confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.finalConfirmation),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.typeDeleteToConfirm,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: AppLocalizations.of(context)!.typeDeleteToConfirm,
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
              onPressed: () async {
                if (confirmController.text.trim() == 'SİL') {
                  Navigator.of(context).pop();
                  await _deleteAccount();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.pleaseTypeDelete),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.deleteAccount),
            ),
          ],
        );
      },
    );
  }

  // Hesabı sil
  Future<void> _deleteAccount() async {
    try {
      // Önce kullanıcıyı sil
      await Supabase.instance.client.auth.admin.deleteUser(
        Supabase.instance.client.auth.currentUser!.id,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.accountDeletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        
        // Login ekranına yönlendir
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorDeletingAccount}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Bugünkü reklam sayısını al
  Future<int> _getTodayAdCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD formatında
      final adCount = prefs.getInt('ad_count_$today') ?? 0;
      return adCount;
    } catch (e) {
      return 0;
    }
  }

  // Reklam izle
  Future<void> _watchAd() async {
    try {
      // Reklam izleme simülasyonu (gerçek reklam entegrasyonu için buraya reklam SDK'sı eklenebilir)
      await _showAdDialog();
      
      // Reklam sayısını artır
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final currentCount = prefs.getInt('ad_count_$today') ?? 0;
      await prefs.setInt('ad_count_$today', currentCount + 1);
      
      // Coin ekle
      await _addCoinsFromAd();
      
      // UI'yi güncelle
      setState(() {});
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorWatchingAd}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Reklam dialog'u göster
  Future<void> _showAdDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.watchingAd),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.adLoading),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.adSimulation,
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // Reklamdan coin ekle
  Future<void> _addCoinsFromAd() async {
    try {
      // UserService'e coin ekleme fonksiyonu çağır
      final success = await UserService.updateCoins(20, 'earned', 'Reklam izleme');
      
      if (success) {
        // Kullanıcı verilerini yenile
        await loadUserData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.adWatched),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorAddingCoins),
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
    }
  }
}
