import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String? id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final String? username;
  final String? profilePicture;

  Comment({
    this.id,
    this.username,
    this.profilePicture,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  // Factory method to create a Comment object from a Firestore document
  factory Comment.fromJson(Map<String, dynamic> firestoreData, id) {
    return Comment(
      id: id,
      userId: firestoreData['userId'] as String,
      content: firestoreData['content'] as String,
      timestamp: (firestoreData['timestamp'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
