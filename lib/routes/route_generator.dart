// lib/config/routes/route_generator.dart

// ignore_for_file: avoid_print

import 'package:BIBOL/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:BIBOL/models/course/course_model.dart';
import 'package:BIBOL/screens/about/about_page.dart';
import 'package:BIBOL/screens/auth/login_page.dart';
import 'package:BIBOL/screens/auth/register_page.dart';
import 'package:BIBOL/error/unknown_route_page.dart';
import 'package:BIBOL/screens/gallery/gallery_page.dart';
import 'package:BIBOL/screens/home/course_detail_page.dart';
import 'package:BIBOL/screens/home/home_page.dart';
import 'package:BIBOL/screens/home/news_detail_in_home.dart';
import 'package:BIBOL/screens/news/news_pages.dart';
import 'package:BIBOL/screens/profile/profile_page.dart';
import 'package:BIBOL/widgets/common/splash_screen.dart';

class RouteGenerator {
  // Private constructor
  RouteGenerator._();

  /// Generate routes based on settings
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    print('🚀 Navigating to: ${settings.name}');

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => HomePage());

      case AppRoutes.splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (context) => LoginPage());

      // case AppRoutes.register:
      //   return MaterialPageRoute(builder: (context) => RegisterPage());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (context) => HomePage());

      case AppRoutes.news:
        return MaterialPageRoute(builder: (context) => NewsListPage());

      case AppRoutes.gallery:
        return MaterialPageRoute(builder: (context) => GalleryPage());

      case AppRoutes.about:
        return MaterialPageRoute(builder: (context) => AboutPage());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (context) => ProfilePage());

      case AppRoutes.courseDetail:
        if (settings.arguments is CourseModel) {
          final CourseModel course = settings.arguments as CourseModel;
          return MaterialPageRoute(
            builder: (context) => CourseDetailPage(course: course),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const UnknownRoutePage(),
        );

      case AppRoutes.newsDetail:
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
  }

  /// Get static routes map
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppRoutes.splash: (context) => const SplashScreen(),
      AppRoutes.login: (context) => LoginPage(),
      // AppRoutes.register: (context) => RegisterPage(),
      AppRoutes.home: (context) => HomePage(),
      AppRoutes.news: (context) => NewsListPage(),
      AppRoutes.gallery: (context) => GalleryPage(),
      AppRoutes.about: (context) => AboutPage(),
      AppRoutes.profile: (context) => ProfilePage(),
      AppRoutes.courseDetail: (context) {
        final CourseModel course =
            ModalRoute.of(context)!.settings.arguments as CourseModel;
        return CourseDetailPage(course: course);
      },
    };
  }

  /// Handle unknown routes
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const UnknownRoutePage());
  }
}
