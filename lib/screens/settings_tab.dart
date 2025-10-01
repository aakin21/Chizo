import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/compact_language_selector.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../utils/navigation.dart';
import '../services/account_service.dart';
import '../services/global_language_service.dart';
import '../services/global_theme_service.dart';

class SettingsTab extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;
  final Function(String)? onThemeChanged;
  
  const SettingsTab({super.key, this.onLanguageChanged, this.onThemeChanged});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  UserModel? _currentUser;
  bool _isLoggingOut = false;
  
  
  // Marketing Settings
  bool _marketingEmailsEnabled = true;

  final List<String> _themeOptions = ['Beyaz', 'Koyu', 'Pembemsi'];
  String _selectedTheme = 'Beyaz';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSavedTheme();
    _loadMarketingSettings();
  }


  Future<void> _loadMarketingSettings() async {
    try {
      // Load marketing settings
      final prefs = await SharedPreferences.getInstance();
      _marketingEmailsEnabled = prefs.getBool('marketing_emails_enabled') ?? true;
      
      setState(() {});
    } catch (e) {
      // // print('Error loading marketing settings: $e');
      setState(() {}); // still show default preferences
    }
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
      // // print('Error loading user data: $e');
    }
  }


  String _getThemeName(String theme) {
    switch (theme) {
      case 'Beyaz':
        return AppLocalizations.of(context)!.whiteThemeName;
      case 'Koyu':
        return AppLocalizations.of(context)!.darkThemeName;
      case 'Pembemsi':
        return AppLocalizations.of(context)!.pinkThemeName;
      default:
        return theme;
    }
  }

  String _getThemeDescription(String theme) {
    switch (theme) {
      case 'Beyaz':
        return AppLocalizations.of(context)!.lightWhiteTheme;
      case 'Koyu':
        return AppLocalizations.of(context)!.darkMaterialTheme;
      case 'Pembemsi':
        return AppLocalizations.of(context)!.lightPinkTheme;
      default:
        return '';
    }
  }

  Future<void> _applyTheme(String theme) async {
    // Global theme servisini kullan - restart atmıyor
    await GlobalThemeService().changeTheme(theme);
    
    setState(() {
      _selectedTheme = theme;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.themeChanged(_getThemeName(theme))),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }



  Future<void> _deleteAccount() async {
    String? selectedReason;
    final reasons = <String>[
      'Sıkıldım',
      'Yetersiz uygulama',
      'Biraz araya ihtiyacım var',
      'Daha iyi bir uygulama buldum',
    ];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.deleteAccount),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.deleteAccountWarning),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Hesabı silme sebebiniz nedir?', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  const SizedBox(height: 8),
                  ...reasons.map((r) => RadioListTile<String>(
                        title: Text(r),
                        value: r,
                        groupValue: selectedReason,
                        onChanged: (val) => setInnerState(() => selectedReason = val),
                      )),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: selectedReason == null
                      ? null
                      : () async {
                          Navigator.pop(context);
                          if (_currentUser == null) return;
                          try {
                            await AccountService.deleteAccountCompletely(
                              reason: selectedReason!,
                            );
                          } catch (_) {}
                          // Redirect to login
                          final nav = rootNavigatorKey.currentState;
                          nav?.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => LoginScreen(onLanguageChanged: widget.onLanguageChanged)),
                            (route) => false,
                          );
                        },
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _logout() {
    if (_isLoggingOut) return; // Zaten çıkış yapılıyorsa işlemi engelle
    
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog dışına tıklayarak kapatmayı engelle
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: _isLoggingOut ? null : () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: _isLoggingOut ? null : () async {
              if (_isLoggingOut) return; // Çift tıklamayı engelle
              
              setState(() {
                _isLoggingOut = true;
              });
              
              Navigator.pop(context);
              
              try {
                // Sign out
                await Supabase.instance.client.auth.signOut();
                // Global navigator ile anında yönlendir
                final nav = rootNavigatorKey.currentState;
                nav?.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(onLanguageChanged: widget.onLanguageChanged),
                  ),
                  (route) => false,
                );
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isLoggingOut = false;
                  });
                  // Hata durumunda basit fallback
                  // (SnackBar kullanımı deactivated context hatasına yol açabiliyor)
                }
              } finally {
                // Güvenlik için flag'i sıfırla (navigasyon başarısız olsa da)
                if (mounted) {
                  setState(() {
                    _isLoggingOut = false;
                  });
                }
              }
            },
            child: _isLoggingOut 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  AppLocalizations.of(context)!.logoutButton,
                  style: const TextStyle(color: Colors.red),
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
          
          // Tema ve Görünüm
          _buildSectionCard(
            title: AppLocalizations.of(context)!.themeSelection,
            children: [
              ..._themeOptions.map((theme) => RadioListTile<String>(
                title: Text(_getThemeName(theme)),
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
              )),
            ],
          ),

          const SizedBox(height: 24),

          
          // Uygulama Ayarları
          _buildSectionCard(
            title: AppLocalizations.of(context)!.appSettings,
            children: [
              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.purple),
                title: Text(AppLocalizations.of(context)!.dailyRewards),
                subtitle: Text(AppLocalizations.of(context)!.dailyRewardsSubtitle),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showDailyStreakDialog,
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: Text(AppLocalizations.of(context)!.aboutApp),
                subtitle: const Text('${AppConstants.appName} v${AppConstants.appVersion}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Dil Ayarları
          _buildSectionCard(
            title: '🌍 ${AppLocalizations.of(context)!.language}',
            children: [
              ListTile(
                leading: const Icon(Icons.language, color: Colors.blue),
                title: Text(AppLocalizations.of(context)!.language),
                subtitle: Text('Select your preferred language'),
                trailing: CompactLanguageSelector(
                  onLanguageChanged: (locale) async {
                    // Global dil servisini kullan
                    await GlobalLanguageService().changeLanguage(locale);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Pazarlama Ayarları
          _buildSectionCard(
            title: '📧 Pazarlama Ayarları',
            children: [
              ListTile(
                leading: const Icon(Icons.email, color: Colors.orange),
                title: const Text('Pazarlama E-postaları'),
                subtitle: const Text('Promosyon e-postaları ve güncellemeleri al'),
                trailing: Switch(
                  value: _marketingEmailsEnabled,
                  onChanged: (value) async {
                    await _updateMarketingEmails(value);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Hesap İşlemleri - En alt kısımda
          _buildSectionCard(
            title: AppLocalizations.of(context)!.accountOperations,
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: Text(AppLocalizations.of(context)!.logout),
                subtitle: Text(AppLocalizations.of(context)!.logout),
                trailing: _isLoggingOut 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_ios),
                enabled: !_isLoggingOut, // Loading sırasında disable et
                onTap: _logout,
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.deleteAccount),
                subtitle: Text(AppLocalizations.of(context)!.deleteAccountSubtitle),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _deleteAccount,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
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
          title: Text(AppLocalizations.of(context)!.dailyStreakRewards),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.dailyStreakDescription),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.day1_2Reward),
                Text(AppLocalizations.of(context)!.day3_6Reward),
                Text(AppLocalizations.of(context)!.day7PlusReward),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.ok),
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
        Text(AppLocalizations.of(context)!.appDescription),
      ],
    );
  }


  // Marketing Functions


  Future<void> _updateMarketingEmails(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('marketing_emails_enabled', value);
      setState(() {
        _marketingEmailsEnabled = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value 
          ? 'Marketing emails enabled' 
          : 'Marketing emails disabled'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

}
