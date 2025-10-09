import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationHandler {
  static void initialize() {
    // Handle notification click when app is in background/closed
    OneSignal.Notifications.addClickListener(_handleNotificationClick);

    // Handle notification received when app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener(
      _handleForegroundNotification,
    );
  }

  static void _handleNotificationClick(OSNotificationClickEvent event) {
    debugPrint('🔔 Notification clicked: ${event.notification.additionalData}');

    final data = event.notification.additionalData;
    if (data != null) {
      _handleNotificationData(data);
    }
  }

  static void _handleForegroundNotification(
    OSNotificationWillDisplayEvent event,
  ) {
    debugPrint(
      '🔔 Foreground notification: ${event.notification.additionalData}',
    );

    // Display the notification even when app is in foreground
    event.notification.display();

    final data = event.notification.additionalData;
    if (data != null) {
      // Handle notification data for potential navigation
      debugPrint('Notification data: $data');
    }
  }

  static void _handleNotificationData(Map<String, dynamic> data) {
    final type = data['type'];

    switch (type) {
      case 'chat_message':
        _handleChatMessage(data);
        break;
      case 'alert':
        _handleAlert(data);
        break;
      case 'broadcast':
        _handleBroadcast(data);
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  static void _handleChatMessage(Map<String, dynamic> data) {
    final senderId = data['sender_id'];
    final senderName = data['sender_name'];

    if (senderId != null && senderName != null) {
      // Navigate to chat screen
      final context = _getCurrentContext();
      if (context != null) {
        context.router.push(
          ChatRoute(otherUserId: senderId, otherUserName: senderName),
        );
      }
    }
  }

  static void _handleAlert(Map<String, dynamic> data) {
    final alertType = data['alert_type'];

    // Handle different types of alerts
    switch (alertType) {
      case 'evacuation':
        _navigateToMap();
        break;
      case 'weather':
        _navigateToHome();
        break;
      default:
        _navigateToHome();
    }
  }

  static void _handleBroadcast(Map<String, dynamic> data) {
    // Handle broadcast notifications
    _navigateToHome();
  }

  static void _navigateToHome() {
    final context = _getCurrentContext();
    if (context != null) {
      context.router.navigate(const HomeRoute());
    }
  }

  static void _navigateToMap() {
    final context = _getCurrentContext();
    if (context != null) {
      context.router.navigate(const MapRoute());
    }
  }

  static BuildContext? _getCurrentContext() {
    // You'll need to implement a way to get the current context
    // This could be through a global navigator key or app state management
    return null; // TODO: Implement proper context retrieval
  }

  /// Show in-app notification when app is in foreground
  static void showInAppNotification(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: onTap != null
            ? SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: onTap,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
