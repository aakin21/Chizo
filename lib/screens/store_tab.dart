import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          
          // Coin Bakiyesi
          Card(
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
              _buildCoinPackage('500 Coin', '₺3.49', 500, Colors.yellow),
              _buildCoinPackage('1000 Coin', '₺5.99', 1000, Colors.amber[800]!),
              _buildCoinPackage('2500 Coin', '₺9.99', 2500, Colors.purple),
              _buildCoinPackage('10000 Coin', '₺29.99', 10000, Colors.red),
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
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCoinPackage(String title, String price, int coins, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.monetization_on,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(price),
        trailing: ElevatedButton(
          onPressed: () => _showPurchaseDialog(coins),
          child: const Text('Satın Al'),
        ),
        onTap: () => _showPurchaseDialog(coins),
      ),
    );
  }

  void _watchAdForCoins() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reklam İzle'),
        content: const Text('Reklam izleyerek 5 coin kazanabilirsiniz. Devam etmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
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
          content: Text('5 coin kazandınız!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _addCoins(int coins) async {
    try {
      // Coin'leri hesaba ekle
      final success = await UserService.updateCoins(coins, 'earned', 'Coin satın alma');
      
      if (success) {
        // Coin satın alma bildirimi gönder
        await _sendCoinPurchaseNotification(coins);
        
        setState(() {
          // Reload user data to get updated coins
          _loadUserData();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coin eklenirken hata oluştu!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding coins: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendCoinPurchaseNotification(int coins) async {
    try {
      // Coin satın alma bildirimi
      await NotificationService.sendLocalNotification(
        title: '💰 Coin Satın Alındı!',
        body: '$coins coin satın aldınız!',
        type: NotificationTypes.coinReward,
        data: {
          'transaction_type': 'purchase',
          'coin_amount': coins,
        },
      );
    } catch (e) {
      print('❌ Failed to send coin purchase notification: $e');
    }
  }

  void _showPurchaseDialog(int coins) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coin Satın Al'),
        content: Text('$coins coin satın almak istiyor musunuz?'),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('İşlem gerçekleştiriliyor...'),
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
          content: Text('$coins coin eklendi!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}