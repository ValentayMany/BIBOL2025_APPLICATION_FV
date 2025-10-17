# 🚀 BIBOL App Real-time Implementation Guide

## 📋 Overview
คู่มือการใช้งาน Real-time features สำหรับ BIBOL App ที่มี 3 ตัวเลือกหลัก:

1. **WebSocket** - Real-time แบบทันที
2. **Firebase Realtime Database** - ง่ายต่อการใช้งาน
3. **Smart Polling** - ใช้ได้กับ API ปัจจุบัน

---

## 🔧 การติดตั้ง

### 1. เพิ่ม Dependencies
```yaml
dependencies:
  web_socket_channel: ^3.0.0
  socket_io_client: ^3.0.2
  firebase_database: ^10.4.0  # ถ้าใช้ Firebase
```

### 2. รันคำสั่ง
```bash
flutter pub get
```

---

## 🎯 การใช้งาน

### 1. WebSocket Mode (แนะนำ)
```dart
// เริ่มต้นใช้งาน
final realtimeProvider = RealtimeProvider.instance;
await realtimeProvider.initialize();

// ฟังข่าวสาร real-time
realtimeProvider.newsStream?.listen((news) {
  // อัปเดต UI เมื่อมีข่าวใหม่
});

// ฟังการเปลี่ยนแปลงข้อมูลติดต่อ
realtimeProvider.contactsStream?.listen((contacts) {
  // อัปเดตข้อมูลติดต่อ
});
```

### 2. Smart Polling Mode
```dart
// เริ่มต้น polling
final pollingService = SmartPollingService.instance;
await pollingService.startPolling();

// ฟังการอัปเดตข้อมูล
pollingService.newsStream?.listen((news) {
  // ข้อมูลข่าวอัปเดต
});

// ปรับการตั้งค่า
pollingService.configureIntervals(
  foregroundInterval: Duration(seconds: 30),
  backgroundInterval: Duration(minutes: 5),
);
```

### 3. Firebase Mode
```dart
// เริ่มต้น Firebase
final firebaseService = FirebaseRealtimeService.instance;
await firebaseService.initialize();

// ฟังการเปลี่ยนแปลง
firebaseService.newsStream?.listen((news) {
  // ข่าวใหม่จาก Firebase
});
```

---

## 📱 การใช้งานใน UI

### 1. ใน HomePage
```dart
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initializeRealtime();
  }

  void _initializeRealtime() async {
    final realtimeProvider = RealtimeProvider.instance;
    await realtimeProvider.initialize();
    
    // ฟังข่าวสาร
    realtimeProvider.newsStream?.listen((news) {
      setState(() {
        _latestNews = news;
      });
    });
  }
}
```

### 2. ใน Provider Pattern
```dart
// ใน main.dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RealtimeProvider.instance),
      ],
      child: MyApp(),
    ),
  );
}

// ใน Widget
Consumer<RealtimeProvider>(
  builder: (context, realtimeProvider, child) {
    return Column(
      children: [
        Text('Status: ${realtimeProvider.status}'),
        if (realtimeProvider.isConnected)
          Icon(Icons.wifi, color: Colors.green)
        else
          Icon(Icons.wifi_off, color: Colors.red),
      ],
    );
  },
)
```

---

## ⚙️ การตั้งค่า

### 1. Environment Configuration
```dart
// lib/config/environment.dart
class EnvironmentConfig {
  static const String webBaseUrl = 'https://web2025.bibol.edu.la';
  static const String wsUrl = 'wss://web2025.bibol.edu.la/ws';
  static const bool enableRealtime = true;
  static const RealtimeMode defaultMode = RealtimeMode.auto;
}
```

### 2. App Lifecycle Management
```dart
class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final realtimeProvider = RealtimeProvider.instance;
    
    switch (state) {
      case AppLifecycleState.resumed:
        realtimeProvider.setAppState(true);
        break;
      case AppLifecycleState.paused:
        realtimeProvider.setAppState(false);
        break;
      default:
        break;
    }
  }
}
```

---

## 🔄 การเปลี่ยนโหมด

```dart
// เปลี่ยนเป็น WebSocket
await realtimeProvider.setMode(RealtimeMode.websocket);

// เปลี่ยนเป็น Polling
await realtimeProvider.setMode(RealtimeMode.polling);

// เปลี่ยนเป็น Auto (แนะนำ)
await realtimeProvider.setMode(RealtimeMode.auto);
```

---

## 📊 การตรวจสอบสถานะ

```dart
// ดูสถานะทั้งหมด
final status = realtimeProvider.getDetailedStatus();
print('Real-time Status: $status');

// ดูเฉพาะการเชื่อมต่อ
if (realtimeProvider.isConnected) {
  print('✅ Real-time is active');
} else {
  print('❌ Real-time is disconnected');
}
```

---

## 🛠️ การแก้ไขปัญหา

### 1. WebSocket ไม่เชื่อมต่อ
```dart
// ตรวจสอบ URL
final wsUrl = 'wss://web2025.bibol.edu.la/ws';
print('Testing WebSocket URL: $wsUrl');

// ลองเชื่อมต่อใหม่
await realtimeProvider.reconnect();
```

### 2. Polling ช้าเกินไป
```dart
// ปรับความถี่
pollingService.configureIntervals(
  foregroundInterval: Duration(seconds: 15), // เร็วขึ้น
  backgroundInterval: Duration(minutes: 2),
);
```

### 3. ข้อมูลไม่อัปเดต
```dart
// ตรวจสอบ API response
final news = await NewsService.getNews();
print('API Response: $news');

// ตรวจสอบ hash
print('Current hash: ${_lastNewsHash}');
```

---

## 🎯 ข้อแนะนำ

### 1. สำหรับเริ่มต้น
- ใช้ **Smart Polling** ก่อน เพราะใช้งานง่าย
- ทดสอบกับ API ปัจจุบันได้เลย

### 2. สำหรับ Production
- ใช้ **WebSocket** สำหรับ real-time จริง
- มี fallback เป็น Polling เสมอ

### 3. สำหรับ Performance
- ใช้ **Firebase** ถ้าต้องการ offline support
- ปรับ polling interval ตามการใช้งาน

---

## 📝 Checklist การติดตั้ง

- [ ] เพิ่ม dependencies ใน `pubspec.yaml`
- [ ] รัน `flutter pub get`
- [ ] เพิ่ม Provider ใน `main.dart`
- [ ] เรียกใช้ `RealtimeProvider.instance.initialize()`
- [ ] ฟัง stream ใน UI components
- [ ] ทดสอบการเชื่อมต่อ
- [ ] ตั้งค่า app lifecycle
- [ ] ทดสอบการเปลี่ยนโหมด

---

## 🚀 Next Steps

1. **เริ่มด้วย Smart Polling** - ใช้งานง่ายที่สุด
2. **ทดสอบ WebSocket** - เมื่อ backend พร้อม
3. **พิจารณา Firebase** - ถ้าต้องการ offline support
4. **ปรับแต่ง Performance** - ตามการใช้งานจริง

---

*สร้างโดย AI Assistant สำหรับ BIBOL App*
