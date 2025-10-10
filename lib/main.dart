// lib/main.dart

import 'package:BIBOL/config/environment.dart';
import 'package:BIBOL/providers/theme_provider.dart';
import 'package:BIBOL/routes/app_navigator.dart';
import 'package:BIBOL/routes/app_routes.dart';
import 'package:BIBOL/routes/route_generator.dart';
import 'package:BIBOL/services/cache/cache_service.dart';
import 'package:BIBOL/theme/app_theme.dart';
import 'package:BIBOL/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Print environment configuration
  EnvironmentConfig.printConfig();

  // Initialize cache service
  try {
    await CacheService.initialize();
    AppLogger.success('App initialization completed', tag: 'MAIN');
  } catch (e) {
    AppLogger.error('Failed to initialize app', tag: 'MAIN', error: e);
  }

  // Set system UI overlay style
  AppTheme.setSystemUIOverlayStyle();

  runApp(
    // 🌙 Wrap app with ThemeProvider for dark mode support
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🌙 Watch theme changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Banking Institute App',
          
          // 🌙 Use theme and darkTheme from ThemeProvider
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          
          debugShowCheckedModeBanner: false,

          // Navigation
          navigatorKey: AppNavigator.navigatorKey,
          initialRoute: AppRoutes.splash,

          // Routes
          routes: RouteGenerator.getRoutes(),
          onGenerateRoute: RouteGenerator.generateRoute,
          onUnknownRoute: RouteGenerator.onUnknownRoute,
        );
      },
    );
  }
}
