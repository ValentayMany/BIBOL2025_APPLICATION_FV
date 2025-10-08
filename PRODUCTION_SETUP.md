# 🚀 Production Setup Guide

## ✅ Pre-Production Checklist

### **🔴 Critical (ต้องทำ)**

#### 1. เปลี่ยน Environment
**File:** `lib/config/environment.dart` (line 18)
```dart
// เปลี่ยนจาก
static Environment current = Environment.development;

// เป็น
static Environment current = Environment.production;
```

#### 2. ใส่ Production API URL
**File:** `lib/config/environment.dart` (line 30, 42)
```dart
case Environment.production:
  return 'https://YOUR-PRODUCTION-API.com/api';  // เปลี่ยนเป็น URL จริง
```

---

### **🟡 Important (ควรทำ)**

#### 3. Enable ProGuard
**File:** `android/app/build.gradle`
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        signingConfig signingConfigs.release
    }
}
```

#### 4. Setup Signing Config
**File:** `android/app/build.gradle`
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=path/to/your/keystore.jks
```

#### 5. Update Version
**File:** `pubspec.yaml`
```yaml
version: 1.0.0+1  # Format: major.minor.patch+buildNumber
```

---

### **🟢 Good to Have (ควรมี)**

#### 6. Tests
สร้าง folder `test/` และเพิ่ม tests:
- Unit tests
- Widget tests
- Integration tests

#### 7. Remove Debug Code
ค้นหาและลบ:
```dart
print('...');           // ❌ ลบ
debugPrint('...');      // ❌ ลบ
// TODO comments        // ❌ แก้ให้เสร็จ
```

#### 8. Add Crashlytics/Analytics
```yaml
dependencies:
  firebase_crashlytics: ^latest
  firebase_analytics: ^latest
```

---

## 🏗️ Build Commands

### **Android APK:**
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### **Android App Bundle (Play Store):**
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### **iOS:**
```bash
flutter build ios --release
```

---

## 🧪 Testing Production Build

### 1. Install APK on Device
```bash
flutter install
# หรือ
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 2. Test All Features
- [ ] Login works
- [ ] Logout works
- [ ] News loading
- [ ] Courses loading
- [ ] Gallery works
- [ ] Profile works
- [ ] Offline mode works
- [ ] No crashes
- [ ] Performance good

---

## 📱 App Store Preparation

### **Google Play Store:**
1. Create app in Play Console
2. Upload `app-release.aab`
3. Fill app details
4. Add screenshots
5. Submit for review

### **Apple App Store:**
1. Create app in App Store Connect
2. Upload build via Xcode/Transporter
3. Fill app metadata
4. Add screenshots
5. Submit for review

---

## 🔒 Security Checklist

- [x] ✅ Token encryption (flutter_secure_storage)
- [x] ✅ HTTPS only (check API URLs)
- [x] ✅ No hardcoded secrets
- [ ] ⚠️ SSL Pinning (optional)
- [ ] ⚠️ Root/Jailbreak detection (optional)
- [x] ✅ ProGuard enabled

---

## 📊 Performance Checklist

- [x] ✅ Image caching
- [x] ✅ Data caching (Hive)
- [x] ✅ Lazy loading
- [ ] ⚠️ Performance monitoring (Firebase)
- [ ] ⚠️ Reduce app size

---

## 📝 Before Release

### Final Checks:
```bash
# 1. Clean build
flutter clean
flutter pub get

# 2. Analyze
flutter analyze
# Must show: "No issues found!"

# 3. Test in release mode
flutter run --release

# 4. Build
flutter build appbundle --release

# 5. Test APK on real device
```

### Verify:
- [ ] App name correct
- [ ] App icon correct
- [ ] Version correct
- [ ] All features work
- [ ] No debug logs
- [ ] Permissions correct
- [ ] API URLs correct (Production!)

---

## 🎯 Post-Release

### Monitor:
- Crash reports
- User feedback
- Performance metrics
- API errors

### Update Process:
1. Increment version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Build new release
4. Upload to stores

---

## 🆘 Rollback Plan

If issues found:
1. Unpublish from stores (if possible)
2. Revert to previous version
3. Fix issues
4. Test thoroughly
5. Re-release

---

## ✅ Production Ready Checklist

- [ ] Environment set to `production`
- [ ] Production API URLs configured
- [ ] ProGuard enabled
- [ ] Signing configured
- [ ] Version updated
- [ ] Debug logs removed
- [ ] All features tested
- [ ] No crashes
- [ ] Performance acceptable
- [ ] Built and tested release APK

---

**When all checkboxes are ✅ → Ready for Production! 🚀**
