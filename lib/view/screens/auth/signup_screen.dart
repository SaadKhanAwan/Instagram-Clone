import 'package:flutter/material.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/responsiveness/sizes.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/view/screens/auth/signin_screen.dart';
import 'package:instagram_clone/view/widget/textfield.dart';
import 'package:instagram_clone/viewmodel/controller/auth/signup_provider.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpProvider(),
      child: Scaffold(body: Consumer<SignUpProvider>(
        builder: (context, provider, child) {
          return Form(
            key: provider.formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: provider.image != null
                                ? Image.file(
                                    provider.image!,
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 120,
                                    width: 120,
                                    color: Colors.white,
                                  ),
                          ),
                          Positioned(
                            bottom: -8,
                            right: 4,
                            child: InkWell(
                              onTap: () {
                                provider.pickImage();
                              },
                              child: const Icon(
                                Icons.add,
                                color: Colors.blue,
                                size: 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ResponsiveSizes.verticalSizebox(context, .04),
                    MyTextField(
                      controller: provider.nameController,
                      hintText: "Enter Username",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Username";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        provider.userNameOnchange(value);
                      },
                    ),
                    ResponsiveSizes.verticalSizebox(context, .04),
                    MyTextField(
                      controller: provider.emailController,
                      hintText: "Enter Email",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Email";
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        provider.emailOnchange(value);
                      },
                    ),
                    ResponsiveSizes.verticalSizebox(context, .04),
                    MyTextField(
                      controller: provider.passwordController,
                      hintText: "Enter Password",
                      prefixicon: Icons.lock,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Password";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        provider.passwordOnchange(value);
                      },
                    ),
                    ResponsiveSizes.verticalSizebox(context, .04),
                    InkWell(
                      onTap: () async {
                        if (provider.formKey.currentState!.validate()) {
                          await provider.signUp(context);
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
                                  color: provider.image == null
                                      ? Colors.grey
                                      : blueColor),
                              child: const Text(
                                "Sign Up",
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
                                builder: (_) => const SignInScreen()));
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'SignIn',
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
