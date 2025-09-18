import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/coin_transaction_model.dart';
import '../services/user_service.dart';
import 'coin_purchase_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  UserModel? currentUser;
  bool isLoading = true;
  bool isUpdating = false;

  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _countryController = TextEditingController();
  final _genderController = TextEditingController();
  final _instagramController = TextEditingController();
  final _professionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _countryController.dispose();
    _genderController.dispose();
    _instagramController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    setState(() => isLoading = true);
    try {
      final user = await UserService.getCurrentUser();
      setState(() {
        currentUser = user;
        isLoading = false;
      });
      
      if (user != null) {
        _usernameController.text = user.username;
        _ageController.text = user.age?.toString() ?? '';
        _countryController.text = user.country ?? '';
        _genderController.text = user.gender ?? '';
        _instagramController.text = user.instagramHandle ?? '';
        _professionController.text = user.profession ?? '';
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _updateProfile() async {
    setState(() => isUpdating = true);
    
    try {
      final success = await UserService.updateProfile(
        username: _usernameController.text.trim(),
        age: _ageController.text.trim().isNotEmpty 
            ? int.tryParse(_ageController.text.trim()) 
            : null,
        country: _countryController.text.trim().isNotEmpty 
            ? _countryController.text.trim() 
            : null,
        gender: _genderController.text.trim().isNotEmpty 
            ? _genderController.text.trim() 
            : null,
        instagramHandle: _instagramController.text.trim().isNotEmpty 
            ? _instagramController.text.trim() 
            : null,
        profession: _professionController.text.trim().isNotEmpty 
            ? _professionController.text.trim() 
            : null,
      );
      
      if (success) {
        await loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellenirken hata oluştu')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentUser == null) {
      return const Center(
        child: Text('Kullanıcı bilgileri yüklenemedi'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Ayarları',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Temel Bilgiler
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temel Bilgiler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Yaş',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Ülke',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _genderController.text.isNotEmpty ? _genderController.text : null,
                    decoration: const InputDecoration(
                      labelText: 'Cinsiyet',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                      DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                    ],
                    onChanged: (value) {
                      _genderController.text = value ?? '';
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Premium Bilgiler
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Premium Bilgiler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bu bilgileri diğer kullanıcılar coin harcayarak görebilir',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _instagramController,
                    decoration: const InputDecoration(
                      labelText: 'Instagram Hesabı (10 coin)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.camera_alt),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _professionController,
                    decoration: const InputDecoration(
                      labelText: 'Meslek (5 coin)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Coin Bilgileri
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coin Bilgileri',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Mevcut Coin: ${currentUser!.coins}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CoinPurchaseScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Coin Satın Al'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  FutureBuilder<List<CoinTransactionModel>>(
                    future: UserService.getCoinTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Son İşlemler:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...snapshot.data!.take(3).map((transaction) => 
                              ListTile(
                                leading: Icon(
                                  transaction.type == 'earned' 
                                      ? Icons.add_circle 
                                      : Icons.remove_circle,
                                  color: transaction.type == 'earned' 
                                      ? Colors.green 
                                      : Colors.red,
                                ),
                                title: Text(transaction.description),
                                subtitle: Text(
                                  '${transaction.amount > 0 ? '+' : ''}${transaction.amount} coin',
                                  style: TextStyle(
                                    color: transaction.amount > 0 
                                        ? Colors.green 
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  _formatDate(transaction.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const Text('Henüz işlem geçmişi yok');
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Güncelle Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isUpdating ? null : _updateProfile,
              child: isUpdating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Profili Güncelle'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
