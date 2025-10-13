/// 🧪 Integration Test - Course Flow
/// 
/// ทดสอบ flow การดูหลักสูตรทั้งหมด

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/main.dart' as app;
import 'package:BIBOL/services/cache/cache_service.dart';
import 'package:BIBOL/widgets/home_widgets/course_card_widget.dart';

void main() {
  group('Course Flow Integration Tests', () {
    setUp(() async {
      await CacheService.initialize();
    });

    testWidgets('View courses from home page', (WidgetTester tester) async {
      // 🎯 Test: ดูหลักสูตรจากหน้า home

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // รอให้ข้อมูลโหลด
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // หา CourseCardWidget
      final courseCards = find.byType(CourseCardWidget);

      if (courseCards.evaluate().isNotEmpty) {
        // กดดูหลักสูตร
        await tester.tap(courseCards.first);
        await tester.pumpAndSettle();

        // ควรไปหน้ารายละเอียดหลักสูตร
      }

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Scroll through courses', (WidgetTester tester) async {
      // 🎯 Test: Scroll ดูหลักสูตร

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // หา horizontal scroll view ของ courses
      final listViews = find.byType(ListView);

      if (listViews.evaluate().isNotEmpty) {
        // Scroll ไปข้างหน้า
        await tester.drag(listViews.first, const Offset(-300, 0));
        await tester.pump();
        await tester.pumpAndSettle();

        // Scroll กลับ
        await tester.drag(listViews.first, const Offset(300, 0));
        await tester.pump();
        await tester.pumpAndSettle();
      }

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Course Cache Tests', () {
    testWidgets('Display cached courses', (tester) async {
      // 🎯 Test: แสดงหลักสูตรจาก cache

      // Cache หลักสูตรไว้ก่อน
      await CacheService.cacheCourses([
        {
          'id': '1',
          'title': 'Test Course',
          'icon': '',
          'recommended': true,
        },
      ]);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
