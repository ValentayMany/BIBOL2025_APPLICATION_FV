# 🌙 Dark Mode - คู่มือการใช้งาน

## 📁 ไฟล์ที่เพิ่ม/แก้ไข

```
lib/
├── theme/
│   └── app_theme.dart                     ← UPDATED! เพิ่ม dark theme
├── providers/
│   └── theme_provider.dart                ← NEW! จัดการ theme state
├── widgets/
│   └── settings/
│       └── theme_toggle_widget.dart       ← NEW! Toggle button
└── main.dart                              ← UPDATED! รองรับ theme switching
```

---

## 🎯 ฟีเจอร์ที่ได้

### 1. ✅ **Light & Dark Themes**
- Light theme - สำหรับตอนกลางวัน
- Dark theme - สบายตาตอนกลางคืน
- System theme - ตามการตั้งค่าระบบ

### 2. ✅ **Theme Persistence**
- บันทึก theme preference ใน SharedPreferences
- เปิดแอปใหม่จะใช้ theme เดิม

### 3. ✅ **Smooth Transitions**
- Animation ที่นุ่มนวลเมื่อสลับ theme
- ไม่กระตุก, ไม่สะดุด

### 4. ✅ **Beautiful UI Components**
- Toggle button สวยงาม
- Theme selection card
- Theme selection dialog

---

## 🚀 วิธีใช้งาน

### 1. Toggle Theme (แบบง่าย)

```dart
// lib/screens/Profile/profile_page.dart

import 'package:BIBOL/widgets/settings/theme_toggle_widget.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ໂປຣໄຟລ'),
        actions: [
          // ✅ เพิ่ม toggle button ที่ AppBar
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: ThemeToggleWidget(),
          ),
        ],
      ),
      body: YourContent(),
    );
  }
}
```

### 2. Theme Toggle Card (แบบสวย)

```dart
// lib/screens/Profile/profile_page.dart

import 'package:BIBOL/widgets/settings/theme_toggle_widget.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // ... other settings ...
          
          // ✅ Theme toggle card
          Padding(
            padding: EdgeInsets.all(16),
            child: ThemeToggleCard(),
          ),
          
          // ... more settings ...
        ],
      ),
    );
  }
}
```

### 3. Theme Selection Dialog (แบบเต็ม)

```dart
// lib/screens/Profile/profile_page.dart

import 'package:BIBOL/widgets/settings/theme_toggle_widget.dart';

class ProfilePage extends StatelessWidget {
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ThemeSelectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('ເລືອກໂໝດສີ'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context),
          ),
        ],
      ),
    );
  }
}
```

### 4. Programmatic Theme Change

```dart
import 'package:provider/provider.dart';
import 'package:BIBOL/providers/theme_provider.dart';

// ใน widget
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

// Toggle theme
themeProvider.toggleTheme();

// Set specific theme
themeProvider.setLightMode();
themeProvider.setDarkMode();
themeProvider.setSystemTheme();

// Check current theme
if (themeProvider.isDarkMode) {
  print('Dark mode is enabled');
}
```

### 5. Access Theme Colors

```dart
// ใน widget, ใช้ theme colors แบบนี้
Container(
  color: Theme.of(context).scaffoldBackgroundColor,
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.bodyLarge,
  ),
)

// หรือใช้ ColorScheme
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Icon(
    Icons.home,
    color: Theme.of(context).colorScheme.onPrimary,
  ),
)
```

---

## 🎨 Color Palette

### Light Theme Colors
```dart
Primary Color:     #07325D (น้ำเงินเข้ม)
Secondary Color:   #0A4A85 (น้ำเงิน)
Accent Color:      #10B981 (เขียว)
Background:        #FFFFFF (ขาว)
Card:              #FAFBFF (ขาวอ่อน)
Text Primary:      #07325D (น้ำเงินเข้ม)
Text Secondary:    #6B7280 (เทา)
```

### Dark Theme Colors
```dart
Primary Color:     #0A4A85 (น้ำเงิน)
Secondary Color:   #07325D (น้ำเงินเข้ม)
Accent Color:      #10B981 (เขียว)
Background:        #121212 (ดำ)
Surface:           #1E1E1E (เทาเข้ม)
Card:              #2C2C2C (เทา)
Text Primary:      #E5E7EB (ขาวนวล)
Text Secondary:    #9CA3AF (เทาอ่อน)
```

---

## 📱 ตัวอย่างการใช้งานในหน้าต่างๆ

### Profile Page

```dart
// lib/screens/Profile/profile_page.dart

import 'package:BIBOL/widgets/settings/theme_toggle_widget.dart';
import 'package:provider/provider.dart';
import 'package:BIBOL/providers/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('ໂປຣໄຟລ'),
        actions: [
          // Simple toggle in AppBar
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: ThemeToggleWidget(showLabel: false),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // User info card
          _buildUserInfoCard(),
          
          SizedBox(height: 16),
          
          // Theme toggle card
          ThemeToggleCard(),
          
          SizedBox(height: 16),
          
          // Settings section
          _buildSettingsSection(context),
        ],
      ),
    );
  }
}
```

### Settings Page

```dart
// lib/screens/Settings/settings_page.dart

import 'package:BIBOL/widgets/settings/theme_toggle_widget.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ການຕັ້ງຄ່າ')),
      body: ListView(
        children: [
          // Theme section
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ຮູບລັກສະນະ',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16),
                ThemeToggleCard(),
              ],
            ),
          ),
          
          Divider(),
          
          // Other settings...
        ],
      ),
    );
  }
}
```

### Home Page (with theme-aware colors)

```dart
// lib/screens/Home/home_page.dart

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ใช้ theme colors แทน hardcode colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Color(0xFF121212), Color(0xFF1E1E1E)]
                : [Colors.white, Color(0xFFFAFBFF)],
          ),
        ),
        child: YourContent(),
      ),
    );
  }
}
```

---

## 🔧 Advanced Usage

### 1. Listen to Theme Changes

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    
    // Listen to theme changes
    final themeProvider = Provider.of<ThemeProvider>(
      context, 
      listen: false,
    );
    
    themeProvider.addListener(() {
      print('Theme changed to: ${themeProvider.themeModeString}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return YourWidget();
  }
}
```

### 2. Conditional Rendering Based on Theme

```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    if (themeProvider.isDarkMode) {
      return DarkVersionWidget();
    } else {
      return LightVersionWidget();
    }
  },
)
```

### 3. Custom Theme-Aware Widget

```dart
class MyThemedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: isDark ? 12 : 8,
            offset: Offset(0, isDark ? 6 : 4),
          ),
        ],
      ),
      child: YourContent(),
    );
  }
}
```

---

## 🧪 Testing

### Test Theme Provider

```dart
// test/providers/theme_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:BIBOL/providers/theme_provider.dart';

void main() {
  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('should start with light mode', () {
      expect(themeProvider.isDarkMode, isFalse);
    });

    test('should toggle theme', () async {
      await themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, isTrue);

      await themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, isFalse);
    });

    test('should set dark mode', () async {
      await themeProvider.setDarkMode();
      expect(themeProvider.isDarkMode, isTrue);
    });

    test('should set light mode', () async {
      await themeProvider.setLightMode();
      expect(themeProvider.isDarkMode, isFalse);
    });
  });
}
```

---

## 📊 Best Practices

### 1. ✅ DO: ใช้ Theme Colors

```dart
// ✅ ดี - ใช้ theme colors
Container(
  color: Theme.of(context).cardColor,
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.bodyLarge,
  ),
)

// ❌ ไม่ดี - hardcode colors
Container(
  color: Colors.white,
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.black),
  ),
)
```

### 2. ✅ DO: ตรวจสอบ Brightness

```dart
// ✅ ดี - ตรวจสอบ theme
final isDark = Theme.of(context).brightness == Brightness.dark;
final shadowColor = isDark 
    ? Colors.black.withOpacity(0.5) 
    : Colors.grey.withOpacity(0.3);
```

### 3. ✅ DO: ใช้ ColorScheme

```dart
// ✅ ดี - ใช้ ColorScheme
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
  ),
  child: Text('Button'),
)
```

### 4. ❌ DON'T: Hardcode Colors

```dart
// ❌ ไม่ดี - สี fixed จะไม่เปลี่ยนตาม theme
Container(
  color: Color(0xFF07325D), // ❌
  child: Text(
    'Text',
    style: TextStyle(color: Colors.white), // ❌
  ),
)
```

---

## 🎯 Migration Guide

### แก้ไข widgets เดิมให้รองรับ dark mode:

#### ก่อน:
```dart
Container(
  color: Colors.white,
  child: Text(
    'Hello',
    style: TextStyle(color: Color(0xFF07325D)),
  ),
)
```

#### หลัง:
```dart
Container(
  color: Theme.of(context).cardColor,
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.bodyLarge,
  ),
)
```

---

## ✅ Checklist

- [x] ✅ อัพเดท `app_theme.dart` เพิ่ม light & dark theme
- [x] ✅ สร้าง `ThemeProvider` จัดการ state
- [x] ✅ สร้าง `ThemeToggleWidget`
- [x] ✅ สร้าง `ThemeToggleCard`
- [x] ✅ สร้าง `ThemeSelectionDialog`
- [x] ✅ อัพเดท `main.dart` รองรับ theme switching
- [ ] ⏳ เพิ่ม toggle ใน Profile page
- [ ] ⏳ แก้ไข hardcoded colors ใน widgets เดิม
- [ ] ⏳ ทดสอบ dark mode ในทุกหน้า

---

## 🎉 สรุป

### ก่อนมี Dark Mode:
```
❌ มีแค่ light mode
❌ สว่างเกินตอนกลางคืน
❌ เปลือง battery
❌ ไม่ทันสมัย
```

### หลังมี Dark Mode:
```
✅ มีทั้ง light และ dark mode
✅ สบายตาตอนกลางคืน
✅ ประหยัด battery (OLED)
✅ ทันสมัย เท่ห์
✅ UX ดีขึ้น
```

---

**Enjoy your beautiful dark mode! 🌙✨**
