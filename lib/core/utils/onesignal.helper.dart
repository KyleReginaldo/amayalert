import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future sendNotif({
  required List<String> users,
  required String title,
  required String content,
}) async {
  await http.post(
    Uri.parse('https://api.onesignal.com/notifications?c=push'),
    body: jsonEncode({
      "app_id": '1811210d-e4b7-4304-8cd5-3de7a1da8e26',
      "contents": {"en": content},
      "headings": {"en": title},
      "target_channel": 'push',
      "huawei_category": 'MARKETING',
      "huawei_msg_type": 'message',
      "priority": 10,
      "ios_interruption_level": 'active',
      "ios_badgeType": 'None',
      "ttl": 259200,
      "include_aliases": {"external_id": users},
    }),
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer Key ${dotenv.get('ONESIGNAL_REST_API_KEY')}',
    },
  );
}
