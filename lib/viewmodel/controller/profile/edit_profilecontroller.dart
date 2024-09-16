import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/viewmodel/services/firebase_services.dart';

class EditProfilecontroller extends BaseViewModel {
  final FirebaseServices _services = FirebaseServices();
  String? image;
  final globalkey = GlobalKey<FormState>();
  late String username;
  late String bio;
  late String profileImageUrl;

  EditProfilecontroller({currentName, currentBio, currentImage}) {
    _init(
        currentName: currentName,
        currentBio: currentBio,
        currentImage: currentImage);
  }

  void _init({currentName, currentBio, currentImage}) {
    username = currentName;
    bio = currentBio;
    profileImageUrl = currentImage;
    image = null;
  }

  Future updateProfile({context}) async {
    setstate(ViewState.loading);
    try {
      if (globalkey.currentState!.validate()) {
        globalkey.currentState!.save();
        String? imageUrl = profileImageUrl;

        // If a new image is selected, upload it to Firebase Storage
        if (image != null) {
          File imageFile = File(image!);
          imageUrl =
              await _services.uploadImage(imageFile, chidlName: 'user_images');
        }
        await _services.updateProfile(
            imageUrl: imageUrl ?? profileImageUrl,
            userbio: bio,
            username: username);
        setstate(ViewState.succuss);
        notifyListeners();
        Navigator.pop(context, {
          'image': imageUrl,
          'name': username,
          'bio': bio,
        });
      }
    } catch (e) {
      setstate(ViewState.fail);
      log("error in  catch: $e");
    }
  }

  Future pickImage({required context, required ImageSource source}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? images = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (images != null) {
        image = images.path;
        notifyListeners();
        Navigator.pop(context);
      }
    } catch (e) {
      log("error in  catch: $e");
    }
  }
}
