import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../l10n/app_localizations.dart';
// Notification imports removed - using UserService.updateCoins instead

class StoreTab extends StatefulWidget {
  const StoreTab({super.key});

  @override
  State<StoreTab> createState() => _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  UserModel? _currentUser;
  bool _isLoading = true;
  int _adWatchCount = 0;
  DateTime? _lastAdWatchDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAdWatchData();
  }

  Future<void> _loadAdWatchData() async {
    // SharedPreferences'dan reklam izleme verilerini yükle
    final prefs = await SharedPreferences.getInstance();
    _adWatchCount = prefs.getInt('ad_watch_count') ?? 0;
    final lastWatchString = prefs.getString('last_ad_watch_date');
    if (lastWatchString != null) {
      _lastAdWatchDate = DateTime.parse(lastWatchString);
    }
    
    // Eğer son izleme 24 saatten eskiyse sayacı sıfırla
    if (_lastAdWatchDate != null && 
        DateTime.now().difference(_lastAdWatchDate!).inHours >= 24) {
      _adWatchCount = 0;
      _lastAdWatchDate = null;
      await prefs.remove('ad_watch_count');
      await prefs.remove('last_ad_watch_date');
    }
    
    setState(() {});
  }

  int _getAdCount() {
    return _adWatchCount;
  }

  bool _canWatchAd() {
    return _adWatchCount < 3;
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
    final l10n = AppLocalizations.of(context)!;
    
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
                      Text(
                        l10n.coins,
                        style: const TextStyle(
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
            title: l10n.coinPackages,
            children: [
              _buildCoinPackage('100 Coin', '₺0.99', 100, Colors.blue),
              _buildCoinPackage('250 Coin', '₺1.99', 250, Colors.green),
              _buildCoinPackage('500 Coin', '₺3.49', 500, Colors.yellow),
              _buildCoinPackage('1000 Coin', '₺5.99', 1000, Colors.amber[800]!),
              _buildCoinPackage('2500 Coin', '₺9.99', 2500, Colors.purple),
              _buildCoinPackage('10000 Coin', '₺29.99', 10000, Colors.red),
              _buildAdPackage(),
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
    final l10n = AppLocalizations.of(context)!;
    
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
          child: Text(l10n.buy),
        ),
        onTap: () => _showPurchaseDialog(coins),
      ),
    );
  }

  Widget _buildAdPackage() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.play_circle,
            color: Colors.grey,
          ),
        ),
        title: Text(
          l10n.watchAd,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('50 ${l10n.coins}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${_getAdCount()}/3', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: _canWatchAd() ? _watchAdForCoins : null,
              child: const Text('İzle'),
            ),
          ],
        ),
        onTap: _canWatchAd() ? _watchAdForCoins : null,
      ),
    );
  }

  void _watchAdForCoins() {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_canWatchAd()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Günlük reklam izleme limitiniz doldu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.watchAd),
        content: Text(l10n.watchAdConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateAdWatch();
            },
            child: Text(l10n.watchAd),
          ),
        ],
      ),
    );
  }

  void _simulateAdWatch() async {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(l10n.watchingAd),
          ],
        ),
      ),
    );

    // Simulate 3 seconds of ad watching
    Future.delayed(const Duration(seconds: 3), () async {
      Navigator.pop(context); // Close loading dialog
      
      // Reklam izleme sayacını güncelle
      await _updateAdWatchCount();
      
      // Add coins
      _addCoins(5);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.coinsEarned(5)),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  Future<void> _updateAdWatchCount() async {
    final prefs = await SharedPreferences.getInstance();
    _adWatchCount++;
    _lastAdWatchDate = DateTime.now();
    
    await prefs.setInt('ad_watch_count', _adWatchCount);
    await prefs.setString('last_ad_watch_date', _lastAdWatchDate!.toIso8601String());
    
    setState(() {});
  }

  void _addCoins(int coins) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      // Coin'leri hesaba ekle (UserService.updateCoins zaten bildirim gönderiyor)
      final success = await UserService.updateCoins(coins, 'earned', 'Coin satın alma');
      
      if (success) {
        // Duplicate bildirim kaldırıldı - UserService.updateCoins zaten bildirim gönderiyor
        
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
          content: Text('${l10n.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // _sendCoinPurchaseNotification metodu kaldırıldı - UserService.updateCoins zaten bildirim gönderiyor

  void _showPurchaseDialog(int coins) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.buy} ${l10n.coins}'),
        content: Text('$coins ${l10n.coins} ${l10n.buy}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulatePurchase(coins);
            },
            child: Text(l10n.buy),
          ),
        ],
      ),
    );
  }

  void _simulatePurchase(int coins) {
    final l10n = AppLocalizations.of(context)!;
    
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
          content: Text('$coins ${l10n.coins} eklendi!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}