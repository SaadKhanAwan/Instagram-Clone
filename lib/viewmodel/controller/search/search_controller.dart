import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/viewmodel/services/firebase_services.dart';

class SearchControllerprovider extends BaseViewModel {
  TextEditingController searchController = TextEditingController();
  List<UserData> searchResults = [];
  List<String> randomImages = [];
  DocumentSnapshot? _lastDocument;
  bool isSearching = false;
  bool isLoadingImages = true;
  bool isLoadingMore = false;

  SearchControllerprovider() {
    _init();
  }

  void _init() {
    searchController.addListener(_onSearchChanged);
    _fetchRandomImages();
  }

  void _onSearchChanged() async {
    String query = searchController.text.trim();
    if (query.isNotEmpty) {
      isSearching = true;
      searchResults = await FirebaseServices().searchUsers(query);
      notifyListeners();  // Notify the UI to update
    } else {
      isSearching = false;
      searchResults.clear();
      notifyListeners();  // Notify the UI to update
    }
  }

  Future<void> _fetchRandomImages() async {
    List<String> images = [];
    try {
      QuerySnapshot snapshot = await FirebaseServices().fetchRandomImages(
        startAfter: _lastDocument,
      );
      if (snapshot.docs.isNotEmpty) {
        images = snapshot.docs.map((doc) {
          return (doc.data() as Map<String, dynamic>)['imageUrl'] as String;
        }).toList();
        randomImages.addAll(images);
        _lastDocument = snapshot.docs.last;
        isLoadingImages = false;
        notifyListeners();  // Notify the UI to update
      } else {
        isLoadingImages = false;
        notifyListeners();  // Notify the UI to update
      }
    } catch (e) {
      log("Error fetching images: $e");
      isLoadingImages = false;
      notifyListeners();  // Notify the UI to update
    }
  }

  Future<void> loadMoreImages() async {
    if (!isLoadingMore && _lastDocument != null) {
      isLoadingMore = true;
      notifyListeners();  // Notify the UI to update

      await _fetchRandomImages();

      isLoadingMore = false;
      notifyListeners();  // Notify the UI to update
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
