# 🔧 Manual Fixes Required

**คุณต้องแก้ไขไฟล์เหล่านี้ด้วยตัวเอง:**

---

## ⚠️ **Issue 1: lib/test/ directory still exists**

### **Fix:**
```cmd
# ลบ folder lib/test/ ทั้งหมด
rmdir /s /q lib\test
```

หรือลบใน Windows Explorer:
1. เปิด folder `lib/`
2. ถ้ามี folder `test/` อยู่ → **ลบทิ้ง**
3. Done!

---

## ⚠️ **Issue 2: token_service.dart has unused fields**

### **File:** `lib/services/token/token_service.dart`

### **Find these lines (around line 10-11):**
```dart
static const String _tokenKey = 'auth_token';      // ❌ ลบบรรทัดนี้
static const String _userInfoKey = 'user_info';    // ❌ ลบบรรทัดนี้
```

### **Replace with:**
```dart
// (ลบทั้ง 2 บรรทัดออก - ไม่ต้องใส่อะไรแทน)
```

### **Full Fix - Replace lines 7-12:**

**ค้นหา:**
```dart
/// ⚠️ DEPRECATED: This service is kept for backward compatibility
/// Please use SecureStorageService instead for better security
class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userInfoKey = 'user_info';
  static const String _studentIdKey = 'student_id';
```

**แทนที่ด้วย:**
```dart
/// ⚠️ DEPRECATED: This service is kept for backward compatibility
/// Please use SecureStorageService instead for better security
class TokenService {
  static const String _studentIdKey = 'student_id';
```

---

## ⚠️ **Issue 3: widget_test.dart is wrong**

### **File:** `test/widget_test.dart`

### **Replace entire file with:**

```dart
// BIBOL App - Basic Widget Tests
// These tests verify that the app initializes correctly

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/main.dart';

void main() {
  // Disable HTTP requests during tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Initialization Tests', () {
    testWidgets('App initializes without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      // Verify app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      // Check MaterialApp configuration
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, equals('Banking Institute App'));
      expect(app.debugShowCheckedModeBanner, isFalse);
    });
  });
}
```

---

## ✅ **After Fixing:**

```cmd
# Clean
flutter clean
flutter pub get

# Verify fixes
flutter analyze
```

**Expected:**
```
No issues found!
```

---

## 🚀 **Or Use Auto Fix Script:**

```cmd
# Run the script
FIX_ISSUES.bat

# Then manually fix the files above
# Then run
flutter analyze
```

---

## 📝 **Checklist:**

- [ ] ลบ `lib/test/` directory
- [ ] แก้ `lib/services/token/token_service.dart` (ลบ 2 บรรทัด)
- [ ] แก้ `test/widget_test.dart` (replace ทั้งไฟล์)
- [ ] Run `flutter clean && flutter pub get`
- [ ] Run `flutter analyze` → should show "No issues found!"

---

**After completing all fixes, run:**
```cmd
flutter analyze
```

Should see:
```
Analyzing BIBOL_APP...
No issues found! ✓
```
