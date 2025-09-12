import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auth_flutter_api/screens/about_page.dart';
import 'package:auth_flutter_api/screens/gallery_page.dart';
import 'package:auth_flutter_api/screens/home_page.dart';
import 'package:auth_flutter_api/pages/login_page.dart';
import 'package:auth_flutter_api/screens/news_pages.dart';
import 'package:auth_flutter_api/screens/profile_page.dart';
import 'package:auth_flutter_api/pages/register_page.dart';
import 'package:auth_flutter_api/widgets/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking Institute App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF07325D),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      initialRoute: "/splash",
      debugShowCheckedModeBanner: false,

      // Define all routes
      routes: {
        "/splash": (context) => const SplashScreen(),
        "/login": (context) => LoginPage(),
        "/register": (context) => RegisterPage(),
        "/home": (context) => HomePage(),
        "/news": (context) => NewsPage(),
        "/gallery": (context) => GalleryPage(),
        "/about": (context) => AboutPage(),
        "/profile": (context) => ProfilePage(),
      },

      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const UnknownRoutePage(),
        );
      },

      // Handle route generation for dynamic routes
      onGenerateRoute: (settings) {
        print('🚀 Navigating to: ${settings.name}');

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => HomePage());
          case '/splash':
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (context) => RegisterPage());
          case '/home':
            return MaterialPageRoute(builder: (context) => HomePage());
          case '/news':
            return MaterialPageRoute(builder: (context) => NewsPage());
          case '/gallery':
            return MaterialPageRoute(builder: (context) => GalleryPage());
          case '/about':
            return MaterialPageRoute(builder: (context) => AboutPage());
          case '/profile':
            return MaterialPageRoute(builder: (context) => ProfilePage());
          default:
            return null;
        }
      },
    );
  }
}

// Error page for unknown routes
class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: const Color(0xFF07325D),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/splash',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07325D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Go to Home',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Navigation Helper Class
class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> navigateTo(String routeName) async {
    try {
      await navigatorKey.currentState?.pushNamed(routeName);
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }

  static Future<void> navigateAndReplace(String routeName) async {
    try {
      await navigatorKey.currentState?.pushReplacementNamed(routeName);
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }

  static Future<void> navigateAndRemoveAll(String routeName) async {
    try {
      await navigatorKey.currentState?.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
      );
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }

  static void goBack() {
    try {
      navigatorKey.currentState?.pop();
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }
}

// Route Constants
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String news = '/news';
  static const String gallery = '/gallery';
  static const String about = '/about';
  static const String profile = '/profile';

  static List<String> get allRoutes => [
    splash,
    login,
    register,
    home,
    news,
    gallery,
    about,
    profile,
  ];
}
