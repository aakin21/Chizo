import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';

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
    // Validation
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı adı boş olamaz")),
      );
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("E-posta boş olamaz")),
      );
      return;
    }
    
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre en az 6 karakter olmalıdır")),
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
          const SnackBar(content: Text("Kayıt başarılı!")),
        );

        // Login ekranına yönlendir
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bu kullanıcı zaten kayıtlı veya bir hata oluştu")),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            TextField(controller: _ageController, decoration: const InputDecoration(labelText: "Yaş"), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: const InputDecoration(labelText: "Ülke"),
              items: AppConstants.countries.map((country) => 
                DropdownMenuItem(value: country, child: Text(country))
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: "Cinsiyet"),
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
                : ElevatedButton(onPressed: register, child: const Text("Register")),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Zaten hesabın var mı? "),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ),
                  child: const Text("Giriş yap"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
