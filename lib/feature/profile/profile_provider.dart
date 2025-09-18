import 'dart:io';

import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/profile/profile_model.dart';
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
