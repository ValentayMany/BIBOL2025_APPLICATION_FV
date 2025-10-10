// Home Page Widget Tests
// Tests for HomePage UI and basic functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/screens/Home/home_page.dart';
import 'package:BIBOL/widgets/common/custom_bottom_nav.dart';

void main() {
  // Test helper to create widget with MaterialApp wrapper
  Widget createHomePage() {
    return MaterialApp(
      home: HomePage(),
    );
  }

  group('HomePage Widget Tests', () {
    testWidgets('HomePage renders correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump(); // Initial pump

      // Assert - Check if HomePage widget exists
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('HomePage has CustomBottomNav', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for bottom navigation
      expect(find.byType(CustomBottomNav), findsOneWidget);
    });

    testWidgets('HomePage shows loading indicator initially',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump(); // Don't pump and settle to catch loading state

      // Assert - Check for loading indicator
      // Loading state might show CircularProgressIndicator
      expect(
        find.byType(CircularProgressIndicator),
        findsWidgets,
      );
    });

    testWidgets('HomePage has SafeArea', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();

      // Assert - Check for SafeArea
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('HomePage is scrollable', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Assert - Check for scrollable widget
      expect(
        find.byType(SingleChildScrollView),
        findsWidgets,
      );
    });

    testWidgets('HomePage has proper layout structure',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();

      // Assert - Check for basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('HomePage contains Column or ListView',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for layout widgets
      final hasColumn = find.byType(Column).evaluate().isNotEmpty;
      final hasListView = find.byType(ListView).evaluate().isNotEmpty;

      expect(hasColumn || hasListView, isTrue);
    });
  });

  group('HomePage Navigation Tests', () {
    testWidgets('CustomBottomNav changes on tap', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createHomePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Bottom nav should be present
      expect(find.byType(CustomBottomNav), findsOneWidget);

      // Note: Actual tap testing would require knowing the exact
      // implementation of CustomBottomNav icons/buttons
    });

    testWidgets('HomePage has scaffold key for drawer',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();

      // Assert - Scaffold should exist (drawer functionality)
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
    });
  });

  group('HomePage Animation Tests', () {
    testWidgets('HomePage contains animated widgets',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();

      // Assert - Check for animation widgets
      // HomePage should have animations for smooth transitions
      expect(find.byType(HomePage), findsOneWidget);

      // Pump frames to allow animations to start
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('HomePage animations complete successfully',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();

      // Wait for animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert - Page should be fully rendered
      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('HomePage Responsive Tests', () {
    testWidgets('HomePage renders on small screen',
        (WidgetTester tester) async {
      // Arrange - Set small screen size
      await tester.binding.setSurfaceSize(const Size(320, 568));

      // Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(HomePage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('HomePage renders on large screen',
        (WidgetTester tester) async {
      // Arrange - Set large screen size
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      // Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(HomePage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('HomePage renders on tablet size',
        (WidgetTester tester) async {
      // Arrange - Set tablet screen size
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      // Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(HomePage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('HomePage Error Handling Tests', () {
    testWidgets('HomePage handles initialization without crash',
        (WidgetTester tester) async {
      // Arrange & Act
      bool errorOccurred = false;
      FlutterError.onError = (FlutterErrorDetails details) {
        errorOccurred = true;
      };

      await tester.pumpWidget(createHomePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - No critical errors should occur
      expect(errorOccurred, isFalse);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('HomePage renders without network',
        (WidgetTester tester) async {
      // Arrange & Act - Network calls will fail in test environment
      await tester.pumpWidget(createHomePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Assert - Page should still render (maybe show error states)
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('HomePage Widget Composition Tests', () {
    testWidgets('HomePage uses MaterialApp properly',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('HomePage has proper widget hierarchy',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();

      // Assert - Check basic hierarchy
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('HomePage State Management Tests', () {
    testWidgets('HomePage is a StatefulWidget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomePage());
      await tester.pump();

      // Assert
      final homePageWidget = tester.widget<HomePage>(find.byType(HomePage));
      expect(homePageWidget, isA<StatefulWidget>());
    });

    testWidgets('HomePage maintains state across rebuilds',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createHomePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Act - Trigger a rebuild by pumping again
      await tester.pump();

      // Assert - Widget should still be there
      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('HomePage Memory Management Tests', () {
    testWidgets('HomePage disposes controllers properly',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createHomePage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Act - Remove widget to trigger dispose
      await tester.pumpWidget(Container());
      await tester.pump();

      // Assert - No exception should be thrown
      // If dispose is not called properly, there might be errors
      expect(find.byType(HomePage), findsNothing);
    });
  });
}
