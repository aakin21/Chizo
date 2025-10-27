import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/compact_language_selector.dart';
import '../services/global_language_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;
  
  const LoginScreen({super.key, this.onLanguageChanged});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void login() async {
    final l10n = AppLocalizations.of(context)!;
    
    // Validation
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emailCannotBeEmpty)),
      );
      return;
    }
    
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.passwordCannotBeEmpty)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      final user = response.user;

      if (user != null) {
        // ✅ EMAIL VERIFICATION: Check if email is confirmed
        if (user.emailConfirmedAt == null) {
          // Email doğrulanmamış - giriş yapmasına izin verme
          await Supabase.instance.client.auth.signOut();
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: Row(
                  children: const [
                    Icon(Icons.email_outlined, color: Colors.orange),
                    SizedBox(width: 12),
                    Text(
                      'Email Doğrulanmamış',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lütfen email adresinize gönderilen doğrulama linkine tıklayarak hesabınızı aktifleştirin.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '📧 ${user.email}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '💡 Email gelmedi mi? Spam/Gereksiz klasörünü kontrol edin.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      // Doğrulama emailini tekrar gönder
                      try {
                        await Supabase.instance.client.auth.resend(
                          type: OtpType.signup,
                          email: user.email!,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Doğrulama emaili tekrar gönderildi!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Email gönderilemedi: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Emaili Tekrar Gönder',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tamam'),
                  ),
                ],
              ),
            );
            setState(() { _isLoading = false; });
          }
          return;
        }

        // Email doğrulanmış - users tablosunu kontrol et
        final usersRow = await Supabase.instance.client
            .from('users')
            .select('id')
            .eq('auth_id', user.id)
            .maybeSingle();

        if (!mounted) return;

        // ✅ İlk giriş: users tablosunda kayıt yok, oluştur (email doğrulanmış olduğu için)
        if (usersRow == null) {
          try {
            await Supabase.instance.client.from('users').insert({
              'auth_id': user.id,
              'username': user.email!.split('@')[0], // Email'den username oluştur
              'email': user.email!,
              'coins': 100, // İlk kayıt bonusu
              'is_visible': true,
              'total_matches': 0,
              'wins': 0,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
            debugPrint('✅ User profile created successfully after email verification');
          } catch (e) {
            debugPrint('❌ Failed to create user profile: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profil oluşturulamadı: $e'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() { _isLoading = false; });
            }
            return;
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.loginSuccessful)),
          );
        }

        // HomeScreen'e yönlendir
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.loginError)),
          );
        }
      }
    } catch (e) {
      String errorMessage = _getLocalizedErrorMessage(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getLocalizedErrorMessage(String error) {
    final l10n = AppLocalizations.of(context)!;
    
    if (error.contains('Invalid email')) {
      return l10n.invalidEmail;
    }
    if (error.contains('User not found')) {
      return l10n.userNotFound;
    }
    if (error.contains('User already registered')) {
      return l10n.userAlreadyRegistered;
    }
    if (error.contains('Invalid password')) {
      return l10n.invalidPassword;
    }
    if (error.contains('Password should be at least')) {
      return l10n.passwordMinLength;
    }
    if (error.contains('Password is too weak')) {
      return l10n.passwordTooWeak;
    }
    if (error.contains('Username already taken')) {
      return l10n.usernameAlreadyTaken;
    }
    if (error.contains('Username too short')) {
      return l10n.usernameTooShort;
    }
    if (error.contains('Network error') || error.contains('Connection failed')) {
      return l10n.networkError;
    }
    if (error.contains('Timeout')) {
      return l10n.timeoutError;
    }
    if (error.contains('Email not confirmed')) {
      return l10n.emailNotConfirmed;
    }
    if (error.contains('Too many requests')) {
      return l10n.tooManyRequests;
    }
    if (error.contains('Account disabled')) {
      return l10n.accountDisabled;
    }
    if (error.contains('Duplicate data')) {
      return l10n.duplicateData;
    }
    if (error.contains('Invalid data')) {
      return l10n.invalidData;
    }
    if (error.contains('Invalid credentials')) {
      return l10n.invalidCredentials;
    }
    if (error.contains('Too many emails')) {
      return l10n.tooManyEmails;
    }
    
    return l10n.operationFailed;
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Koyu arka plan
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Koyu app bar
        foregroundColor: Colors.white, // Beyaz ikonlar
        title: Text(
          l10n.login,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          CompactLanguageSelector(
            onLanguageChanged: (locale) async {
              // Global dil servisini kullan
              await GlobalLanguageService().changeLanguage(locale);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121212), // Çok koyu gri
              Color(0xFF1A1A1A), // Koyu gri
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'chizoimage.png',
                  width: 230,
                  height: 230,
                  fit: BoxFit.cover,
                ),
                
                Text(
                  'Chizo',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Giriş Yap',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Email Field
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E1E1E), // Koyu gri
                        Color(0xFF2D2D2D), // Daha koyu gri
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.email, color: Color(0xFFFF6B35)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Password Field
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E1E1E), // Koyu gri
                        Color(0xFF2D2D2D), // Daha koyu gri
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFFFF6B35)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    obscureText: true,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Login Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF6B35), // Ana turuncu
                        Color(0xFFFF8C42), // Açık turuncu
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.login,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                
                const SizedBox(height: 30),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(onLanguageChanged: widget.onLanguageChanged),
                          ),
                        );
                      },
                      child: Text(
                        l10n.registerNow,
                        style: const TextStyle(
                          color: Color(0xFFFF6B35),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
