import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/country_ranking_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCountryStats();
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

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.countryRanking),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank with Flag
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getCountryFlag(country),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Country Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalMatches ${l10n.totalMatches.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${winRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getWinRateColor(winRate),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatChip(
                      '${l10n.winsAgainst}: $wins',
                      Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      '${l10n.lossesAgainst}: $losses',
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.orange.shade300;
    return Colors.blue;
  }

  Color _getWinRateColor(double winRate) {
    if (winRate >= 70) return Colors.green;
    if (winRate >= 50) return Colors.orange;
    return Colors.red;
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
