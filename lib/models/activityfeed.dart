import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityFeedItem {
  final String userId;
  final String commentId;
  final String postId;
  final String username;
  final String userProfileImg;
  final String postImageUrl;
  final String type;
  final String comment; // Only for comments
  final DateTime timestamp;

  ActivityFeedItem({
    required this.userId,
    required this.postId,
    required this.commentId,
    required this.username,
    required this.userProfileImg,
    required this.postImageUrl,
    required this.type,
    required this.comment,
    required this.timestamp,
  });

  // You can implement a method to convert Firestore data into this model
  factory ActivityFeedItem.fromDocument(doc) {
    return ActivityFeedItem(
      userId: doc['userId'] ?? '',
      commentId: doc['commentId'] ?? '',
      postId: doc['postId'] ?? '',
      username: doc['username'],
      userProfileImg: doc['userProfileImg'] ?? '',
      postImageUrl: doc['postImageUrl'] ?? '',
      type: doc['type'] ?? '',
      comment: doc['comment'] ?? '',
      timestamp: (doc['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Method to convert the object back into a JSON (Map) format
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'commentId': commentId,
      'username': username,
      'userProfileImg': userProfileImg,
      'postImageUrl': postImageUrl,
      'type': type,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
