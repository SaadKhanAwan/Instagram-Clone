import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/models/addpost_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/view/screens/auth/signin_screen.dart';
import 'package:instagram_clone/view/widget/edit_profile.dart';
import 'package:instagram_clone/viewmodel/services/firebase_services.dart';

class ProfileController extends BaseViewModel {
  final FirebaseServices _firebaseServices = FirebaseServices();

  UserData? userData;
  List<Post>? userPosts;
  int followerCount = 0;

  ProfileController({userID}) {
    _init(userID: userID);
  }

  _init({userID}) {
    fetchUserDataAndPosts(userId: userID);
  }

  Future<void> fetchUserDataAndPosts({userId}) async {
    setstate(ViewState.loading);
    try {
      // Fetch user data
      userData = await _firebaseServices.fetchUserData(userId);

      // Fetch user posts
      userPosts = await _firebaseServices.fetchUserPosts(userId);

      followerCount = userData?.followers.length ?? 0;
      setstate(ViewState.succuss);
      notifyListeners();
    } catch (e) {
      setstate(ViewState.fail);
      log("error in catch: $e");
    }
  }

  Future followUnfollow({isFollowing, userId}) async {
    // setstate(ViewState.loading);
    try {
      if (isFollowing) {
        await _firebaseServices.unfollowUser(userId);
        followerCount--;
        setstate(ViewState.succuss);
        notifyListeners();
      } else {
        await _firebaseServices.followUser(userId);

        followerCount++;
        setstate(ViewState.succuss);
        notifyListeners();
      }
    } catch (e) {
      setstate(ViewState.loading);
      log("error in catch: $e");
    }
  }

  Future signOut({required context}) async {
    try {
      await _firebaseServices.signOut().then((value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const SignInScreen()));
      });
    } catch (e) {
      log(("error in catch: $e"));
    }
  }

  Stream<bool> checkIsLogin({required targetUserId}) {
    try {
      return _firebaseServices.isFollowingUserStream(targetUserId);
    } catch (e) {
      log("error in catch: $e");
      return const Stream.empty();
    }
  }

  Future editprofie({required context}) async {
    try {
      final updatedUserData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditProfile(
            currentImage: userData?.image ?? '',
            currentName: userData?.name ?? 'Static Username',
            currentBio: userData?.bio ?? 'This is a static bio',
          ),
        ),
      );
      if (updatedUserData != null) {
        userData?.image = updatedUserData['image'];
        userData?.name = updatedUserData['name'];
        userData?.bio = updatedUserData['bio'];
        notifyListeners();
      }
    } catch (e) {
      log("error in catch: $e");
    }
  }
}
