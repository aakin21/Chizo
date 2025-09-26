import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/coin_purchase_screen.dart';
import '../widgets/language_selector.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _notificationsEnabled = true;
  bool _tournamentNotifications = true;
  bool _voteReminderNotifications = true;
  bool _winCelebrationNotifications = true;
  bool _streakReminderNotifications = true;
  UserModel? _currentUser;

  final List<String> _themeOptions = ['Beyaz', 'Koyu', 'Pembemsi'];
  String _selectedTheme = 'Beyaz';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('selected_theme') ?? 'Beyaz';
    setState(() {
      _selectedTheme = savedTheme;
    });
  }


  Future<void> _loadUserData() async {
    try {
      final user = await UserService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _onLanguageChanged(Locale locale) {
    // Full app refresh after language change
    setState(() {});
    // Force app rebuild with new locale
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dil değiştirildi. Sayfa yenileniyor...'),
        duration: const Duration(seconds: 1),
      ),
        );
      }
    });
  }

  String _getThemeDescription(String theme) {
    switch (theme) {
      case 'Beyaz':
        return 'Açık beyaz tema - Mevcut tema';
      case 'Koyu':
        return 'Siyah materyal koyu tema';
      case 'Pembemsi':
        return 'Açık pembe renk tema';
      default:
        return '';
    }
  }

  Future<void> _applyTheme(String theme) async {
    // Save theme preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);
    print('Save theme: $theme to SharedPreferences'); // Debug
    
    setState(() {
      _selectedTheme = theme;
    });
    
    // Verify save was successful
    final verifyTheme = await prefs.getString('selected_theme');
    print('Saved theme verify: $verifyTheme'); // Debug
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Tema değiştirildi: $theme - Uygulama yeniden başlatılacak'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Verify the save once more before restart
    final currentSavedTheme = await prefs.getString('selected_theme');
    print('Final verification - theme in storage: $currentSavedTheme');
    
    // Force immediate restart for reliable theme change  
    await Future.delayed(const Duration(milliseconds: 200));
    _restartApp();
  }

  void _restartApp() {
    // Force complete app restart for theme change
    print('🔄 RESTARTING APP for theme change: ${_selectedTheme}');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
      (route) => false,
    );
  }


  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Bu işlem geri alınamaz! Tüm verileriniz kalıcı olarak silinecek.\n'
          'Hesabınızı silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (_currentUser != null) {
                try {
                  // Delete user account
                  await Supabase.instance.client.from('users').delete().eq('id', _currentUser!.id);
                  
                  // Sign out
                  await Supabase.instance.client.auth.signOut();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hesabınız silindi')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Supabase.instance.client.auth.signOut();
            },
            child: const Text(
              'Çıkış',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Dil ayarları
          _buildSectionCard(
            title: '🌍 Dil / Language',
            children: [
              LanguageSelector(onLanguageChanged: _onLanguageChanged),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Tema ve Görünüm
          _buildSectionCard(
            title: '🎨 Tema Seçimi',
            children: [
              ..._themeOptions.map((theme) => RadioListTile<String>(
                title: Text(theme),
                subtitle: Text(_getThemeDescription(theme)),
                value: theme,
                groupValue: _selectedTheme,
                onChanged: (value) async {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  // Tema değiştir ve uygula
                  await _applyTheme(theme);
                },
              )).toList(),
            ],
          ),

          const SizedBox(height: 24),

          // Bildirimler
          _buildSectionCard(
            title: '🔔 Bildirim Ayarları',
            children: [
              SwitchListTile(
                title: const Text('Tüm Bildirimler'),
                subtitle: const Text('Ana bildirimleri aç/kapat'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                secondary: const Icon(Icons.notifications),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Turnuva Bildirimleri'),
                subtitle: const Text('Yeni turnuva davetleri'),
                value: _tournamentNotifications,
                onChanged: !_notificationsEnabled ? null : (value) {
                  setState(() {
                    _tournamentNotifications = value;
                  });
                },
                secondary: const Icon(Icons.emoji_events),
              ),
              SwitchListTile(
                title: const Text('Oylama Hatırlatması'),
                subtitle: const Text('Hatırlatma bildirimleri'),
                value: _voteReminderNotifications,
                onChanged: !_notificationsEnabled ? null : (value) {
                  setState(() {
                    _voteReminderNotifications = value;
                  });
                },
                secondary: const Icon(Icons.how_to_vote),
              ),
              SwitchListTile(
                title: const Text('Kazanç Kutlaması'),
                subtitle: const Text('Zafer bildirimleri'),
                value: _winCelebrationNotifications,
                onChanged: !_notificationsEnabled ? null : (value) {
                  setState(() {
                    _winCelebrationNotifications = value;
                  });
                },
                secondary: const Icon(Icons.celebration),
              ),
              SwitchListTile(
                title: const Text('Seri Hatırlatması'),
                subtitle: const Text('Günlük seri ödülleri hatırlatması'),
                value: _streakReminderNotifications,
                onChanged: !_notificationsEnabled ? null : (value) {
                  setState(() {
                    _streakReminderNotifications = value;
                  });
                },
                secondary: const Icon(Icons.local_fire_department),
              ),
            ],
          ),

          const SizedBox(height: 24),
          
          // Coin İşlemleri
          _buildSectionCard(
            title: '💰 Para & Coin İşlemleri',
            children: [
              ListTile(
                leading: const Icon(Icons.local_activity, color: Colors.amber),
                title: const Text('Coin Paketi Satın Al'),
                subtitle: const Text('Coin satın alın ve ödüller kazanın'),
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
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Uygulama Ayarları
          _buildSectionCard(
            title: '⚙️ Uygulama Ayarları',
            children: [
              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.purple),
                title: const Text('Günlük Ödüller'),
                subtitle: const Text('Seri ödülleri ve boost\'ları görün'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showDailyStreakDialog,
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('Uygulama Hakkında'),
                subtitle: const Text('${AppConstants.appName} v${AppConstants.appVersion}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Hesap İşlemleri
          _buildSectionCard(
            title: '👤 Hesap İşlemleri',
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: const Text('Çıkış Yap'),
                subtitle: const Text('Oturumu kapat'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _logout,
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Hesabı Sil'),
                subtitle: const Text('Hesabınızı kalıcı olarak sil'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _deleteAccount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showDailyStreakDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Günlük Seri Ödülleri'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎯 Her gün uygulamaya girin ve bonuslar kazanın!'),
                SizedBox(height: 12),
                Text('Day 1-2: 10-25 Coin'),
                Text('Day 3-6: 50-100 Coin'),
                Text('Day 7+: 200+ Coin & Boost'),
              ],
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

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(
        Icons.emoji_events,
        size: 48,
        color: Colors.deepPurple,
      ),
      children: [
        const Text('Sohbet odalarında oylama ve turnuva uygulaması.'),
      ],
    );
  }
}