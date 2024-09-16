import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/responsiveness/mobilelayout.dart';
import 'package:instagram_clone/responsiveness/weblayout.dart';
import 'package:instagram_clone/utils/dilogues.dart';
import 'package:instagram_clone/viewmodel/services/firebase_services.dart';

import '../../../responsiveness/responsiveness_layout.dart';

class SigninProvider extends BaseViewModel {
  String email = "";
  String password = "";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseServices _services = FirebaseServices();

  void emailOnchange(value) {
    email = value;
  }

  void passwordOnchange(value) {
    password = value;
  }

  Future signIn(context) async {
    setstate(ViewState.loading);

    try {
      final userCredential =
          await _services.signIn(email: email, password: password);
      if (userCredential == null) {
        Dilogues.showSnackbar(context, message: "Failed.Try Again");
      } else {
        Dilogues.showSnackbar(context, message: "SignIn Sucussfully");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const ResponsiveLayout(
                      mobileScreenLayout: MobileLayout(),
                      webScreenLayout: WebLayout(),
                    )));
      }
      setstate(ViewState.succuss);
    } catch (e) {
      log("error in catch$e");
      Dilogues.showSnackbar(context, message: "$e");
      setstate(ViewState.fail);
    }
  }
}
