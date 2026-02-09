import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Service for handling Firebase Cloud Messaging and local notifications
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize Firebase and local notifications
  Future<void> initialize() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Get FCM token for this device
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Show a local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'tapto_channel',
      'Tapto Notifications',
      channelDescription: 'Notifications from Tapto',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      showLocalNotification(
        title: notification.title ?? 'Tapto',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle when user taps on notification and app was in background
  void _handleMessageOpenedApp(RemoteMessage message) {
    // Handle navigation based on message data
    _handleNotificationNavigation(message.data);
  }

  /// Handle when user taps on local notification
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      // Parse payload and navigate
      _handleNotificationNavigation(_parsePayload(response.payload!));
    }
  }

  /// Parse notification payload
  Map<String, dynamic> _parsePayload(String payload) {
    try {
      // Simple key-value parsing (you might want to use JSON)
      final Map<String, dynamic> data = {};
      final pairs = payload.split(',');
      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          data[keyValue[0].trim()] = keyValue[1].trim();
        }
      }
      return data;
    } catch (e) {
      return {};
    }
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id'];

    // This would typically use a navigation service or router
    // For now, we'll just print the navigation intent
    switch (type) {
      case 'order':
        print('Navigate to order details: $id');
        break;
      case 'product':
        print('Navigate to product details: $id');
        break;
      case 'cart':
        print('Navigate to cart');
        break;
      default:
        print('Unknown notification type: $type');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed
  await Firebase.initializeApp();

  // Handle background message
  print('Background message: ${message.notification?.title}');
}