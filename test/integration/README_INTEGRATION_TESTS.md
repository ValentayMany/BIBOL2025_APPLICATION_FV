# 🧪 Integration Tests

## 📋 Overview

Integration tests ทดสอบการทำงานร่วมกันของหลายส่วนในแอป รวมถึง UI, Services, และ Navigation

---

## 📁 Test Files

### 1. `login_flow_test.dart`
ทดสอบ flow การ login และ authentication

**Test Cases:**
- ✅ Complete login flow (splash → login → home)
- ✅ Login with valid credentials
- ✅ Logout flow
- ✅ Navigate through all bottom nav pages

### 2. `news_flow_test.dart`
ทดสอบ flow การดูข่าว

**Test Cases:**
- ✅ Browse news from home page
- ✅ Navigate to News page
- ✅ Search news
- ✅ Pull to refresh news
- ✅ Display cached news when offline

### 3. `course_flow_test.dart`
ทดสอบ flow การดูหลักสูตร

**Test Cases:**
- ✅ View courses from home page
- ✅ Scroll through courses
- ✅ Display cached courses

---

## 🚀 How to Run

### Run all integration tests:
```bash
flutter test test/integration/
```

### Run specific test file:
```bash
flutter test test/integration/login_flow_test.dart
flutter test test/integration/news_flow_test.dart
flutter test test/integration/course_flow_test.dart
```

### Run with coverage:
```bash
flutter test --coverage test/integration/
```

### Run with verbose output:
```bash
flutter test --verbose test/integration/
```

---

## 📊 Test Coverage

| Flow | Tests | Status |
|------|-------|--------|
| **Login Flow** | 4 tests | ✅ |
| **News Flow** | 5 tests | ✅ |
| **Course Flow** | 3 tests | ✅ |
| **Total** | **12 tests** | ✅ |

---

## 🎯 Critical User Flows Covered

### 1. ✅ Authentication Flow
- Splash screen → Login → Home
- Login validation
- Logout

### 2. ✅ Content Browsing
- View news list
- View news details
- View courses
- Search functionality

### 3. ✅ Navigation
- Bottom navigation
- Page transitions
- Back navigation

### 4. ✅ Offline Capability
- Display cached data
- Handle no internet

---

## 💡 Best Practices

### 1. **Setup & Teardown**
```dart
setUp(() async {
  await CacheService.initialize();
});

tearDown(() async {
  // Clean up
});
```

### 2. **Wait for Animations**
```dart
await tester.pumpAndSettle(); // รอจน animations เสร็จ
await tester.pump(Duration(seconds: 2)); // รอเวลาที่กำหนด
```

### 3. **Handle Async Operations**
```dart
// รอให้ data โหลด
await tester.pumpAndSettle(const Duration(seconds: 5));
```

### 4. **Safe Navigation**
```dart
final widget = find.byType(SomeWidget);
if (widget.evaluate().isNotEmpty) {
  await tester.tap(widget);
  await tester.pumpAndSettle();
}
```

---

## 🔧 Mock Services

สำหรับ integration tests ที่ต้องการทดสอบกับ mock data:

```dart
// TODO: เพิ่ม mock services
// import 'package:mockito/mockito.dart';

// Mock API responses
// when(mockNewsService.getNews()).thenReturn(...);
```

---

## 🐛 Common Issues

### Issue: "Timed out while executing pumpAndSettle"
**Solution:** เพิ่ม timeout หรือใช้ pump แทน
```dart
await tester.pump(const Duration(seconds: 2));
```

### Issue: "Widget not found"
**Solution:** รอให้โหลดเสร็จก่อน
```dart
await tester.pumpAndSettle();
await tester.pump(const Duration(milliseconds: 500));
```

### Issue: "RenderFlex overflowed"
**Solution:** ใช้ `testWidgets` แทน `test` เพื่อมี `tester`

---

## 📈 Next Steps

### ขยาย Test Coverage:
- [ ] Add more error scenarios
- [ ] Test with mock API
- [ ] Test offline scenarios
- [ ] Test image loading
- [ ] Test form validation

### Performance Testing:
- [ ] Measure screen load time
- [ ] Test memory usage
- [ ] Test scroll performance

---

## 🎉 Summary

Integration tests ช่วยให้มั่นใจว่า:
- ✅ User flows ทำงานได้ถูกต้อง
- ✅ Navigation ไม่มี bug
- ✅ Data loading ทำงานปกติ
- ✅ Offline mode ใช้งานได้

**รันเทสอย่างสม่ำเสมอ เพื่อจับ bug ก่อนถึงมือ user!** 🚀
