import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/language_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase başlat - Environment variables should be used in production
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', 
        defaultValue: 'https://rsuptwsgnpgsvlqigitq.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzdXB0d3NnbnBnc3ZscWlnaXRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NjMzODUsImV4cCI6MjA3MzUzOTM4NX0.KiLkHJ22FhJkc8BnkLrTZpk-_gM81bTiCfe0gh3-DfM'),
  );

  runApp(const MyApp());
}

class AuthWrapper extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  
  const AuthWrapper({super.key, required this.onLanguageChanged});

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
          return HomeScreen(onLanguageChanged: onLanguageChanged);
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
  Key _appKey = UniqueKey();
  String _selectedTheme = 'Beyaz';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentLocale();
    _initialThemeLoad();
  }

  Future<void> _initialThemeLoad() async {
    print('🚀 APP STARTING - Loading theme...');
    await _loadTheme();
    if (mounted) setState(() {});
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

  // Public method to refresh theme from other pages
  void refreshTheme() async {
    await _loadTheme();
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getCurrentLocale();
    setState(() {
      _currentLocale = locale;
    });
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString('selected_theme') ?? 'Beyaz';
      print('🔍 THEME LOADING: Reading from storage -> $theme');
      
      // Force update state always to ensure fresh theme
      setState(() {
        _selectedTheme = theme;
      });
      print('✅ THEME APPLIED: $_selectedTheme set successfully');
    } catch (e) {
      print('❌ THEME ERROR: Failed to load theme - $e');
      setState(() {
        _selectedTheme = 'Beyaz'; // fallback
      });
    }
  }

  void changeLanguage(Locale locale) async {
    await LanguageService.setLanguage(locale);
    setState(() {
      _currentLocale = locale;
      _appKey = UniqueKey(); // Force complete rebuild
    });
  }

  ColorScheme _getThemeColorScheme() {
    print('🎨 THEME SYSTEM: $_selectedTheme');
    switch (_selectedTheme) {
      case 'Beyaz':
        print('  ↳ BEYAZ light theme active');
        return ColorScheme.fromSeed(seedColor: Colors.white, brightness: Brightness.light);
      case 'Koyu':
        print('  ↳ KOYU dark theme active');
        return ColorScheme.fromSeed(seedColor: Colors.grey.shade900, brightness: Brightness.dark);
      case 'Pembemsi':
        print('  ↳ PEMBE light theme active');
        return ColorScheme.fromSeed(seedColor: const Color(0xFFC2185B), brightness: Brightness.light);
      default:
        print('  ↳ DEFAULT beyaz theme');
        return ColorScheme.fromSeed(seedColor: Colors.white, brightness: Brightness.light);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: AuthWrapper(onLanguageChanged: changeLanguage),
      
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
