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
        return Result.success('Sign in successful');
      } else {
        return Result.error('Sign in failed');
      }
    } catch (e) {
      return Result.error(e.toString());
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
}
