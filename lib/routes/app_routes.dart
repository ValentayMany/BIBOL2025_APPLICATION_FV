// lib/config/routes/app_routes.dart

class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route constants
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String news = '/news';
  static const String gallery = '/gallery';
  static const String about = '/about';
  static const String profile = '/profile';
  static const String courseDetail = '/course-detail';
  static const String newsDetail = '/news/detail';

  // List of all routes
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
    newsDetail,
  ];
}
