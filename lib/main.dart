// lib/main.dart

import 'package:BIBOL/routes/app_navigator.dart';
import 'package:BIBOL/routes/app_routes.dart';
import 'package:BIBOL/routes/route_generator.dart';
import 'package:BIBOL/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  AppTheme.setSystemUIOverlayStyle();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking Institute App',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,

      // Navigation
      navigatorKey: AppNavigator.navigatorKey,
      initialRoute: AppRoutes.splash,

      // Routes
      routes: RouteGenerator.getRoutes(),
      onGenerateRoute: RouteGenerator.generateRoute,
      onUnknownRoute: RouteGenerator.onUnknownRoute,
    );
  }
}
