import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'user_service.dart';

class PhotoUploadService {
  static final SupabaseClient _client = Supabase.instance.client;
  static final ImagePicker _picker = ImagePicker();

  // Photo upload costs (2-5 slots, first photo is profile photo)
  static const Map<int, int> photoUploadCosts = {
    2: 50,  // Second photo costs 50 coins
    3: 100, // Third photo costs 100 coins
    4: 150, // Fourth photo costs 150 coins
    5: 200, // Fifth photo costs 200 coins
  };

  /// Get user's current photos
  static Future<List<Map<String, dynamic>>> getUserPhotos(String userId) async {
    try {
      final response = await _client
          .from('user_photos')
          .select('*')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('photo_order', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting user photos: $e');
      return [];
    }
  }

  /// Get next available photo slot
  static Future<int?> getNextAvailableSlot(String userId) async {
    try {
      final photos = await getUserPhotos(userId);
      final usedSlots = photos.map((photo) => photo['photo_order'] as int).toSet();
      
      for (int i = 2; i <= 5; i++) {
        if (!usedSlots.contains(i)) {
          return i;
        }
      }
      
      return null; // All slots are full
    } catch (e) {
      print('Error getting next available slot: $e');
      return null;
    }
  }

  /// Check if user can upload photo to specific slot
  static Future<Map<String, dynamic>> canUploadPhoto(int slot) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return {'canUpload': false, 'message': 'User not found'};
      }

      final photos = await getUserPhotos(currentUser.id);
      final usedSlots = photos.map((photo) => photo['photo_order'] as int).toSet();

      // Check if slot is already used
      if (usedSlots.contains(slot)) {
        return {'canUpload': false, 'message': 'This photo slot is already used'};
      }

      // Check if slot is valid (2-5 only, 1 is profile photo)
      if (slot < 2 || slot > 5) {
        return {'canUpload': false, 'message': 'Invalid photo slot'};
      }

      // Check if user has enough coins
      final requiredCoins = photoUploadCosts[slot] ?? 0;
      if (currentUser.coins < requiredCoins) {
        return {
          'canUpload': false, 
          'message': 'Insufficient coins. Required: $requiredCoins, Available: ${currentUser.coins}'
        };
      }

      return {
        'canUpload': true, 
        'requiredCoins': requiredCoins,
        'message': 'Can upload photo'
      };
    } catch (e) {
      print('Error checking photo upload: $e');
      return {'canUpload': false, 'message': 'Error checking upload permission'};
    }
  }

  /// Upload photo to specific slot
  static Future<Map<String, dynamic>> uploadPhoto(int slot) async {
    try {
      // Check if user can upload
      final canUploadResult = await canUploadPhoto(slot);
      if (!canUploadResult['canUpload']) {
        return canUploadResult;
      }

      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return {'success': false, 'message': 'User not found'};
      }

      // Pick image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) {
        return {'success': false, 'message': 'No image selected'};
      }

      // Upload to Supabase Storage
      String publicUrl;
      final fileName = '${currentUser.id}_photo_${slot}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'user_photos/$fileName';

      if (kIsWeb) {
        // Web platform - use bytes
        final bytes = await image.readAsBytes();
        final uploadResponse = await _client.storage
            .from('profile-images')
            .uploadBinary(filePath, bytes);

        if (uploadResponse.isEmpty) {
          return {'success': false, 'message': 'Failed to upload image'};
        }
      } else {
        // Mobile platform - use file
        final file = File(image.path);
        final uploadResponse = await _client.storage
            .from('profile-images')
            .upload(filePath, file);

        if (uploadResponse.isEmpty) {
          return {'success': false, 'message': 'Failed to upload image'};
        }
      }

      // Get public URL
      publicUrl = _client.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      // Deduct coins if not first photo
      final requiredCoins = photoUploadCosts[slot] ?? 0;
      if (requiredCoins > 0) {
        final coinUpdateSuccess = await UserService.updateCoins(
          -requiredCoins, 
          'spent', 
          'Photo upload slot $slot'
        );
        
        if (!coinUpdateSuccess) {
          // If coin update fails, delete the uploaded image
          await _client.storage
              .from('profile-images')
              .remove([filePath]);
          return {'success': false, 'message': 'Failed to deduct coins'};
        }
      }

      // Save photo record to database
      final insertResponse = await _client
          .from('user_photos')
          .insert({
            'user_id': currentUser.id,
            'photo_url': publicUrl,
            'photo_order': slot,
            'is_active': true,
          })
          .select();

      if (insertResponse.isEmpty) {
        // If database insert fails, delete the uploaded image and refund coins
        await _client.storage
            .from('profile-images')
            .remove([filePath]);
        
        if (requiredCoins > 0) {
          await UserService.updateCoins(
            requiredCoins, 
            'refund', 
            'Photo upload failed - refund'
          );
        }
        
        return {'success': false, 'message': 'Failed to save photo record'};
      }

      return {
        'success': true,
        'message': 'Photo uploaded successfully',
        'photoUrl': publicUrl,
        'slot': slot,
        'coinsSpent': requiredCoins,
      };
    } catch (e) {
      print('Error uploading photo: $e');
      return {'success': false, 'message': 'Error uploading photo: $e'};
    }
  }

  /// Delete photo from specific slot
  static Future<Map<String, dynamic>> deletePhoto(int slot) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return {'success': false, 'message': 'User not found'};
      }

      // Get photo record
      final photoResponse = await _client
          .from('user_photos')
          .select('*')
          .eq('user_id', currentUser.id)
          .eq('photo_order', slot)
          .eq('is_active', true)
          .single();

      // photoResponse will never be null due to .single() method

      // Delete from storage
      final fileName = photoResponse['photo_url'].split('/').last;
      await _client.storage
          .from('profile-images')
          .remove(['user_photos/$fileName']);

      // Mark as inactive in database
      await _client
          .from('user_photos')
          .update({'is_active': false})
          .eq('id', photoResponse['id']);

      return {
        'success': true,
        'message': 'Photo deleted successfully',
        'slot': slot,
      };
    } catch (e) {
      print('Error deleting photo: $e');
      return {'success': false, 'message': 'Error deleting photo: $e'};
    }
  }

  /// Reorder photos
  static Future<Map<String, dynamic>> reorderPhotos(List<int> newOrder) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        return {'success': false, 'message': 'User not found'};
      }

      // Validate new order (2-5 only, 1 is profile photo)
      if (newOrder.length > 4 || newOrder.any((order) => order < 2 || order > 5)) {
        return {'success': false, 'message': 'Invalid photo order'};
      }

      // Get current photos
      final photos = await getUserPhotos(currentUser.id);
      if (photos.length != newOrder.length) {
        return {'success': false, 'message': 'Photo count mismatch'};
      }

      // Update photo orders
      for (int i = 0; i < photos.length; i++) {
        await _client
            .from('user_photos')
            .update({'photo_order': newOrder[i]})
            .eq('id', photos[i]['id']);
      }

      return {
        'success': true,
        'message': 'Photos reordered successfully',
      };
    } catch (e) {
      print('Error reordering photos: $e');
      return {'success': false, 'message': 'Error reordering photos: $e'};
    }
  }

  /// Get photo upload cost for specific slot
  static int getPhotoUploadCost(int slot) {
    return photoUploadCosts[slot] ?? 0;
  }

  /// Get total photos count for user
  static Future<int> getUserPhotoCount(String userId) async {
    try {
      final photos = await getUserPhotos(userId);
      return photos.length;
    } catch (e) {
      print('Error getting photo count: $e');
      return 0;
    }
  }

  /// Get photo statistics for a specific photo
  static Future<Map<String, dynamic>?> getPhotoStats(String photoId) async {
    try {
      final response = await _client
          .from('photo_stats')
          .select('*')
          .eq('photo_id', photoId)
          .maybeSingle();

      if (response == null) {
        // Create initial stats if not exists
        return await _createInitialPhotoStats(photoId);
      }

      return response;
    } catch (e) {
      print('Error getting photo stats: $e');
      return null;
    }
  }

  /// Create initial photo statistics
  static Future<Map<String, dynamic>?> _createInitialPhotoStats(String photoId) async {
    try {
      final response = await _client
          .from('photo_stats')
          .insert({
            'photo_id': photoId,
            'wins': 0,
            'total_matches': 0,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating initial photo stats: $e');
      return null;
    }
  }

  /// Update photo statistics (increment win or total matches)
  static Future<bool> updatePhotoStats(String photoId, {bool isWin = false}) async {
    try {
      // Get current stats
      final currentStats = await getPhotoStats(photoId);
      if (currentStats == null) return false;

      final newWins = isWin 
          ? (currentStats['wins'] as int) + 1 
          : (currentStats['wins'] as int);
      final newTotalMatches = (currentStats['total_matches'] as int) + 1;

      // Update stats
      await _client
          .from('photo_stats')
          .update({
            'wins': newWins,
            'total_matches': newTotalMatches,
          })
          .eq('photo_id', photoId);

      return true;
    } catch (e) {
      print('Error updating photo stats: $e');
      return false;
    }
  }

  /// Check if user has enough coins to view photo stats (50 coins)
  static Future<bool> canViewPhotoStats() async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) return false;

      return currentUser.coins >= 50;
    } catch (e) {
      print('Error checking photo stats view permission: $e');
      return false;
    }
  }

  /// Pay for photo stats view (50 coins)
  static Future<bool> payForPhotoStatsView() async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) return false;

      if (currentUser.coins < 50) return false;

      return await UserService.updateCoins(
        -50, 
        'spent', 
        'Photo statistics view'
      );
    } catch (e) {
      print('Error paying for photo stats view: $e');
      return false;
    }
  }

  /// Get all photo statistics for user's photos
  static Future<List<Map<String, dynamic>>> getUserPhotoStats(String userId) async {
    try {
      // Get user's photos
      final photos = await getUserPhotos(userId);
      final List<Map<String, dynamic>> photoStats = [];

      for (final photo in photos) {
        final stats = await getPhotoStats(photo['id']);
        if (stats != null) {
          photoStats.add({
            'photo_id': photo['id'],
            'photo_url': photo['photo_url'],
            'photo_order': photo['photo_order'],
            'wins': stats['wins'],
            'total_matches': stats['total_matches'],
            'win_rate': stats['total_matches'] > 0 
                ? ((stats['wins'] as int) / (stats['total_matches'] as int) * 100).toStringAsFixed(1)
                : '0.0',
          });
        }
      }

      return photoStats;
    } catch (e) {
      print('Error getting user photo stats: $e');
      return [];
    }
  }
}
