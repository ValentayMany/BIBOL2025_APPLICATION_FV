# 🏦 BIBOL - Banking Institute of Lao App

[![Flutter](https://img.shields.io/badge/Flutter-3.7+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Private-red.svg)](LICENSE)

A modern, feature-rich mobile application for the Banking Institute of Laos (BIBOL). This app provides students with easy access to courses, news, gallery, and profile management.

---

## ✨ Features

### 🎓 **Core Features**
- **📰 News & Updates** - Stay updated with the latest news from the institute
- **📚 Course Catalog** - Browse and explore available courses
- **🖼️ Photo Gallery** - View institutional photos and events
- **👤 Student Profile** - Manage your student profile
- **🔐 Secure Authentication** - Login securely with encrypted storage

### 🚀 **Technical Features**
- ✅ Multi-environment support (Dev, Staging, Production)
- ✅ Secure token storage with `flutter_secure_storage`
- ✅ Offline caching with Hive
- ✅ Beautiful UI with animations
- ✅ Responsive design (supports all screen sizes)
- ✅ Lao language support with Google Fonts
- ✅ Comprehensive error handling
- ✅ Logger for debugging

---

## 📱 Screenshots

| Home | News | Profile |
|------|------|---------|
| ![Home](screenshots/home.png) | ![News](screenshots/news.png) | ![Profile](screenshots/profile.png) |

---

## 🛠️ Tech Stack

### **Framework**
- Flutter 3.7+
- Dart 3.7+

### **Key Dependencies**
```yaml
# Networking
http: ^1.5.0
dio: ^5.9.0

# State Management
provider: ^6.1.5+1

# Storage
shared_preferences: ^2.5.3
flutter_secure_storage: ^9.2.2
hive: ^2.2.3
hive_flutter: ^1.1.0

# UI/UX
google_fonts: ^6.1.0
font_awesome_flutter: ^10.7.0
cached_network_image: ^3.4.1
flutter_html: ^3.0.0
animated_splash_screen: ^1.3.0
page_transition: ^2.0.2

# Utils
intl: ^0.20.2
json_annotation: ^4.9.0
url_launcher: ^6.3.2
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.7.0)
- Dart SDK (>=3.7.0)
- Android Studio / VS Code
- iOS: Xcode 14+ (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd BIBOL
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment**
   
   Open `lib/config/environment.dart` and update the API URLs:
   ```dart
   // For development
   case Environment.development:
     return 'http://YOUR_LOCAL_IP:8000/api'; // Replace with your IP
   
   // For production
   case Environment.production:
     return 'https://api.bibol.edu.la/api'; // Your production API
   ```

4. **Run the app**
   ```bash
   # Development
   flutter run
   
   # Release
   flutter run --release
   ```

### Finding Your Local IP
**Mac/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows:**
```cmd
ipconfig
```
Look for "IPv4 Address"

---

## 🏗️ Project Structure

```
lib/
├── config/              # Configuration files
│   ├── environment.dart # Environment configuration
│   └── bibol_api.dart   # API endpoints
├── models/              # Data models
│   ├── course/
│   ├── news/
│   ├── students/
│   └── ...
├── screens/             # UI Screens
│   ├── Home/
│   ├── News/
│   ├── Profile/
│   ├── Gallery/
│   └── auth/
├── services/            # Business logic & API calls
│   ├── auth/
│   ├── course/
│   ├── news/
│   ├── storage/
│   └── ...
├── widgets/             # Reusable widgets
│   ├── common/
│   ├── home_widgets/
│   ├── news_widget/
│   └── ...
├── utils/               # Utility classes
│   ├── logger.dart
│   ├── validators.dart
│   ├── snackbar_utils.dart
│   └── date_utils.dart
├── routes/              # Navigation
│   ├── app_routes.dart
│   └── route_generator.dart
├── theme/               # App theming
│   └── app_theme.dart
└── main.dart            # Entry point
```

---

## 🧪 Testing

### Run Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/services/secure_storage_service_test.dart

# With coverage
flutter test --coverage
```

### Test Coverage
Current test coverage:
- Services: ✅ Tested
- Utils: ✅ Tested
- Widgets: 🚧 In Progress

---

## 🔧 Configuration

### Environment Variables
Change the environment in `lib/config/environment.dart`:
```dart
static Environment current = Environment.development; // or staging, production
```

### API Endpoints
All API endpoints are configured in `lib/config/bibol_api.dart`:
- `ApiConfig` - Main API configuration
- `NewsApiConfig` - News endpoints
- `CourseApiConfig` - Course endpoints
- `GalleryApiConfig` - Gallery endpoints
- `StudentsApiConfig` - Student/Auth endpoints

---

## 📦 Build & Release

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS
```bash
flutter build ios --release
```

---

## 🔐 Security

### Token Storage
- ✅ Uses `flutter_secure_storage` for sensitive data
- ✅ Auto-migration from old `SharedPreferences`
- ✅ Token expiry validation
- ✅ Encrypted storage on both iOS and Android

### API Security
- ✅ HTTPS endpoints (production)
- ✅ Token-based authentication
- ✅ Request timeout handling
- ✅ Retry mechanism for failed requests

---

## 📝 Code Quality

### Linting
```bash
flutter analyze
```

### Formatting
```bash
flutter format lib/
```

### Best Practices
- ✅ Follows Flutter style guide
- ✅ Consistent naming conventions
- ✅ Proper error handling
- ✅ Documented code
- ✅ Reusable components

---

## 🐛 Debugging

### Enable Logging
Logs are automatically enabled in development mode. To view:
```bash
flutter run --verbose
```

### Common Issues

**Issue: `localhost` not working on device**
- Solution: Use your computer's IP address instead of `localhost` in `environment.dart`

**Issue: Secure storage not working**
- iOS: Check keychain settings
- Android: Enable encrypted shared preferences

**Issue: Network timeout**
- Check your internet connection
- Increase timeout in `environment.dart`

---

## 📚 Documentation

### Code Documentation
- [API Configuration](docs/api-configuration.md)
- [Authentication Flow](docs/authentication.md)
- [State Management](docs/state-management.md)
- [Testing Guide](docs/testing.md)

### External Resources
- [Flutter Documentation](https://docs.flutter.dev)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design](https://material.io/design)

---

## 🤝 Contributing

### Development Workflow
1. Create a feature branch
2. Make changes
3. Write/update tests
4. Run tests and linting
5. Submit pull request

### Commit Message Format
```
type: subject

body (optional)

footer (optional)
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## 📄 License

This project is private and proprietary. All rights reserved.

---

## 👥 Team

**Banking Institute of Laos (BIBOL)**
- Email: info@bibol.edu.la
- Website: https://bibol.edu.la

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Open source contributors
- BIBOL staff and students

---

## 📞 Support

For support, please contact:
- Email: support@bibol.edu.la
- Phone: +856 20 XXXX XXXX

---

## 🗺️ Roadmap

### Version 1.1 (Upcoming)
- [ ] Push notifications
- [ ] Offline mode improvements
- [ ] Dark mode
- [ ] Multi-language support (English, Thai)

### Version 1.2 (Future)
- [ ] Chat feature
- [ ] Course enrollment
- [ ] Grade tracking
- [ ] Attendance monitoring

---

**Made with ❤️ for BIBOL students**
