import 'dart:developer';

import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/models/activityfeed.dart';
import 'package:instagram_clone/viewmodel/services/firebase_services.dart';

class NotificationsController extends BaseViewModel {
  final FirebaseServices _services = FirebaseServices();


  Stream<List<ActivityFeedItem>> fetchActivityFeed() {
    try {
      final response = _services.fetchActivityFeed();
      return response;
    } catch (e) {
      log("error is $e");
      return const Stream.empty();
    }
  }

  String getActivityText(ActivityFeedItem item) {
    switch (item.type) {
      case "like":
        return "Liked your photo";
      case "comment":
        return "Commented: ${item.comment}";
      case "follow":
        return "Started following you";
      default:
        return "Erro in fetch";
    }
  }

  String formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${difference.inDays ~/ 7} weeks ago';
    }
  }
}
