import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../widgets/compact_language_selector.dart';
import '../widgets/country_selector.dart';
import '../services/language_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedCountryCode;
  String? _selectedGender;
  bool _isLoading = false;


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
          'gender': _selectedGender,
          'is_visible': true,
          'total_matches': 0,
          'wins': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.registrationSuccessful)),
        );

        // Login ekranına yönlendir
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.userAlreadyExists)),
        );
      }
    } catch (e) {
      String errorMessage = _getLocalizedErrorMessage(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
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
      appBar: AppBar(
        title: Text(l10n.register),
        actions: [
          CompactLanguageSelector(
            onLanguageChanged: (locale) async {
              await LanguageService.saveUserLanguagePreference(locale);
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController, 
              decoration: InputDecoration(
                labelText: l10n.username,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController, 
              decoration: InputDecoration(
                labelText: l10n.email,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController, 
              decoration: InputDecoration(
                labelText: l10n.password,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController, 
              decoration: InputDecoration(
                labelText: l10n.age,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ), 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 16),
            CountrySelector(
              key: ValueKey(Localizations.localeOf(context).languageCode),
              selectedCountryCode: _selectedCountryCode,
              onCountrySelected: (countryCode) {
                setState(() {
                  _selectedCountryCode = countryCode;
                });
              },
              label: AppLocalizations.of(context)!.country,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: l10n.gender,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
              items: AppConstants.genders.map((gender) => 
                DropdownMenuItem(value: gender, child: Text(gender))
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: register, child: Text(l10n.register)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.alreadyHaveAccount),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ),
                  child: Text(l10n.loginNow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
