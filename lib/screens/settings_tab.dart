import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/coin_transaction_model.dart';
import '../services/user_service.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';
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
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
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
            'Ayarlar',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Hesap Ayarları
          _buildSettingsSection(
            'Hesap',
            [
              _buildSettingsTile(
                icon: Icons.lock_reset,
                title: 'Şifre Değiştir',
                subtitle: 'Hesap güvenliğinizi artırın',
                onTap: _showPasswordResetDialog,
              ),
              _buildSettingsTile(
                icon: Icons.notifications,
                title: 'Bildirimler',
                subtitle: 'Bildirim ayarlarınızı yönetin',
                onTap: () {
                  // Bildirim ayarları
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Uygulama Ayarları
          _buildSettingsSection(
            'Uygulama',
            [
              _buildSettingsTile(
                icon: Icons.language,
                title: 'Dil',
                subtitle: 'Uygulama dilini değiştirin',
                onTap: _showLanguageDialog,
                trailing: FutureBuilder<Locale>(
                  future: LanguageService.getCurrentLocale(),
                  builder: (context, snapshot) {
                    final currentLocale = snapshot.data ?? const Locale('tr', 'TR');
                    final languageName = LanguageService.getLanguageNameWithContext(context, currentLocale.languageCode);
                    final languageFlag = LanguageService.getLanguageFlag(currentLocale.languageCode);
                    return Text('$languageFlag $languageName');
                  },
                ),
              ),
              _buildSettingsTile(
                icon: Icons.dark_mode,
                title: 'Tema',
                subtitle: 'Açık/Koyu tema seçimi',
                onTap: () {
                  // Tema ayarları
                },
                trailing: const Text('Sistem'),
              ),
              _buildSettingsTile(
                icon: Icons.storage,
                title: 'Önbellek',
                subtitle: 'Uygulama verilerini temizle',
                onTap: _showClearCacheDialog,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Coin ve Ödeme
          _buildSettingsSection(
            'Coin ve Ödeme',
            [
              _buildSettingsTile(
                icon: Icons.monetization_on,
                title: 'Coin Satın Al',
                subtitle: '${currentUser!.coins} coin',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CoinPurchaseScreen(),
                    ),
                  );
                },
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              _buildSettingsTile(
                icon: Icons.play_circle,
                title: 'Reklam İzle',
                subtitle: 'Ücretsiz coin kazanın',
                onTap: _showWatchAdDialog,
              ),
              _buildSettingsTile(
                icon: Icons.history,
                title: 'İşlem Geçmişi',
                subtitle: 'Coin işlemlerinizi görün',
                onTap: _showTransactionHistory,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Gizlilik ve Güvenlik
          _buildSettingsSection(
            'Gizlilik ve Güvenlik',
            [
              _buildSettingsTile(
                icon: Icons.visibility,
                title: 'Görünürlük',
                subtitle: 'Match\'lerde görünürlük ayarları',
                onTap: () {
                  // Görünürlük ayarları
                },
                trailing: Switch(
                  value: currentUser!.isVisible,
                  onChanged: (value) async {
                    final success = await UserService.updateProfile(isVisible: value);
                    if (success) {
                      await loadUserData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value ? 'Artık match\'lerde görünürsünüz' : 'Match\'lerden gizlendiniz'),
                        ),
                      );
                    }
                  },
                ),
              ),
              _buildSettingsTile(
                icon: Icons.report,
                title: 'Rapor Et',
                subtitle: 'Sorun bildirin veya öneride bulunun',
                onTap: _showReportDialog,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Hakkında
          _buildSettingsSection(
            'Hakkında',
            [
              _buildSettingsTile(
                icon: Icons.info,
                title: 'Uygulama Hakkında',
                subtitle: 'Sürüm 1.0.0',
                onTap: _showAboutDialog,
              ),
              _buildSettingsTile(
                icon: Icons.help,
                title: 'Yardım ve Destek',
                subtitle: 'SSS ve iletişim',
                onTap: _showHelpDialog,
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip,
                title: 'Gizlilik Politikası',
                subtitle: 'Veri kullanımı ve gizlilik',
                onTap: _showPrivacyPolicy,
              ),
              _buildSettingsTile(
                icon: Icons.description,
                title: 'Kullanım Koşulları',
                subtitle: 'Hizmet şartları ve kurallar',
                onTap: _showTermsOfService,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Hesap İşlemleri
          _buildSettingsSection(
            'Hesap İşlemleri',
            [
              _buildSettingsTile(
                icon: Icons.logout,
                title: 'Çıkış Yap',
                subtitle: 'Hesabınızdan güvenli çıkış',
                onTap: _showLogoutDialog,
                textColor: Colors.orange,
              ),
              _buildSettingsTile(
                icon: Icons.delete_forever,
                title: 'Hesabı Sil',
                subtitle: 'Hesabınızı kalıcı olarak silin',
                onTap: _showDeleteAccountDialog,
                textColor: Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.blue),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Şifre sıfırlama dialog'u
  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şifre Sıfırlama'),
          content: const Text('Şifre sıfırlama bağlantısı e-posta adresinize gönderilecek.'),
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
            content: Text('Şifre sıfırlama bağlantısı e-posta adresinize gönderildi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-posta adresi bulunamadı'),
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
          content: SizedBox(
            width: double.maxFinite,
            child: LanguageSelector(
              onLanguageChanged: (locale) {
                Navigator.of(context).pop();
                widget.onLanguageChanged?.call(locale);
              },
            ),
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

  // Önbellek temizleme dialog'u
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Önbellek Temizle'),
          content: const Text('Uygulama önbelleği temizlenecek. Bu işlem geri alınamaz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearCache();
              },
              child: const Text('Temizle'),
            ),
          ],
        );
      },
    );
  }

  // Önbellek temizle
  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önbellek temizlendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Reklam izleme dialog'u
  void _showWatchAdDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reklam İzle'),
          content: const Text('Reklam izleyerek 20 coin kazanabilirsiniz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _watchAd();
              },
              child: const Text('İzle'),
            ),
          ],
        );
      },
    );
  }

  // Reklam izle
  Future<void> _watchAd() async {
    try {
      // Reklam simülasyonu
      await Future.delayed(const Duration(seconds: 3));
      
      // Coin ekle
      final success = await UserService.updateCoins(20, 'earned', 'Reklam izleme');
      
      if (success) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reklam izlendi! 20 coin kazandınız'),
            backgroundColor: Colors.green,
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

  // İşlem geçmişi
  void _showTransactionHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İşlem Geçmişi'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: FutureBuilder<List<CoinTransactionModel>>(
              future: UserService.getCoinTransactions(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final transaction = snapshot.data![index];
                      return ListTile(
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
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  );
                }
                return const Text('İşlem geçmişi bulunamadı');
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  // Rapor dialog'u
  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rapor Et'),
          content: const Text('Sorun bildirmek veya öneride bulunmak için e-posta gönderebilirsiniz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // E-posta gönderme işlemi
              },
              child: const Text('E-posta Gönder'),
            ),
          ],
        );
      },
    );
  }

  // Hakkında dialog'u
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uygulama Hakkında'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Chizo v1.0.0'),
              SizedBox(height: 8),
              Text('Turnuva ve oylama uygulaması'),
              SizedBox(height: 8),
              Text('© 2024 Chizo Team'),
            ],
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

  // Yardım dialog'u
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yardım ve Destek'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sıkça Sorulan Sorular:'),
              SizedBox(height: 8),
              Text('• Nasıl coin kazanırım?'),
              Text('• Match nasıl oluşturulur?'),
              Text('• Fotoğraf nasıl yüklenir?'),
              SizedBox(height: 8),
              Text('Daha fazla yardım için:'),
              Text('support@chizo.com'),
            ],
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

  // Gizlilik politikası
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Gizlilik Politikası'),
          content: const SingleChildScrollView(
            child: Text(
              'Bu uygulama kullanıcı verilerini güvenli bir şekilde saklar. '
              'Kişisel bilgileriniz sadece uygulama işlevselliği için kullanılır. '
              'Verileriniz üçüncü taraflarla paylaşılmaz.',
            ),
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

  // Kullanım koşulları
  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kullanım Koşulları'),
          content: const SingleChildScrollView(
            child: Text(
              'Bu uygulamayı kullanarak aşağıdaki koşulları kabul etmiş olursunuz:\n\n'
              '• Uygulamayı yasal amaçlarla kullanacaksınız\n'
              '• Diğer kullanıcılara saygılı davranacaksınız\n'
              '• Spam veya zararlı içerik paylaşmayacaksınız\n'
              '• Uygulama kurallarına uyacaksınız',
            ),
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
          content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
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
            'Hesabınızı silmek istediğinizden emin misiniz? '
            'Bu işlem geri alınamaz ve tüm verileriniz silinecektir.',
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
                      content: Text('Lütfen "SİL" yazın'),
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
            content: Text('Hesabınız başarıyla silindi'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}