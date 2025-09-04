import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:auth_flutter_api/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: FittedBox(
        fit:
            BoxFit
                .contain, // Ensure the content fits within the available space
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/LOGO.png', height: 150),
            SizedBox(height: 20), // Add some spacing
            Text(
              'ສະຖາບັນການທະນາຄານ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      nextScreen: HomePage(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      backgroundColor: Color(0xFF07325D),
    );
  }
}