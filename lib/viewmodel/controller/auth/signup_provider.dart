import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/utils/dilogues.dart';
import 'package:instagram_clone/viewmodel/services/firebase_services.dart';

class SignUpProvider extends BaseViewModel {
  final FirebaseServices _services = FirebaseServices();
  String email = "";
  String username = "";
  String password = "";
  File? image;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void emailOnchange(value) {
    email = value;
    notifyListeners();
  }

  void passwordOnchange(value) {
    password = value;
    notifyListeners();
  }

  void userNameOnchange(value) {
    username = value;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future signUp(context) async {
    setstate(ViewState.loading);
    try {
      if (image != null) {
        final userCredential = await _services.signUp(
            email: email, password: password, name: username, image: image!);
        if (userCredential == null) {
          Dilogues.showSnackbar(context, message: "Failed.Try Again");
        } else {
          resetFields();
          passwordOnchange("");
          notifyListeners();
          Dilogues.showSnackbar(context,
              message: "Account created Sucussfully");
        }
        setstate(ViewState.succuss);
      } else {
        Dilogues.showSnackbar(context, message: "Please Select a Image first");
        setstate(ViewState.succuss);
      }
    } catch (e) {
      log("error in catch$e");
      Dilogues.showSnackbar(context, message: "$e");
      setstate(ViewState.fail);
    }
  }

  void resetFields() {
    email = "";
    username = "";
    password = "";
    image = null;
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
