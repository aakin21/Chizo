import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/language_service.dart';
import 'services/global_language_service.dart';
import 'services/global_theme_service.dart';
import 'services/notification_service.dart';
import 'l10n/app_localizations.dart';
import 'utils/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialize (sadece mobile için)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase initialization failed (web platform): $e
  }

  // Supabase başlat - Environment variables should be used in production
  try {
    await Supabase.initialize(
      url: 'https://rsuptwsgnpgsvlqigitq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzdXB0d3NnbnBnc3ZscWlnaXRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NjMzODUsImV4cCI6MjA3MzUzOTM4NX0.KiLkHJ22FhJkc8BnkLrTZpk-_gM81bTiCfe0gh3-DfM',
    );
  } catch (e) {
    // Supabase initialization failed: $e
  }

  // Notification service'i initialize et
  await NotificationService.initialize();

  runApp(const MyApp());
}

class AuthWrapper extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  final Function(String) onThemeChanged;
  
  const AuthWrapper({super.key, required this.onLanguageChanged, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.loading, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }
        
        final session = snapshot.hasData ? snapshot.data!.session : null;
        
        if (session != null) {
          // User is logged in, go to home screen
          return HomeScreen(
            onLanguageChanged: onLanguageChanged,
            onThemeChanged: onThemeChanged,
          );
        } else {
          // User is not logged in, go to login screen  
          return LoginScreen(onLanguageChanged: onLanguageChanged);
        }
      },
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale _currentLocale = const Locale('tr', 'TR');
  String _selectedTheme = 'Beyaz';
  bool _isThemeLoaded = false;
  Key _appKey = UniqueKey(); // Dil değişikliği için key

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentLocale();
    _loadTheme();
    
    // Global dil servisini initialize et
    GlobalLanguageService().setLanguageChangeCallback(changeLanguage);
    
    // Global theme servisini initialize et
    GlobalThemeService().setThemeChangeCallback(changeTheme);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh theme when app becomes active
    if (state == AppLifecycleState.resumed) {
      _loadTheme();
    }
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getCurrentLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
    }
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString('selected_theme') ?? 'Beyaz';
      
      if (mounted) {
        setState(() {
          _selectedTheme = theme;
          _isThemeLoaded = true;
        });
      }
    } catch (e) {
      // THEME ERROR: Failed to load theme - $e
      if (mounted) {
        setState(() {
          _selectedTheme = 'Beyaz';
          _isThemeLoaded = true;
        });
      }
    }
  }

  void changeLanguage(Locale locale) async {
    // Language change requested to $locale
    
    // Önce dil ayarını kaydet
    await LanguageService.setLanguage(locale);
    
    // Dil ayarını tekrar yükle - kaydedilen ayarı doğrula
    final savedLocale = await LanguageService.getCurrentLocale();
    
    if (mounted) {
      setState(() {
        _currentLocale = savedLocale; // Kaydedilen dil ayarını kullan
        _appKey = UniqueKey(); // Yeni key ile tüm uygulamayı yeniden build et
      });
      // Language changed successfully to $savedLocale
    }
  }

  void changeTheme(String theme) async {
    // THEME CHANGE REQUESTED: $theme
    
    // Theme ayarını kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);
    
    // Kısa bir gecikme - theme ayarının kaydedilmesi için
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (mounted) {
      setState(() {
        _selectedTheme = theme;
        // UniqueKey kaldırıldı - refresh atmıyor, sadece state güncelleniyor
      });
      // Theme changed successfully to $theme
    }
  }

  ColorScheme _getThemeColorScheme() {
    // THEME SYSTEM: $_selectedTheme
    
    switch (_selectedTheme) {
      case 'Beyaz':
        // BEYAZ light theme active
        return ColorScheme.fromSeed(
          seedColor: Colors.white, 
          brightness: Brightness.light
        );
      case 'Koyu':
        // KOYU dark theme active
        return ColorScheme.fromSeed(
          seedColor: Colors.grey.shade900, 
          brightness: Brightness.dark
        );
      case 'Pembemsi':
        // PEMBE light theme active
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFFC2185B), 
          brightness: Brightness.light
        );
      default:
        // DEFAULT beyaz theme
        return ColorScheme.fromSeed(
          seedColor: Colors.white, 
          brightness: Brightness.light
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme yüklenene kadar loading göster
    if (!_isThemeLoaded) {
      return MaterialApp(
        title: 'Chizo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white, brightness: Brightness.light),
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      key: _appKey, // Dil değişikliği için key
      title: 'Chizo',
      theme: ThemeData(
        colorScheme: _getThemeColorScheme(),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(
        onLanguageChanged: changeLanguage,
        onThemeChanged: changeTheme, // Theme değişikliği callback'i ekle
      ),
      
      // Localization configuration
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageService.supportedLocales,
      locale: _currentLocale,
    );
  }
}
