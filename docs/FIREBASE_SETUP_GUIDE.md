# 🔥 Firebase Setup Guide for BIBOL App

This guide will help you set up Firebase Cloud Messaging (FCM) for push notifications in the BIBOL app.

---

## 📋 Prerequisites

- Flutter SDK installed
- Firebase CLI installed (`npm install -g firebase-tools`)
- FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)
- Firebase account (https://console.firebase.google.com)
- Android Studio / Xcode configured

---

## 🚀 Setup Steps

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project**
3. Enter project name: `BIBOL` or `bibol-app`
4. Enable Google Analytics (optional)
5. Click **Create project**

---

### Step 2: Install Firebase CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Add to PATH (if needed)
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

---

### Step 3: Configure Firebase for Flutter

Run FlutterFire configuration command:

```bash
# In your project root directory
flutterfire configure
```

This will:
1. Ask you to select/create a Firebase project
2. Select platforms (Android, iOS)
3. Generate `firebase_options.dart` file
4. Configure both platforms automatically

**Output:**
```
✓ Firebase project selected
✓ Platforms configured
✓ firebase_options.dart created
```

---

### Step 4: Android Configuration

#### 4.1 Update `android/build.gradle`

```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### 4.2 Update `android/app/build.gradle`

```gradle
// At the top
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

// At the bottom
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        // ...
        minSdkVersion 21  // FCM requires min SDK 21
    }
}
```

#### 4.3 Update `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
    <application>
        <!-- ... existing code ... -->
        
        <!-- Firebase Messaging Service -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Notification channel (optional) -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="bibol_channel" />
    </application>

    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
</manifest>
```

---

### Step 5: iOS Configuration

#### 5.1 Enable Push Notifications in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Add **Push Notifications**
6. Add **Background Modes**
   - Check **Remote notifications**

#### 5.2 Update `ios/Runner/Info.plist`

```xml
<dict>
    <!-- ... existing keys ... -->
    
    <!-- Firebase Messaging -->
    <key>FirebaseAppDelegateProxyEnabled</key>
    <false/>
</dict>
```

#### 5.3 Update `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import Firebase
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    
    // Request notification permissions
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle APNs token
  override func application(_ application: UIApplication, 
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}
```

---

### Step 6: Update `lib/main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:BIBOL/services/notifications/push_notification_service.dart';
import 'firebase_options.dart';

// Background message handler (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize push notifications
  await PushNotificationService.initialize(
    onMessage: (RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
    },
    onTokenRefresh: (String token) {
      print('FCM Token refreshed: $token');
      // TODO: Send token to your backend
    },
  );
  
  runApp(const MyApp());
}
```

---

### Step 7: Test Push Notifications

#### Option 1: Firebase Console

1. Go to Firebase Console → Cloud Messaging
2. Click **Send your first message**
3. Enter notification title and text
4. Click **Send test message**
5. Enter your FCM token (get from app logs)
6. Click **Test**

#### Option 2: Command Line (curl)

```bash
# Get your Server Key from Firebase Console → Project Settings → Cloud Messaging

curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Test Notification",
      "body": "This is a test message from BIBOL"
    },
    "data": {
      "type": "news",
      "id": "123"
    }
  }'
```

#### Option 3: Backend API

Send from your Node.js backend:

```javascript
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccountKey),
});

// Send notification
const message = {
  notification: {
    title: 'New News Article',
    body: 'Check out the latest news from BIBOL',
  },
  data: {
    type: 'news',
    id: '456',
  },
  token: deviceFCMToken,
};

admin.messaging().send(message)
  .then((response) => {
    console.log('Successfully sent message:', response);
  })
  .catch((error) => {
    console.log('Error sending message:', error);
  });
```

---

## 🔧 Configuration Options

### Notification Channels (Android)

Create custom notification channels:

```dart
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'bibol_high_importance', // id
  'High Importance Notifications', // name
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
```

### Custom Notification Sound

1. Add sound file to:
   - Android: `android/app/src/main/res/raw/notification.mp3`
   - iOS: Xcode → Add Files to "Runner" → notification.caf

2. Use in notification:
```dart
const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  'bibol_channel',
  'BIBOL Notifications',
  sound: RawResourceAndroidNotificationSound('notification'),
);
```

---

## 🐛 Troubleshooting

### Issue 1: Notifications not received

**Check:**
- FCM token is being generated
- Device has internet connection
- Notification permissions granted
- Firebase project configured correctly
- google-services.json / GoogleService-Info.plist in place

**Solution:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Issue 2: iOS notifications not working

**Check:**
- Push Notifications capability enabled in Xcode
- APNs certificate configured in Firebase Console
- Device is not in Do Not Disturb mode
- App has notification permissions

**Solution:**
1. Go to Firebase Console → Project Settings → Cloud Messaging
2. Upload APNs certificate or configure APNs key
3. Rebuild iOS app

### Issue 3: Background notifications not working

**Check:**
- Background message handler is top-level function
- Background Modes enabled in Xcode (iOS)
- App not force-closed (iOS doesn't deliver to force-closed apps)

**Solution:**
```dart
// Ensure background handler is annotated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ...
}
```

### Issue 4: Token not refreshing

**Solution:**
```dart
// Listen to token refresh
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  print('Token refreshed: $newToken');
  // Send to your backend
});
```

---

## 📱 Platform-Specific Notes

### Android

- **Minimum SDK:** 21 (Android 5.0)
- **Notification Channels:** Required for Android 8.0+
- **Foreground Service:** Required for background location
- **Battery Optimization:** May prevent notifications on some devices

### iOS

- **APNs Certificate:** Required for production
- **Development vs Production:** Different certificates
- **Sandbox vs Production:** Configure in Firebase Console
- **Background Limitations:** System-controlled delivery

---

## 🔐 Security Best Practices

1. **Never commit service account keys** to version control
2. **Use environment variables** for sensitive data
3. **Validate notification data** on backend before sending
4. **Rate limit** notification sending
5. **Use topics** instead of storing all device tokens
6. **Rotate server keys** regularly
7. **Monitor** for suspicious activity

---

## 📊 Monitoring & Analytics

### Firebase Console

- **Cloud Messaging Dashboard:** View delivery rates
- **Crashlytics:** Monitor notification-related crashes
- **Analytics:** Track notification engagement

### Custom Logging

```dart
import 'package:BIBOL/utils/logger.dart';

// Log notification events
AppLogger.info('Notification sent to topic: $topic', tag: 'PUSH');
AppLogger.success('Notification delivered', tag: 'PUSH');
AppLogger.error('Notification failed', tag: 'PUSH', error: e);
```

---

## 🚀 Advanced Features

### Topic Subscriptions

```dart
// Subscribe to topics
await PushNotificationService.subscribeToTopic('news');
await PushNotificationService.subscribeToTopic('announcements');

// Unsubscribe
await PushNotificationService.unsubscribeFromTopic('news');
```

### Conditional Delivery

Send to specific user segments:

```javascript
const message = {
  notification: {
    title: 'Student Announcement',
  },
  condition: "'student' in topics && 'grade-12' in topics",
};
```

### Data-Only Messages

```dart
// Send data without notification
const message = {
  data: {
    type: 'sync',
    timestamp: Date.now().toString(),
  },
  token: deviceToken,
};
```

---

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- [Firebase Console](https://console.firebase.google.com)
- [APNs Overview](https://developer.apple.com/documentation/usernotifications)

---

## ✅ Checklist

Before going to production:

- [ ] Firebase project created
- [ ] FlutterFire configured
- [ ] Android configured (google-services.json)
- [ ] iOS configured (GoogleService-Info.plist)
- [ ] Push notifications tested on real devices
- [ ] APNs certificate uploaded (iOS production)
- [ ] Background notifications working
- [ ] Token refresh handling implemented
- [ ] Backend integrated for sending notifications
- [ ] Error handling implemented
- [ ] Analytics configured
- [ ] Documentation updated

---

**Need help?** Contact the development team or check Firebase support.
