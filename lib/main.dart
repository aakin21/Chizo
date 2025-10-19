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
import 'services/notification_integration_service.dart';
import 'l10n/app_localizations.dart';
import 'utils/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialize
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase initialization failed
  }

  // Supabase initialize
  try {
    await Supabase.initialize(
      url: 'https://rsuptwsgnpgsvlqigitq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzdXB0d3NnbnBnc3ZscWlnaXRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NjMzODUsImV4cCI6MjA3MzUzOTM4NX0.KiLkHJ22FhJkc8BnkLrTZpk-_gM81bTiCfe0gh3-DfM',
    );
  } catch (e) {
    // Supabase initialization failed
  }

  // Initialize notification services
  await NotificationIntegrationService.initializeAll();

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
          return HomeScreen(
            onLanguageChanged: onLanguageChanged,
            onThemeChanged: onThemeChanged,
          );
        } else {
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
  Key _appKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentLocale();
    _loadTheme();
    
    GlobalLanguageService().setLanguageChangeCallback(changeLanguage);
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
      final theme = prefs.getString('selected_theme') ?? 'Koyu';
      
      if (mounted) {
        setState(() {
          _selectedTheme = theme;
          _isThemeLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedTheme = 'Koyu';
          _isThemeLoaded = true;
        });
      }
    }
  }

  void changeLanguage(Locale locale) async {
    await LanguageService.setLanguage(locale);
    final savedLocale = await LanguageService.getCurrentLocale();
    
    if (mounted) {
      setState(() {
        _currentLocale = savedLocale;
        _appKey = UniqueKey();
      });
    }
  }

  void changeTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      setState(() {
        _selectedTheme = theme;
        _appKey = UniqueKey(); // Tüm uygulamayı yeniden oluştur
      });
    }
  }

  ColorScheme _getThemeColorScheme() {
    switch (_selectedTheme) {
      case 'Beyaz':
        return ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light
        );
      case 'Koyu':
        return ColorScheme.fromSeed(
          seedColor: Colors.grey.shade900,
          brightness: Brightness.dark
        );
      default:
        return ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      key: _appKey,
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
        onThemeChanged: changeTheme,
      ),
      
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
