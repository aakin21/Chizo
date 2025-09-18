import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

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
  final _countryController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;

  void register() async {
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
          'id': user.id, // CRITICAL: Auth user ID'sini ekle
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'coins': 100, // Yeni kullanıcılara 100 coin hediye
          'age': _ageController.text.trim().isNotEmpty 
              ? int.tryParse(_ageController.text.trim()) 
              : null,
          'country': _countryController.text.trim().isNotEmpty 
              ? _countryController.text.trim() 
              : null,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Beklenmedik bir hata oluştu: $e")),
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
    _countryController.dispose();
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
            TextField(controller: _countryController, decoration: const InputDecoration(labelText: "Ülke")),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: "Cinsiyet"),
              items: const [
                DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
              ],
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
