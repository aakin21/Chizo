import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart'; // Path doğru olduğundan emin ol
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void login() async {
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
          const SnackBar(content: Text("Giriş başarılı!")),
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
          const SnackBar(content: Text("Giriş hatası: Bilinmeyen hata")),
        );
      }
    } catch (e) {
      String errorMessage = _getUserFriendlyErrorMessage(e.toString());
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

  // Kullanıcı dostu hata mesajları
  String _getUserFriendlyErrorMessage(String error) {
    // E-posta ile ilgili hatalar
    if (error.contains('Invalid email')) {
      return '❌ Geçersiz e-posta adresi! Lütfen doğru formatta e-posta girin.';
    }
    if (error.contains('User not found')) {
      return '❌ Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı!';
    }
    
    // Şifre ile ilgili hatalar
    if (error.contains('Invalid password')) {
      return '❌ Yanlış şifre! Lütfen şifrenizi kontrol edin.';
    }
    if (error.contains('Password should be at least')) {
      return '❌ Şifre en az 6 karakter olmalıdır!';
    }
    
    // Ağ bağlantısı hataları
    if (error.contains('network') || error.contains('connection')) {
      return '❌ İnternet bağlantınızı kontrol edin!';
    }
    if (error.contains('timeout')) {
      return '❌ Bağlantı zaman aşımı! Lütfen tekrar deneyin.';
    }
    
    // Hesap durumu hataları
    if (error.contains('Email not confirmed')) {
      return '❌ E-posta adresinizi onaylamanız gerekiyor!';
    }
    if (error.contains('Too many requests')) {
      return '❌ Çok fazla deneme! Lütfen birkaç dakika sonra tekrar deneyin.';
    }
    if (error.contains('Account disabled')) {
      return '❌ Hesabınız devre dışı bırakılmış!';
    }
    
    // Genel hatalar
    if (error.contains('Invalid credentials')) {
      return '❌ E-posta veya şifre hatalı!';
    }
    if (error.contains('User already registered')) {
      return '❌ Bu e-posta adresi zaten kayıtlı!';
    }
    
    // Bilinmeyen hatalar için
    return '❌ Giriş yapılamadı! Lütfen bilgilerinizi kontrol edin.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: const Text("Login"),
                  ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Hesabın yok mu? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Register ol",
                    style: TextStyle(
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
