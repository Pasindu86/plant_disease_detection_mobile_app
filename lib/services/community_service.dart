import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityService {
  final CollectionReference _postsCollection = FirebaseFirestore.instance
      .collection('community_posts');

  // Stream of posts
  Stream<List<PostModel>> getPosts() {
    // Only fetch posts where expiresAt is in the future
    return _postsCollection
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs.map((doc) {
            return PostModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          // Since we filtered by expiresAt, we sort locally or through compound index.
          // Sorting locally is easier for simple setups:
          posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return posts;
        });
  }

  // Create text post
  Future<void> createPost({
    required String title,
    required String description,
    File? imageFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? imageUrl;

    // Upload image if provided
    if (imageFile != null) {
      try {
        final bytes = await imageFile.readAsBytes();
        imageUrl = base64Encode(bytes);
      } catch (e) {
        print('Error encoding image: $e');
        // Let user create a text-only post if image conversion fails, or rethrow
        rethrow;
      }
    }

    final newPost = PostModel(
      id: '',
      userId: user.uid,
      userName: user.displayName ?? 'Farmer',
      title: title,
      description: description,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    await _postsCollection.add(newPost.toMap());
  }

  // Like or unlike a post
  Future<void> toggleLike(String postId, List<String> currentLikes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (currentLikes.contains(user.uid)) {
      await _postsCollection.doc(postId).update({
        'likes': FieldValue.arrayRemove([user.uid]),
      });
    } else {
      await _postsCollection.doc(postId).update({
        'likes': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  // Delete a post
  Future<void> deletePost(String postId, {String? imageUrl}) async {
    // Because we are no longer using Firebase Storage, we simply delete the Firestore doc.
    await _postsCollection.doc(postId).delete();
  }

  // Automatically delete expired posts and their images
  Future<void> deleteExpiredPosts() async {
    try {
      final now = DateTime.now();
      final expiredSnapshot = await _postsCollection
          .where('expiresAt', isLessThan: Timestamp.fromDate(now))
          .get();

      for (var doc in expiredSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final imageUrl = data['imageUrl'] as String?;
        await deletePost(doc.id, imageUrl: imageUrl);
      }
    } catch (e) {
      print('Error cleaning up expired posts: \$e');
    }
  }
}
