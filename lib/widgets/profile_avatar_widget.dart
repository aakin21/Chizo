import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/photo_upload_service.dart';
import '../services/user_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/win_rate_colors.dart';

class ProfileAvatarWidget extends StatefulWidget {
  final UserModel user;
  final Map<String, dynamic>? photoData;
  final double size;
  final bool showWinRateBar;
  final bool canChangePhoto;
  final VoidCallback? onPhotoChanged;
  final bool showStatsUnlockButton;

  const ProfileAvatarWidget({
    super.key,
    required this.user,
    this.photoData,
    this.size = 60,
    this.showWinRateBar = true,
    this.canChangePhoto = false,
    this.onPhotoChanged,
    this.showStatsUnlockButton = true,
  });

  @override
  State<ProfileAvatarWidget> createState() => _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends State<ProfileAvatarWidget> {
  bool isUnlocked = false;
  bool isUpdating = false;
  DateTime? unlockExpiryTime;

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

  Future<void> _checkUnlockStatus() async {
    if (widget.photoData != null) {
      final photoId = widget.photoData!['id'];
      final savedUnlockTime = await _getStoredUnlockTime(photoId);
      
      if (savedUnlockTime != null && DateTime.now().isBefore(savedUnlockTime)) {
        setState(() {
          isUnlocked = true;
          unlockExpiryTime = savedUnlockTime;
        });
        
        _startAutoLockTimer();
      } else {
        if (savedUnlockTime != null) {
          await _removeStoredUnlockTime(photoId);
        }
        setState(() {
          isUnlocked = false;
          unlockExpiryTime = null;
        });
      }
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
          
          if (widget.photoData != null) {
            final photoId = widget.photoData!['id'];
            _removeStoredUnlockTime(photoId);
          }
          
          // 24 saat sonra bildirim gönder
          _sendExpiryNotification();
        }
      });
    }
  }

  Future<void> _sendExpiryNotification() async {
    try {
      // 24 saat sonra bildirim gönder
      // await NotificationService.sendLocalNotification(
      //   title: 'İstatistikler Kilitlendi 🔒',
      //   body: 'Fotoğraf istatistikleri süresi doldu. Tekrar 100 coin ile açabilirsiniz.',
      //   payload: 'photo_stats_expired',
      // );
    } catch (e) {
      // Hata sessizce yutulur
    }
  }

  Future<DateTime?> _getStoredUnlockTime(String photoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString('photo_unlock_$photoId');
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
    } catch (e) {
      // Hata sessizce yutulur
    }
    return null;
  }

  Future<void> _storeUnlockTime(String photoId, DateTime expiryTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('photo_unlock_$photoId', expiryTime.toIso8601String());
    } catch (e) {
      // Hata sessizce yutulur
    }
  }

  Future<void> _removeStoredUnlockTime(String photoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('photo_unlock_$photoId');
    } catch (e) {
      // Hata sessizce yutulur
    }
  }

  Future<void> _sendUnlockNotification() async {
    try {
      // Bildirim servisini import et ve kullan
      // await NotificationService.sendLocalNotification(
      //   title: 'İstatistikler Açıldı! 📊',
      //   body: 'Fotoğraf istatistikleri 24 saat boyunca görüntülenebilir. 100 coin harcandı.',
      //   payload: 'photo_stats_unlocked',
      // );
    } catch (e) {
      // Hata sessizce yutulur
    }
  }


  double get winRate {
    if (widget.photoData != null && widget.photoData!['total_matches'] != null) {
      final totalMatches = widget.photoData!['total_matches'] as int;
      final wins = widget.photoData!['wins'] as int;
      if (totalMatches == 0) return 0.0;
      return (wins / totalMatches);
    }
    return widget.user.winRate / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          _buildAvatar(),
          
        if (widget.showWinRateBar) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildWinRateProgressBar(),
          ),
        ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: widget.canChangePhoto ? _handleAvatarTap : null,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _getAvatarBorderColor(),
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
          child: _buildAvatarContent(),
        ),
      ),
    );
  }

  Color _getAvatarBorderColor() {
    // Only show colored border when stats are unlocked
    if (isUnlocked || !widget.showStatsUnlockButton) {
      // Use the same color logic as progress bar for consistency
      return WinRateColors.getBorderColor(winRate);
    } else {
      // Default white border when stats are locked
      return Colors.white;
    }
  }

  Widget _buildAvatarContent() {
    final photoUrl = widget.photoData?['photo_url'];
    
    if (photoUrl != null) {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.person, size: 30),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.person, size: 30),
        ),
      );
    }
    
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: widget.size * 0.6,
      ),
    );
  }

  Widget _buildWinRateProgressBar() {
    int totalMatches = 0;
    int wins = 0;
    
    if (widget.photoData != null) {
      totalMatches = widget.photoData!['total_matches'] ?? 0;
      wins = widget.photoData!['wins'] ?? 0;
    } else {
      totalMatches = widget.user.totalMatches;
      wins = widget.user.wins;
    }
    
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
                widthFactor: winRate,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: WinRateColors.getProgressBarColors(winRate),
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // Overlay maske - 100 coin ödemeden önce progress bar'ı tüm renk geçişlerimizle kapatır
              if (!isUnlocked && widget.showStatsUnlockButton)
                GestureDetector(
                  onTap: _handleUnlockStats,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: WinRateColors.getProgressBarColors(1.0), // Tam renk geçişi
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      border: Border.all(
                        color: WinRateColors.getBorderColor(1.0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: WinRateColors.getBorderColor(1.0).withValues(alpha: 0.4),
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
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '100 coin',
                            style: TextStyle(
                              fontSize: 13,
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
              // Yüzde değeri (sadece unlock edilmişse göster)
              if (isUnlocked || !widget.showStatsUnlockButton)
                Center(
                  child: Text(
                    '${(winRate * 100).toStringAsFixed(0)}%',
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
        
        // Win/Match sayıları (sadece unlock edilmişse göster)
        if (isUnlocked || !widget.showStatsUnlockButton)
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: Text(
              '$wins/$totalMatches',
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
  


  Future<void> _handleAvatarTap() async {
    if (isUpdating) return;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.selectFromGallery),
              onTap: () {
                Navigator.pop(context);
                _uploadNewPhoto();
              },
            ),
            
            if (widget.photoData != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  AppLocalizations.of(context)!.deletePhoto,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteCurrentPhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadNewPhoto() async {
    setState(() => isUpdating = true);
    
    try {
      // Mevcut fotoğrafın slot numarasını bul veya yeni slot ata
      final currentSlot = widget.photoData?['photo_order'] as int? ?? 1;
      
      final result = await PhotoUploadService.uploadPhoto(currentSlot, context: context);
      
      if (!mounted) return;

      if (result['success']) {
        widget.onPhotoChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Fotoğraf başarıyla yüklendi ve kare formata kırpıldı'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Fotoğraf yüklenemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf yüklenemedi'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  Future<void> _deleteCurrentPhoto() async {
    if (widget.photoData == null) return;
    
    setState(() => isUpdating = true);
    
    try {
      final slot = widget.photoData!['photo_order'] as int;
      final result = await PhotoUploadService.deletePhoto(slot);

      if (!mounted) return;

      if (result['success']) {
        widget.onPhotoChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Fotoğraf silinemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf silinemedi'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  Future<void> _handleUnlockStats() async {
    if (isUpdating) return;
    
    // Check if user has enough coins
    if (widget.user.coins < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yetersiz coin. En az 100 coin gerekli.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İstatistikleri Aç'),
        content: Text('Bu fotoğrafın istatistiklerini görüntülemek için 100 coin harcayacaksınız.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Aç (100 coin)'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    setState(() => isUpdating = true);

    try {
      // Gerçek coin harcama - UserService ile entegre et
      final coinUpdateSuccess = await UserService.updateCoins(
        -100, 
        'spent', 
        'Fotoğraf istatistik görüntüleme'
      );
      
      if (!coinUpdateSuccess) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Yeterli coin yok!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 24 saatlik unlock süresi ayarla
      final expiryTime = DateTime.now().add(Duration(hours: 24));
      
      setState(() {
        isUnlocked = true;
        unlockExpiryTime = expiryTime;
      });
      
      // Storage'a kaydet
      if (widget.photoData != null) {
        final photoId = widget.photoData!['id'];
        await _storeUnlockTime(photoId, expiryTime);
      }
      
      // Timer başlat
      _startAutoLockTimer();
      
      // Bildirim gönder
      await _sendUnlockNotification();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ İstatistikler 24 saat açık! 100 coin harcandı.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kilidi açma başarısız'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }
}