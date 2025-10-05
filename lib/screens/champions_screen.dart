import 'package:flutter/material.dart';
import '../services/tournament_service.dart';

class ChampionsScreen extends StatefulWidget {
  const ChampionsScreen({super.key});

  @override
  State<ChampionsScreen> createState() => _ChampionsScreenState();
}

class _ChampionsScreenState extends State<ChampionsScreen> {
  List<Map<String, dynamic>> champions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChampions();
  }

  Future<void> _loadChampions() async {
    try {
      setState(() {
        isLoading = true;
      });

      final championsList = await TournamentService.getTournamentWinners();
      
      setState(() {
        champions = championsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Şampiyonlar yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Şampiyonlar',
          style: TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            )
          : champions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.grey,
                        size: 80,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Henüz şampiyon yok',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'İlk turnuva bittiğinde şampiyonlar burada görünecek',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: champions.length,
                  itemBuilder: (context, index) {
                    final champion = champions[index];
                    return _buildChampionCard(champion);
                  },
                ),
    );
  }

  Widget _buildChampionCard(Map<String, dynamic> champion) {
    return GestureDetector(
      onTap: () => _showChampionDetails(champion),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Turnuva ikonu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getTournamentTypeColor(champion['tournament_type']).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.emoji_events,
                color: _getTournamentTypeColor(champion['tournament_type']),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Turnuva bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    champion['tournament_name'] ?? 'Bilinmeyen Turnuva',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(champion['completed_at']),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTournamentTypeText(champion['tournament_type']),
                    style: TextStyle(
                      color: _getTournamentTypeColor(champion['tournament_type']),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Şampiyon bilgisi
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Şampiyon',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  champion['first_place_username'] ?? 'Bilinmeyen',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 8),
            
            // Ok işareti
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showChampionDetails(Map<String, dynamic> champion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          champion['tournament_name'] ?? 'Turnuva Detayları',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Sıra - Altın
              _buildPodiumPosition(
                position: 1,
                username: champion['first_place_username'],
                photoUrl: champion['first_place_photo_url'],
                prize: champion['first_place_prize'],
                color: Colors.amber,
                icon: Icons.emoji_events,
              ),
              
              const SizedBox(height: 20),
              
              // 2. Sıra - Gümüş
              _buildPodiumPosition(
                position: 2,
                username: champion['second_place_username'],
                photoUrl: champion['second_place_photo_url'],
                prize: champion['second_place_prize'],
                color: Colors.grey[400]!,
                icon: Icons.emoji_events,
              ),
              
              const SizedBox(height: 20),
              
              // 3. Sıra - Bronz
              _buildPodiumPosition(
                position: 3,
                username: champion['third_place_username'],
                photoUrl: champion['third_place_photo_url'],
                prize: champion['third_place_prize'],
                color: Colors.orange[700]!,
                icon: Icons.emoji_events,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Kapat',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition({
    required int position,
    required String username,
    required String? photoUrl,
    required int prize,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Sıralama numarası
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Fotoğraf
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: photoUrl != null && photoUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      photoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          icon,
                          color: color,
                          size: 30,
                        );
                      },
                    ),
                  )
                : Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
          ),
          
          const SizedBox(width: 16),
          
          // Kullanıcı bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$prize coin',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTournamentTypeColor(String? type) {
    switch (type) {
      case 'weekly_5000':
        return Colors.purple;
      case 'instant_5000':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getTournamentTypeText(String? type) {
    switch (type) {
      case 'weekly_5000':
        return 'Haftalık 5000 Coin';
      case 'instant_5000':
        return 'Anında 5000 Coin';
      default:
        return 'Bilinmeyen';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Tarih bilinmiyor';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Tarih bilinmiyor';
    }
  }
}
