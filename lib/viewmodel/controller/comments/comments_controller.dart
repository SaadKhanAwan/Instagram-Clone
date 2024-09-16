import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/models/comments.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/utils/dilogues.dart';
import 'package:instagram_clone/viewmodel/services/firebase_services.dart';

class CommentsController extends BaseViewModel {
  final FirebaseServices _services = FirebaseServices();
  TextEditingController commentController = TextEditingController();
  bool isposting = false;
  String userName = '';
  String userImage = '';
  
  Stream<List<Comment>>? _commentsStream;
  Stream<List<Comment>>? get commentsStream => _commentsStream;

  CommentsController({required String postID}) {
    _init(postID);
  }

  _init(postID){
    fetchComments(postId: postID);
   fetchMyuserName();
  }

  Future addComment({
    postID,
    context,
    required String postImageUrl,
    required String recipientUserId,
  }) async {
    setstate(ViewState.loading);
    try {
      isposting = true;
      await _services
          .addComment(
              postId: postID,
              content: commentController.text,
              username: userName,
              postImageUrl: postImageUrl,
              recipientUserId: recipientUserId,
              userProfileImg: userImage,
              )
          .then((value) {
        Dilogues.showSnackbar(context, message: "Comment Added Sucussfully");
        commentController.clear();
      });
      setstate(ViewState.succuss);
      isposting = false;
    } catch (e) {
      setstate(ViewState.fail);
      Dilogues.showSnackbar(context, message: "Comment FAiled:$e");
      log("Error deleting post: $e");
      isposting = false;
    }
  }

  void fetchComments({String? postId}) {
    try {
      _commentsStream = _services.fetchComments(postId!);
      
    } catch (e) {
      log("Error deleting post: $e");
    }
  }

  Future<void> deleteComment(
      {String? postId, String? commentId, required context,required recipientUserId}) async {
          if (postId == null || commentId == null) {
    log("Post ID or Comment ID is null");
    return;
  }

    try {
      
      await _services.deleteComment(postId, commentId,recipientUserId: recipientUserId);
      Dilogues.showSnackbar(context, message: "Comment Deleted");
      notifyListeners();
    } catch (e) {
      Dilogues.showSnackbar(context, message: "Comment Deletetion failed");
      log("Error deleting post: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  String timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months months ago';
    } else {
      int years = (difference.inDays / 365).floor();
      return '$years years ago';
    }
  }


  Future fetchMyuserName() async {
    try {
      final UserData? name =
          await _services.fetchUserData(FirebaseAuth.instance.currentUser!.uid);
      userName= name!.name;
      userImage= name.image;


    } catch (e) {
      log("error message in: $e");
    }
  }
}
