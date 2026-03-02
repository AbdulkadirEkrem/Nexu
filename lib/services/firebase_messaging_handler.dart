import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level function for handling background messages
/// Must be a top-level function, not a class method
/// This function must be at the top level (not inside a class) to work properly
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification?.title}');
  // TODO: Handle background message processing
  // You can add custom logic here, such as updating local database,
  // showing local notifications, etc.
}

