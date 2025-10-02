import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../models/user_model.dart';
import '../services/photo_upload_service.dart';
import '../services/user_service.dart';
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
        }
      });
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

  String _getRemainingTimeText() {
    if (unlockExpiryTime == null) return '';
    
    final remaining = unlockExpiryTime!.difference(DateTime.now());
    if (remaining.isNegative) return '';
    
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}s ${minutes}dk kaldı';
    } else if (minutes > 0) {
      return '${minutes}dk ${seconds}sn kaldı';
    } else {
      return '${seconds}sn kaldı';
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
    return Row(
      children: [
        _buildAvatar(),
        
        if (widget.showWinRateBar) ...[
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: (!isUnlocked && widget.showStatsUnlockButton) ? _handleUnlockStats : null,
              child: _buildWinRateProgressBar(),
            ),
          ),
        ],
      ],
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
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kazanma Oranı',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            if (isUnlocked || !widget.showStatsUnlockButton)
              Text(
                '${(winRate * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getProgressBarColors()[1],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Kilitle',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[300],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: isUnlocked || !widget.showStatsUnlockButton ? winRate : 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: _getProgressBarColors(),
                ),
              ),
            ),
          ),
        ),
        
        if (!isUnlocked && widget.showStatsUnlockButton)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 4),
                Text(
                  'İstatistikleri görüntülemek için tıklayın',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        
        if (isUnlocked || !widget.showStatsUnlockButton)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility,
                  size: 16,
                  color: Colors.green[700],
                ),
                const SizedBox(width: 4),
                Text(
                  'İstatistikler görünür',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 4),
        
        _buildMatchWinStats(totalMatches, wins),
      ],
    );
  }
  
  Widget _buildMatchWinStats(int totalMatches, int wins) {
    if (totalMatches > 0) {
      return Row(
        children: [
          Text(
            '$wins/$totalMatches',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Maç',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    } else {
      return Text(
        'Henüz maç yok',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  List<Color> _getProgressBarColors() {
    if (winRate >= 0.8) {
      return [Colors.green[400]!, Colors.green[600]!];
    } else if (winRate >= 0.6) {
      return [Colors.blue[400]!, Colors.blue[600]!];
    } else if (winRate >= 0.4) {
      return [Colors.orange[400]!, Colors.orange[600]!];
    } else {
      return [Colors.red[400]!, Colors.red[600]!];
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
    
    final l10n = AppLocalizations.of(context)!;
    
    // Check if user has enough coins
    if (widget.user.coins < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.insufficientCoins),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İstatistikleri Kilitle'),
        content: Text('Bu fotoğrafın istatistiklerini görüntülemek için 10 coin harcayacaksınız.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Kilitle (10 coin)'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    setState(() => isUpdating = true);

    try {
      // Simulate coin spending - replace with actual UserService method
      final success = true; // await UserService.spendCoins(10, 'spent', 'İstatistik görüntüleme');

      if (success) {
        // 24 saatlik unlock süresi ayarla (demo için 30 saniye)
        final expiryTime = DateTime.now().add(Duration(seconds: 30)); // Duration(hours: 24) gerçek için
        
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İstatistikler kilidi açıldı'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kilidi açma başarısız'),
            backgroundColor: Colors.red,
          ),
        );
      }
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