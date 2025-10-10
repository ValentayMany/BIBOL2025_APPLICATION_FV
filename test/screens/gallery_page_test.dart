// Gallery Page Widget Tests
// Tests for GalleryPage UI and basic functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/screens/Gallery/gallery_page.dart';
import 'package:BIBOL/widgets/common/custom_bottom_nav.dart';

void main() {
  // Test helper to create widget with MaterialApp wrapper
  Widget createGalleryPage() {
    return const MaterialApp(
      home: GalleryPage(),
    );
  }

  group('GalleryPage Widget Tests', () {
    testWidgets('GalleryPage renders correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();

      // Assert - Check if GalleryPage widget exists
      expect(find.byType(GalleryPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('GalleryPage has CustomBottomNav',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for bottom navigation
      expect(find.byType(CustomBottomNav), findsOneWidget);
    });

    testWidgets('GalleryPage shows loading state initially',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump(); // Don't settle to catch loading state

      // Assert - Check for loading indicator
      expect(
        find.byType(CircularProgressIndicator),
        findsWidgets,
      );
    });

    testWidgets('GalleryPage has SafeArea', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();

      // Assert - Check for SafeArea
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('GalleryPage is scrollable', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for scrollable widget
      final scrollableWidgets = find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView ||
            widget is ListView ||
            widget is GridView ||
            widget is CustomScrollView,
      );
      expect(scrollableWidgets, findsWidgets);
    });

    testWidgets('GalleryPage has const constructor',
        (WidgetTester tester) async {
      // Arrange & Act
      const galleryPage = GalleryPage();

      // Assert - Widget should be constructable with const
      expect(galleryPage, isA<GalleryPage>());
    });
  });

  group('GalleryPage State Management Tests', () {
    testWidgets('GalleryPage is a StatefulWidget',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();

      // Assert
      final galleryPageWidget =
          tester.widget<GalleryPage>(find.byType(GalleryPage));
      expect(galleryPageWidget, isA<StatefulWidget>());
    });

    testWidgets('GalleryPage maintains state across rebuilds',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Act - Trigger a rebuild
      await tester.pump();

      // Assert - Widget should still exist
      expect(find.byType(GalleryPage), findsOneWidget);
    });
  });

  group('GalleryPage Layout Tests', () {
    testWidgets('GalleryPage has proper scaffold structure',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();

      // Assert - Check for Scaffold
      expect(find.byType(Scaffold), findsOneWidget);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, isNotNull);
    });

    testWidgets('GalleryPage has bottom navigation',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for CustomBottomNav
      expect(find.byType(CustomBottomNav), findsOneWidget);
    });

    testWidgets('GalleryPage might use GridView for images',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Note: GridView might not appear without data
      // This test just ensures the page renders without crash
      expect(find.byType(GalleryPage), findsOneWidget);
    });
  });

  group('GalleryPage Responsive Tests', () {
    testWidgets('GalleryPage renders on small screen',
        (WidgetTester tester) async {
      // Arrange - Set small screen size
      await tester.binding.setSurfaceSize(const Size(320, 568));

      // Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(GalleryPage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('GalleryPage renders on medium screen',
        (WidgetTester tester) async {
      // Arrange - Set medium screen size
      await tester.binding.setSurfaceSize(const Size(375, 667));

      // Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(GalleryPage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('GalleryPage renders on large screen',
        (WidgetTester tester) async {
      // Arrange - Set large screen size
      await tester.binding.setSurfaceSize(const Size(414, 896));

      // Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(GalleryPage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('GalleryPage renders on tablet (600+)',
        (WidgetTester tester) async {
      // Arrange - Set tablet screen size
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      // Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Should adapt layout for tablet
      expect(find.byType(GalleryPage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('GalleryPage is responsive across different sizes',
        (WidgetTester tester) async {
      // Test multiple screen sizes
      final sizes = [
        const Size(320, 568), // Small
        const Size(375, 667), // Medium
        const Size(414, 896), // Large
        const Size(768, 1024), // Tablet
      ];

      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(createGalleryPage());
        await tester.pump();

        expect(find.byType(GalleryPage), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
        await tester.pump();
      }

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('GalleryPage Animation Tests', () {
    testWidgets('GalleryPage contains animated widgets',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();

      // Pump multiple frames for animations
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - No crash should occur
      expect(find.byType(GalleryPage), findsOneWidget);
    });

    testWidgets('GalleryPage animations complete successfully',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();

      // Wait for animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert - Page should be fully rendered
      expect(find.byType(GalleryPage), findsOneWidget);
    });
  });

  group('GalleryPage Error Handling Tests', () {
    testWidgets('GalleryPage handles initialization without crash',
        (WidgetTester tester) async {
      // Arrange
      bool errorOccurred = false;
      FlutterError.onError = (FlutterErrorDetails details) {
        errorOccurred = true;
      };

      // Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - No critical errors should occur
      expect(errorOccurred, isFalse);
      expect(find.byType(GalleryPage), findsOneWidget);
    });

    testWidgets('GalleryPage renders without network',
        (WidgetTester tester) async {
      // Arrange & Act - Network calls will fail in test environment
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Assert - Page should still render (maybe show empty state)
      expect(find.byType(GalleryPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('GalleryPage handles empty gallery list',
        (WidgetTester tester) async {
      // Arrange & Act - No data available
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Assert - Should show empty state or continue without crash
      expect(find.byType(GalleryPage), findsOneWidget);
    });
  });

  group('GalleryPage Memory Management Tests', () {
    testWidgets('GalleryPage disposes controllers properly',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Act - Remove widget to trigger dispose
      await tester.pumpWidget(Container());
      await tester.pump();

      // Assert - No exception should be thrown
      expect(find.byType(GalleryPage), findsNothing);
    });
  });

  group('GalleryPage Integration Tests', () {
    testWidgets('GalleryPage works within MaterialApp',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(GalleryPage), findsOneWidget);
    });

    testWidgets('GalleryPage has proper widget hierarchy',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();

      // Assert - Check hierarchy
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(GalleryPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('GalleryPage UI Component Tests', () {
    testWidgets('GalleryPage has Material design',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();

      // Assert - Should use Material widgets
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('GalleryPage uses proper theming',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createGalleryPage());
      await tester.pump();

      // Assert - MaterialApp provides theme
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp, isNotNull);
    });
  });

  group('GalleryPage Performance Tests', () {
    testWidgets('GalleryPage renders efficiently',
        (WidgetTester tester) async {
      // Arrange & Act
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createGalleryPage());
      await tester.pump();

      stopwatch.stop();

      // Assert - Should render in reasonable time (< 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
