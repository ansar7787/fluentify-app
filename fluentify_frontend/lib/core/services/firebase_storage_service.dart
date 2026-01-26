import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final extension = path.extension(imageFile.path);
      final fileName = '${userId}_${_uuid.v4()}$extension';
      final ref = _storage.ref().child('profile_images').child(fileName);

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/${extension.replaceAll('.', '')}'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading to Firebase Storage: $e');
      return null;
    }
  }

  Future<bool> deleteOldImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting from Firebase Storage: $e');
      return false;
    }
  }
}
