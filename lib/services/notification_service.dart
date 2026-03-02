import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Service for handling Firebase Cloud Messaging (FCM) and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _initialized;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission for notifications
      await _requestPermission();

      // Get FCM token
      await _getFCMToken();

      // Set up message handlers
      _setupMessageHandlers();

      _initialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
      rethrow;
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permission');
    } else {
      debugPrint('User declined or has not accepted notification permission');
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint('FCM Token refreshed: $newToken');
      // TODO: Update token in Firestore when it refreshes
    });
  }

  /// Set up message handlers for foreground, background, and terminated states
  void _setupMessageHandlers() {
    // Handle foreground messages (when app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.messageId}');
      _showLocalNotification(message);
    });

    // Handle background messages (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened app: ${message.messageId}');
      // TODO: Navigate to appropriate screen based on notification data
    });

    // Check if app was opened from a terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state: ${message.messageId}');
        // TODO: Navigate to appropriate screen based on notification data
      }
    });
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Handle notification tap and navigate to appropriate screen
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}

/// Top-level function for handling background messages
/// Must be a top-level function, not a class method
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // TODO: Handle background message processing
}

