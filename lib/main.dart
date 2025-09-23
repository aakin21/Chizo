import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/language_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase başlat
  await Supabase.initialize(
    url: 'https://rsuptwsgnpgsvlqigitq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzdXB0d3NnbnBnc3ZscWlnaXRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NjMzODUsImV4cCI6MjA3MzUzOTM4NX0.KiLkHJ22FhJkc8BnkLrTZpk-_gM81bTiCfe0gh3-DfM',
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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

class _MyAppState extends State<MyApp> {
  Locale _currentLocale = const Locale('tr', 'TR');

  @override
  void initState() {
    super.initState();
    _loadCurrentLocale();
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getCurrentLocale();
    setState(() {
      _currentLocale = locale;
    });
  }

  void changeLanguage(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chizo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
