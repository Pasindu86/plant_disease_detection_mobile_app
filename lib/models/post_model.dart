import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime timestamp;
  final DateTime expiresAt;
  final List<String> likes;
  final int commentsCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.timestamp,
    required this.expiresAt,
    this.likes = const [],
    this.commentsCount = 0,
  });

  factory PostModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PostModel(
      id: documentId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      title: data['title'] ?? '',
      description: data['description'] ?? data['content'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt:
          (data['expiresAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 7)),
      likes: List<String>.from(data['likes'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'likes': likes,
      'commentsCount': commentsCount,
    };
  }
}
