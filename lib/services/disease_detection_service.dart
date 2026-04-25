import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service to save and retrieve disease detection records from Firestore.
class DiseaseDetectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Use a getter so it doesn't crash the entire service if the plugin is missing during instantiation
  FirebaseStorage get _storage => FirebaseStorage.instance;

  /// Save a disease detection result to Firestore
  Future<void> saveDetection({
    required String diseaseName,
    required double confidence,
    required bool isHealthy,
    String? imagePath,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to save detections');
      }

      String? imageUrl = imagePath;
      
      // Upload image to Firebase Storage if it's a local file
      if (imagePath != null && imagePath.isNotEmpty && !imagePath.startsWith('http')) {
        final file = File(imagePath);
        if (await file.exists()) {
          try {
            final fileName = 'detections/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
            final ref = _storage.ref().child(fileName);
            await ref.putFile(file);
            imageUrl = await ref.getDownloadURL();
          } catch (storageError) {
            print('⚠️ Storage upload failed (is Firebase Storage enabled?): $storageError');
            // If storage fails, we just keep the local path or null so Firestore save can still complete
            imageUrl = imagePath; 
          }
        }
      }

      await _firestore.collection('plant-care-o1').add({
        'userId': user.uid,
        'userEmail': user.email,
        'diseaseName': diseaseName,
        'confidence': confidence,
        'isHealthy': isHealthy,
        'imagePath': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'detectedAt': DateTime.now().toIso8601String(),
      });
      
      print('✅ Detection saved successfully: $diseaseName ($confidence)');
    } catch (e) {
      print('❌ Error saving detection: $e');
      rethrow;
    }
  }

  /// Get all detections for the current user
  Stream<List<Map<String, dynamic>>> getUserDetections() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('plant-care-o1')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get detection count for the current user
  Future<int> getDetectionCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final snapshot = await _firestore
        .collection('plant-care-o1')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.length;
  }

  /// Delete a specific detection
  Future<void> deleteDetection(String detectionId) async {
    try {
      await _firestore.collection('plant-care-o1').doc(detectionId).delete();
      print('✅ Detection deleted successfully');
    } catch (e) {
      print('❌ Error deleting detection: $e');
      rethrow;
    }
  }

  /// Get recent detections (limited to n)
  Future<List<Map<String, dynamic>>> getRecentDetections({int limit = 10}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('plant-care-o1')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}
