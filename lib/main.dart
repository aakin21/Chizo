import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/register_screen.dart'; // RegisterScreen path'i doğru olmalı

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Match App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const RegisterScreen(), // Uygulama açılış ekranı
    );
  }
}
