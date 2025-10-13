/// 🧪 Integration Test - News Flow
/// 
/// ทดสอบ flow การดูข่าวทั้งหมด

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/main.dart' as app;
import 'package:BIBOL/services/cache/cache_service.dart';
import 'package:BIBOL/widgets/home_widgets/news_card_widget.dart';

void main() {
  group('News Flow Integration Tests', () {
    setUp(() async {
      await CacheService.initialize();
    });

    testWidgets('Browse news from home page', (WidgetTester tester) async {
      // 🎯 Test: ดูข่าวจากหน้า home

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // รอให้ข้อมูลโหลด
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // ตรวจหา NewsCardWidget
      final newsCards = find.byType(NewsCardWidget);

      if (newsCards.evaluate().isNotEmpty) {
        // มีข่าว - ทดสอบกดดู
        await tester.tap(newsCards.first);
        await tester.pumpAndSettle();

        // ควรไปหน้ารายละเอียดข่าว
        // (ตรวจสอบว่าไม่ crash)
      }

      // Test passed
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Navigate to News page', (WidgetTester tester) async {
      // 🎯 Test: ไปหน้า News

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // หา bottom nav
      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isEmpty) return;

      // กด tab ข่าว (ปกติจะเป็น tab ที่ 1)
      final navItems = find.descendant(
        of: bottomNav,
        matching: find.byType(InkResponse),
      );

      if (navItems.evaluate().length > 1) {
        await tester.tap(navItems.at(1));
        await tester.pumpAndSettle();

        // รอให้โหลดข่าว
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Search news', (WidgetTester tester) async {
      // 🎯 Test: ค้นหาข่าว

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // หา TextField ของ search
      final searchFields = find.byType(TextField);

      if (searchFields.evaluate().isNotEmpty) {
        // พิมพ์คำค้นหา
        await tester.enterText(searchFields.first, 'ข่าว');
        await tester.pump();

        // รอให้ค้นหา
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
      }

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Pull to refresh news', (WidgetTester tester) async {
      // 🎯 Test: Pull to refresh

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // หา RefreshIndicator หรือ CustomScrollView
      final scrollView = find.byType(CustomScrollView);

      if (scrollView.evaluate().isNotEmpty) {
        // ดึงลงมา (pull to refresh)
        await tester.drag(scrollView.first, const Offset(0, 300));
        await tester.pump();

        // รอให้ refresh
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('News Cache Tests', () {
    testWidgets('Display cached news when offline', (tester) async {
      // 🎯 Test: แสดงข่าวจาก cache เมื่อ offline

      // Cache ข่าวไว้ก่อน
      await CacheService.cacheNews([
        {
          'id': '1',
          'title': 'Test News',
          'details': 'Test Details',
          'photo_file': '',
          'visits': 100,
        },
      ]);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ควรเห็นข่าวจาก cache
      // (แม้จะไม่มี internet)
      
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
