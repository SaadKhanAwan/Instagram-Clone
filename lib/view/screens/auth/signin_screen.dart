import 'package:flutter/material.dart';
import 'package:instagram_clone/responsiveness/sizes.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/view/screens/auth/signup_screen.dart';
import 'package:instagram_clone/view/widget/textfield.dart';
import 'package:instagram_clone/viewmodel/controller/auth/signin_provider.dart';

import 'package:provider/provider.dart';

import '../../../data/helper/baseviewmodel/baseviewmodel.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SigninProvider(),
      child: Scaffold(body: Consumer<SigninProvider>(
        builder: (context, provider, child) {
          return Form(
            key: provider.formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text(
                      "Instagram",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Italic",
                          fontSize: 30,
                          fontWeight: FontWeight.w700),
                    ),
                    ResponsiveSizes.verticalSizebox(context, .04),
                    MyTextField(
                        hintText: "Enter Email",
                        onChanged: (value) {
                          provider.emailOnchange(value);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Email";
                          } else if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        }),
                    ResponsiveSizes.verticalSizebox(context, .04),
                    MyTextField(
                        onChanged: (value) {
                          provider.passwordOnchange(value);
                        },
                        hintText: "Enter Password",
                        prefixicon: Icons.lock,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Password";
                          }
                          return null;
                        }),
                    ResponsiveSizes.verticalSizebox(context, .04),
                    InkWell(
                      onTap: () async {
                        if (provider.formKey.currentState!.validate()) {
                          await provider.signIn(context);
                        }
                      },
                      child: provider.state == ViewState.loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              height: ResponsiveSizes.height(context, .08),
                              width: ResponsiveSizes.width(context, .92),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: blueColor),
                              child: const Text(
                                "Log In",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w700),
                              ),
                            ),
                    ),
                    ResponsiveSizes.verticalSizebox(context, .1),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpScreen()));
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Don\'t have an account? ',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'SignUp',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      )),
    );
  }
}
