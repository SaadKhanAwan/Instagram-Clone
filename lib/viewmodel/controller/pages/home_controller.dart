import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/utils/dilogues.dart';
import 'package:instagram_clone/viewmodel/services/firebase_services.dart';

class HomeController extends BaseViewModel {
  final FirebaseServices _services = FirebaseServices();
  final ScrollController scrollController = ScrollController();
  List<Map<String, dynamic>> posts = [];
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  DocumentSnapshot? _lastDocument;
  Map<String, bool> isFavoritedMap = {};
  List<Map<String, dynamic>> favoritePosts = [];
  Map<String, bool> isLikedMap = {};
  Map<String, int> likeCountMap = {};
  bool loadingFavorites = false;
  String userName = '';
  String userImage = '';


  HomeController() {
    init();
  }

  void init()async {
    scrollController.addListener(_scrollListener);
    _loadInitialPosts();
    loadFavoritePosts();
     await fetchMyuserName();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMorePosts) {
      _loadMorePosts(); // Load more posts if there is more data
    }
  }

  Future<void> _loadInitialPosts() async {
    try {
      setstate(ViewState.loading);
      List<Map<String, dynamic>> initialPosts =
          await _services.fetchPostsWithUserData(limit: 8);
      if (initialPosts.isNotEmpty) {
        posts = initialPosts;
        _lastDocument = initialPosts.last['document'] as DocumentSnapshot?;
        await loadInitialFavoriteStates();
        notifyListeners();
        setstate(ViewState.succuss);
      } else {
        setstate(ViewState.fail); // No initial posts
      }
    } catch (e) {
      setstate(ViewState.fail);
      log("Error loading initial posts: $e");
    }
  }

  Future<void> _loadMorePosts() async {
    if (!_hasMorePosts || _isLoadingMore) {
      return;
    }

    setstate(ViewState.loading);

    try {
      _isLoadingMore = true;

      List<Map<String, dynamic>> newPosts = await _services
          .fetchPostsWithUserData(limit: 4, startAfter: _lastDocument);

      if (newPosts.isNotEmpty) {
        posts.addAll(newPosts);
        _lastDocument = newPosts.last['document'] as DocumentSnapshot?;
      } else {
        _hasMorePosts = false; // No more posts to load
      }

      _isLoadingMore = false;
      setstate(ViewState.succuss);
    } catch (e) {
      setstate(ViewState.fail);
      log("Error loading more posts: $e");
    }
  }

  Future<void> refreshPosts() async {
    _lastDocument = null;
    _hasMorePosts = true;
    posts.clear();
    await _loadInitialPosts();
  }

  Future<void> deletePost(String postId, {required context}) async {
    try {
      await _services.deletePost(postId);
      posts.removeWhere((post) => post['post']['postId'] == postId);
      Dilogues.showSnackbar(context, message: "Post Deleted");
      notifyListeners();
    } catch (e) {
      Dilogues.showSnackbar(context, message: "Post Deletetion failed");
      log("Error deleting post: $e");
    }
  }

  Future checkIsLike(postID) async {
    notifyListeners();

    return await _services.isPostLikedByUser(postID);
  }

  Future likeFunctionality(
    String postId,
  ) async {
    isLikedMap[postId] = await checkIsLike(postId) ?? false;
    notifyListeners();
  }

  likeCountFunctionality({required String postId, required int likes}) {
    likeCountMap[postId] = likes;
    notifyListeners();
  }

  Future<void> toggleLikePost(
    String postId, { 
    required String postImageUrl,
    required String recipientUserId,
  }) async {
    if (isLikedMap[postId]!) {
      await FirebaseServices().dislikePost(postId,recipientUserId: recipientUserId);
      likeCountMap[postId] = likeCountMap[postId]! - 1;
    } else {
      await FirebaseServices().likePost(postId,
          postImageUrl: postImageUrl,
          recipientUserId: recipientUserId,
          userProfileImg: userImage,
          username: userName);
      likeCountMap[postId] = likeCountMap[postId]! + 1;
    }
    isLikedMap[postId] = !isLikedMap[postId]!;
    notifyListeners();
  }

  Future<void> loadFavoritePosts() async {
    try {
      loadingFavorites = true;
      notifyListeners();
      favoritePosts = await _services.fetchFavoritePosts();
      // Populate the isFavoritedMap for each post
      for (var post in favoritePosts) {
        String postId = post['post']['postId'];
        isFavoritedMap[postId] = true;
      }
      loadingFavorites = false;
      notifyListeners();
    } catch (e) {
      loadingFavorites = false;
      log("Error loading favorite posts: $e");
    }
  }

  Future<void> checkIsFavourite({required String postId}) async {
    try {
      bool isFavorited = await _services.isPostFavorited(postId);
      isFavoritedMap[postId] = isFavorited; // Store the favorite status
      notifyListeners();
    } catch (e) {
      log("Error checking if post is favorited: $e");
    }
  }

  Future<void> loadInitialFavoriteStates() async {
    for (var post in posts) {
      String postId = post['post']['postId'];
      await checkIsFavourite(postId: postId); // Check each post
      // Set the initial value to false for posts not in favorites
      isFavoritedMap[postId] ??= false;
    }
    notifyListeners();
  }

  Future<void> addFavorite(String postId) async {
    try {
      await _services.addPostToFavorites(postId: postId);
      await loadFavoritePosts(); // Update the favorite posts list
      notifyListeners(); // Notify the UI to rebuild
    } catch (e) {
      log("Error adding post to favorites: $e");
    }
  }

  Future<void> removeFavorite(String postId) async {
    try {
      await _services.removePostFromFavorites(postId: postId);
      await loadFavoritePosts(); // Update the favorite posts list
      notifyListeners(); // Notify the UI to rebuild
    } catch (e) {
      log("Error removing post from favorites: $e");
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String postId) async {
    bool isFavorited = isFavoritedMap[postId] ?? false;

    // Toggle the local favorite state immediately
    isFavoritedMap[postId] = !isFavorited;

    notifyListeners(); // Update UI immediately

    if (isFavorited) {
      await removeFavorite(postId);
    } else {
      await addFavorite(postId);
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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
}
