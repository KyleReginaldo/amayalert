import 'dart:convert';
import 'dart:io';

import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/profile/profile_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/dto/user.dto.dart';

class ProfileProvider {
  Future<Result<Profile>> getUserProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      final profile = ProfileMapper.fromMap(response);
      return Result.success(profile);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    }
  }

  /// Request an OTP for phone change via the external OTP server (or fallback
  /// to Supabase Functions). The server is expected to insert the
  /// `phone_verifications` row and send the email; we do not return the code.
  Future<Result<String>> requestPhoneChangeOtp({
    required String userId,
    required String newPhone,
  }) async {
    try {
      debugPrint(
        'requestPhoneChangeOtp called for userId=$userId newPhone=$newPhone',
      );
      // Option A: client-side SMTP send (development/testing). Enable by
      // setting CLIENT_SMTP=true in .env. This will create the verification
      // row via the Supabase client and send the email directly from the app.
      final clientSmtp = dotenv.env['CLIENT_SMTP'] == 'true';
      debugPrint('CLIENT_SMTP flag: $clientSmtp');
      if (clientSmtp) {
        final code = (100000 + (DateTime.now().microsecondsSinceEpoch % 900000))
            .toString();
        final expiresAt = DateTime.now()
            .add(const Duration(minutes: 10))
            .toIso8601String();

        // Insert verification row using the authenticated supabase client
        final insertResp = await Supabase.instance.client
            .from('phone_verifications')
            .insert({
              'user_id': userId,
              'phone': newPhone,
              'code': code,
              'expires_at': expiresAt,
              'verified': false,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
        debugPrint('Inserted phone_verifications row: $insertResp');

        // Send email directly from the client using mailer package
        // final mailer = SmtpMailer.fromEnv();
        final profileResp = await Supabase.instance.client
            .from('users')
            .select('email')
            .eq('id', userId)
            .single();
        final recipient = profileResp['email'] as String?;
        if (recipient == null) {
          debugPrint('User email not found for userId=$userId');
          return Result.error('User email not found');
        }

        debugPrint('Sending OTP code=$code to recipient=$recipient');

        // final sendRes = await mailer.sendOtp(to: recipient, code: code);
        // debugPrint(
        //   'mailer.sendOtp result: isError=${sendRes.isError} error=${sendRes.error}',
        // );
        // if (sendRes.isError) return Result.error(sendRes.error);

        // Optionally return the code for development debugging
        if (dotenv.env['DEV_SHOW_OTP'] == 'true') {
          return Result.success(code);
        }

        return Result.success('OTP sent');
      }

      // Option B: call external OTP server or Supabase Function
      final accessToken =
          Supabase.instance.client.auth.currentSession?.accessToken;
      if (accessToken == null) return Result.error('Not authenticated');

      final otpServer = dotenv.env['OTP_SERVER_URL'];
      final supabaseUrl = dotenv.get('SUPABASE_URL');
      String functionsUrl;
      if (otpServer != null && otpServer.isNotEmpty) {
        functionsUrl = otpServer;
      } else {
        // Try to derive the correct Supabase Functions endpoint from
        // SUPABASE_URL. Typical Supabase Functions host looks like:
        //   https://<project>.functions.supabase.co/<fn>
        // while SUPABASE_URL is usually https://<project>.supabase.co
        try {
          final uri = Uri.parse(supabaseUrl);
          final host = uri.host; // e.g. myproj.supabase.co
          if (host.endsWith('.supabase.co')) {
            final functionsHost = host.replaceFirst(
              '.supabase.co',
              '.functions.supabase.co',
            );
            functionsUrl = '${uri.scheme}://$functionsHost/send_otp_email';
          } else {
            // Fallback: older or custom installs may expose functions under
            // /functions/v1 on the main url
            functionsUrl = '$supabaseUrl/functions/v1/send_otp_email';
          }
        } catch (_) {
          functionsUrl = '$supabaseUrl/functions/v1/send_otp_email';
        }
      }
      // Helpful debug output to surface the exact endpoint we try to call
      print('OTP request endpoint: $functionsUrl');

      debugPrint(
        'Calling OTP endpoint with accessToken present, functionsUrl=$functionsUrl',
      );
      final resp = await http.post(
        Uri.parse(functionsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'newPhone': newPhone}),
      );
      debugPrint(
        'OTP endpoint responded: status=${resp.statusCode} body=${resp.body}',
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return Result.success('OTP sent');
      }

      return Result.error(
        'Failed to request OTP: ${resp.statusCode} ${resp.body}',
      );
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  /// Verify OTP: client-side check against `phone_verifications` table and
  /// update user's phone_number on success.
  Future<Result<String>> verifyPhoneChangeOtp({
    required String userId,
    required String newPhone,
    required String code,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final query = await Supabase.instance.client
          .from('phone_verifications')
          .select()
          .eq('user_id', userId)
          .eq('phone', newPhone)
          .eq('code', code)
          .eq('verified', false)
          .gte('expires_at', now)
          .limit(1)
          .order('created_at', ascending: false);

      final results = query as List<dynamic>;
      if (results.isNotEmpty) {
        final verification = results.first;

        // Update user's phone number
        await Supabase.instance.client
            .from('users')
            .update({'phone_number': newPhone})
            .eq('id', userId);

        // Mark verification as verified
        await Supabase.instance.client
            .from('phone_verifications')
            .update({'verified': true})
            .eq('id', verification['id']);

        return Result.success('Phone number updated');
      }

      return Result.error('Invalid or expired code');
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  Future<Result<String>> updateUserProfile({
    required String userId,
    required UpdateUserDTO dto,
  }) async {
    try {
      String? imageUrl;
      if (dto.imageFile != null) {
        final response = await supabase.storage
            .from('files')
            .upload(
              '${DateTime.now().microsecondsSinceEpoch.toString()}_${dto.imageFile!.name}',
              File(dto.imageFile!.path),
            );
        imageUrl = supabase.storage.from('').getPublicUrl(response);
      }
      final response = await Supabase.instance.client
          .from('users')
          .update({
            ...dto.toJson(),
            if (imageUrl != null) 'profile_picture': imageUrl,
          })
          .eq('id', userId)
          .select()
          .single();
      if (response.isNotEmpty) {
        return Result.success('Profile updated successfully');
      } else {
        return Result.error('Failed to update profile');
      }
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    }
  }
}
