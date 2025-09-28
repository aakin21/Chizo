import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  static final SupabaseClient _client = Supabase.instance.client;
  static final ImagePicker _picker = ImagePicker();

  // Galeriden resim seç
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      return image;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Kameradan resim çek
  static Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      return image;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Resmi Supabase Storage'a yükle
  static Future<String?> uploadImage(XFile imageFile, String fileName) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('No authenticated user');
        return null;
      }

      print('User email: ${user.email}');
      print('File path: ${imageFile.path}');

      // Dosya uzantısını kontrol et ve düzelt
      String finalFileName = fileName;
      if (!fileName.toLowerCase().endsWith('.jpg') && 
          !fileName.toLowerCase().endsWith('.jpeg') && 
          !fileName.toLowerCase().endsWith('.png')) {
        finalFileName = '$fileName.jpg';
      }

      // Kullanıcı ID'si ile dosya adı oluştur (RLS policy için gerekli)
      final uniqueFileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}_$finalFileName';
      
      print('Final file name: $uniqueFileName');
      
      // XFile'dan bytes al
      final Uint8List fileBytes = await imageFile.readAsBytes();
      print('File bytes length: ${fileBytes.length}');
      
      // İlk birkaç byte'ı kontrol et (dosya tipi için)
      if (fileBytes.isNotEmpty) {
        print('First bytes: ${fileBytes.take(10).toList()}');
      }
      
      print('About to upload to storage...');
      
      // Storage'a yükle
      final uploadResult = await _client.storage
          .from('profile-images')
          .uploadBinary(uniqueFileName, fileBytes);

      print('Upload result: $uploadResult');

      // Public URL'i al
      final imageUrl = _client.storage
          .from('profile-images')
          .getPublicUrl(uniqueFileName);

      print('Image URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }

  // Eski resmi sil
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      // URL'den dosya adını çıkar
      final fileName = imageUrl.split('/').last;
      
      await _client.storage
          .from('profile-images')
          .remove([fileName]);
      
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}

