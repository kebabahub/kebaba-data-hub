import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Push notifications via Firebase Cloud Messaging.
///
/// INACTIVE until you:
///  1. Create a Firebase project and add the Android app (package name below)
///     and iOS app (bundle ID below).
///  2. Drop the generated google-services.json into android/app/ and
///     GoogleService-Info.plist into ios/Runner/.
///  3. Call `Firebase.initializeApp()` in main.dart before runApp() — it's
///     already wired up there, commented, ready to uncomment once the config
///     files exist.
///  4. On the server side, add a `device_tokens` table + an endpoint that
///     saves the FCM token from registerDeviceToken() below, then have
///     send_notification() (includes/functions.php) also push via FCM's
///     HTTP v1 API when a device token is on file. Ask me to build that
///     server-side half once step 1-3 are done.
class PushService {
  PushService._();
  static final instance = PushService._();

  final _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(const InitializationSettings(android: androidInit, iOS: iosInit));

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _local.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails('kebaba_default', 'Notifications', importance: Importance.high, priority: Priority.high),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }

  /// Call after login — sends the device's FCM token to the server so it can
  /// target this device. Requires the server-side endpoint described above.
  Future<String?> registerDeviceToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null; // Firebase not configured yet — safe no-op.
    }
  }
}
