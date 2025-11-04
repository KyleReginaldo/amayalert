import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/result/result.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

final smtpServer = gmail("amayalert.site@gmail.com", "acrr iajm kafb gdqi");

Future<Result<String>> sendEmailOtp(String email, String phone) async {
  final code = (100000 + (DateTime.now().microsecondsSinceEpoch % 900000))
      .toString();
  final message = Message()
    ..from = Address("amayalert.site@gmail.com", 'Amayalert Support')
    ..recipients.add(email)
    // ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
    // ..bccRecipients.add(Address('bccAddress@example.com'))
    ..subject = 'Your Amayalert verification code'
    ..html =
        """<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial; background:#f6f8fa; color:#333; padding:20px; }
    .card { max-width:600px; margin:0 auto; background:#fff; border-radius:8px; padding:24px; box-shadow:0 2px 8px rgba(35,47,60,0.08); }
    h1 { color:#0d6efd; margin:0 0 8px; font-size:20px; }
    p { margin:0 0 12px; line-height:1.5; }
    .code { display:inline-block; padding:10px 14px; background:#f1f3f5; border-radius:6px; font-family:monospace; font-size:18px; letter-spacing:2px; }
    .footer { font-size:12px; color:#6c757d; margin-top:18px; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Amayalert — One-time code</h1>
    <p>Hi,</p>
    <p>Use the verification code below to continue. It expires in 10 minutes.</p>
    <p class="code">$code</p>
    <p class="footer">If you didn't request this, you can safely ignore this email.</p>
  </div>
</body>
</html>""";
  try {
    final sendReport = await send(message, smtpServer);
    debugPrint('Message sent: $sendReport');

    // Store OTP in appropriate table based on whether phone is provided
    await supabase.from('phone_verifications').insert({
      'phone': phone,
      'code': code,
      'email': email,
      'expires_at': DateTime.now().add(Duration(minutes: 10)).toIso8601String(),
      'user_id': userID,
    });

    return Result.success(code);
  } on MailerException catch (e) {
    return Result.error('Message not sent: ${e.toString()}');
  }
}

Future<Result<String>> sendForgotPasswordOtp(String email) async {
  return sendEmailOtp(email, ''); // Empty phone string for forgot password flow
}
