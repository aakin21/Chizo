import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../l10n/app_localizations.dart';

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
  String? _selectedCountry;
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
          'country': _selectedCountry,
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
      String errorMessage = ErrorHandler.getUserFriendlyErrorMessage(e.toString());
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
      appBar: AppBar(title: Text(l10n.register)),
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
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: InputDecoration(
                labelText: l10n.country,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.public),
              ),
              items: AppConstants.countries.map((country) => 
                DropdownMenuItem(value: country, child: Text(country))
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                });
              },
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
