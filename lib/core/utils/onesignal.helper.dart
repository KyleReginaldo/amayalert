import 'dart:convert';

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
      'Authorization':
          'Bearer Key os_v2_app_daiscdpew5bqjdgvhxt2dwuoezejniwvkbqew7n3qi4mmdpk4rw3vzdevzbfb5vvcsqxeht3kwdrzpqgwoojeocveyluuj3aipdgabi',
    },
  );
}
