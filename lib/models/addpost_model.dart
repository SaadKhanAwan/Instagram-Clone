import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final List likesCount;
  final List commentsCount;

  Post({
    required this.postId,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
  });

  factory Post.fromDocumentSnapshot(Map<String, dynamic> doc) {
    return Post(
      postId: doc['postId'],
      userId: doc['userId'],
      content: doc['content'] ?? "",
      imageUrl: doc['imageUrl'],
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
      likesCount: doc['likesCount'],
      commentsCount: doc['commentsCount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
    };
  }
}
