import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/compact_language_selector.dart';
import '../widgets/country_selector.dart';
import '../widgets/gender_selector.dart';
import '../services/global_language_service.dart';

class RegisterScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;
  
  const RegisterScreen({super.key, this.onLanguageChanged});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedCountryCode;
  String? _selectedGenderCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Theme tracking removed - this screen doesn't use theme
  }

  void register() async {
    final l10n = AppLocalizations.of(context)!;
    
    // Validation
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.usernameCannotBeEmpty)),
      );
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emailCannotBeEmpty)),
      );
      return;
    }
    
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.passwordMinLength)),
      );
      return;
    }

    if (_selectedCountryCode == null || _selectedCountryCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir ülke seçin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;

      if (user != null) {
        // users tablosuna veri ekle
        await Supabase.instance.client.from('users').insert({
          'auth_id': user.id, // CRITICAL: Auth user ID'sini ekle
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'coins': 100, // Yeni kullanıcılara 100 coin hediye
          'age': _ageController.text.trim().isNotEmpty 
              ? int.tryParse(_ageController.text.trim()) 
              : null,
          'country_code': _selectedCountryCode,
          'gender_code': _selectedGenderCode,
          'is_visible': true,
          'total_matches': 0,
          'wins': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.registrationSuccessful)),
          );

          // Login ekranına yönlendir
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen(onLanguageChanged: widget.onLanguageChanged)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.userAlreadyExists)),
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
      setState(() => _isLoading = false);
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
    _usernameController.dispose();
    _ageController.dispose();
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
          l10n.register,
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
              children: [
                const SizedBox(height: 20),
                
                // Logo/Title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'chizoimage.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  'Chizo',
                  style: TextStyle(
                    fontSize: 28,
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
                  'Kayıt Ol',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Username Field
                _buildStyledTextField(
                  controller: _usernameController,
                  labelText: l10n.username,
                  prefixIcon: Icons.person,
                ),
                
                const SizedBox(height: 16),
                
                // Email Field
                _buildStyledTextField(
                  controller: _emailController,
                  labelText: l10n.email,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                _buildStyledTextField(
                  controller: _passwordController,
                  labelText: l10n.password,
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
                
                const SizedBox(height: 16),
                
                // Age Field
                _buildStyledTextField(
                  controller: _ageController,
                  labelText: l10n.age,
                  prefixIcon: Icons.cake,
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: 16),
                
                // Country Selector
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
                  child: CountrySelector(
                    selectedCountryCode: _selectedCountryCode,
                    onCountrySelected: (countryCode) {
                      setState(() {
                        _selectedCountryCode = countryCode;
                      });
                    },
                    label: l10n.country,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Gender Selector
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
                  child: GenderSelector(
                    selectedGenderCode: _selectedGenderCode,
                    onGenderSelected: (genderCode) {
                      setState(() {
                        _selectedGenderCode = genderCode;
                      });
                    },
                    label: l10n.gender,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Register Button
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
                          onPressed: register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.register,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                
                const SizedBox(height: 20),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen(onLanguageChanged: widget.onLanguageChanged)),
                      ),
                      child: Text(
                        l10n.loginNow,
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

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Container(
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
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFFFF6B35)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
