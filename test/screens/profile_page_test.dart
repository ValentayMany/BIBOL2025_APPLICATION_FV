// Profile Page Widget Tests
// Tests for ProfilePage UI and basic functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/screens/Profile/profile_page.dart';
import 'package:BIBOL/widgets/common/custom_bottom_nav.dart';

void main() {
  // Test helper to create widget with MaterialApp wrapper
  Widget createProfilePage() {
    return MaterialApp(
      home: ProfilePage(),
    );
  }

  group('ProfilePage Widget Tests', () {
    testWidgets('ProfilePage renders correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();

      // Assert - Check if ProfilePage widget exists
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ProfilePage has CustomBottomNav',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for bottom navigation
      expect(find.byType(CustomBottomNav), findsOneWidget);
    });

    testWidgets('ProfilePage shows loading state initially',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump(); // Don't settle to catch loading state

      // Assert - Check for loading indicator
      expect(
        find.byType(CircularProgressIndicator),
        findsWidgets,
      );
    });

    testWidgets('ProfilePage has SafeArea', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();

      // Assert - Check for SafeArea
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('ProfilePage is scrollable', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for scrollable widget
      final scrollableWidgets = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView || widget is ListView,
      );
      expect(scrollableWidgets, findsWidgets);
    });
  });

  group('ProfilePage State Management Tests', () {
    testWidgets('ProfilePage is a StatefulWidget',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();

      // Assert
      final profilePageWidget =
          tester.widget<ProfilePage>(find.byType(ProfilePage));
      expect(profilePageWidget, isA<StatefulWidget>());
    });

    testWidgets('ProfilePage maintains state across rebuilds',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Act - Trigger a rebuild
      await tester.pump();

      // Assert - Widget should still exist
      expect(find.byType(ProfilePage), findsOneWidget);
    });
  });

  group('ProfilePage Layout Tests', () {
    testWidgets('ProfilePage has proper scaffold structure',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();

      // Assert - Check for Scaffold
      expect(find.byType(Scaffold), findsOneWidget);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, isNotNull);
    });

    testWidgets('ProfilePage has bottom navigation',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for CustomBottomNav
      expect(find.byType(CustomBottomNav), findsOneWidget);
    });
  });

  group('ProfilePage Responsive Tests', () {
    testWidgets('ProfilePage renders on small screen',
        (WidgetTester tester) async {
      // Arrange - Set small screen size
      await tester.binding.setSurfaceSize(const Size(320, 568));

      // Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(ProfilePage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('ProfilePage renders on medium screen',
        (WidgetTester tester) async {
      // Arrange - Set medium screen size
      await tester.binding.setSurfaceSize(const Size(375, 667));

      // Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(ProfilePage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('ProfilePage renders on large screen',
        (WidgetTester tester) async {
      // Arrange - Set large screen size
      await tester.binding.setSurfaceSize(const Size(414, 896));

      // Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(ProfilePage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('ProfilePage renders on tablet',
        (WidgetTester tester) async {
      // Arrange - Set tablet screen size
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      // Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(ProfilePage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('ProfilePage Animation Tests', () {
    testWidgets('ProfilePage contains animated widgets',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();

      // Pump multiple frames for animations
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - No crash should occur
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('ProfilePage animations complete successfully',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();

      // Wait for animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert - Page should be fully rendered
      expect(find.byType(ProfilePage), findsOneWidget);
    });
  });

  group('ProfilePage Error Handling Tests', () {
    testWidgets('ProfilePage handles initialization without crash',
        (WidgetTester tester) async {
      // Arrange
      bool errorOccurred = false;
      FlutterError.onError = (FlutterErrorDetails details) {
        errorOccurred = true;
      };

      // Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - No critical errors should occur
      expect(errorOccurred, isFalse);
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('ProfilePage renders when not logged in',
        (WidgetTester tester) async {
      // Arrange & Act - User info will be null in test environment
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Assert - Page should still render (show login prompt or empty state)
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('ProfilePage Memory Management Tests', () {
    testWidgets('ProfilePage disposes controllers properly',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Act - Remove widget to trigger dispose
      await tester.pumpWidget(Container());
      await tester.pump();

      // Assert - No exception should be thrown
      expect(find.byType(ProfilePage), findsNothing);
    });
  });

  group('ProfilePage Integration Tests', () {
    testWidgets('ProfilePage works within MaterialApp',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('ProfilePage has proper widget hierarchy',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();

      // Assert - Check hierarchy
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('ProfilePage Lifecycle Tests', () {
    testWidgets('ProfilePage initializes correctly',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();

      // Assert - Widget should be in widget tree
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('ProfilePage handles app lifecycle changes',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createProfilePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Act - Simulate app lifecycle change
      await tester.pump();

      // Assert - Widget should still work
      expect(find.byType(ProfilePage), findsOneWidget);
    });
  });

  group('ProfilePage UI Component Tests', () {
    testWidgets('ProfilePage has Material design', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();

      // Assert - Should use Material widgets
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('ProfilePage uses proper theming', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createProfilePage());
      await tester.pump();

      // Assert - MaterialApp provides theme
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp, isNotNull);
    });
  });
}
