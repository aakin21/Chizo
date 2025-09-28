import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/language_service.dart';
import 'services/notification_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialize (sadece mobile için)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed (web platform): $e');
  }

  // Supabase başlat - Environment variables should be used in production
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', 
        defaultValue: 'https://rsuptwsgnpgsvlqigitq.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzdXB0d3NnbnBnc3ZscWlnaXRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NjMzODUsImV4cCI6MjA3MzUzOTM4NX0.KiLkHJ22FhJkc8BnkLrTZpk-_gM81bTiCfe0gh3-DfM'),
  );

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
          return const LoginScreen();
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentLocale();
    _loadTheme();
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
      print('🔍 THEME LOADING: Reading from storage -> $theme');
      
      if (mounted) {
        setState(() {
          _selectedTheme = theme;
          _isThemeLoaded = true;
        });
        print('✅ THEME APPLIED: $_selectedTheme set successfully');
      }
    } catch (e) {
      print('❌ THEME ERROR: Failed to load theme - $e');
      if (mounted) {
        setState(() {
          _selectedTheme = 'Beyaz';
          _isThemeLoaded = true;
        });
      }
    }
  }

  void changeLanguage(Locale locale) async {
    await LanguageService.setLanguage(locale);
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
    }
  }

  void changeTheme(String theme) async {
    print('🎨 THEME CHANGE REQUESTED: $theme');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_theme', theme);
      
      if (mounted) {
        setState(() {
          _selectedTheme = theme;
        });
        print('✅ THEME CHANGED SUCCESSFULLY: $theme');
      }
    } catch (e) {
      print('❌ THEME CHANGE ERROR: $e');
    }
  }

  ColorScheme _getThemeColorScheme() {
    print('🎨 THEME SYSTEM: $_selectedTheme');
    
    switch (_selectedTheme) {
      case 'Beyaz':
        print('  ↳ BEYAZ light theme active');
        return ColorScheme.fromSeed(
          seedColor: Colors.white, 
          brightness: Brightness.light
        );
      case 'Koyu':
        print('  ↳ KOYU dark theme active');
        return ColorScheme.fromSeed(
          seedColor: Colors.grey.shade900, 
          brightness: Brightness.dark
        );
      case 'Pembemsi':
        print('  ↳ PEMBE light theme active');
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFFC2185B), 
          brightness: Brightness.light
        );
      default:
        print('  ↳ DEFAULT beyaz theme');
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