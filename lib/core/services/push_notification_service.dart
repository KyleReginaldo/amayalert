import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PushNotificationService {
  static const String _oneSignalAppId = '1811210d-e4b7-4304-8cd5-3de7a1da8e26';
  static const String _baseUrl = 'https://api.onesignal.com';

  // Get OneSignal REST API Key from environment or fallback to hardcoded value
  static String get _restApiKey =>
      'os_v2_app_daiscdpew5bqjdgvhxt2dwuoezejniwvkbqew7n3qi4mmdpk4rw3vzdevzbfb5vvcsqxeht3kwdrzpqgwoojeocveyluuj3aipdgabi';

  /// Send a push notification to a specific user
  static Future<bool> sendMessageNotification({
    required String receiverUserId,
    required String senderName,
    required String messageContent,
    String? attachmentUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.onesignal.com/notifications?c=push'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization':
              'Bearer Key os_v2_app_daiscdpew5bqjdgvhxt2dwuoezejniwvkbqew7n3qi4mmdpk4rw3vzdevzbfb5vvcsqxeht3kwdrzpqgwoojeocveyluuj3aipdgabi',
        },
        body: jsonEncode({
          'app_id': _oneSignalAppId,
          'headings': {'en': 'New message from $senderName'},
          'contents': {
            'en': messageContent.length > 100
                ? '${messageContent.substring(0, 100)}...'
                : messageContent,
          },
          "target_channel": "push",
          "huawei_category": "MARKETING",
          "huawei_msg_type": "message",
          "priority": 10,
          "ios_interruption_level": "active",
          "ios_badgeType": "None",
          "ttl": 259200,
          "big_picture": attachmentUrl,
          'include_aliases': {
            'external_id': [receiverUserId],
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint(
          '✅ Push notification sent successfully: ${responseData['id']}',
        );
        return true;
      } else {
        debugPrint(
          '❌ Failed to send push notification: ${response.statusCode}',
        );
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending push notification: $e');
      return false;
    }
  }

  /// Send a push notification to multiple users
  static Future<bool> sendBulkMessageNotification({
    required List<String> receiverUserIds,
    required String senderName,
    required String messageContent,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications?c=push'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer Key $_restApiKey',
        },
        body: jsonEncode({
          'app_id': _oneSignalAppId,
          'headings': {'en': 'New message from $senderName'},
          'contents': {
            'en': messageContent.length > 100
                ? '${messageContent.substring(0, 100)}...'
                : messageContent,
          },
          'target_channel': 'push',
          'huawei_category': 'MARKETING',
          'huawei_msg_type': 'message',
          'priority': 10,
          'ios_interruption_level': 'active',
          'ios_badgeType': 'Increase',
          'ttl': 259200,
          'include_aliases': {'external_id': receiverUserIds},
          'data': {
            'type': 'chat_message',
            'sender_id': additionalData?['sender_id'],
            'sender_name': senderName,
            ...?additionalData,
          },
          'android_sound': 'message_sound',
          'ios_sound': 'message_sound.wav',
          'android_accent_color': 'FF4955FF',
          'small_icon': 'ic_notification',
          'large_icon': 'ic_launcher',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint(
          '✅ Bulk push notification sent successfully: ${responseData['id']}',
        );
        return true;
      } else {
        debugPrint(
          '❌ Failed to send bulk push notification: ${response.statusCode}',
        );
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending bulk push notification: $e');
      return false;
    }
  }

  /// Send a general alert notification
  static Future<bool> sendAlertNotification({
    required List<String> receiverUserIds,
    required String title,
    required String content,
    String alertType = 'general',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications?c=push'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode({
          'app_id': _oneSignalAppId,
          'headings': {'en': title},
          'contents': {'en': content},
          'target_channel': 'push',
          'huawei_category': 'MARKETING',
          'huawei_msg_type': 'message',
          'priority': 10,
          'ios_interruption_level': 'critical', // Higher priority for alerts
          'ios_badgeType': 'Increase',
          'ttl': 259200,
          'include_aliases': {'external_id': receiverUserIds},
          'data': {
            'type': 'alert',
            'alert_type': alertType,
            ...?additionalData,
          },
          'android_sound': 'alert_sound',
          'ios_sound': 'alert_sound.wav',
          'android_accent_color': 'FFFF4444', // Red for alerts
          'small_icon': 'ic_alert',
          'large_icon': 'ic_launcher',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint(
          '✅ Alert notification sent successfully: ${responseData['id']}',
        );
        return true;
      } else {
        debugPrint(
          '❌ Failed to send alert notification: ${response.statusCode}',
        );
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending alert notification: $e');
      return false;
    }
  }

  /// Send notification to all users (broadcast)
  static Future<bool> sendBroadcastNotification({
    required String title,
    required String content,
    String? imageUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final notificationBody = <String, dynamic>{
        'app_id': _oneSignalAppId,
        'headings': {'en': title},
        'contents': {'en': content},
        'target_channel': 'push',
        'huawei_category': 'MARKETING',
        'huawei_msg_type': 'message',
        'priority': 10,
        'ios_interruption_level': 'active',
        'ios_badgeType': 'Increase',
        'ttl': 259200,
        'included_segments': ['All'], // Send to all users
        'data': {'type': 'broadcast', ...?additionalData},
        'android_sound': 'default',
        'ios_sound': 'default',
        'android_accent_color': 'FF4955FF',
        'small_icon': 'ic_notification',
        'large_icon': 'ic_launcher',
      };

      // Add image if provided
      if (imageUrl != null) {
        notificationBody['big_picture'] = imageUrl;
        notificationBody['ios_attachments'] = {'id1': imageUrl};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/notifications?c=push'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode(notificationBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint(
          '✅ Broadcast notification sent successfully: ${responseData['id']}',
        );
        return true;
      } else {
        debugPrint(
          '❌ Failed to send broadcast notification: ${response.statusCode}',
        );
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending broadcast notification: $e');
      return false;
    }
  }
}
