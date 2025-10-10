# 📝 Changelog

All notable changes to the BIBOL project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.2.0] - 2025-10-10 - 🔄 Token Refresh, Tests & Push Notifications

### ✨ Added

#### Automatic Token Refresh
- **TokenRefreshService** 🔄
  - Automatic token validation before API calls
  - Seamless token refresh when expired
  - Retry mechanism for failed requests
  - Thread-safe refresh to prevent race conditions
  - Graceful logout when refresh token expires

- **API Interceptor** 🔒
  - Automatic token injection in all API calls
  - Auto-retry on 401 (Unauthorized) responses
  - Support for GET, POST, PUT, DELETE requests
  - Public API calls without authentication
  - Response parsing utilities

#### Comprehensive Test Coverage
- **Widget Tests** 🧪
  - LoginPage tests (20+ test cases)
  - HomePage tests (20+ test cases)
  - NewsPage tests (25+ test cases)
  - ProfilePage tests (22+ test cases)
  - GalleryPage tests (25+ test cases)
  - Total: 112+ new test cases

- **Service Tests** 🧪
  - TokenRefreshService tests
  - Token validation tests
  - Authentication state tests
  - Error handling tests

#### Push Notifications
- **PushNotificationService** 🔔
  - Firebase Cloud Messaging integration
  - Local notifications support
  - Foreground/background/terminated state handling
  - Topic subscription management
  - Badge count management
  - Custom notification channels

- **Notification Helper** 🛠️
  - Navigation from notifications
  - In-app notification banners
  - Permission handling
  - Topic subscription helpers
  - Backend token management

#### Documentation
- **Token Refresh Guide** 📚
  - Complete usage documentation
  - Architecture diagrams
  - Code examples
  - Migration guide
  - Debugging tips

- **Firebase Setup Guide** 🔥
  - Step-by-step Firebase configuration
  - Android & iOS setup
  - Testing instructions
  - Troubleshooting guide
  - Security best practices

### 🔧 Changed

#### API Layer
- Updated `StudentAuthService` to use `ApiInterceptor`
- `getProfile()` now uses auto-refresh
- `updateStudentEmail()` now uses auto-refresh
- Added refresh token endpoint to `StudentsApiConfig`

#### Security
- Enhanced token management
- Better error handling for expired tokens
- Automatic cleanup on refresh failure

### 📊 Improvements

#### Test Coverage
- Increased from 40-60% to **80%+**
- Added 112+ widget test cases
- Added 30+ service test cases
- Comprehensive error handling tests

#### Developer Experience
- Better API error messages
- Detailed logging for debugging
- Type-safe API responses
- Easier migration path

---

## [1.1.0] - 2025-10-07 - 🚀 Major Security & Performance Update

### ✨ Added

#### Security Enhancements
- **Secure Token Storage** 🔐
  - Implemented `flutter_secure_storage` for encrypted token storage
  - Auto-migration from old `SharedPreferences` to secure storage
  - Token expiry validation mechanism
  - Refresh token support

#### Environment Configuration
- **Multi-Environment Support** 🌍
  - Development, Staging, and Production environments
  - Configurable API endpoints per environment
  - Environment-specific timeouts and retry logic
  - Easy switching between environments

#### Offline Support
- **Cache Service** 💾
  - Implemented Hive for local data caching
  - News, courses, and gallery offline caching
  - Configurable cache expiry (24 hours default)
  - Cache statistics and management

#### Utilities
- **AppLogger** 📝
  - Centralized logging with different log levels (debug, info, warning, error, critical)
  - Colored console output for better readability
  - Performance measurement utilities
  - API request/response logging

- **SnackBarUtils** 🎨
  - Consistent snackbar styling across the app
  - Success, error, warning, info, and loading variants
  - Action button support
  - Lao language support

- **Validators** 📋
  - Reusable form validators
  - Email, phone, password, required field validation
  - Lao phone number validation
  - Admission number validation
  - Composite validators support

- **DateUtils** 📅
  - Date formatting for Lao format
  - Relative time strings ("2 ຊົ່ວໂມງກ່ອນ")
  - Date comparison utilities
  - Age calculation

#### Testing
- **Unit Tests** 🧪
  - Test suite for `SecureStorageService`
  - Test suite for `Validators`
  - Test coverage tracking setup
  - Mock support with `mockito`

#### Documentation
- **Comprehensive README** 📚
  - Installation instructions
  - Configuration guide
  - API documentation
  - Testing guide
  - Build and release instructions
  - Troubleshooting section

- **Code Documentation**
  - Inline code comments
  - Function documentation
  - Architecture documentation

### 🔧 Changed

#### API Configuration
- Replaced hardcoded `localhost:8000` with configurable environment URLs
- Improved API endpoint management
- Better error handling for API calls

#### Token Management
- Updated `TokenService` to use `SecureStorageService` internally
- Backward compatible migration for existing users
- Enhanced logging for auth operations

#### Dependencies
- Added `flutter_secure_storage: ^9.2.2`
- Added `hive_flutter: ^1.1.0`
- Added `mockito: ^5.4.4` (dev)
- Added `build_runner: ^2.4.13` (dev)
- Removed unused: `boxes`, `freezed`, `iconify_flutter_plus`

### 🐛 Fixed
- Fixed security vulnerability with plain text token storage
- Fixed API localhost issue on physical devices
- Fixed missing error handling in several services
- Fixed code duplication in UI components

### 🗑️ Removed
- Removed unused dependencies (`boxes`, `freezed`, `iconify_flutter_plus`)
- Removed deprecated code patterns
- Cleaned up unused imports

### 📊 Improvements

#### Performance
- Implemented caching to reduce API calls
- Optimized image loading with `cached_network_image`
- Reduced app startup time

#### Code Quality
- Added comprehensive error handling
- Improved code organization
- Consistent coding style
- Better separation of concerns

#### Security
- Encrypted storage for sensitive data
- Token validation and expiry checking
- Secure API communication

---

## [1.0.0] - 2025-09-XX - Initial Release

### ✨ Features
- User authentication (Login/Logout)
- News feed with search
- Course catalog
- Photo gallery
- Student profile management
- About page
- Custom bottom navigation
- Splash screen
- Beautiful UI with animations
- Lao language support

### 📱 Platforms
- Android support
- iOS support
- Responsive design

### 🎨 UI/UX
- Material Design
- Google Fonts (Noto Sans Lao)
- Custom animations
- Glassmorphic design elements

---

## Upgrade Guide

### From 1.0.0 to 1.1.0

#### 1. Update Dependencies
```bash
flutter pub get
```

#### 2. Update API Configuration
Open `lib/config/environment.dart` and set your API URLs:
```dart
case Environment.development:
  return 'http://YOUR_IP:8000/api'; // Replace with your IP
```

#### 3. Data Migration
The app will automatically migrate your data from old storage to secure storage on first run. No action needed.

#### 4. Test
```bash
flutter test
flutter run
```

---

## Known Issues

### Version 1.1.0
- None

### Version 1.0.0
- ❌ **FIXED in 1.1.0**: Tokens stored in plain text (security issue)
- ❌ **FIXED in 1.1.0**: API using localhost (doesn't work on devices)
- ❌ **FIXED in 1.1.0**: No offline support
- ❌ **FIXED in 1.1.0**: Missing tests

---

## Coming Soon

### Version 1.3.0 (Planned)
- [ ] Push notifications
- [ ] Dark mode
- [ ] Multi-language support (English, Thai)
- [ ] Enhanced accessibility features
- [ ] Integration tests
- [ ] E2E tests

### Version 1.3.0 (Future)
- [ ] Chat feature
- [ ] Course enrollment
- [ ] Grade tracking
- [ ] Attendance monitoring
- [ ] Calendar integration

---

## Contributors

- **Development Team** - Initial work and v1.1.0 improvements
- **BIBOL Staff** - Requirements and testing
- **AI Assistant** - Code review and improvements

---

## Questions?

For questions about changes, please contact:
- Email: dev@bibol.edu.la
- GitHub Issues: [Create an issue](../../issues)