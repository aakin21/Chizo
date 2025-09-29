import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/compact_language_selector.dart';

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

      final user = response.user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loginSuccessful)),
        );

        // HomeScreen’e yönlendir (username parametresi yok)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loginError)),
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
      appBar: AppBar(
        title: Text(l10n.login),
        actions: [
          CompactLanguageSelector(
            onLanguageChanged: (locale) async {
              // CompactLanguageSelector zaten LanguageService.setLanguage() çağırıyor
              // Sadece parent'a bildir yeterli
              if (widget.onLanguageChanged != null) {
                widget.onLanguageChanged!(locale);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: Text(l10n.login),
                  ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.dontHaveAccount),
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
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
