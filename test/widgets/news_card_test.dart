// ✅ test/widgets/news_card_test.dart

import 'package:BIBOL/models/topic/topic_model.dart';
import 'package:BIBOL/models/user/user_model.dart'; // ✅ เพิ่ม import ของ User model
import 'package:BIBOL/widgets/home_widgets/news_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../google_fonts_test_helper.dart';
import 'package:html_unescape/html_unescape.dart';

void main() {
  // ✅ Initialize Google Fonts for testing
  GoogleFontsTestHelper.initialize();

  // ✅ Helper function to create a mock User - moved outside group
  User createMockUser() {
    return User(
      id: 1,
      name: 'Test User',
      href: 'https://example.com/profile', // หรือ dummy URL
    );
  }

  group('NewsCardWidget Tests', () {
    // ✅ Helper function to create a test Topic (News)
    Topic createTestNews({
      int id = 1,
      String title = 'Test News Title',
      String details = 'Test news details',
      String photoFile = '',
      int visits = 100,
    }) {
      return Topic(
        id: id,
        title: title,
        details: details,
        date: DateTime.now(),
        videoType: null,
        videoFile: '',
        photoFile: photoFile,
        audioFile: null,
        icon: null,
        visits: visits,
        href: '',
        fieldsCount: 0,
        fields: [],
        joinedCategoriesCount: 0,
        joinedCategories: [],
        user: createMockUser(), // ✅ ใช้ object ของ User จริง
      );
    }

    // ✅ Wrap widget for testing with GoogleFonts support
    Widget makeTestableWidget(Widget child) {
      return GoogleFontsTestHelper.createTestWidget(child);
    }

    testWidgets('should display news title correctly', (tester) async {
      final news = createTestNews(title: 'Breaking News: Flutter is Awesome');
      await tester.pumpWidget(
        makeTestableWidget(NewsCardWidget(news: news, screenWidth: 375)),
      );
      expect(find.text('Breaking News: Flutter is Awesome'), findsOneWidget);
    });

    testWidgets('should display news with HTML tags stripped', (tester) async {
      final news = createTestNews(title: '<p>Test <b>Bold</b> Text</p>');
      await tester.pumpWidget(
        makeTestableWidget(NewsCardWidget(news: news, screenWidth: 375)),
      );
      expect(find.text('Test Bold Text'), findsOneWidget);
    });

    testWidgets('should display visit count', (tester) async {
      final news = createTestNews(visits: 250);
      await tester.pumpWidget(
        makeTestableWidget(NewsCardWidget(news: news, screenWidth: 375)),
      );
      expect(find.text('250'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      final news = createTestNews();
      bool wasTapped = false;

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

      expect(wasTapped, isTrue);
    });

    testWidgets('should render featured card with correct layout', (
      tester,
    ) async {
      final news = createTestNews(
        title: 'Featured News',
        details: 'This is a featured news article',
      );

      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(news: news, screenWidth: 375, isFeatured: true),
        ),
      );

      expect(find.text('Featured News'), findsOneWidget);
      expect(find.byIcon(Icons.fiber_new_rounded), findsOneWidget);
      expect(find.text('ໃໝ່'), findsOneWidget); // Lao for "New"
    });

    testWidgets('should render compact card when not featured', (tester) async {
      final news = createTestNews(title: 'Regular News');

      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(news: news, screenWidth: 375, isFeatured: false),
        ),
      );

      expect(find.text('Regular News'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('should display error icon when image URL is invalid', (
      tester,
    ) async {
      final news = createTestNews(photoFile: 'invalid-url');

      await tester.pumpWidget(
        makeTestableWidget(NewsCardWidget(news: news, screenWidth: 375)),
      );
      await tester.pump();

      expect(find.byIcon(Icons.article_rounded), findsOneWidget);
    });

    testWidgets('should adapt layout for small screens', (tester) async {
      final news = createTestNews(title: 'Small Screen Test');

      await tester.pumpWidget(
        makeTestableWidget(NewsCardWidget(news: news, screenWidth: 320)),
      );

      expect(find.text('Small Screen Test'), findsOneWidget);
      expect(find.byType(NewsCardWidget), findsOneWidget);
    });

    testWidgets('should adapt layout for large screens/tablets', (
      tester,
    ) async {
      final news = createTestNews(title: 'Tablet Test');

      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(news: news, screenWidth: 768, isFeatured: true),
        ),
      );

      expect(find.text('Tablet Test'), findsOneWidget);
      expect(find.byType(NewsCardWidget), findsOneWidget);
    });

    // แทนที่ test case เดิมด้วยอันนี้ในไฟล์ test/widgets/news_card_test.dart

    // แทนที่ test case ที่บรรทัด 178-187 ในไฟล์ test/widgets/news_card_test.dart

    testWidgets('should handle HTML entities correctly', (tester) async {
      final news = createTestNews(
        title: 'Test &amp; More <HTML> &quot;Entities&quot;',
      );

      await tester.pumpWidget(
        makeTestableWidget(NewsCardWidget(news: news, screenWidth: 375)),
      );

      // ✅ HTML tags ถูกลบออก, HTML entities ถูก decode
      // ผลลัพธ์ที่คาดหวัง: "Test & More "Entities""
      expect(find.text('Test & More "Entities"'), findsOneWidget);
    });

    testWidgets('should display read more button in featured card', (
      tester,
    ) async {
      final news = createTestNews();

      await tester.pumpWidget(
        makeTestableWidget(
          NewsCardWidget(news: news, screenWidth: 414, isFeatured: true),
        ),
      );

      expect(find.text('ອ່ານເພີ່ມ'), findsOneWidget); // Lao for "Read more"
    });

    testWidgets('should have proper widget hierarchy', (tester) async {
      final news = createTestNews();

      await tester.pumpWidget(
        makeTestableWidget(NewsCardWidget(news: news, screenWidth: 375)),
      );

      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Material), findsWidgets);
      expect(find.byType(InkWell), findsOneWidget);
    });
  });
}
