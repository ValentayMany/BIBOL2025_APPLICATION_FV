import 'package:auth_flutter_api/screens/about_page.dart';
import 'package:auth_flutter_api/screens/gallery_page.dart';
import 'package:auth_flutter_api/screens/home_page.dart';
import 'package:auth_flutter_api/screens/login_page.dart';
import 'package:auth_flutter_api/screens/news.dart';
import 'package:auth_flutter_api/screens/profile_page.dart';
import 'package:auth_flutter_api/screens/register_page.dart';
import 'package:auth_flutter_api/widgets/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Demo',
      initialRoute: "/splash",
      debugShowCheckedModeBanner: false,
      routes: {
        "/splash": (context) => SplashScreen(),
        "/login": (context) => LoginPage(),
        "/register": (context) => RegisterPage(),
        "/home": (context) => HomePage(),
        '/': (context) => HomePage(),
        '/news': (context) => NewsPage(),
        '/gallery': (context) => GalleryPage(),
        '/about': (context) => AboutPage(),
        '/profile': (context) => ProfilePage(),
        // '/login': (context) => LoginPage(), // if you have login
      },
    );
  }
}
