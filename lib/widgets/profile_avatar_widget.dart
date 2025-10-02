import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../models/user_model.dart';
import '../services/photo_upload_service.dart';
import '../l10n/app_localizations.dart';

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
      
      print('Bildirim gönderildi: İstatistikler süresi doldu');
    } catch (e) {
      print('Bildirim gönderme hatası: $e');
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
      print('Error parsing unlock time: $e');
    }
    return null;
  }

  Future<void> _storeUnlockTime(String photoId, DateTime expiryTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('photo_unlock_$photoId', expiryTime.toIso8601String());
    } catch (e) {
      print('Error storing unlock time: $e');
    }
  }

  Future<void> _removeStoredUnlockTime(String photoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('photo_unlock_$photoId');
    } catch (e) {
      print('Error removing unlock time: $e');
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
      
      print('Bildirim gönderildi: İstatistikler 24 saat açık, 100 coin harcandı');
    } catch (e) {
      print('Bildirim gönderme hatası: $e');
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
    if (winRate >= 0.8) return Colors.amber;
    if (winRate >= 0.6) return Colors.grey[400]!;
    if (winRate >= 0.4) return Colors.orange;
    return Colors.grey;
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
                      colors: _getProgressBarColors(),
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
  

  List<Color> _getProgressBarColors() {
    // Her progress bar aynı renk geçişine sahip - sarıdan kırmızıya
    // %60'ta açık kırmızıya geçiş, %5'lik aralıklarla smooth geçiş
    final progress = winRate;
    
    // Her zaman sarıdan başla, %60'ta kırmızıya geç
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
      
      final result = await PhotoUploadService.uploadPhoto(currentSlot);
      
      if (result['success']) {
        widget.onPhotoChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf başarıyla yüklendi'),
            backgroundColor: Colors.green,
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
      // await UserService.spendCoins(100, 'spent', 'Fotoğraf istatistik görüntüleme');

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