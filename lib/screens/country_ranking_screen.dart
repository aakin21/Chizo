import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/country_ranking_service.dart';
import '../services/user_service.dart';
import '../l10n/app_localizations.dart';

class CountryRankingScreen extends StatefulWidget {
  const CountryRankingScreen({super.key});

  @override
  State<CountryRankingScreen> createState() => _CountryRankingScreenState();
}

class _CountryRankingScreenState extends State<CountryRankingScreen> {
  List<Map<String, dynamic>> countryStats = [];
  bool isLoading = true;
  String? errorMessage;
  bool isUnlocked = false; // Progress bar'ların açık olup olmadığını kontrol eder
  DateTime? unlockExpiryTime; // 24 saatlik unlock süresi

  @override
  void initState() {
    super.initState();
    _loadCountryStats();
    _checkUnlockStatus();
  }

  Future<void> _loadCountryStats() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final authUserId = Supabase.instance.client.auth.currentUser?.id;
      if (authUserId == null) {
        setState(() {
          errorMessage = 'User not authenticated';
          isLoading = false;
        });
        return;
      }

      final stats = await CountryRankingService.getUserCountryStats(authUserId);
      
      setState(() {
        countryStats = stats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ülke İstatistiklerini Görüntüle'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchaseCountryStats();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Satın Al (500)'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkUnlockStatus() async {
    try {
      final authUserId = Supabase.instance.client.auth.currentUser?.id;
      if (authUserId == null) return;
      
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString('country_stats_unlock_$authUserId');
      if (timeString != null) {
        final savedTime = DateTime.parse(timeString);
        if (DateTime.now().isBefore(savedTime)) {
          setState(() {
            isUnlocked = true;
            unlockExpiryTime = savedTime;
          });
          _startAutoLockTimer();
        } else {
          await prefs.remove('country_stats_unlock_$authUserId');
        }
      }
    } catch (e) {
      print('Error checking unlock status: $e');
    }
  }

  void _startAutoLockTimer() {
    if (unlockExpiryTime != null) {
      final remainingTime = unlockExpiryTime!.difference(DateTime.now());
      if (remainingTime.isNegative) {
        setState(() {
          isUnlocked = false;
          unlockExpiryTime = null;
        });
        return;
      }

      // 24 saat sonra otomatik kilit
      Future.delayed(remainingTime, () {
        if (mounted) {
          setState(() {
            isUnlocked = false;
            unlockExpiryTime = null;
          });
          _removeStoredUnlockTime();
        }
      });
    }
  }

  Future<void> _storeUnlockTime(DateTime expiryTime) async {
    try {
      final authUserId = Supabase.instance.client.auth.currentUser?.id;
      if (authUserId == null) return;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('country_stats_unlock_$authUserId', expiryTime.toIso8601String());
    } catch (e) {
      print('Error storing unlock time: $e');
    }
  }

  Future<void> _removeStoredUnlockTime() async {
    try {
      final authUserId = Supabase.instance.client.auth.currentUser?.id;
      if (authUserId == null) return;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('country_stats_unlock_$authUserId');
    } catch (e) {
      print('Error removing unlock time: $e');
    }
  }

  Future<void> _purchaseCountryStats() async {
    try {
      // Gerçek coin harcama sistemi
      final success = await UserService.updateCoins(-500, 'spent', 'Ülke istatistikleri görüntüleme');
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Yetersiz coin! 500 coin gerekli.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      // 24 saatlik unlock süresi ayarla
      final expiryTime = DateTime.now().add(Duration(hours: 24));
      
      // Progress bar'ları aç
      setState(() {
        isUnlocked = true;
        unlockExpiryTime = expiryTime;
      });
      
      // Storage'a kaydet
      _storeUnlockTime(expiryTime);
      
      // Timer başlat
      _startAutoLockTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Ülke istatistikleri 24 saat açık! 500 coin harcandı.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Hata: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Ülkelere Göre İstatistikler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: isLoading
          ? _buildLoadingState()
          : errorMessage != null
              ? _buildErrorState()
              : countryStats.isEmpty
                  ? _buildEmptyState()
                  : _buildStatsList(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading country statistics...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCountryStats,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.flag_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noDataAvailable,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: countryStats.length,
      itemBuilder: (context, index) {
        return _buildCountryStatCard(countryStats[index], index + 1);
      },
    );
  }

  Widget _buildCountryStatCard(Map<String, dynamic> stat, int rank) {
    final l10n = AppLocalizations.of(context)!;
    final country = stat['country'] as String;
    final wins = stat['wins'] as int;
    final losses = stat['losses'] as int;
    final totalMatches = stat['totalMatches'] as int;
    final winRate = stat['winRate'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Ülke Bayrağı Avatar (Profil fotoğrafı gibi)
          _buildCountryAvatar(country, rank, winRate),
          
          const SizedBox(width: 16),
          
          // Progress Bar (Profil fotoğrafları gibi)
          Expanded(
            child: _buildCountryProgressBar(winRate, wins, totalMatches),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryAvatar(String country, int rank, double winRate) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _getCountryBorderColor(winRate),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          color: Colors.grey[100],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getCountryFlag(country),
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryProgressBar(double winRate, int wins, int totalMatches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
              ),
              // Progress fill
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: winRate / 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: _getCountryProgressBarColors(winRate),
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // Kilitli overlay - sadece kilitliyken göster
              if (!isUnlocked)
                GestureDetector(
                  onTap: _showPurchaseDialog,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellow[300]!,
                          Colors.yellow[400]!,
                          Colors.yellow[500]!,
                          Colors.yellow[600]!,
                          Colors.orange[200]!,
                          Colors.orange[300]!,
                          Colors.orange[400]!,
                          Colors.orange[500]!,
                          Colors.orange[600]!,
                          Colors.orange[700]!,
                          Colors.orange[800]!,
                          Colors.orange[900]!,
                          Colors.red[200]!,
                          Colors.red[300]!,
                          Colors.red[400]!,
                          Colors.red[500]!,
                          Colors.red[600]!,
                          Colors.red[700]!,
                          Colors.red[800]!,
                          Colors.red[900]!,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 1.0],
                      ),
                      border: Border.all(
                        color: Colors.orange[600]!,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '500 coin',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Yüzde değeri - sadece açıksa göster
              if (isUnlocked)
                Center(
                  child: Text(
                    '${winRate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Win/Match sayıları
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            isUnlocked ? '$wins/$totalMatches' : 'Kilitli - 500 coin ile aç',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getCountryBorderColor(double winRate) {
    if (winRate >= 80) return Colors.amber;
    if (winRate >= 60) return Colors.grey[400]!;
    if (winRate >= 40) return Colors.orange;
    return Colors.grey;
  }

  List<Color> _getCountryProgressBarColors(double winRate) {
    // Aynı renk geçişleri - sarıdan kırmızıya
    final progress = winRate / 100.0;
    
    if (progress <= 0.0) {
      return [Colors.yellow[300]!, Colors.yellow[300]!];
    } else if (progress <= 0.05) {
      return [Colors.yellow[300]!, Colors.yellow[400]!];
    } else if (progress <= 0.10) {
      return [Colors.yellow[300]!, Colors.yellow[500]!];
    } else if (progress <= 0.15) {
      return [Colors.yellow[300]!, Colors.yellow[600]!];
    } else if (progress <= 0.20) {
      return [Colors.yellow[300]!, Colors.orange[200]!];
    } else if (progress <= 0.25) {
      return [Colors.yellow[300]!, Colors.orange[300]!];
    } else if (progress <= 0.30) {
      return [Colors.yellow[300]!, Colors.orange[400]!];
    } else if (progress <= 0.35) {
      return [Colors.yellow[300]!, Colors.orange[500]!];
    } else if (progress <= 0.40) {
      return [Colors.yellow[300]!, Colors.orange[600]!];
    } else if (progress <= 0.45) {
      return [Colors.yellow[300]!, Colors.orange[700]!];
    } else if (progress <= 0.50) {
      return [Colors.yellow[300]!, Colors.orange[800]!];
    } else if (progress <= 0.55) {
      return [Colors.yellow[300]!, Colors.orange[900]!];
    } else if (progress <= 0.60) {
      return [Colors.yellow[300]!, Colors.red[200]!]; // %60'ta açık kırmızıya geçiş
    } else if (progress <= 0.65) {
      return [Colors.yellow[300]!, Colors.red[300]!];
    } else if (progress <= 0.70) {
      return [Colors.yellow[300]!, Colors.red[400]!];
    } else if (progress <= 0.75) {
      return [Colors.yellow[300]!, Colors.red[500]!];
    } else if (progress <= 0.80) {
      return [Colors.yellow[300]!, Colors.red[600]!];
    } else if (progress <= 0.85) {
      return [Colors.yellow[300]!, Colors.red[700]!];
    } else if (progress <= 0.90) {
      return [Colors.yellow[300]!, Colors.red[800]!];
    } else if (progress <= 0.95) {
      return [Colors.yellow[300]!, Colors.red[900]!];
    } else {
      return [Colors.yellow[300]!, Colors.red[900]!];
    }
  }

  String _getCountryFlag(String country) {
    // Basit ülke bayrağı emojileri
    switch (country.toLowerCase()) {
      case 'turkiye':
      case 'türkiye':
        return '🇹🇷';
      case 'almanya':
        return '🇩🇪';
      case 'fransa':
        return '🇫🇷';
      case 'ingiltere':
        return '🇬🇧';
      case 'amerika':
      case 'abd':
        return '🇺🇸';
      case 'italya':
        return '🇮🇹';
      case 'ispanya':
        return '🇪🇸';
      case 'hollanda':
        return '🇳🇱';
      case 'belçika':
        return '🇧🇪';
      case 'portekiz':
        return '🇵🇹';
      case 'yunanistan':
        return '🇬🇷';
      case 'bulgaristan':
        return '🇧🇬';
      case 'romanya':
        return '🇷🇴';
      case 'polonya':
        return '🇵🇱';
      case 'çekya':
        return '🇨🇿';
      case 'macaristan':
        return '🇭🇺';
      case 'avusturya':
        return '🇦🇹';
      case 'isviçre':
        return '🇨🇭';
      case 'isveç':
        return '🇸🇪';
      case 'norveç':
        return '🇳🇴';
      case 'danimarka':
        return '🇩🇰';
      case 'finlandiya':
        return '🇫🇮';
      case 'rusya':
        return '🇷🇺';
      case 'ukrayna':
        return '🇺🇦';
      case 'kanada':
        return '🇨🇦';
      case 'avustralya':
        return '🇦🇺';
      case 'japonya':
        return '🇯🇵';
      case 'güney kore':
        return '🇰🇷';
      case 'çin':
        return '🇨🇳';
      case 'hindistan':
        return '🇮🇳';
      case 'brezilya':
        return '🇧🇷';
      case 'arjantin':
        return '🇦🇷';
      case 'meksika':
        return '🇲🇽';
      case 'mısır':
        return '🇪🇬';
      case 'güney afrika':
        return '🇿🇦';
      case 'nijerya':
        return '🇳🇬';
      case 'kenya':
        return '🇰🇪';
      case 'fas':
        return '🇲🇦';
      case 'cezayir':
        return '🇩🇿';
      case 'tunus':
        return '🇹🇳';
      case 'libya':
        return '🇱🇾';
      case 'sudan':
        return '🇸🇩';
      case 'etiyopya':
        return '🇪🇹';
      case 'uganda':
        return '🇺🇬';
      case 'tanzanya':
        return '🇹🇿';
      case 'ghana':
        return '🇬🇭';
      case 'senegal':
        return '🇸🇳';
      case 'mali':
        return '🇲🇱';
      case 'burkina faso':
        return '🇧🇫';
      case 'nijer':
        return '🇳🇪';
      case 'çad':
        return '🇹🇩';
      case 'kamerun':
        return '🇨🇲';
      case 'gabon':
        return '🇬🇦';
      case 'kongo':
        return '🇨🇬';
      case 'demokratik kongo':
        return '🇨🇩';
      case 'orta afrika':
        return '🇨🇫';
      case 'gine':
        return '🇬🇳';
      case 'sierra leone':
        return '🇸🇱';
      case 'liberya':
        return '🇱🇷';
      case 'fildişi sahili':
        return '🇨🇮';
      case 'gine bissau':
        return '🇬🇼';
      case 'gambiya':
        return '🇬🇲';
      case 'mauritius':
        return '🇲🇺';
      case 'seyşeller':
        return '🇸🇨';
      case 'madagaskar':
        return '🇲🇬';
      case 'komorlar':
        return '🇰🇲';
      case 'mayotte':
        return '🇾🇹';
      case 'reunion':
        return '🇷🇪';
      case 'saint helena':
        return '🇸🇭';
      case 'ascension':
        return '🇦🇨';
      case 'tristan da cunha':
        return '🇹🇦';
      case 'british virgin islands':
        return '🇻🇬';
      case 'anguilla':
        return '🇦🇮';
      case 'montserrat':
        return '🇲🇸';
      case 'saint kitts':
        return '🇰🇳';
      case 'antigua':
        return '🇦🇬';
      case 'dominica':
        return '🇩🇲';
      case 'saint lucia':
        return '🇱🇨';
      case 'saint vincent':
        return '🇻🇨';
      case 'grenada':
        return '🇬🇩';
      case 'barbados':
        return '🇧🇧';
      case 'trinidad':
        return '🇹🇹';
      case 'jamaika':
        return '🇯🇲';
      case 'bahamas':
        return '🇧🇸';
      case 'belize':
        return '🇧🇿';
      case 'guatemala':
        return '🇬🇹';
      case 'honduras':
        return '🇭🇳';
      case 'el salvador':
        return '🇸🇻';
      case 'nikaragua':
        return '🇳🇮';
      case 'kosta rika':
        return '🇨🇷';
      case 'panama':
        return '🇵🇦';
      case 'küba':
        return '🇨🇺';
      case 'haiti':
        return '🇭🇹';
      case 'dominik':
        return '🇩🇴';
      case 'puerto rico':
        return '🇵🇷';
      case 'virgin islands':
        return '🇻🇮';
      case 'saint pierre':
        return '🇵🇲';
      case 'greenland':
        return '🇬🇱';
      case 'bermuda':
        return '🇧🇲';
      case 'cayman islands':
        return '🇰🇾';
      case 'turks':
        return '🇹🇨';
      case 'aruba':
        return '🇦🇼';
      case 'netherlands antilles':
        return '🇦🇳';
      case 'sint maarten':
        return '🇸🇽';
      case 'saba':
        return '🇧🇶';
      case 'sint eustatius':
        return '🇧🇶';
      case 'bonaire':
        return '🇧🇶';
      case 'curaçao':
        return '🇨🇼';
      case 'surinam':
        return '🇸🇷';
      case 'guyana':
        return '🇬🇾';
      case 'fransız guyanası':
        return '🇬🇫';
      case 'venezuela':
        return '🇻🇪';
      case 'kolombiya':
        return '🇨🇴';
      case 'ekvador':
        return '🇪🇨';
      case 'peru':
        return '🇵🇪';
      case 'bolivya':
        return '🇧🇴';
      case 'şili':
        return '🇨🇱';
      case 'paraguay':
        return '🇵🇾';
      case 'uruguay':
        return '🇺🇾';
      case 'falkland':
        return '🇫🇰';
      case 'güney georgia':
        return '🇬🇸';
      case 'south sandwich':
        return '🇬🇸';
      case 'bouvet':
        return '🇧🇻';
      case 'heard':
        return '🇭🇲';
      case 'mcdonald':
        return '🇭🇲';
      case 'fransız güney':
        return '🇹🇫';
      case 'kerguelen':
        return '🇹🇫';
      case 'crozet':
        return '🇹🇫';
      case 'amsterdam':
        return '🇹🇫';
      case 'saint paul':
        return '🇹🇫';
      case 'adelie land':
        return '🇹🇫';
      case 'ross dependency':
        return '🇳🇿';
      case 'peter i island':
        return '🇳🇴';
      case 'queen maud land':
        return '🇳🇴';
      case 'british antarctic':
        return '🇬🇧';
      case 'chilean antarctic':
        return '🇨🇱';
      case 'australian antarctic':
        return '🇦🇺';
      case 'french antarctic':
        return '🇫🇷';
      case 'norwegian antarctic':
        return '🇳🇴';
      case 'new zealand antarctic':
        return '🇳🇿';
      case 'south african antarctic':
        return '🇿🇦';
      case 'argentine antarctic':
        return '🇦🇷';
      case 'brazilian antarctic':
        return '🇧🇷';
      case 'peruvian antarctic':
        return '🇵🇪';
      case 'ecuadorian antarctic':
        return '🇪🇨';
      case 'uruguayan antarctic':
        return '🇺🇾';
      default:
        return '🏳️';
    }
  }
}

