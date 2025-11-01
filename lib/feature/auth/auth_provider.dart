import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/dto/user.dto.dart';
import '../../core/result/result.dart';

class AuthProvider {
  Future<Result<String>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        await OneSignal.login(response.user!.id);

        return Result.success('Sign in successful');
      } else {
        return Result.error('Sign in failed');
      }
    } on AuthException catch (e) {
      return Result.error(e.message);
    }
  }

  Future<Result<String>> signUp({CreateUserDTO? dto}) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: dto!.email,
        password: dto.password,
      );
      if (response.user != null) {
        final user = await Supabase.instance.client
            .from('users')
            .insert({'id': response.user!.id, ...dto.toJson()})
            .select()
            .single();
        if (user.isNotEmpty) {
          await OneSignal.login(response.user!.id);
          return Result.success('Sign up successful');
        } else {
          await Supabase.instance.client.auth.signOut();
          await Supabase.instance.client
              .from('users')
              .delete()
              .eq('email', dto.email);
          await Supabase.instance.client.auth.admin.deleteUser(
            response.user!.id,
          );
          return Result.error('Sign up failed');
        }
      } else {
        return Result.error('Sign up failed');
      }
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<String>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return Result.error('No user is currently signed in');
      }

      // First, verify the current password by re-authenticating
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      if (response.session == null) {
        return Result.error('Current password is incorrect');
      }

      // If re-authentication is successful, update the password
      final updateResponse = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (updateResponse.user != null) {
        return Result.success('Password changed successfully');
      } else {
        return Result.error('Failed to update password');
      }
    } on AuthException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An error occurred: ${e.toString()}');
    }
  }

  Future<Result<String>> resetPassword({required String email}) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.amayalert.app://reset-password',
      );
      return Result.success('Password reset email sent successfully');
    } on AuthException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An error occurred: ${e.toString()}');
    }
  }

  Future<Result<String>> updatePassword({required String newPassword}) async {
    try {
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        return Result.success('Password updated successfully');
      } else {
        return Result.error('Failed to update password');
      }
    } on AuthException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An error occurred: ${e.toString()}');
    }
  }
}
