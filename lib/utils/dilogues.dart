import 'package:flutter/material.dart';

class Dilogues {
  static void showSnackbar(BuildContext context, {required String message}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.blue,
    );

    // Show the SnackBar using ScaffoldMessenger
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}