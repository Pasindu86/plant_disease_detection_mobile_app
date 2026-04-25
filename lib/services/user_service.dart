import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's data from Firestore
  Future<UserModel?> getUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) {
        // Create initial user document if it doesn't exist
        final newUser = UserModel(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .set(newUser.toMap());
        return newUser;
      }

      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({String? name, String? phoneNumber}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final updateData = <String, dynamic>{
        'uid': currentUser.uid,
        'email': currentUser.email ?? '',
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (name != null) {
        updateData['name'] = name;
      }
      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
      }

      // Use set with merge to create document if it doesn't exist
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload user profile photo to Firestore as base64
  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Read the image file and convert to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Save to Firestore
      await _firestore.collection('users').doc(currentUser.uid).set({
        'profilePhoto': base64Image,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      return base64Image;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  // Delete user profile photo
  Future<void> deleteProfilePhoto() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Update Firestore to remove the photo
      await _firestore.collection('users').doc(currentUser.uid).set({
        'profilePhoto': null,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to delete profile photo: $e');
    }
  }

  // Stream of user data (for real-time updates)
  Stream<UserModel?> getUserDataStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(null);

    return _firestore.collection('users').doc(currentUser.uid).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }
}
