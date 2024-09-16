import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/responsiveness/mobilelayout.dart';
import 'package:instagram_clone/responsiveness/responsiveness_layout.dart';
import 'package:instagram_clone/responsiveness/weblayout.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/view/screens/auth/signin_screen.dart';
import 'package:instagram_clone/viewmodel/services/notification_servies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialise app based on platform- web or mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyB7ifvyOhr2gIxFGGisgP-gKMqxGFnjDHs",
          appId: "1:429296505153:web:94da3fb181cd296046d1c0",
          messagingSenderId: "429296505153",
          projectId: "instagram-clone-4b8fb",
          storageBucket: "instagram-clone-4b8fb.appspot.com"),
    );
  } else {
    await Firebase.initializeApp();
  }
  FirebaseNotification().initializeLocalNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram Clone',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
      ),
      // home:const  ResponsiveLayout(mobileScreenLayout: MobileLayout(),webScreenLayout: WebLayout(),)
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // Checking if the snapshot has any data or not
            if (snapshot.hasData) {
              // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
              return const ResponsiveLayout(
                mobileScreenLayout: MobileLayout(),
                webScreenLayout: WebLayout(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            }
          }
          // means connection to future hasnt been made yet
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return const SignInScreen();
        },
      ),
    );
  }
}
