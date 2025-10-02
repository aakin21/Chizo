import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class StoreTab extends StatefulWidget {
  const StoreTab({super.key});

  @override
  State<StoreTab> createState() => _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            
            // Coin Bakiyesi
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Coin",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_currentUser?.coins ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Coin Paketleri
            _buildSectionCard(
              title: '💰 Coin Paketleri',
              children: [
                _buildCoinPackage('100 Coin', '₺0.99', 100, Colors.blue),
                _buildCoinPackage('250 Coin', '₺1.99', 250, Colors.green),
                _buildCoinPackage('500 Coin', '₺3.49', 500, Colors.orange),
                _buildCoinPackage('1000 Coin', '₺5.99', 1000, Colors.purple),
                _buildCoinPackage('2500 Coin', '₺9.99', 2500, Colors.red),
              ],
            ),

            const SizedBox(height: 24),

            // Reklam İzleme
            _buildSectionCard(
              title: '📺 Reklam İzle',
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.play_circle,
                    color: Colors.blue,
                    size: 28,
                  ),
                  title: const Text(
                    "Reklam İzleyerek Coin Kazan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    "24 saat içinde 3 video izleme hakkı - Her video için 5 coin",
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _watchAdForCoins,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  void _watchAdForCoins() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reklam İzleyerek Coin Kazan"),
        content: const Text("Reklam izleyerek 5 coin kazanabilirsiniz. Devam etmek istiyor musunuz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateAdWatch();
            },
            child: const Text("Reklam İzle"),
          ),
        ],
      ),
    );
  }

  void _simulateAdWatch() {
    // Simulate ad watching
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Reklam izleniyor...'),
          ],
        ),
      ),
    );

    // Simulate 3 seconds of ad watching
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Close loading dialog
      
      // Add coins
      _addCoins(5);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reklam izlendi! 5 coin kazandınız"),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _addCoins(int amount) {
    setState(() {
      // Reload user data to get updated coins
      _loadUserData();
    });
  }

  Widget _buildCoinPackage(String title, String price, int coins, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.monetization_on,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          price,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () => _purchaseCoinPackage(coins, price),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Satın Al'),
        ),
      ),
    );
  }

  void _purchaseCoinPackage(int coins, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coin Paketi Satın Al'),
        content: Text('$coins coin paketini $price karşılığında satın almak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulatePurchase(coins);
            },
            child: const Text('Satın Al'),
          ),
        ],
      ),
    );
  }

  void _simulatePurchase(int coins) {
    // Simulate purchase
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Satın alma işlemi gerçekleştiriliyor...'),
          ],
        ),
      ),
    );

    // Simulate 2 seconds of processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      
      // Add coins
      _addCoins(coins);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$coins coin satın alındı!"),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}