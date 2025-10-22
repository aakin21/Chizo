import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'user_service.dart';
import '../l10n/app_localizations.dart';

class PhotoUploadService {
  static final SupabaseClient _client = Supabase.instance.client;
  static final ImagePicker _picker = ImagePicker();

  // Photo upload costs (1-5 slots, first photo is free)
  static const Map<int, int> photoUploadCosts = {
    1: 0,   // First photo is free
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
      // print('Error getting user photos: $e');
      return [];
    }
  }

  /// Get user's photos with win rate statistics
  static Future<List<Map<String, dynamic>>> getUserPhotoStats(String userId) async {
    try {
      // First get the photos
      final photos = await getUserPhotos(userId);
      
      List<Map<String, dynamic>> photosWithStats = [];
      
      for (final photo in photos) {
        final photoId = photo['id'];
        
        // Get real photo statistics from database
        final photoStats = await getPhotoStats(photoId);
        
        int totalMatches = 0;
        int wins = 0;
        double winRate = 0.0;
        
        if (photoStats != null) {
          totalMatches = photoStats['total_matches'] ?? 0;
          wins = photoStats['wins'] ?? 0;
          if (totalMatches > 0) {
            winRate = (wins / totalMatches) * 100;
          }
        }

        photosWithStats.add({
          ...photo,
          'id': photoId,
          'total_matches': totalMatches,
          'wins': wins,
          'win_rate': winRate.toStringAsFixed(1),
        });
      }

      return photosWithStats;
    } catch (e) {
      // print('Error getting user photo stats: $e');
      return [];
    }
  }

  /// Upload tournament photo
  static Future<String?> uploadTournamentPhoto(XFile image) async {
    try {
      final fileName = 'tournament_${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      
      if (kIsWeb) {
        // Web platform - use bytes
        final bytes = await image.readAsBytes();
        final response = await _client.storage
            .from('tournament-photos')
            .uploadBinary(fileName, bytes);

        if (response.isNotEmpty) {
          final photoUrl = _client.storage
              .from('tournament-photos')
              .getPublicUrl(fileName);
          
          return photoUrl;
        }
      } else {
        // Mobile platform - use file
        final file = File(image.path);
        final response = await _client.storage
            .from('tournament-photos')
            .upload(fileName, file);

        if (response.isNotEmpty) {
          final photoUrl = _client.storage
              .from('tournament-photos')
              .getPublicUrl(fileName);
          
          return photoUrl;
        }
      }
      
      return null;
    } catch (e) {
      // print('Error uploading tournament photo: $e');
      return null;
    }
  }

  /// Get next available photo slot
  static Future<int?> getNextAvailableSlot(String userId) async {
    try {
      // Get all photos (including inactive ones) to check slot usage
      final allPhotos = await _client
          .from('user_photos')
          .select('photo_order, is_active')
          .eq('user_id', userId);
      
      print('DEBUG: All photos for user $userId: $allPhotos');
      
      // Only consider active photos for slot usage (handle null is_active as true for backward compatibility)
      final activePhotos = allPhotos.where((photo) => 
        photo['is_active'] == true || photo['is_active'] == null).toList();
      
      print('DEBUG: Active photos: $activePhotos');
      
      // If we have photos but no photo_order values, assign them sequentially
      if (activePhotos.isNotEmpty && activePhotos.every((photo) => photo['photo_order'] == null)) {
        print('DEBUG: All photos have null photo_order, assigning sequential numbers');
        // Assign sequential numbers to existing photos
        for (int i = 0; i < activePhotos.length; i++) {
          final photoId = activePhotos[i]['id'];
          await _client
              .from('user_photos')
              .update({'photo_order': i + 1})
              .eq('id', photoId);
        }
        // Return the next available slot
        return activePhotos.length + 1;
      }
      
      // Filter out photos with null photo_order and convert to int
      final usedSlots = activePhotos
          .where((photo) => photo['photo_order'] != null)
          .map((photo) {
            final order = photo['photo_order'];
            if (order is int) return order;
            if (order is double) return order.toInt();
            if (order is String) return int.tryParse(order) ?? 0;
            return 0;
          })
          .where((order) => order > 0)
          .toSet();
      
      print('DEBUG: Used slots: $usedSlots');
      
      for (int i = 1; i <= 5; i++) {
        if (!usedSlots.contains(i)) {
          print('DEBUG: Found available slot: $i');
          return i;
        }
      }
      
      return null; // All slots are full
    } catch (e) {
      print('DEBUG: Error getting next available slot: $e');
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

      print('DEBUG: Checking if user can upload to slot $slot');
      
      // Get all photos to check slot usage
      final allPhotos = await _client
          .from('user_photos')
          .select('photo_order, is_active, id')
          .eq('user_id', currentUser.id);
      
      print('DEBUG: All photos for user ${currentUser.id}: $allPhotos');
      
      // Only consider active photos for slot usage (handle null is_active as true for backward compatibility)
      final activePhotos = allPhotos.where((photo) => 
        photo['is_active'] == true || photo['is_active'] == null).toList();
      
      // Filter out photos with null photo_order and convert to int
      final usedSlots = activePhotos
          .where((photo) => photo['photo_order'] != null)
          .map((photo) {
            final order = photo['photo_order'];
            if (order is int) return order;
            if (order is double) return order.toInt();
            if (order is String) return int.tryParse(order) ?? 0;
            return 0;
          })
          .where((order) => order > 0)
          .toSet();

      // Check if slot is already used
      if (usedSlots.contains(slot)) {
        print('DEBUG: Slot $slot is already used by photos: $usedSlots');
        // Find the existing photo in this slot
        final existingPhoto = activePhotos.firstWhere(
          (photo) => _safeIntFromDynamic(photo['photo_order']) == slot,
          orElse: () => {},
        );
        print('DEBUG: Existing photo in slot $slot: $existingPhoto');
        return {'canUpload': false, 'message': 'Photo slot $slot is already used. Please delete the existing photo first.'};
      }

      // Check if slot is valid (1-5)
      if (slot < 1 || slot > 5) {
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
      // print('Error checking photo upload: $e');
      return {'canUpload': false, 'message': 'Error checking upload permission'};
    }
  }

  /// Upload photo to specific slot
  static Future<Map<String, dynamic>> uploadPhoto(int slot, {BuildContext? context}) async {
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

      // Crop image to iPhone portrait format (3:4 aspect ratio)
      XFile? croppedFile;
      try {
        print('DEBUG: Starting image crop for slot $slot');
        croppedFile = await _cropImageToiPhoneFormat(image, context);
        if (croppedFile == null) {
          print('DEBUG: Image cropping returned null (user cancelled)');
          return {'success': false, 'message': 'Image cropping cancelled'};
        }
        print('DEBUG: Image cropping completed successfully');
      } catch (e) {
        print('ERROR: Image cropping failed for slot $slot: $e');
        print('ERROR: Stack trace: ${StackTrace.current}');
        
        // Check if it's a UCropActivity error
        if (e.toString().contains('UCropActivity') || e.toString().contains('ActivityNotFoundException')) {
          return {'success': false, 'message': 'Image cropping feature is not available. Please try again or restart the app.'};
        }
        
        return {'success': false, 'message': 'Image cropping failed. Please try again.'};
      }

      // Upload to Supabase Storage
      String publicUrl;
      final fileName = '${currentUser.id}_photo_${slot}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'user_photos/$fileName';

      try {
        if (kIsWeb) {
          // Web platform - use bytes
          final bytes = await croppedFile.readAsBytes();
          final uploadResponse = await _client.storage
              .from('profile-images')
              .uploadBinary(filePath, bytes);

          if (uploadResponse.isEmpty) {
            return {'success': false, 'message': 'Failed to upload image'};
          }
        } else {
          // Mobile platform - use file
          final file = File(croppedFile.path);
          final uploadResponse = await _client.storage
              .from('profile-images')
              .upload(filePath, file);

          if (uploadResponse.isEmpty) {
            return {'success': false, 'message': 'Failed to upload image'};
          }
        }
      } catch (e) {
        print('ERROR: Storage upload failed: $e');
        return {'success': false, 'message': 'Failed to upload image to storage. Please try again.'};
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
      List<Map<String, dynamic>> insertResponse;
      try {
        insertResponse = await _client
            .from('user_photos')
            .insert({
              'user_id': currentUser.id,
              'photo_url': publicUrl,
              'photo_order': slot,
              'is_active': true,
            })
            .select();

        if (insertResponse.isEmpty) {
          throw Exception('Database insert returned empty response');
        }
      } catch (e) {
        print('ERROR: Database insert failed for slot $slot: $e');
        print('ERROR: This might be due to:');
        print('ERROR: 1. Duplicate photo_order constraint (slot $slot already exists)');
        print('ERROR: 2. Database connection issue');
        print('ERROR: 3. Invalid user_id or photo_url');
        
        // If database insert fails, delete the uploaded image and refund coins
        try {
          await _client.storage
              .from('profile-images')
              .remove([filePath]);
        } catch (storageError) {
          print('ERROR: Failed to clean up uploaded file: $storageError');
        }
        
        if (requiredCoins > 0) {
          try {
            await UserService.updateCoins(
              requiredCoins, 
              'refund', 
              'Photo upload failed - refund'
            );
          } catch (coinError) {
            print('ERROR: Failed to refund coins: $coinError');
          }
        }
        
        // Check if it's a duplicate constraint error
        if (e.toString().contains('duplicate') || e.toString().contains('unique')) {
          return {'success': false, 'message': 'Photo slot $slot is already used. Please delete the existing photo first.'};
        }
        
        return {'success': false, 'message': 'Failed to save photo record to database'};
      }

      // Photo stats artık user_photos içinde (wins=0, total_matches=0 default)
      final photoId = insertResponse.first['id'];

      return {
        'success': true,
        'message': 'Photo uploaded successfully',
        'photoUrl': publicUrl,
        'slot': slot,
        'coinsSpent': requiredCoins,
      };
    } catch (e) {
      print('ERROR: Photo upload failed for slot $slot: $e');
      print('ERROR: Stack trace: ${StackTrace.current}');
      return {'success': false, 'message': 'Photo upload failed. Please try again.'};
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

      // Completely remove from database instead of just marking as inactive
      await _client
          .from('user_photos')
          .delete()
          .eq('id', photoResponse['id']);

      return {
        'success': true,
        'message': 'Photo deleted successfully',
        'slot': slot,
      };
    } catch (e) {
      // print('Error deleting photo: $e');
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
      // print('Error reordering photos: $e');
      return {'success': false, 'message': 'Error reordering photos: $e'};
    }
  }

  /// Get photo upload cost for specific slot
  static int getPhotoUploadCost(int slot) {
    return photoUploadCosts[slot] ?? 0;
  }

  /// Safely convert dynamic value to int
  static int? _safeIntFromDynamic(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Debug method to check existing photos for a user
  static Future<void> debugUserPhotos(String userId) async {
    try {
      print('=== DEBUG: Checking photos for user $userId ===');
      
      final allPhotos = await _client
          .from('user_photos')
          .select('id, photo_order, is_active, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: true);
      
      print('DEBUG: Total photos found: ${allPhotos.length}');
      for (var photo in allPhotos) {
        print('DEBUG: Photo ID: ${photo['id']}, Order: ${photo['photo_order']}, Active: ${photo['is_active']}, Created: ${photo['created_at']}');
      }
      
      final activePhotos = allPhotos.where((photo) => 
        photo['is_active'] == true || photo['is_active'] == null).toList();
      
      print('DEBUG: Active photos: ${activePhotos.length}');
      final usedSlots = activePhotos
          .where((photo) => photo['photo_order'] != null)
          .map((photo) => _safeIntFromDynamic(photo['photo_order']))
          .where((order) => order != null && order > 0)
          .toSet();
      
      print('DEBUG: Used slots: $usedSlots');
      print('=== END DEBUG ===');
    } catch (e) {
      print('ERROR: Failed to debug user photos: $e');
    }
  }

  /// Get total photos count for user
  static Future<int> getUserPhotoCount(String userId) async {
    try {
      final photos = await getUserPhotos(userId);
      return photos.length;
    } catch (e) {
      // print('Error getting photo count: $e');
      return 0;
    }
  }

  /// Get photo statistics for a specific photo (user_photos kullan - photo_stats silindi)
  static Future<Map<String, dynamic>?> getPhotoStats(String photoId) async {
    try {
      final response = await _client
          .from('user_photos')
          .select('wins, total_matches, created_at, updated_at')
          .eq('id', photoId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Update photo statistics - user_photos kullan (photo_stats silindi)
  static Future<bool> updatePhotoStats(String photoId, {bool isWin = false}) async {
    try {
      final currentStats = await getPhotoStats(photoId);
      if (currentStats == null) return false;

      final newWins = isWin
          ? (currentStats['wins'] as int? ?? 0) + 1
          : (currentStats['wins'] as int? ?? 0);
      final newTotalMatches = (currentStats['total_matches'] as int? ?? 0) + 1;

      await _client
          .from('user_photos')
          .update({
            'wins': newWins,
            'total_matches': newTotalMatches,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', photoId);

      return true;
    } catch (e) {
      // print('Error updating photo stats: $e');
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
      // print('Error checking photo stats view permission: $e');
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
      // print('Error paying for photo stats view: $e');
      return false;
    }
  }

  /// Crop image to iPhone portrait format (3:4 aspect ratio)
  static Future<XFile?> _cropImageToiPhoneFormat(XFile imageFile, BuildContext? context) async {
    try {
      print('DEBUG: Starting image crop with file: ${imageFile.path}');
      
      // Get localized strings
      String cropTitle = 'Crop Image';
      String doneButton = 'Done';
      String cancelButton = 'Cancel';
      
      if (context != null) {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          cropTitle = l10n.cropImage;
          doneButton = l10n.cropImageDone;
          cancelButton = l10n.cropImageCancel;
        }
      }

      print('DEBUG: Calling ImageCropper with title: $cropTitle');
      
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4), // iPhone portrait format
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: cropTitle,
            toolbarColor: const Color(0xFFFF6B35),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio4x3, // 4:3 format
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio4x3, // 4:3 format
            ],
            backgroundColor: Colors.black,
            activeControlsWidgetColor: const Color(0xFFFF6B35),
            cropGridColor: Colors.white.withValues(alpha: 0.5),
            cropFrameColor: const Color(0xFFFF6B35),
          ),
          IOSUiSettings(
            title: cropTitle,
            doneButtonTitle: doneButton,
            cancelButtonTitle: cancelButton,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: false, // Allow aspect ratio selection
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            hidesNavigationBar: false,
          ),
        ],
      );

      print('DEBUG: ImageCropper returned: ${croppedFile?.path}');
      return croppedFile != null ? XFile(croppedFile.path) : null;
    } catch (e) {
      print('ERROR: Image cropping failed: $e');
      print('ERROR: This might be due to:');
      print('ERROR: 1. UCropActivity not found in AndroidManifest.xml');
      print('ERROR: 2. Image file path is invalid: ${imageFile.path}');
      print('ERROR: 3. Image cropper plugin issue');
      rethrow; // Re-throw to be caught by the calling method
    }
  }

}
