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
  
  

  final List<String> _themeOptions = ['Beyaz', 'Koyu', 'Pembemsi'];
  String _selectedTheme = 'Beyaz';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSavedTheme();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dil değişikliğini dinle ve UI'yi güncelle
    setState(() {});
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
    final isDarkTheme = _selectedTheme == 'Koyu';
    
    return Container(
      decoration: isDarkTheme 
          ? BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF121212), // Çok koyu gri
                  Color(0xFF1A1A1A), // Koyu gri
                ],
              ),
            )
          : null,
      child: SingleChildScrollView(
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
                leading: const Icon(Icons.emoji_events, color: Color(0xFFFF6B35)),
                title: Text(AppLocalizations.of(context)!.dailyRewards),
                subtitle: Text(AppLocalizations.of(context)!.dailyRewardsSubtitle),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showDailyStreakDialog,
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Color(0xFFFF6B35)),
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
          
          // Match Ayarları
          _buildSectionCard(
            title: '⚔️ Match Ayarları',
            children: [
              ListTile(
                leading: const Icon(Icons.visibility, color: Color(0xFFFF6B35)),
                title: Text(AppLocalizations.of(context)!.visibleInMatches),
                subtitle: const Text("Diğer kullanıcılar sizi görebilir"),
                trailing: Switch(
                  value: _currentUser?.isVisible ?? false,
                  activeColor: const Color(0xFFFF6B35), // Turuncu aktif renk
                  activeTrackColor: const Color(0xFFFF6B35).withOpacity(0.3), // Hafif turuncu track
                  onChanged: (value) async {
                    final success = await UserService.updateProfile(isVisible: value);
                    if (success) {
                      await _loadUserData();
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
              ),
              // Yaş Aralığı Tercihleri
              ListTile(
                leading: const Icon(Icons.cake, color: Color(0xFFFF6B35)),
                title: const Text('Yaş Aralığı Tercihleri'),
                subtitle: const Text('Hangi yaş aralıklarından oylanmak istediğinizi seçin'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showAgeRangePreferencesDialog(),
              ),
              // Ülke Tercihleri
              ListTile(
                leading: const Icon(Icons.public, color: Color(0xFFFF6B35)),
                title: const Text('Ülke Tercihleri'),
                subtitle: const Text('Hangi ülkelerden oylanmak istediğinizi seçin'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showCountryPreferencesDialog(),
              ),
            ],
          ),
          
          
          
          const SizedBox(height: 24),
          
          // Dil Ayarları
          _buildSectionCard(
            title: '🌍 ${AppLocalizations.of(context)!.language}',
            children: [
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFFFF6B35)),
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

          // Davet Sistemi
          _buildSectionCard(
            title: "Referral Link",
            children: [
              Text(
                UserService.generateReferralLink(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await _shareReferralLink();
                },
                icon: const Icon(Icons.share),
                label: Text(AppLocalizations.of(context)!.shareLink),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35), // Turuncu arka plan
                  foregroundColor: Colors.white, // Beyaz yazı
                  minimumSize: const Size(double.infinity, 48),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                leading: const Icon(Icons.logout, color: Color(0xFFFF6B35)),
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
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    final isDarkTheme = _selectedTheme == 'Koyu';
    
    return Container(
      decoration: BoxDecoration(
        gradient: isDarkTheme 
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E1E1E), // Koyu gri
                  Color(0xFF2D2D2D), // Daha koyu gri
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFFFF8F5), // Hafif turuncu ton
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkTheme 
              ? const Color(0xFFFF6B35).withOpacity(0.3)
              : const Color(0xFFFF6B35).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkTheme 
                ? const Color(0xFFFF6B35).withOpacity(0.2)
                : const Color(0xFFFF6B35).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: isDarkTheme 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
                color: const Color(0xFFFF6B35), // Turuncu başlık rengi (her temada aynı)
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
    final isDarkTheme = _selectedTheme == 'Koyu';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkTheme ? const Color(0xFF1E1E1E) : null,
          title: Text(
            AppLocalizations.of(context)!.dailyStreakRewards,
            style: TextStyle(
              color: isDarkTheme ? Colors.white : null,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.dailyStreakDescription,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.day1_2Reward,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : null,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.day3_6Reward,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : null,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.day7PlusReward,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : null,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: isDarkTheme ? const Color(0xFFFF6B35) : null,
              ),
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


  Future<void> _copyReferralLink() async {
    // Clipboard functionality would be implemented here
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.linkCopied),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _shareReferralLink() async {
    final link = UserService.generateReferralLink();
    // Share functionality would be implemented here
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppLocalizations.of(context)!.shareLink}: $link'),
        backgroundColor: Colors.blue,
      ),
    );
  }


  // Marketing Functions






  // Yaş aralığı tercihleri dialog'u
  void _showAgeRangePreferencesDialog() {
    if (_currentUser == null) return;
    final isDarkTheme = _selectedTheme == 'Koyu';
    
    // Mevcut seçili yaş aralıklarını al (eğer yoksa tüm yaş aralıkları seçili olsun)
    List<String> selectedAgeRanges = _currentUser!.ageRangePreferences ?? AppConstants.ageRanges;
    
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
          backgroundColor: isDarkTheme ? const Color(0xFF1E1E1E) : null,
          title: Text(
            'Yaş Aralığı Tercihleri',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : null,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 250,
            child: SingleChildScrollView(
              child: Column(
              children: [
                const SizedBox(height: 20),
                // Süper şık RangeSlider ile yaş aralığı seçimi
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surface.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Yaş aralığı göstergesi - daha şık
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF6B35), // Ana turuncu ton
                              Color(0xFFFF8C42), // Açık turuncu ton
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cake,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$minAge - $maxAge',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Süper şık RangeSlider
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RangeSlider(
                          values: RangeValues(minAge.toDouble(), maxAge.toDouble()),
                          min: 18,
                          max: 100,
                          divisions: 82,
                          activeColor: const Color(0xFFFF6B35), // Turuncu aktif renk
                          inactiveColor: const Color(0xFFFF6B35).withOpacity(0.2), // Hafif turuncu inaktif
                          overlayColor: MaterialStateProperty.all(
                            const Color(0xFFFF6B35).withOpacity(0.15), // Turuncu overlay
                          ),
                          onChanged: (values) {
                            setDialogState(() {
                              minAge = values.start.round();
                              maxAge = values.end.round();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Min ve max yaş göstergeleri - daha şık
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.1), // Hafif turuncu arka plan
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '18',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF6B35), // Turuncu yazı rengi
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.1), // Hafif turuncu arka plan
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '100',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF6B35), // Turuncu yazı rengi
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600], // Gri yazı rengi
              ),
              child: const Text('İptal'),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35), // Turuncu arka plan
                foregroundColor: Colors.white, // Beyaz yazı
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  // Ülke tercihleri dialog'u
  void _showCountryPreferencesDialog() {
    final isDarkTheme = _selectedTheme == 'Koyu';
    List<String> selectedCountries = _currentUser?.countryPreferences ?? AppConstants.countries;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDarkTheme ? const Color(0xFF1E1E1E) : null,
          title: Text(
            'Ülke Tercihleri',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : null,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            height: 400,
            decoration: BoxDecoration(
              gradient: isDarkTheme 
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2D2D2D), // Koyu gri
                        Color(0xFF1E1E1E), // Daha koyu gri
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Color(0xFFFFF8F5), // Çok hafif turuncu ton
                      ],
                    ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Hangi ülkelerden oylanmak istediğinizi seçin:',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : null,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: AppConstants.countries.length,
                    itemBuilder: (context, index) {
                      final country = AppConstants.countries[index];
                      return CheckboxListTile(
                        title: Text(
                          country,
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : null,
                          ),
                        ),
                        value: selectedCountries.contains(country),
                        activeColor: const Color(0xFFFF6B35), // Turuncu checkbox rengi
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedCountries.add(country);
                            } else {
                              selectedCountries.remove(country);
                            }
                          });
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600], // Gri yazı rengi
              ),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateCountryPreferences(selectedCountries);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35), // Turuncu arka plan
                foregroundColor: Colors.white, // Beyaz yazı
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  // Yaş aralığı tercihlerini güncelle
  Future<void> _updateAgeRangePreferences(List<String> ageRanges) async {
    try {
      final success = await UserService.updateAgeRangePreferences(ageRanges);
      if (success) {
        await _loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yaş aralığı tercihleri güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme sırasında hata oluştu')),
      );
    }
  }

  // Ülke tercihlerini güncelle
  Future<void> _updateCountryPreferences(List<String> countries) async {
    try {
      final success = await UserService.updateCountryPreferences(countries);
      if (success) {
        await _loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ülke tercihleri güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme sırasında hata oluştu')),
      );
    }
  }

}
