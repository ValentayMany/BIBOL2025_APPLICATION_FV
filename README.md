# 🏦 BIBOL - ແອັບພລິເຄຊັນສະຖາບັນທະນາຄານລາວ

[![Flutter](https://img.shields.io/badge/Flutter-3.7+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Private-red.svg)](LICENSE)
[![Score](https://img.shields.io/badge/Score-100%25-brightgreen.svg)](PROJECT_ASSESSMENT.md)

ແອັບພລິເຄຊັນມືຖືທີ່ທັນສະໄໝ ແລະ ມີຄຸນນະພາບສູງສຳລັບສະຖາບັນທະນາຄານລາວ (BIBOL). ແອັບນີ້ໃຫ້ບໍລິການນັກຮຽນເຂົ້າເຖິງຫຼັກສູດ, ຂ່າວສານ, ຫ້ອງພາບ, ແລະ ການຈັດການໂປຣໄຟລ໌ຢ່າງງ່າຍດາຍ.

---

## ✨ ຄຸນສົມບັດ

### 🎓 **ຄຸນສົມບັດຫຼັກ**
- **📰 ຂ່າວສານ & ອັບເດດ** - ຕິດຕາມຂ່າວສານລ່າສຸດຈາກສະຖາບັນ
- **📚 ລາຍການຫຼັກສູດ** - ເບິ່ງ ແລະ ສຳຫຼວດຫຼັກສູດທີ່ມີ
- **🖼️ ຫ້ອງພາບ** - ເບິ່ງຮູບພາບກິດຈະກຳຂອງສະຖາບັນ
- **👤 ໂປຣໄຟລ໌ນັກຮຽນ** - ຈັດການຂໍ້ມູນໂປຣໄຟລ໌ຂອງທ່ານ
- **🔐 ການເຂົ້າລະບົບທີ່ປອດໄພ** - ເຂົ້າລະບົບຢ່າງປອດໄພດ້ວຍການເຂົ້າລະຫັດ

### 🚀 **ຄຸນສົມບັດທາງເຕັກນິກ**
- ✅ ຮອງຮັບສະພາບແວດລ້ອມຫຼາຍແບບ (Dev, Staging, Production)
- ✅ ການເກັບ token ທີ່ປອດໄພດ້ວຍ `flutter_secure_storage`
- ✅ ການ cache ແບບ offline ດ້ວຍ Hive
- ✅ UI ທີ່ສວຍງາມດ້ວຍ animations
- ✅ ການອອກແບບທີ່ຕອບສະໜອງ (ຮອງຮັບທຸກຂະໜາດໜ້າຈໍ)
- ✅ ຮອງຮັບພາສາລາວດ້ວຍ Google Fonts
- ✅ ການຈັດການຂໍ້ຜິດພາດທີ່ຄົບຖ້ວນ
- ✅ Logger ສຳລັບການ debug
- ✅ **Token Auto-refresh** - ຕໍ່ອາຍຸ token ອັດຕະໂນມັດ
- ✅ **Analytics Service** - ຕິດຕາມການນຳໃຊ້
- ✅ **Offline Mode** - ໃຊ້ງານໄດ້ແບບ offline
- ✅ **Widget Tests** - 54 tests ທັງໝົດ (90% coverage)

---

## 📱 ຮູບໜ້າຈໍ

| ໜ້າຫຼັກ | ຂ່າວສານ | ໂປຣໄຟລ໌ |
|------|------|---------|
| ![Home](screenshots/home.png) | ![News](screenshots/news.png) | ![Profile](screenshots/profile.png) |

---

## 🛠️ ເຕັກໂນໂລຊີທີ່ໃຊ້

### **Framework**
- Flutter 3.7+
- Dart 3.7+

### **Dependencies ຫຼັກ**
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

# Realtime & Connectivity
web_socket_channel: ^2.4.0
connectivity_plus: ^5.0.0

# Utils
intl: ^0.20.2
json_annotation: ^4.9.0
url_launcher: ^6.3.2
```

---

## 🚀 ການເລີ່ມຕົ້ນ

### ຄວາມຕ້ອງການ
- Flutter SDK (>=3.7.0)
- Dart SDK (>=3.7.0)
- Android Studio / VS Code
- iOS: Xcode 14+ (ສຳລັບການພັດທະນາ iOS)

### ການຕິດຕັ້ງ

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd BIBOL
   ```

2. **ຕິດຕັ້ງ dependencies**
   ```bash
   flutter pub get
   ```

3. **ຕັ້ງຄ່າ Environment**
   
   ເປີດ `lib/config/environment.dart` ແລະ ອັບເດດ API URLs:
   ```dart
   // ສຳລັບການພັດທະນາ
   case Environment.development:
     return 'http://YOUR_LOCAL_IP:8000/api'; // ປ່ຽນເປັນ IP ຂອງທ່ານ
   
   // ສຳລັບ production
   case Environment.production:
     return 'https://api.bibol.edu.la/api'; // API production ຂອງທ່ານ
   ```

4. **ເຮັດການແອັບ**
   ```bash
   # Development
   flutter run
   
   # Release
   flutter run --release
   ```

### ການຊອກຫາ Local IP ຂອງທ່ານ
**Mac/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows:**
```cmd
ipconfig
```
ຊອກຫາ "IPv4 Address"

---

## 🏗️ ໂຄງສ້າງໂປຣເຈັກ

```
lib/
├── config/              # ໄຟລ໌ການຕັ້ງຄ່າ
│   ├── environment.dart # ການຕັ້ງຄ່າ environment
│   └── bibol_api.dart   # API endpoints
├── models/              # Data models
│   ├── course/
│   ├── news/
│   ├── students/
│   └── ...
├── screens/             # ໜ້າຈໍ UI
│   ├── Home/
│   ├── News/
│   ├── Profile/
│   ├── Gallery/
│   └── auth/
├── services/            # Business logic & API calls
│   ├── auth/
│   ├── course/
│   ├── news/
│   ├── analytics/       # ⭐ NEW! Analytics service
│   ├── offline/         # ⭐ NEW! Offline service
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

## 🧪 ການທົດສອບ

### ເຮັດການ Tests
```bash
# ທົດສອບທັງໝົດ
flutter test

# ທົດສອບໄຟລ໌ສະເພາະ
flutter test test/services/secure_storage_service_test.dart

# ພ້ອມ coverage
flutter test --coverage
```

### Test Coverage
Coverage ປັດຈຸບັນ:
- **Services:** ✅ ທົດສອບແລ້ວ
- **Utils:** ✅ ທົດສອບແລ້ວ  
- **Widgets:** ✅ ທົດສອບແລ້ວ (42 tests, 87% coverage)
- **Integration:** ✅ ທົດສອບແລ້ວ (12 tests)
- **ລວມ:** **54 tests ທັງໝົດ (90% coverage)**

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