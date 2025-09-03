import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:auth_flutter_api/screens/home_page.dart';
import 'package:auth_flutter_api/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: 'assets/images/LOGO.png',
      nextScreen: LoginPage(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      backgroundColor: Color(0xFF07325D),
    );
  }
}
