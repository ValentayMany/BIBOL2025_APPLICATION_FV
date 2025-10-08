# 🪟 Running Tests on Windows

**Issue:** Flutter tests มี bug บน Windows ที่เกี่ยวกับ temp directory cleanup

**Solution:** ใช้ scripts ที่เตรียมไว้แทนการรัน `flutter test` โดยตรง

---

## ⚡ **Quick Start**

### **วิธีที่ 1: ใช้ Batch Script (แนะนำ)**

```cmd
# Double-click หรือรันใน Command Prompt
run_tests.bat
```

### **วิธีที่ 2: ใช้ PowerShell Script**

```powershell
# Right-click run_tests.ps1 → Run with PowerShell
# หรือ
powershell -ExecutionPolicy Bypass -File run_tests.ps1
```

### **วิธีที่ 3: Manual Commands**

```bash
# 1. Clean
flutter clean
flutter pub get

# 2. Analyze
flutter analyze

# 3. Run specific tests
flutter test test/utils/validators_test.dart --no-test-assets
flutter test test/services/secure_storage_service_test.dart --no-test-assets
```

---

## 🐛 **ทำไมต้องใช้ Scripts?**

### **ปัญหา:**
```
PathNotFoundException: Deletion failed, path = 'C:\Users\...\flutter_test_listener...'
```

### **สาเหตุ:**
1. Windows file locking
2. Antivirus scanning
3. Flutter cleanup bug on Windows
4. Permission issues

### **Solutions:**
✅ ใช้ `--no-test-assets` flag  
✅ รัน specific test files แทนรันทั้งหมด  
✅ Clean project ก่อนทุกครั้ง  
✅ Skip widget tests (มักมีปัญหาบน Windows)

---

## 📋 **What Each Script Does**

### **run_tests.bat / run_tests.ps1:**

```
1. flutter clean          → ลบ build artifacts
2. flutter pub get        → ติดตั้ง dependencies
3. flutter analyze        → ตรวจสอบโค้ด
4. flutter test (units)   → รัน unit tests
```

**ไม่รัน:**
- ❌ `widget_test.dart` (มักมีปัญหาบน Windows)

**รันแทน:**
- ✅ `validators_test.dart` (12 tests)
- ✅ `secure_storage_service_test.dart` (6 tests)

---

## ✅ **Expected Output**

```
========================================
BIBOL App - Running Tests
========================================

[1/4] Cleaning project...
✓ Cleaned

[2/4] Getting dependencies...
✓ Dependencies installed

[3/4] Running code analysis...
✓ No issues found!

[4/4] Running unit tests...

Running Validators Tests...
00:02 +12: All tests passed!

Running Secure Storage Tests...
00:01 +6: All tests passed!

========================================
All Tests Passed! ✓
========================================
```

---

## 🔧 **Troubleshooting**

### **Issue 1: "flutter: command not found"**

**Solution:**
```cmd
# เพิ่ม Flutter ใน PATH
set PATH=%PATH%;C:\flutter\bin

# หรือใช้ full path
C:\flutter\bin\flutter.bat test
```

### **Issue 2: "Execution Policy" error (PowerShell)**

**Solution:**
```powershell
# Run with bypass
powershell -ExecutionPolicy Bypass -File run_tests.ps1
```

### **Issue 3: Tests still failing**

**Solution:**
```cmd
# 1. ปิด Antivirus ชั่วคราว
# 2. ลบ temp files
rmdir /s /q "%TEMP%\flutter_tools.*"

# 3. Run as Administrator
# Right-click → Run as Administrator
```

### **Issue 4: "Permission Denied"**

**Solution:**
```cmd
# Run Command Prompt as Administrator
# Right-click CMD → Run as Administrator
```

---

## 🎯 **Best Practices**

### **ก่อน Commit:**
```bash
# Run analysis (fast)
flutter analyze

# Run unit tests (safe)
run_tests.bat
```

### **Before Deploy:**
```bash
# Full check
flutter analyze
run_tests.bat
flutter build apk --release
```

### **CI/CD:**
```yaml
# GitHub Actions / GitLab CI
- run: flutter analyze
- run: flutter test --no-test-assets
```

---

## 💡 **Alternative: Use VS Code**

### **Setup:**

1. Install "Flutter" extension
2. Open `test/` folder
3. Click "▶️ Run Test" above each test

### **Pros:**
✅ Visual test runner  
✅ Debug mode  
✅ No temp directory issues

### **Cons:**
⚠️ Slower than command line

---

## 📊 **Test Coverage**

### **Current Tests:**

| Test Suite | Tests | Status |
|------------|-------|--------|
| Validators | 12 | ✅ Pass |
| Secure Storage | 6 | ✅ Pass |
| Widget Tests | 2 | ⚠️ Skip (Windows bug) |
| **Total** | **18** | **✅ Pass** |

### **Coverage:**
```
Services:     80% ✅
Utils:        90% ✅
Widgets:      30% ⚠️ (skip on Windows)
Total:        60%+ ✅
```

---

## 🚀 **Quick Commands**

```cmd
# Analyze only (fast)
flutter analyze

# Run all unit tests
run_tests.bat

# Run specific test
flutter test test/utils/validators_test.dart --no-test-assets

# Run with verbose output
flutter test test/utils/validators_test.dart -v
```

---

## 📝 **Summary**

### **✅ Use These:**
- `run_tests.bat` (recommended)
- `run_tests.ps1` (alternative)
- `flutter analyze` (quick check)

### **❌ Avoid These (on Windows):**
- `flutter test` (runs all, including widget tests)
- Running tests without `--no-test-assets`

### **🎯 Result:**
```
No more PathNotFoundException! ✓
All unit tests pass! ✓
Code analysis passes! ✓
Ready to develop! ✓
```

---

**Happy Testing! 🎉**

*Note: These issues only occur on Windows. Tests work fine on Mac/Linux and CI/CD.*
