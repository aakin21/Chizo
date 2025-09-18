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
  String? _selectedCountry;
  String? _selectedGender;
  bool _isLoading = false;

  // Avrupa ülkeleri + Türkiye listesi
  static const List<String> _countries = [
    'turkiye',
    'Almanya',
    'Fransa',
    'İtalya',
    'İspanya',
    'Hollanda',
    'Belçika',
    'Avusturya',
    'İsviçre',
    'Polonya',
    'Çek Cumhuriyeti',
    'Macaristan',
    'Romanya',
    'Bulgaristan',
    'Hırvatistan',
    'Slovenya',
    'Slovakya',
    'Estonya',
    'Letonya',
    'Litvanya',
    'Finlandiya',
    'İsveç',
    'Norveç',
    'Danimarka',
    'Portekiz',
    'Yunanistan',
    'Kıbrıs',
    'Malta',
    'Lüksemburg',
    'İrlanda',
    'İngiltere',
    'İzlanda',
  ];

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
      String errorMessage = _getUserFriendlyErrorMessage(e.toString());
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

  // Kullanıcı dostu hata mesajları
  String _getUserFriendlyErrorMessage(String error) {
    // E-posta ile ilgili hatalar
    if (error.contains('Invalid email')) {
      return '❌ Geçersiz e-posta adresi! Lütfen doğru formatta e-posta girin.';
    }
    if (error.contains('User already registered')) {
      return '❌ Bu e-posta adresi zaten kayıtlı! Giriş yapmayı deneyin.';
    }
    
    // Şifre ile ilgili hatalar
    if (error.contains('Password should be at least')) {
      return '❌ Şifre en az 6 karakter olmalıdır!';
    }
    if (error.contains('Password is too weak')) {
      return '❌ Şifre çok zayıf! Daha güçlü bir şifre seçin.';
    }
    
    // Kullanıcı adı ile ilgili hatalar
    if (error.contains('Username already taken')) {
      return '❌ Bu kullanıcı adı zaten alınmış! Başka bir kullanıcı adı seçin.';
    }
    if (error.contains('Username too short')) {
      return '❌ Kullanıcı adı en az 3 karakter olmalıdır!';
    }
    
    // Ağ bağlantısı hataları
    if (error.contains('network') || error.contains('connection')) {
      return '❌ İnternet bağlantınızı kontrol edin!';
    }
    if (error.contains('timeout')) {
      return '❌ Bağlantı zaman aşımı! Lütfen tekrar deneyin.';
    }
    
    // Veritabanı hataları
    if (error.contains('duplicate key')) {
      return '❌ Bu bilgiler zaten kullanılıyor! Farklı bilgiler deneyin.';
    }
    if (error.contains('constraint')) {
      return '❌ Girdiğiniz bilgilerde hata var! Lütfen kontrol edin.';
    }
    
    // Genel hatalar
    if (error.contains('Invalid credentials')) {
      return '❌ Geçersiz bilgiler! Lütfen kontrol edin.';
    }
    if (error.contains('Email rate limit')) {
      return '❌ Çok fazla e-posta gönderildi! Lütfen bekleyin.';
    }
    
    // Bilinmeyen hatalar için
    return '❌ Kayıt olunamadı! Lütfen bilgilerinizi kontrol edin.';
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
              items: _countries.map((country) => 
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
