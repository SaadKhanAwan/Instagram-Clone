
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/routes/route_name.dart';
import 'package:instagram_clone/view/screens/auth/signin_screen.dart';
import 'package:instagram_clone/view/screens/auth/signup_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.signUp:
       return MaterialPageRoute(builder: (_) => const SignUpScreen());
       case RouteNames.logIn:
       return MaterialPageRoute(builder: (_) => const SignInScreen());
      
      // case RouteNames.signIn:
      //   return MaterialPageRoute(builder: (_) => const MentessDetails());
      default:
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        });
    }
  }
}
