import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/compact_language_selector.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class SettingsTab extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;
  final Function(String)? onThemeChanged;
  
  const SettingsTab({super.key, this.onLanguageChanged, this.onThemeChanged});

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
  bool _isLoggingOut = false;

  final List<String> _themeOptions = ['Beyaz', 'Koyu', 'Pembemsi'];
  String _selectedTheme = 'Beyaz';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSavedTheme();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    try {
      // Load notification preferences from database
      _notificationsEnabled = await NotificationService.isNotificationEnabled('all') ?? true;
      _tournamentNotifications = await NotificationService.isNotificationEnabled('tournament') ?? true;
      _voteReminderNotifications = await NotificationService.isNotificationEnabled('vote_reminder') ?? true;
      _winCelebrationNotifications = await NotificationService.isNotificationEnabled('win_celebration') ?? true;
      _streakReminderNotifications = await NotificationService.isNotificationEnabled('streak_reminder') ?? true;
      
      setState(() {});
    } catch (e) {
      print('Error loading notification preferences: $e');
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
      print('Error loading user data: $e');
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
    // Save theme preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);
    print('Save theme: $theme to SharedPreferences'); // Debug
    
    setState(() {
      _selectedTheme = theme;
    });
    
    // Call the theme change callback if provided
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(theme);
    }
    
    // Verify save was successful
    final verifyTheme = prefs.getString('selected_theme');
    print('Saved theme verify: $verifyTheme'); // Debug
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.themeChanged(_getThemeName(theme))),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Verify the save once more before restart
    final currentSavedTheme = prefs.getString('selected_theme');
    print('Final verification - theme in storage: $currentSavedTheme');
    
    // Force immediate restart for reliable theme change  
    await Future.delayed(const Duration(milliseconds: 200));
    _restartApp();
  }

  void _restartApp() {
    // Force complete app restart for theme change
    print('🔄 RESTARTING APP for theme change: $_selectedTheme');
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
        title: Text(AppLocalizations.of(context)!.deleteAccount),
        content: Text(AppLocalizations.of(context)!.deleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
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
                    SnackBar(content: Text(AppLocalizations.of(context)!.accountDeleted)),
                  );
                  
                  // Navigate to login screen and clear all previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen(onLanguageChanged: widget.onLanguageChanged)),
                    (route) => false,
                  );
                  
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
                  );
                }
              }
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    if (_isLoggingOut) return; // Zaten çıkış yapılıyorsa işlemi engelle
    
    showDialog(
      context: context,
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
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${AppLocalizations.of(context)!.logout} successful!')),
                  );
                  
                  // Navigate to login screen and clear all previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen(onLanguageChanged: widget.onLanguageChanged)),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isLoggingOut = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
                  );
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

          // Bildirimler
          _buildSectionCard(
            title: AppLocalizations.of(context)!.notificationSettings,
            children: [
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.allNotifications),
                subtitle: Text(AppLocalizations.of(context)!.allNotificationsSubtitle),
                value: _notificationsEnabled,
                onChanged: (value) async {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  await NotificationService.updateNotificationPreference('all', value);
                },
                secondary: const Icon(Icons.notifications),
              ),
              const Divider(),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.tournamentNotifications),
                subtitle: Text(AppLocalizations.of(context)!.newTournamentInvitations),
                value: _tournamentNotifications,
                onChanged: !_notificationsEnabled ? null : (value) async {
                  setState(() {
                    _tournamentNotifications = value;
                  });
                  await NotificationService.updateNotificationPreference('tournament', value);
                },
                secondary: const Icon(Icons.emoji_events),
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.voteReminder),
                subtitle: Text(AppLocalizations.of(context)!.voteReminder),
                value: _voteReminderNotifications,
                onChanged: !_notificationsEnabled ? null : (value) async {
                  setState(() {
                    _voteReminderNotifications = value;
                  });
                  await NotificationService.updateNotificationPreference('vote_reminder', value);
                },
                secondary: const Icon(Icons.how_to_vote),
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.winCelebration),
                subtitle: Text(AppLocalizations.of(context)!.victoryNotifications),
                value: _winCelebrationNotifications,
                onChanged: !_notificationsEnabled ? null : (value) async {
                  setState(() {
                    _winCelebrationNotifications = value;
                  });
                  await NotificationService.updateNotificationPreference('win_celebration', value);
                },
                secondary: const Icon(Icons.celebration),
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.streakReminder),
                subtitle: Text(AppLocalizations.of(context)!.streakReminderSubtitle),
                value: _streakReminderNotifications,
                onChanged: !_notificationsEnabled ? null : (value) async {
                  setState(() {
                    _streakReminderNotifications = value;
                  });
                  await NotificationService.updateNotificationPreference('streak_reminder', value);
                },
                secondary: const Icon(Icons.local_fire_department),
              ),
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
            title: '🌍 Dil / Language',
            children: [
              ListTile(
                leading: const Icon(Icons.language, color: Colors.blue),
                title: Text(AppLocalizations.of(context)!.language),
                subtitle: Text('Select your preferred language'),
                trailing: CompactLanguageSelector(
                  onLanguageChanged: (locale) async {
                    // CompactLanguageSelector zaten LanguageService.setLanguage() çağırıyor
                    // Parent'a bildir ve sayfayı yeniden build et
                    if (widget.onLanguageChanged != null) {
                      widget.onLanguageChanged!(locale);
                    }
                    // Sayfayı yeniden build et
                    setState(() {});
                    
                    // Dil değişikliği sonrası otomatik refresh
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (mounted) {
                      setState(() {});
                      // Dil değişikliği için de restart
                      _restartApp();
                    }
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
                onTap: _isLoggingOut ? null : _logout,
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
}