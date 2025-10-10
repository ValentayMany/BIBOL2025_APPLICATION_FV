// test/widgets/news_card_test.dart

import 'package:BIBOL/models/topic/topic_model.dart';
import 'package:BIBOL/widgets/home_widgets/news_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewsCardWidget Tests', () {
    // Helper function to create a test news item
    Topic createTestNews({
      int id = 1,
      String title = 'Test News Title',
      String details = 'Test news details',
      String photoFile = '',
      int visits = 100,
    }) {
      return Topic(
        topicId: id,
        title: title,
        details: details,
        photoFile: photoFile,
        visits: visits,
        createdOn: DateTime.now().toString(),
      );
    }

    // Helper function to wrap widget with MaterialApp
    Widget makeTestableWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('should display news title correctly', (tester) async {
      // Arrange
      final news = createTestNews(
        title: 'Breaking News: Flutter is Awesome',
      );

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 375,
          ),
        ),
      );

      // Assert
      expect(find.text('Breaking News: Flutter is Awesome'), findsOneWidget);
    });

    testWidgets('should display news with HTML tags stripped', (tester) async {
      // Arrange
      final news = createTestNews(
        title: '<p>Test <b>Bold</b> Text</p>',
      );

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 375,
          ),
        ),
      );

      // Assert
      expect(find.text('Test Bold Text'), findsOneWidget);
    });

    testWidgets('should display visit count', (tester) async {
      // Arrange
      final news = createTestNews(visits: 250);

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 375,
          ),
        ),
      );

      // Assert
      expect(find.text('250'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      final news = createTestNews();
      bool wasTapped = false;

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 375,
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(NewsCardWidget));
      await tester.pumpAndSettle();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should render featured card with correct layout', (tester) async {
      // Arrange
      final news = createTestNews(
        title: 'Featured News',
        details: 'This is a featured news article',
      );

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 375,
            isFeatured: true,
          ),
        ),
      );

      // Assert
      expect(find.text('Featured News'), findsOneWidget);
      expect(find.byIcon(Icons.fiber_new_rounded), findsOneWidget);
      expect(find.text('ໃໝ່'), findsOneWidget); // "New" badge in Lao
    });

    testWidgets('should render compact card when not featured', (tester) async {
      // Arrange
      final news = createTestNews(title: 'Regular News');

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 375,
            isFeatured: false,
          ),
        ),
      );

      // Assert
      expect(find.text('Regular News'), findsOneWidget);
      // Compact card should have different layout
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('should display error icon when image URL is invalid', (tester) async {
      // Arrange
      final news = createTestNews(
        photoFile: 'invalid-url',
      );

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 375,
          ),
        ),
      );
      await tester.pump();

      // Assert - should show fallback icon instead of broken image
      expect(find.byIcon(Icons.article_rounded), findsOneWidget);
    });

    testWidgets('should adapt layout for small screens', (tester) async {
      // Arrange
      final news = createTestNews(title: 'Small Screen Test');

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 320, // Small screen
          ),
        ),
      );

      // Assert
      expect(find.text('Small Screen Test'), findsOneWidget);
      // Widget should still be rendered
      expect(find.byType(NewsCardWidget), findsOneWidget);
    });

    testWidgets('should adapt layout for large screens/tablets', (tester) async {
      // Arrange
      final news = createTestNews(title: 'Tablet Test');

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 768, // Tablet size
            isFeatured: true,
          ),
        ),
      );

      // Assert
      expect(find.text('Tablet Test'), findsOneWidget);
      expect(find.byType(NewsCardWidget), findsOneWidget);
    });

    testWidgets('should handle HTML entities correctly', (tester) async {
      // Arrange
      final news = createTestNews(
        title: 'Test &amp; More &lt;HTML&gt; &quot;Entities&quot;',
      );

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 375,
          ),
        ),
      );

      // Assert
      expect(find.text('Test & More <HTML> "Entities"'), findsOneWidget);
    });

    testWidgets('should display read more button in featured card', (tester) async {
      // Arrange
      final news = createTestNews();

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 414, // Medium screen
            isFeatured: true,
          ),
        ),
      );

      // Assert
      expect(find.text('ອ່ານເພີ່ມ'), findsOneWidget); // "Read more" in Lao
    });

    testWidgets('should have proper widget hierarchy', (tester) async {
      // Arrange
      final news = createTestNews();

      // Act
      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(
            news: news,
            screenWidth: 375,
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Material), findsWidgets);
      expect(find.byType(InkWell), findsOneWidget);
    });
  });
}
