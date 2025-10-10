# 🔄 Token Refresh Guide

## Overview

The BIBOL app now includes **automatic token refresh** functionality to improve user experience by seamlessly refreshing authentication tokens before they expire.

---

## 🎯 Features

### ✅ What's Included

- **Auto Token Validation** - Checks token validity before each API call
- **Auto Token Refresh** - Refreshes expired tokens automatically
- **Retry Mechanism** - Retries failed requests after token refresh
- **Graceful Logout** - Logs out user when refresh token expires
- **Thread-Safe** - Prevents multiple simultaneous refresh attempts

---

## 🏗️ Architecture

### Components

```
┌─────────────────────────────────────────┐
│         Application Layer               │
│  (Screens, Widgets, Services)           │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│       API Interceptor                   │
│  - Injects auth token                   │
│  - Handles 401 responses                │
│  - Triggers token refresh               │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│    Token Refresh Service                │
│  - Validates tokens                     │
│  - Refreshes expired tokens             │
│  - Manages authentication state         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│   Secure Storage Service                │
│  - Stores tokens securely               │
│  - Encrypts sensitive data              │
└─────────────────────────────────────────┘
```

---

## 🚀 Usage

### Basic API Calls

Instead of using `http` directly, use `ApiInterceptor`:

#### ❌ Old Way (No Auto-Refresh)
```dart
import 'package:http/http.dart' as http;

final token = await TokenService.getToken();
final response = await http.get(
  Uri.parse('https://api.example.com/profile'),
  headers: {
    'Authorization': 'Bearer $token',
  },
);
```

#### ✅ New Way (With Auto-Refresh)
```dart
import 'package:BIBOL/services/auth/api_interceptor.dart';

// Token is automatically injected and refreshed if needed
final response = await ApiInterceptor.get(
  'https://api.example.com/profile',
  timeout: const Duration(seconds: 30),
);
```

---

## 📝 Examples

### 1. GET Request

```dart
import 'package:BIBOL/services/auth/api_interceptor.dart';

Future<void> fetchProfile() async {
  try {
    final response = await ApiInterceptor.get(
      'https://api.example.com/profile',
      timeout: const Duration(seconds: 30),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Profile: $data');
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
```

### 2. POST Request

```dart
import 'package:BIBOL/services/auth/api_interceptor.dart';

Future<void> updateProfile(Map<String, dynamic> data) async {
  try {
    final response = await ApiInterceptor.post(
      'https://api.example.com/profile',
      body: data,
      timeout: const Duration(seconds: 30),
    );

    if (response.statusCode == 200) {
      print('Profile updated successfully');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### 3. PUT Request

```dart
import 'package:BIBOL/services/auth/api_interceptor.dart';

Future<void> updateEmail(String email) async {
  final response = await ApiInterceptor.put(
    'https://api.example.com/profile',
    body: {'email': email},
  );

  if (response.statusCode == 200) {
    print('Email updated');
  }
}
```

### 4. DELETE Request

```dart
import 'package:BIBOL/services/auth/api_interceptor.dart';

Future<void> deleteAccount() async {
  final response = await ApiInterceptor.delete(
    'https://api.example.com/account',
  );

  if (response.statusCode == 200) {
    print('Account deleted');
  }
}
```

---

## 🔐 Manual Token Management

### Check if Token is Valid

```dart
import 'package:BIBOL/services/auth/token_refresh_service.dart';

final isValid = await TokenRefreshService.validateToken();
if (!isValid) {
  print('Token is invalid or expired');
}
```

### Check if Token Needs Refresh

```dart
import 'package:BIBOL/services/auth/token_refresh_service.dart';

final needsRefresh = await TokenRefreshService.needsRefresh();
if (needsRefresh) {
  print('Token will expire soon');
}
```

### Manually Refresh Token

```dart
import 'package:BIBOL/services/auth/token_refresh_service.dart';

final success = await TokenRefreshService.refreshToken();
if (success) {
  print('Token refreshed successfully');
} else {
  print('Token refresh failed - user needs to login');
}
```

### Get Valid Token

```dart
import 'package:BIBOL/services/auth/token_refresh_service.dart';

// This will refresh if needed
final token = await TokenRefreshService.getValidToken();
if (token != null) {
  print('Valid token: $token');
}
```

### Check Authentication Status

```dart
import 'package:BIBOL/services/auth/token_refresh_service.dart';

final isAuthenticated = await TokenRefreshService.isAuthenticated();
if (isAuthenticated) {
  print('User is authenticated');
} else {
  print('User needs to login');
}
```

### Logout

```dart
import 'package:BIBOL/services/auth/token_refresh_service.dart';

await TokenRefreshService.logout();
print('User logged out');
```

---

## 🔄 How Token Refresh Works

### Flow Diagram

```
User makes API call
        │
        ▼
ApiInterceptor receives request
        │
        ▼
Check if token exists ──No──> Return 401
        │
        │ Yes
        ▼
Is token valid? ──No──> Try refresh ──Success──> Continue
        │                    │
        │ Yes               Fail
        ▼                    │
Inject token              Logout user
        │
        ▼
Make HTTP request
        │
        ▼
Receive response
        │
        ▼
Is 401? ──Yes──> Try refresh ──Success──> Retry request
        │                │
        │ No            Fail
        ▼                │
Return response      Logout user
```

### Token Expiry Timeline

```
Login
  │
  ├─> Token valid (24 hours)
  │
  ├─> [23h 55m] Token needs refresh (5 min warning)
  │   └─> Auto-refresh on next API call
  │
  ├─> [24h+] Token expired
  │   └─> Auto-refresh on next API call
  │
  └─> [Refresh token expired] Logout user
```

---

## ⚙️ Configuration

### Environment-Specific Settings

Token refresh behavior is configured per environment:

```dart
// lib/config/environment.dart

// Development - longer timeouts
case Environment.development:
  return const Duration(seconds: 60);

// Production - standard timeouts
case Environment.production:
  return const Duration(seconds: 30);
```

### API Endpoints

```dart
// lib/config/bibol_api.dart

class StudentsApiConfig {
  // Token refresh endpoint
  static String getTokenRefreshUrl() => '$baseUrl/students/refresh';
}
```

---

## 🧪 Testing

### Unit Tests

Token refresh includes comprehensive unit tests:

```bash
# Run token refresh tests
flutter test test/services/token_refresh_service_test.dart

# Run all tests
flutter test
```

### Test Coverage

```
TokenRefreshService:
  ✅ Token validation
  ✅ Token refresh logic
  ✅ Error handling
  ✅ State management
  ✅ Logout functionality
```

---

## 🐛 Debugging

### Enable Debug Logging

```dart
import 'package:BIBOL/services/auth/token_refresh_service.dart';

// Print current token status
await TokenRefreshService.debugPrintStatus();
```

Output:
```
═══════════════════════════════════════
  TOKEN STATUS
═══════════════════════════════════════
🔐 [TOKEN] Has Token: true
🔐 [TOKEN] Has Refresh Token: true
🔐 [TOKEN] Token Valid: true
🔐 [TOKEN] Is Logged In: true
🔐 [TOKEN] Is Refreshing: false
🔐 [TOKEN] Pending Requests: 0
───────────────────────────────────────
```

### Common Issues

#### Issue 1: Token Not Refreshing

**Symptoms:**
- User gets logged out unexpectedly
- 401 errors on API calls

**Solution:**
```dart
// Check if refresh token exists
final refreshToken = await SecureStorageService.getRefreshToken();
if (refreshToken == null) {
  print('No refresh token - user must login');
}
```

#### Issue 2: Multiple Refresh Attempts

**Symptoms:**
- Slow API responses
- Multiple refresh requests in logs

**Solution:**
- The service automatically prevents simultaneous refreshes
- Check for race conditions in your code

#### Issue 3: Refresh Token Expired

**Symptoms:**
- User gets logged out after refresh attempt

**Solution:**
- This is expected behavior
- Refresh tokens typically last 7-30 days
- User needs to login again

---

## 📊 Performance

### Metrics

- **Token Check:** ~5ms
- **Token Refresh:** ~500-1000ms (network dependent)
- **Retry After Refresh:** ~500-1000ms (network dependent)

### Optimization Tips

1. **Batch Requests:** Group API calls to minimize refresh checks
2. **Cache Responses:** Reduce unnecessary API calls
3. **Preemptive Refresh:** Refresh before expiry to avoid delays

---

## 🔒 Security

### Best Practices

1. **Always Use HTTPS** - Never send tokens over HTTP
2. **Secure Storage** - Tokens are encrypted using platform-specific secure storage
3. **Short-Lived Tokens** - Access tokens expire in 24 hours
4. **Refresh Token Rotation** - New refresh token issued on each refresh
5. **Logout on Failure** - Clear all data when refresh fails

### Token Storage

```
iOS: Keychain (Hardware-encrypted)
Android: EncryptedSharedPreferences (AES-256)
```

---

## 📚 API Reference

### TokenRefreshService

#### Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `validateToken()` | Check if current token is valid | `Future<bool>` |
| `needsRefresh()` | Check if token needs refresh | `Future<bool>` |
| `refreshToken()` | Manually refresh the token | `Future<bool>` |
| `ensureValidToken()` | Ensure token is valid, refresh if needed | `Future<bool>` |
| `getValidToken()` | Get token, refresh if needed | `Future<String?>` |
| `isAuthenticated()` | Check if user is authenticated | `Future<bool>` |
| `logout()` | Clear all tokens and logout | `Future<void>` |
| `debugPrintStatus()` | Print token status (debug only) | `Future<void>` |

### ApiInterceptor

#### Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `get(url)` | HTTP GET with auto-refresh | `Future<Response>` |
| `post(url, body)` | HTTP POST with auto-refresh | `Future<Response>` |
| `put(url, body)` | HTTP PUT with auto-refresh | `Future<Response>` |
| `delete(url)` | HTTP DELETE with auto-refresh | `Future<Response>` |
| `getPublic(url)` | HTTP GET without auth | `Future<Response>` |
| `postPublic(url, body)` | HTTP POST without auth | `Future<Response>` |

---

## 🎓 Migration Guide

### For Existing Code

If you have existing API calls using `http` directly, migrate them:

**Step 1:** Import ApiInterceptor
```dart
import 'package:BIBOL/services/auth/api_interceptor.dart';
```

**Step 2:** Replace `http.get` with `ApiInterceptor.get`
```dart
// Before
final response = await http.get(Uri.parse(url), headers: headers);

// After
final response = await ApiInterceptor.get(url);
```

**Step 3:** Remove manual token injection
```dart
// Before
final token = await TokenService.getToken();
headers['Authorization'] = 'Bearer $token';

// After
// Token is automatically injected by ApiInterceptor
```

---

## 📄 License

This token refresh implementation is part of the BIBOL app and follows the same license.

---

## 🙏 Credits

Developed with ❤️ for BIBOL students.
