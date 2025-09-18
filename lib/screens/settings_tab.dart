import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/coin_transaction_model.dart';
import '../services/user_service.dart';
import 'coin_purchase_screen.dart';
import 'login_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

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
  final _instagramController = TextEditingController();
  final _professionController = TextEditingController();
  String? _selectedCountry;

  // Avrupa ülkeleri + Türkiye listesi
  static const List<String> _countries = [
    'turkiye',
    'Almanya',
    'Fransa',
    'İtalya',
    'İspanya',
    'Hollanda',
    'Belçika',
    'Avusturya',
    'İsviçre',
    'Polonya',
    'Çek Cumhuriyeti',
    'Macaristan',
    'Romanya',
    'Bulgaristan',
    'Hırvatistan',
    'Slovenya',
    'Slovakya',
    'Estonya',
    'Letonya',
    'Litvanya',
    'Finlandiya',
    'İsveç',
    'Norveç',
    'Danimarka',
    'Portekiz',
    'Yunanistan',
    'Kıbrıs',
    'Malta',
    'Lüksemburg',
    'İrlanda',
    'İngiltere',
    'İzlanda',
  ];

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
    _instagramController.dispose();
    _professionController.dispose();
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
        _instagramController.text = user.instagramHandle ?? '';
        _professionController.text = user.profession ?? '';
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
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
        instagramHandle: _instagramController.text.trim().isNotEmpty 
            ? _instagramController.text.trim() 
            : null,
        profession: _professionController.text.trim().isNotEmpty 
            ? _professionController.text.trim() 
            : null,
      );
      
      if (success) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellenirken hata oluştu')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
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
      return const Center(
        child: Text('Kullanıcı bilgileri yüklenemedi'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Ayarları',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Temel Bilgiler
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temel Bilgiler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Yaş',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedCountry != null && _countries.contains(_selectedCountry) 
                        ? _selectedCountry 
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Ülke',
                      border: OutlineInputBorder(),
                    ),
                    items: _countries.map((country) => 
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
                    decoration: const InputDecoration(
                      labelText: 'Cinsiyet',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                      DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                    ],
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
                  const Text(
                    'Premium Bilgiler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bu bilgileri diğer kullanıcılar coin harcayarak görebilir',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _instagramController,
                    decoration: const InputDecoration(
                      labelText: 'Instagram Hesabı (10 coin)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.camera_alt),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _professionController,
                    decoration: const InputDecoration(
                      labelText: 'Meslek (5 coin)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                  ),
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
                  const Text(
                    'Coin Bilgileri',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Mevcut Coin: ${currentUser!.coins}',
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
                        label: const Text('Coin Satın Al'),
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
                              const Text(
                                'Reklam İzle',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Günde maksimum 5 reklam izleyebilirsiniz',
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
                              const Text('Reklam başına: 20 coin'),
                              const Spacer(),
                              FutureBuilder<int>(
                                future: _getTodayAdCount(),
                                builder: (context, snapshot) {
                                  final adCount = snapshot.data ?? 0;
                                  final remainingAds = 5 - adCount;
                                  return Text(
                                    'Kalan: $remainingAds/5',
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
                                  label: Text(canWatchAd ? 'Reklam İzle' : 'Günlük limit doldu'),
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
                            const Text(
                              'Son İşlemler:',
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
                      return const Text('Henüz işlem geçmişi yok');
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
                  const Text(
                    'Hesap Ayarları',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Şifre Değiştir
                  ListTile(
                    leading: const Icon(Icons.lock_reset, color: Colors.blue),
                    title: const Text('Şifre Değiştir'),
                    subtitle: const Text('E-posta ile şifre sıfırlama'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showPasswordResetDialog,
                  ),
                  
                  const Divider(),
                  
                  // Dil Seçimi
                  ListTile(
                    leading: const Icon(Icons.language, color: Colors.green),
                    title: const Text('Dil Seçimi'),
                    subtitle: const Text('Türkçe'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showLanguageDialog,
                  ),
                  
                  const Divider(),
                  
                  // Çıkış Yap
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.orange),
                    title: const Text('Çıkış Yap'),
                    subtitle: const Text('Hesabınızdan güvenli çıkış'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showLogoutDialog,
                  ),
                  
                  const Divider(),
                  
                  // Hesabı Sil
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Hesabı Sil'),
                    subtitle: const Text('Hesabınızı kalıcı olarak silin'),
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
                  : const Text('Profili Güncelle'),
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
          title: const Text('Şifre Sıfırlama'),
          content: const Text(
            'E-posta adresinize şifre sıfırlama bağlantısı gönderilecek. Devam etmek istiyor musunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _sendPasswordResetEmail();
              },
              child: const Text('Gönder'),
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
          const SnackBar(
            content: Text('Şifre sıfırlama e-postası gönderildi!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-posta adresi bulunamadı!'),
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

  // Dil seçimi dialog'u
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dil Seçimi'),
          content: const Text(
            'Dil seçimi özelliği yakında eklenecek!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  // Çıkış yap dialog'u
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text(
            'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
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
              child: const Text('Çıkış Yap'),
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
          content: Text('Çıkış yapılırken hata oluştu: $e'),
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
          title: const Text('Hesabı Sil'),
          content: const Text(
            'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinecektir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
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
              child: const Text('Hesabı Sil'),
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
          title: const Text('Son Onay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hesabınızı silmek için "SİL" yazın:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'SİL yazın',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (confirmController.text.trim() == 'SİL') {
                  Navigator.of(context).pop();
                  await _deleteAccount();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen "SİL" yazın!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hesabı Sil'),
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
          const SnackBar(
            content: Text('Hesabınız başarıyla silindi!'),
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
          content: Text('Hesap silinirken hata oluştu: $e'),
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
          content: Text('Reklam izlenirken hata oluştu: $e'),
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
          title: const Text('Reklam İzleniyor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Reklam yükleniyor...'),
              const SizedBox(height: 16),
              const Text(
                'Bu simülasyon reklamıdır. Gerçek uygulamada burada reklam gösterilecektir.',
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
          const SnackBar(
            content: Text('Reklam izlendi! +20 coin kazandınız!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coin eklenirken hata oluştu'),
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
