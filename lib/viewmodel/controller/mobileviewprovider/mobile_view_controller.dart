import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/view/screens/pages/add_post.dart';
import 'package:instagram_clone/view/screens/pages/favourite_screen.dart';
import 'package:instagram_clone/view/screens/pages/homescreen.dart';
import 'package:instagram_clone/view/screens/pages/profile_screen.dart';
import 'package:instagram_clone/view/screens/pages/search_screen.dart';

class MobileViewController extends BaseViewModel {
  int currentIndex = 0;
  final PageController pageController = PageController();

  final List<BottomNavigationBarItem> bottomNavigationBarItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.add),
      label: 'Add',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: 'Favorite',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  final List<Widget> pages = [
    const PostScreen(),
    const SearchScreen(),
    const AddPostScreen(),
    const FavouriteScreen(),
    UserProfileScreen(userId:FirebaseAuth.instance.currentUser!.uid ,),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onpageChange(index) {
    currentIndex = index;
    notifyListeners();
  }

  void changeIndex(index) {
    currentIndex = index;
    pageController.jumpToPage(
      index,
    );
    notifyListeners();
  }
}
