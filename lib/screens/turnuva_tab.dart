import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tournament_model.dart';
import '../models/user_model.dart';
import '../services/tournament_service.dart';
import '../services/user_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/beautiful_snackbar.dart';
import '../services/global_theme_service.dart';
import 'tournament_detail_screen.dart';
import 'champions_screen.dart';


class TurnuvaTab extends StatefulWidget {
  const TurnuvaTab({super.key});

  @override
  State<TurnuvaTab> createState() => _TurnuvaTabState();
}

class _TurnuvaTabState extends State<TurnuvaTab> {
  List<TournamentModel> tournaments = [];
  bool isLoading = true;
  UserModel? currentUser;
  Map<String, String> creatorNames = {}; // Creator ID -> Username mapping
  String _currentTheme = 'Koyu';

  @override
  void initState() {
    super.initState();
    loadTournaments();
    _loadCurrentTheme();
    
    // Global theme service'e callback kaydet
    GlobalThemeService().setThemeChangeCallback((theme) {
      if (mounted) {
        setState(() {
          _currentTheme = theme;
        });
      }
    });
  }

  @override
  void dispose() {
    // Callback'i temizle
    GlobalThemeService().clearAllCallbacks();
    super.dispose();
  }

  Future<void> _loadCurrentTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString('selected_theme') ?? 'Koyu';
      if (mounted) {
        setState(() {
          _currentTheme = theme;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentTheme = 'Koyu';
        });
      }
    }
  }

  Future<void> loadTournaments() async {
    setState(() => isLoading = true);
    try {
      // Önce Supabase bağlantısını test et
      await TournamentService.testSupabaseConnection();
      
      // Turnuva fazlarını güncelle (status kontrolü)
      await TournamentService.updateTournamentPhases();
      
      // Önce haftalık turnuvaları oluşturmayı dene
      await TournamentService.createWeeklyTournaments();
      
      // Debug: Turnuva name_key durumunu kontrol et
      await TournamentService.debugTournamentNameKeys();
      
      // Mevcut turnuvaların name_key alanlarını güncelle
      await TournamentService.updateExistingTournamentNameKeys();
      
      // Kullanıcının diline göre turnuvaları getir
      final currentLanguage = Localizations.localeOf(context).languageCode;
      final activeTournaments = await TournamentService.getActiveTournaments(language: currentLanguage);
      final user = await UserService.getCurrentUser();
      
      if (!mounted) return;
      
      // Her turnuva için kullanıcının katılım durumunu kontrol et
      for (var tournament in activeTournaments) {
        tournament.isUserParticipating = await _checkUserParticipation(tournament.id);
      }
      
      // Creator isimlerini yükle
      await _loadCreatorNames(activeTournaments);
      
      setState(() {
        tournaments = activeTournaments;
        currentUser = user;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => isLoading = false);
      BeautifulSnackBar.showError(
        context,
        message: '${AppLocalizations.of(context)!.error}: $e',
      );
    }
  }


  // Kullanıcının turnuvaya katılıp katılmadığını kontrol et
  Future<bool> _checkUserParticipation(String tournamentId) async {
    try {
      // currentUser null ise tekrar al
      UserModel? user = currentUser;
      if (user == null) {
        user = await UserService.getCurrentUser();
        if (user == null) return false;
      }
      
      final participation = await TournamentService.client
          .from('tournament_participants')
          .select('id')
          .eq('tournament_id', tournamentId)
          .eq('user_id', user.id)
          .maybeSingle();
      
      return participation != null;
    } catch (e) {
      return false;
    }
  }

  // Creator isimlerini yükle
  Future<void> _loadCreatorNames(List<TournamentModel> tournaments) async {
    try {
      // Private turnuvaların creator ID'lerini topla
      final creatorIds = tournaments
          .where((t) => t.isPrivate && t.creatorId != null)
          .map((t) => t.creatorId!)
          .toSet()
          .toList();

      if (creatorIds.isEmpty) return;

      // Creator isimlerini veritabanından al
      final response = await TournamentService.client
          .from('users')
          .select('id, username')
          .inFilter('id', creatorIds);

      // Map'i güncelle
      for (var user in response) {
        creatorNames[user['id']] = user['username'] ?? 'Bilinmeyen';
      }
    } catch (e) {
      // Error loading creator names
    }
  }




















  @override
  Widget build(BuildContext context) {
    final isDarkTheme = _currentTheme == 'Koyu';
    
    return Container(
      decoration: isDarkTheme 
          ? BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF121212), // Çok koyu gri
                  Color(0xFF1A1A1A), // Koyu gri
                ],
              ),
            )
          : null,
      child: RefreshIndicator(
        onRefresh: loadTournaments,
        child: _buildSimpleTournamentList(),
      ),
    );
  }

  // Basit turnuva listesi
  Widget _buildSimpleTournamentList() {
    final isDarkTheme = _currentTheme == 'Koyu';
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _showJoinPrivateTournamentDialog,
                icon: const Icon(Icons.key, size: 16),
                label: Text(AppLocalizations.of(context)!.joinWithKey),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreatePrivateTournamentDialog,
                icon: const Icon(Icons.add, size: 16),
                label: Text(AppLocalizations.of(context)!.private),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToChampions,
                icon: const Icon(Icons.emoji_events, size: 16),
                label: const Text('Şampiyonlar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35), // Ana turuncu ton
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (isLoading)
            SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  color: isDarkTheme ? const Color(0xFFFF6B35) : null,
                ),
              ),
            )
          else if (tournaments.isEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFF6B35).withValues(alpha: 0.1),
                            const Color(0xFFFF8C42).withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.emoji_events, 
                        size: 60, 
                        color: Color(0xFFFF6B35), // Ana turuncu ton
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noActiveTournament,
                      style: TextStyle(
                        fontSize: 16, 
                        color: isDarkTheme ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: tournaments.map((tournament) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSimpleTournamentCard(tournament),
                ),
              ).toList(),
            ),
        ],
      ),
    );
  }

  // Turnuva amblemi widget'ı
  Widget _buildAppLogoIcon() {
    return const Icon(
      Icons.emoji_events,
      color: Colors.white,
      size: 24,
    );
  }

  // Basit turnuva kartı - sadece isim ve katılımcı sayısı
  Widget _buildSimpleTournamentCard(TournamentModel tournament) {
    final isDarkTheme = _currentTheme == 'Koyu';
    
    return GestureDetector(
      onTap: () => _navigateToTournamentDetail(tournament),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDarkTheme 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E1E1E), // Koyu gri
                    const Color(0xFF2D2D2D), // Daha koyu gri
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFFFF8F5), // Çok açık turuncu ton
                  ],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkTheme 
                ? const Color(0xFFFF6B35).withValues(alpha: 0.3)
                : const Color(0xFFFF6B35).withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkTheme 
                  ? const Color(0xFFFF6B35).withValues(alpha: 0.2)
                  : const Color(0xFFFF6B35).withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: isDarkTheme 
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Turnuva ikonu - Uygulama logosu
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFF6B35), // Ana turuncu ton
                    const Color(0xFFFF8C42), // Açık turuncu ton
                    const Color(0xFFE55A2B), // Koyu turuncu ton
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: tournament.isPrivate 
                ? const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 24,
                  )
                : _buildAppLogoIcon(),
            ),
            
            const SizedBox(width: 12),
            
            // Turnuva bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.getLocalizedName(AppLocalizations.of(context)!),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tournament.currentParticipants}/${tournament.maxParticipants} katılımcı',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkTheme ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  if (tournament.isPrivate) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Oluşturan: ${creatorNames[tournament.creatorId] ?? "Bilinmeyen"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkTheme ? Colors.white60 : Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Durum göstergesi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(tournament.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(tournament.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(tournament.status),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Ok ikonu
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkTheme ? Colors.white60 : Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Turnuva detay sayfasına git
  void _navigateToTournamentDetail(TournamentModel tournament) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailScreen(tournament: tournament),
      ),
    );
    
    // Her zaman listeyi yenile (katılım durumu değişebilir)
    loadTournaments();
  }

  // Durum rengi
  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Durum metni
  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'upcoming':
        return 'Yakında';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal';
      default:
        return 'Bilinmeyen';
    }
  }





  // Turnuva format tooltip'leri
  String _getFormatTooltip(String format) {
    switch (format) {
      case 'league':
        return 'Lig Usulü: Herkes herkesle oynar, en yüksek win rate kazanır. Sınırsız katılımcı.';
      case 'elimination':
        return 'Eleme Usulü: Tek maçlık eleme sistemi. Maksimum 8 kişi (Çeyrek final, Yarı final, Final).';
      default:
        return 'Turnuva formatı seçin';
    }
  }

  // Private turnuva oluşturma dialog'u
  Future<void> _showCreatePrivateTournamentDialog() async {
    // Önce kullanıcının coin'ini kontrol et
    final currentUser = await UserService.getCurrentUser();
    if (currentUser == null) {
      BeautifulSnackBar.showError(
        context,
        message: 'Kullanıcı bilgileri alınamadı',
      );
      return;
    }

    const requiredCoins = 5000;
    if (currentUser.coins < requiredCoins) {
      BeautifulSnackBar.showWarning(
        context,
        message: 'Private turnuva oluşturmak için $requiredCoins coin gerekli. Mevcut coin: ${currentUser.coins}',
      );
      return;
    }

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final maxParticipantsController = TextEditingController(text: '8');
    
    String selectedFormat = 'league';
    String selectedGender = 'Erkek';
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 7));
    TimeOfDay startTime = const TimeOfDay(hour: 20, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 22, minute: 0);

    final isDarkTheme = _currentTheme == 'Koyu';
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDarkTheme ? const Color(0xFF1E1E1E) : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.createPrivateTournament,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Private turnuva oluşturmak için 5000 coin gereklidir',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Turnuva adı
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.tournamentName,
                    border: OutlineInputBorder(),
                    prefixIcon: const Icon(
                      Icons.emoji_events,
                      color: Color(0xFFFF6B35), // Ana turuncu ton
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Açıklama
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Max participants
                TextField(
                  controller: maxParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.maxParticipants,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.people),
                    // Private turnuvalar için eleme usulü sınırı yok
                  ),
                  onChanged: (value) {
                    // Private turnuvalar için eleme usulü sınırı yok
                  },
                ),
                const SizedBox(height: 16),
                
                // Turnuva formatı
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedFormat,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.tournamentFormat,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sports_esports),
                        ),
                        items: [
                          DropdownMenuItem(value: 'league', child: Text(AppLocalizations.of(context)!.leagueFormat)),
                          DropdownMenuItem(value: 'elimination', child: Text(AppLocalizations.of(context)!.eliminationFormat)),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedFormat = value!;
                            // Private turnuvalar için eleme usulü sınırı yok
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: _getFormatTooltip(selectedFormat),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Cinsiyet
                DropdownButtonFormField<String>(
                  initialValue: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Cinsiyet',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                    DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedGender = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Başlangıç tarihi ve saati
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Başlangıç Tarihi'),
                  subtitle: Text('${startDate.day}/${startDate.month}/${startDate.year}'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        startDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Başlangıç Saati'),
                  subtitle: Text('${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (time != null) {
                      setDialogState(() {
                        startTime = time;
                      });
                    }
                  },
                ),
                
                // Bitiş tarihi ve saati
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Bitiş Tarihi'),
                  subtitle: Text('${endDate.day}/${endDate.month}/${endDate.year}'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: startDate,
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        endDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Bitiş Saati'),
                  subtitle: Text('${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (time != null) {
                      setDialogState(() {
                        endTime = time;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || 
                    descriptionController.text.isEmpty ||
                    maxParticipantsController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen tüm alanları doldurun'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Private turnuvalar için eleme usulü sınırı yok
                
                Navigator.pop(context);
                
                // Tarih ve saati birleştir
                final finalStartDate = DateTime(
                  startDate.year,
                  startDate.month,
                  startDate.day,
                  startTime.hour,
                  startTime.minute,
                );
                final finalEndDate = DateTime(
                  endDate.year,
                  endDate.month,
                  endDate.day,
                  endTime.hour,
                  endTime.minute,
                );
                
                await _createPrivateTournament(
                  name: nameController.text,
                  description: descriptionController.text,
                  maxParticipants: int.parse(maxParticipantsController.text),
                  startDate: finalStartDate,
                  endDate: finalEndDate,
                  tournamentFormat: selectedFormat,
                  gender: selectedGender,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  // Private turnuva oluştur
  Future<void> _createPrivateTournament({
    required String name,
    required String description,
    required int maxParticipants,
    required DateTime startDate,
    required DateTime endDate,
    required String tournamentFormat,
    required String gender,
  }) async {
    try {
      // Kullanıcının diline göre private turnuva oluştur
      final currentLanguage = Localizations.localeOf(context).languageCode;
      final result = await TournamentService.createPrivateTournament(
        name: name,
        description: description,
        maxParticipants: maxParticipants,
        startDate: startDate,
        endDate: endDate,
        tournamentFormat: tournamentFormat,
        gender: gender,
        language: currentLanguage,
      );

      if (result['success']) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Private Key: ${result['private_key']}',
              textColor: Colors.white,
              onPressed: () {
                // Private key'i kopyala
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Private Key: ${result['private_key']}'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          ),
        );
        
        // Turnuvaları yenile
        loadTournaments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Private key ile katılma dialog'u
  Future<void> _showJoinPrivateTournamentDialog() async {
    final keyController = TextEditingController();

    final isDarkTheme = _currentTheme == 'Koyu';
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkTheme ? const Color(0xFF1E1E1E) : null,
        title: Row(
          children: [
            const Icon(Icons.key, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              'Private Key ile Katıl',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : null,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Private Key',
                hintText: 'ABCD1234',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
            ),
            const SizedBox(height: 16),
            const Text(
              'Turnuva oluşturan kişiden private key\'i alın',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (keyController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen private key girin'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              await _joinPrivateTournament(keyController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.join),
          ),
        ],
      ),
    );
  }











  // Şampiyonlar sayfasına git
  void _navigateToChampions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChampionsScreen(),
      ),
    );
  }

  // Private turnuvaya katıl
  Future<void> _joinPrivateTournament(String privateKey) async {
    try {
      final result = await TournamentService.joinPrivateTournament(privateKey);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Turnuvaları yenile
        loadTournaments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }









}
