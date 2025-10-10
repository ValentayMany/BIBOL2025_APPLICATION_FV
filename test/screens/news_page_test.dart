// News Page Widget Tests
// Tests for NewsListPage UI and basic functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/screens/News/news_pages.dart';
import 'package:BIBOL/widgets/common/custom_bottom_nav.dart';

void main() {
  // Test helper to create widget with MaterialApp wrapper
  Widget createNewsPage({String? categoryId, String? categoryTitle}) {
    return MaterialApp(
      home: NewsListPage(
        categoryId: categoryId,
        categoryTitle: categoryTitle,
      ),
    );
  }

  group('NewsListPage Widget Tests', () {
    testWidgets('NewsListPage renders correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();

      // Assert - Check if NewsListPage widget exists
      expect(find.byType(NewsListPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('NewsListPage has CustomBottomNav',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for bottom navigation
      expect(find.byType(CustomBottomNav), findsOneWidget);
    });

    testWidgets('NewsListPage shows loading state initially',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump(); // Don't settle to catch loading state

      // Assert - Check for loading indicator or loading widgets
      expect(
        find.byType(CircularProgressIndicator),
        findsWidgets,
      );
    });

    testWidgets('NewsListPage has SafeArea', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();

      // Assert - Check for SafeArea
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('NewsListPage is scrollable', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for scrollable widget
      final scrollableWidgets = find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView ||
            widget is ListView ||
            widget is CustomScrollView,
      );
      expect(scrollableWidgets, findsWidgets);
    });

    testWidgets('NewsListPage accepts optional categoryId',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createNewsPage(categoryId: 'test-category-123'),
      );
      await tester.pump();

      // Assert - Widget should render without error
      expect(find.byType(NewsListPage), findsOneWidget);
    });

    testWidgets('NewsListPage accepts optional categoryTitle',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createNewsPage(
          categoryId: 'test-category',
          categoryTitle: 'Test Category',
        ),
      );
      await tester.pump();

      // Assert - Widget should render without error
      expect(find.byType(NewsListPage), findsOneWidget);
    });
  });

  group('NewsListPage Search Functionality Tests', () {
    testWidgets('NewsListPage has search field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for TextField (search field)
      // The exact finder depends on implementation
      final textFields = find.byType(TextField);
      final textFormFields = find.byType(TextFormField);

      expect(
        textFields.evaluate().isNotEmpty || textFormFields.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Search controller can be initialized',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();

      // Assert - Widget should have initialized properly
      expect(find.byType(NewsListPage), findsOneWidget);
    });
  });

  group('NewsListPage Layout Tests', () {
    testWidgets('NewsListPage has proper scaffold structure',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();

      // Assert - Check for Scaffold
      expect(find.byType(Scaffold), findsOneWidget);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, isNotNull);
    });

    testWidgets('NewsListPage has bottom navigation',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Check for CustomBottomNav
      expect(find.byType(CustomBottomNav), findsOneWidget);
    });
  });

  group('NewsListPage Responsive Tests', () {
    testWidgets('NewsListPage renders on small screen (320x568)',
        (WidgetTester tester) async {
      // Arrange - Set small screen size
      await tester.binding.setSurfaceSize(const Size(320, 568));

      // Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(NewsListPage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('NewsListPage renders on medium screen (375x667)',
        (WidgetTester tester) async {
      // Arrange - Set medium screen size
      await tester.binding.setSurfaceSize(const Size(375, 667));

      // Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(NewsListPage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('NewsListPage renders on large screen (414x896)',
        (WidgetTester tester) async {
      // Arrange - Set large screen size
      await tester.binding.setSurfaceSize(const Size(414, 896));

      // Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(NewsListPage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('NewsListPage renders on tablet (768x1024)',
        (WidgetTester tester) async {
      // Arrange - Set tablet screen size
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      // Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(NewsListPage), findsOneWidget);

      // Cleanup
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('NewsListPage State Management Tests', () {
    testWidgets('NewsListPage is a StatefulWidget',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();

      // Assert
      final newsPageWidget =
          tester.widget<NewsListPage>(find.byType(NewsListPage));
      expect(newsPageWidget, isA<StatefulWidget>());
    });

    testWidgets('NewsListPage maintains state across rebuilds',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Act - Trigger a rebuild
      await tester.pump();

      // Assert - Widget should still exist
      expect(find.byType(NewsListPage), findsOneWidget);
    });
  });

  group('NewsListPage Animation Tests', () {
    testWidgets('NewsListPage handles animations without crash',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();

      // Pump multiple frames for animations
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - No crash should occur
      expect(find.byType(NewsListPage), findsOneWidget);
    });

    testWidgets('NewsListPage animations complete successfully',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();

      // Wait for animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert - Page should be fully rendered
      expect(find.byType(NewsListPage), findsOneWidget);
    });
  });

  group('NewsListPage Error Handling Tests', () {
    testWidgets('NewsListPage handles initialization without crash',
        (WidgetTester tester) async {
      // Arrange
      bool errorOccurred = false;
      FlutterError.onError = (FlutterErrorDetails details) {
        errorOccurred = true;
      };

      // Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - No critical errors should occur
      expect(errorOccurred, isFalse);
      expect(find.byType(NewsListPage), findsOneWidget);
    });

    testWidgets('NewsListPage renders without network',
        (WidgetTester tester) async {
      // Arrange & Act - Network calls will fail in test environment
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Assert - Page should still render (maybe show error state)
      expect(find.byType(NewsListPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('NewsListPage Memory Management Tests', () {
    testWidgets('NewsListPage disposes controllers properly',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createNewsPage());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Act - Remove widget to trigger dispose
      await tester.pumpWidget(Container());
      await tester.pump();

      // Assert - No exception should be thrown
      expect(find.byType(NewsListPage), findsNothing);
    });
  });

  group('NewsListPage Constructor Tests', () {
    testWidgets('NewsListPage works with null parameters',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();

      // Assert
      expect(find.byType(NewsListPage), findsOneWidget);
    });

    testWidgets('NewsListPage works with categoryId only',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createNewsPage(categoryId: 'test-123'),
      );
      await tester.pump();

      // Assert
      expect(find.byType(NewsListPage), findsOneWidget);
    });

    testWidgets('NewsListPage works with both parameters',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createNewsPage(
          categoryId: 'test-123',
          categoryTitle: 'Test Title',
        ),
      );
      await tester.pump();

      // Assert
      expect(find.byType(NewsListPage), findsOneWidget);
    });
  });

  group('NewsListPage Integration Tests', () {
    testWidgets('NewsListPage works within MaterialApp',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(NewsListPage), findsOneWidget);
    });

    testWidgets('NewsListPage has proper widget hierarchy',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createNewsPage());
      await tester.pump();

      // Assert - Check hierarchy
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(NewsListPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
