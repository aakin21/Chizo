import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  // Disable debug prints in production/release builds
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  String? initializationError;

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
    initializationError = 'Yapılandırma dosyası yüklenemedi. Lütfen uygulamayı yeniden yükleyin.';
  }

  // Firebase initialize
  if (initializationError == null) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      // App can continue without Firebase
    }
  }

  // Supabase initialize
  // ✅ SECURITY FIX: Credentials now loaded from .env file
  if (initializationError == null) {
    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception('Missing Supabase credentials in .env file');
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('CRITICAL: Supabase initialization failed: $e');
      initializationError = 'Bağlantı kurulamadı. Lütfen internet bağlantınızı kontrol edin ve uygulamayı yeniden başlatın.';
    }
  }

  // Initialize notification services (only if no errors)
  if (initializationError == null) {
    try {
      await NotificationIntegrationService.initializeAll();
    } catch (e) {
      debugPrint('Notification service initialization failed: $e');
      // App can continue without notifications
    }
  }

  // Run app or show error screen
  if (initializationError != null) {
    runApp(ErrorApp(errorMessage: initializationError));
  } else {
    runApp(const MyApp());
  }
}

/// Error screen for fatal initialization failures
class ErrorApp extends StatelessWidget {
  final String errorMessage;

  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chizo',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Başlatma Hatası',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // On mobile, this will close the app
                    // User can then restart it manually
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Kapat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    // Önce UI'yi hemen güncelle (anında görünür değişiklik)
    if (mounted) {
      setState(() {
        _selectedTheme = theme;
        _appKey = UniqueKey(); // Tüm uygulamayı yeniden oluştur
      });
    }

    // Sonra SharedPreferences'a kaydet (arka planda)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);
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
