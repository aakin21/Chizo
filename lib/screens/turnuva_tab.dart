import 'package:flutter/material.dart';
import '../models/tournament_model.dart';
import '../services/tournament_service.dart';
import '../services/user_service.dart';

class TurnuvaTab extends StatefulWidget {
  const TurnuvaTab({super.key});

  @override
  State<TurnuvaTab> createState() => _TurnuvaTabState();
}

class _TurnuvaTabState extends State<TurnuvaTab> {
  List<TournamentModel> tournaments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTournaments();
  }

  Future<void> loadTournaments() async {
    setState(() => isLoading = true);
    try {
      final activeTournaments = await TournamentService.getActiveTournaments();
      setState(() {
        tournaments = activeTournaments;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _joinTournament(TournamentModel tournament) async {
    final currentUser = await UserService.getCurrentUser();
    if (currentUser == null) return;

    if (currentUser.coins < tournament.entryFee) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz coin!')),
      );
      return;
    }

    final success = await TournamentService.joinTournament(tournament.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turnuvaya katıldınız!')),
      );
      await loadTournaments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turnuvaya katılım başarısız!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Turnuvalar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (tournaments.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Şu anda aktif turnuva bulunmuyor',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: tournaments.length,
                itemBuilder: (context, index) {
                  final tournament = tournaments[index];
                  return _buildTournamentCard(tournament);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTournamentCard(TournamentModel tournament) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tournament.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tournament.status == 'active' 
                        ? Colors.green 
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tournament.status == 'active' ? 'Aktif' : 'Yaklaşıyor',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              tournament.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildInfoChip(
                  Icons.people,
                  '${tournament.currentParticipants}/${tournament.maxParticipants}',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.monetization_on,
                  '${tournament.entryFee} coin',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.stars,
                  '${tournament.prizePool} coin ödül',
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Başlangıç: ${_formatDate(tournament.startDate)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: tournament.currentParticipants >= tournament.maxParticipants
                    ? null
                    : () => _joinTournament(tournament),
                child: Text(
                  tournament.currentParticipants >= tournament.maxParticipants
                      ? 'Turnuva Dolu'
                      : 'Katıl',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
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
