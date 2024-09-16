import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/utils/dilogues.dart';
import 'package:instagram_clone/viewmodel/services/firebase_services.dart';

class AddpostController extends BaseViewModel {
  final FirebaseServices _services = FirebaseServices();
  File? image;
  String? caption;
  bool isposting = false;
  final TextEditingController captionController = TextEditingController();

  captionvalue(value) {
    caption = value;
    notifyListeners();
  }

  imagenull() {
    image = null;
    notifyListeners();
  }

// add is posting and check
  Future addpost(context) async {
    isposting = true;
    setstate(ViewState.loading);
    try {
      final response = await _services.uploadPost(
          content: caption.toString(), imageUrl: image!);
      if (response != null) {
        Dilogues.showSnackbar(context, message: "Post uploaded Sucussfully");
        image = null;
        caption = "";
        captionController.clear();
        isposting = false;
        notifyListeners();
      } else {
        Dilogues.showSnackbar(context, message: "Post not uploaded");
        isposting = false;
        notifyListeners();
      }
    } catch (e) {
      isposting = false;
      notifyListeners();
      Dilogues.showSnackbar(context, message: "$e");
      log("error:$e ");
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }
}
