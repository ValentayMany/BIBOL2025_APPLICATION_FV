import 'package:BIBOL/screens/News/news_detail_in_home.dart';
import 'package:BIBOL/test/simple_connection_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BIBOL/screens/About/about_page.dart';
import 'package:BIBOL/screens/Gallery/gallery_page.dart';
import 'package:BIBOL/screens/Home/home_page.dart';
import 'package:BIBOL/screens/R&L/login_page.dart';
import 'package:BIBOL/screens/News/news_pages.dart';
import 'package:BIBOL/screens/Profile/profile_page.dart';
import 'package:BIBOL/screens/R&L/register_page.dart';
import 'package:BIBOL/models/course/course_model.dart';
import 'package:BIBOL/widgets/splash_screen.dart';

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
        "/news": (context) => NewsListPage(),
        "/gallery": (context) => GalleryPage(),
        "/about": (context) => AboutPage(),
        "/profile": (context) => ProfilePage(),
        // เพิ่ม route สำหรับ course detail
        "/course-detail": (context) {
          final CourseModel course =
              ModalRoute.of(context)!.settings.arguments as CourseModel;
          return CourseDetailPage(course: course);
        },
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
            return MaterialPageRoute(builder: (context) => NewsListPage());
          case '/gallery':
            return MaterialPageRoute(builder: (context) => GalleryPage());
          case '/about':
            return MaterialPageRoute(builder: (context) => AboutPage());
          case '/profile':
            return MaterialPageRoute(builder: (context) => ProfilePage());

          // เพิ่ม case สำหรับ course detail
          case '/course-detail':
            if (settings.arguments is CourseModel) {
              final CourseModel course = settings.arguments as CourseModel;
              return MaterialPageRoute(
                builder: (context) => CourseDetailPage(course: course),
              );
            }
            // ถ้าไม่มี arguments หรือ arguments ไม่ถูกต้อง
            return MaterialPageRoute(
              builder: (context) => const UnknownRoutePage(),
            );

          // เพิ่ม case สำหรับ news detail
          case '/news/detail':
            if (settings.arguments is String) {
              final String newsId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => NewsDetailPage(newsId: newsId),
              );
            }
            return MaterialPageRoute(
              builder: (context) => const UnknownRoutePage(),
            );

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

  static Future<void> navigateTo(String routeName, {Object? arguments}) async {
    try {
      await navigatorKey.currentState?.pushNamed(
        routeName,
        arguments: arguments,
      );
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }

  static Future<void> navigateAndReplace(
    String routeName, {
    Object? arguments,
  }) async {
    try {
      await navigatorKey.currentState?.pushReplacementNamed(
        routeName,
        arguments: arguments,
      );
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

  // เพิ่ม method สำหรับ navigate ไป course detail
  static Future<void> navigateToCourseDetail(CourseModel course) async {
    try {
      await navigatorKey.currentState?.pushNamed(
        AppRoutes.courseDetail,
        arguments: course,
      );
    } catch (e) {
      print('❌ Navigation Error: $e');
    }
  }

  // เพิ่ม method สำหรับ navigate ไป news detail
  static Future<void> navigateToNewsDetail(String newsId) async {
    try {
      await navigatorKey.currentState?.pushNamed(
        AppRoutes.newsDetail,
        arguments: newsId,
      );
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
  static const String courseDetail = '/course-detail';
  static const String newsDetail = '/news/detail'; // เพิ่ม route constant

  static List<String> get allRoutes => [
    splash,
    login,
    register,
    home,
    news,
    gallery,
    about,
    profile,
    courseDetail,
    newsDetail, // เพิ่มในลิสต์
  ];
}
