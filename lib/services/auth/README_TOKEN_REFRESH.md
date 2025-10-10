# 🔄 Token Refresh Mechanism - คู่มือการใช้งาน

## 📁 ไฟล์ที่เพิ่มมา

```
lib/
├── services/auth/
│   ├── token_refresh_service.dart         ← NEW! จัดการ refresh token
│   └── students_auth_service.dart         (มีอยู่แล้ว)
├── interceptors/
│   └── auth_interceptor.dart              ← NEW! Auto-retry เมื่อ 401
└── config/
    └── bibol_api.dart                     (อัพเดทแล้ว - เพิ่ม refreshTokenUrl)
```

---

## 🎯 ฟีเจอร์ที่ได้

### 1. ✅ **Token Refresh อัตโนมัติ**
- เมื่อ access token หมดอายุ (401 error)
- จะ auto-refresh token ด้วย refresh token
- Retry request ใหม่โดยอัตโนมัติ

### 2. ✅ **Prevent Multiple Refresh Requests**
- ถ้ามีหลาย request fail พร้อมกัน
- จะ refresh token ครั้งเดียว
- Request อื่นๆ รอผลแล้วใช้ token เดียวกัน

### 3. ✅ **Auto-Logout เมื่อ Refresh ล้มเหลว**
- ถ้า refresh token หมดอายุ
- จะลบข้อมูล auth ทั้งหมด
- User ต้อง login ใหม่

---

## 🚀 วิธีใช้งาน

### วิธีที่ 1: ใช้ AuthInterceptor (แนะนำ!)

```dart
import 'package:BIBOL/interceptors/auth_interceptor.dart';

// แทนที่จะใช้ http.get/post ตรงๆ
// ✅ ใช้ AuthInterceptor แทน

// ตัวอย่าง GET request
final response = await AuthInterceptor.get(
  Uri.parse('https://api.example.com/profile'),
);

// ตัวอย่าง POST request
final response = await AuthInterceptor.post(
  Uri.parse('https://api.example.com/update-profile'),
  body: jsonEncode({'name': 'John Doe'}),
);

// ตัวอย่าง PUT request
final response = await AuthInterceptor.put(
  Uri.parse('https://api.example.com/update-email'),
  body: jsonEncode({'email': 'newemail@example.com'}),
);

// ตัวอย่าง DELETE request
final response = await AuthInterceptor.delete(
  Uri.parse('https://api.example.com/delete-account'),
);
```

**ข้อดี:**
- ✅ Auto-add Authorization header
- ✅ Auto-refresh token เมื่อ 401
- ✅ Auto-retry request
- ✅ ไม่ต้องจัดการเอง

---

### วิธีที่ 2: ใช้ TokenRefreshService เอง

```dart
import 'package:BIBOL/services/auth/token_refresh_service.dart';

// เช็คว่าต้อง refresh หรือไม่
final needsRefresh = await TokenRefreshService.needsRefresh();

if (needsRefresh) {
  // Refresh token
  final newToken = await TokenRefreshService.refreshToken();
  
  if (newToken != null) {
    print('✅ Token refreshed: $newToken');
    // ทำ request ของคุณต่อ
  } else {
    print('❌ Refresh failed, need to re-login');
    // Navigate to login screen
  }
}
```

---

## 🔧 อัพเดท Services ที่มีอยู่

### StudentAuthService - เพิ่ม getProfile with auto-refresh

```dart
// lib/services/auth/students_auth_service.dart

import 'package:BIBOL/interceptors/auth_interceptor.dart';

class StudentAuthService {
  // ก่อนหน้า: ใช้ http.get ธรรมดา
  Future<Map<String, dynamic>?> getProfile() async {
    final response = await http.get(
      Uri.parse(StudentsApiConfig.getStudentProfileUrl()),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 401) {
      // ต้องจัดการ token expired เอง 😢
    }
  }
  
  // ✅ ตอนนี้: ใช้ AuthInterceptor
  Future<Map<String, dynamic>?> getProfile() async {
    final response = await AuthInterceptor.get(
      Uri.parse(StudentsApiConfig.getStudentProfileUrl()),
    );
    
    // AuthInterceptor จัดการ 401 ให้อัตโนมัติ! 🎉
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data'];
    }
    return null;
  }
}
```

---

## 📝 ตัวอย่างการใช้งานจริง

### 1. ใน NewsService

```dart
// lib/services/news/news_service.dart

import 'package:BIBOL/interceptors/auth_interceptor.dart';

class NewsService {
  static Future<NewsResponse> getNews({int limit = 10}) async {
    // ✅ ใช้ AuthInterceptor
    final response = await AuthInterceptor.get(
      Uri.parse(NewsApiConfig.getNewsUrl(count: limit)),
    );
    
    if (response.statusCode == 200) {
      return NewsResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load news');
  }
}
```

### 2. ใน CourseService

```dart
// lib/services/course/course_Service.dart

import 'package:BIBOL/interceptors/auth_interceptor.dart';

class CourseService {
  static Future<CourseResponse> getCourses() async {
    // ✅ ใช้ AuthInterceptor
    final response = await AuthInterceptor.get(
      Uri.parse(CourseApiConfig.getCoursesUrl()),
    );
    
    if (response.statusCode == 200) {
      return CourseResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load courses');
  }
}
```

### 3. ใน ProfilePage - Update Email

```dart
// lib/screens/Profile/edit_profile_page.dart

import 'package:BIBOL/interceptors/auth_interceptor.dart';

Future<void> updateEmail(String newEmail) async {
  try {
    // ✅ ใช้ AuthInterceptor
    final response = await AuthInterceptor.put(
      Uri.parse(StudentsApiConfig.updateStudentProfileUrl()),
      body: jsonEncode({'email': newEmail}),
    );
    
    if (response.statusCode == 200) {
      SnackBarUtils.showSuccess(context, 'อัพเดทอีเมวสำเร็จ');
    } else {
      SnackBarUtils.showError(context, 'อัพเดทล้มเหลว');
    }
  } catch (e) {
    SnackBarUtils.showError(context, 'เกิดข้อผิดพลาด: $e');
  }
}
```

---

## ⚙️ Backend Requirements

Backend ต้องมี endpoint นี้:

```javascript
// Node.js/Express example
POST /api/students/refresh-token

// Request Body:
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

// Response (Success - 200):
{
  "success": true,
  "data": {
    "token": "new_access_token_here",
    "refresh_token": "new_refresh_token_here"  // optional
  }
}

// Response (Expired - 401):
{
  "success": false,
  "message": "Refresh token expired"
}
```

**หมายเหตุ:** ถ้า backend คุณใช้ format อื่น สามารถแก้ไขใน `token_refresh_service.dart` บรรทัด 65-76

---

## 🧪 Testing

### Test Token Refresh

```dart
// ในหน้า Profile หรือ Settings
import 'package:BIBOL/services/auth/token_refresh_service.dart';

ElevatedButton(
  onPressed: () async {
    print('Testing token refresh...');
    final newToken = await TokenRefreshService.refreshToken();
    if (newToken != null) {
      print('✅ Token refreshed successfully');
      SnackBarUtils.showSuccess(context, 'Token refreshed!');
    } else {
      print('❌ Token refresh failed');
      SnackBarUtils.showError(context, 'Refresh failed');
    }
  },
  child: Text('Test Token Refresh'),
)
```

### Debug Token Status

```dart
import 'package:BIBOL/services/storage/secure_storage_service.dart';
import 'package:BIBOL/services/auth/token_refresh_service.dart';

Future<void> debugTokenStatus() async {
  print('=== TOKEN STATUS ===');
  
  final token = await SecureStorageService.getToken();
  print('Has Token: ${token != null}');
  
  final isValid = await SecureStorageService.isTokenValid();
  print('Is Valid: $isValid');
  
  final hasRefreshToken = await TokenRefreshService.hasRefreshToken();
  print('Has Refresh Token: $hasRefreshToken');
  
  final needsRefresh = await TokenRefreshService.needsRefresh();
  print('Needs Refresh: $needsRefresh');
  
  print('===================');
}
```

---

## 🎯 Checklist การ Implement

- [x] ✅ สร้าง `token_refresh_service.dart`
- [x] ✅ สร้าง `auth_interceptor.dart`
- [x] ✅ อัพเดท `bibol_api.dart` เพิ่ม refresh URL
- [ ] ⏳ อัพเดท `students_auth_service.dart` ให้ return refresh_token เมื่อ login
- [ ] ⏳ อัพเดท Services ต่างๆ ให้ใช้ `AuthInterceptor`
- [ ] ⏳ ทดสอบ token refresh flow
- [ ] ⏳ Backend เพิ่ม `/refresh-token` endpoint

---

## 📖 เพิ่มเติม

### Login Response ควร Return Refresh Token

อัพเดท `login()` method ใน `students_auth_service.dart`:

```dart
Future<StudentLoginResponse?> login({
  required String admissionNo,
  required String email,
}) async {
  // ... existing code ...
  
  if (loginResponse.success && loginResponse.data != null) {
    // บันทึก access token
    await TokenService.saveToken(loginResponse.data!.token);
    
    // บันทึก refresh token (ถ้า backend return มา)
    if (loginResponse.data!.refreshToken != null) {
      await SecureStorageService.saveRefreshToken(
        loginResponse.data!.refreshToken!
      );
    }
    
    // บันทึก user info
    await TokenService.saveUserInfo(loginResponse.data!.toJson());
  }
  
  return loginResponse;
}
```

---

## 🎉 สรุป

### ก่อนใช้ Token Refresh:
```dart
// ❌ ต้องจัดการ 401 เอง
final response = await http.get(url, headers: {
  'Authorization': 'Bearer $token'
});

if (response.statusCode == 401) {
  // Token expired, ต้อง login ใหม่
  Navigator.pushReplacementNamed(context, '/login');
}
```

### หลังใช้ Token Refresh:
```dart
// ✅ Auto-refresh token
final response = await AuthInterceptor.get(url);

// ถ้า 401 จะ auto-refresh และ retry ให้อัตโนมัติ!
if (response.statusCode == 200) {
  // ได้ข้อมูลแล้ว
}
```

**ผลลัพธ์:**
- 🎉 UX ดีขึ้น (ไม่ถูก logout บ่อย)
- 🎉 Code สะอาดขึ้น (ไม่ต้องจัดการ 401 ทุกที่)
- 🎉 Secure (ใช้ refresh token แทน long-lived access token)

---

**Happy Coding! 🚀**
