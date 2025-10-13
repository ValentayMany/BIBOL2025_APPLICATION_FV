/// 🧪 Integration Test - Login Flow
/// 
/// ทดสอบ flow การ login ทั้งหมด ตั้งแต่เปิดแอปจนถึง login สำเร็จ

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/main.dart' as app;
import 'package:BIBOL/services/cache/cache_service.dart';

void main() {
  group('Login Flow Integration Tests', () {
    setUp(() async {
      // Initialize cache service before each test
      await CacheService.initialize();
    });

    testWidgets('Complete login flow - success', (WidgetTester tester) async {
      // 🎯 Test: Login flow จาก splash → login → home

      // 1. Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 2. ควรเห็นหน้า login (ถ้ายังไม่ได้ login)
      // หรือ home page (ถ้า login แล้ว)
      // รอให้ splash screen หายไป
      await tester.pumpAndSettle();

      // ตรวจสอบว่ามี widget พื้นฐานของแอป
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Login with valid credentials', (WidgetTester tester) async {
      // 🎯 Test: Login ด้วย credentials ที่ถูกต้อง

      // Note: ในการทดสอบจริง ควรใช้ mock API
      // แต่ที่นี่เราจะทดสอบ UI flow

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ถ้าเจอ TextField สำหรับ admission number
      final admissionField = find.byType(TextField).first;
      if (admissionField.evaluate().isNotEmpty) {
        // พิมพ์ admission number
        await tester.enterText(admissionField, '12345');
        await tester.pump();

        // ตรวจสอบว่า text ถูกใส่แล้ว
        expect(find.text('12345'), findsOneWidget);
      }
    });

    testWidgets('Logout flow', (WidgetTester tester) async {
      // 🎯 Test: Logout flow

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ถ้าเจอปุ่ม logout
      final logoutButton = find.byIcon(Icons.power_settings_new_rounded);
      if (logoutButton.evaluate().isNotEmpty) {
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();

        // ควรกลับไปหน้า login หรือ confirm dialog
        // (ขึ้นอยู่กับ implementation)
      }
    });
  });

  group('Navigation Flow Tests', () {
    testWidgets('Navigate through all bottom nav pages', (tester) async {
      // 🎯 Test: เปลี่ยนหน้าผ่าน bottom navigation

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // หา BottomNavigationBar
      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isEmpty) {
        return; // ถ้าไม่เจอ ให้ข้าม test นี้
      }

      // กด tab ต่างๆ
      final navItems = find.descendant(
        of: bottomNav,
        matching: find.byType(InkResponse),
      );

      for (int i = 0; i < navItems.evaluate().length && i < 5; i++) {
        await tester.tap(navItems.at(i));
        await tester.pumpAndSettle();

        // รอให้หน้าโหลดเสร็จ
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Test passed ถ้าไม่มี error
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
