import 'dart:io';

import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RescueProvider {
  final supabase = Supabase.instance.client;

  Future<Result<String>> createRescue({
    required String userId,
    required CreateRescueRequest request,
  }) async {
    try {
      // Upload attachments if provided
      List<String>? attachmentUrls;
      if (request.attachmentFiles != null &&
          request.attachmentFiles!.isNotEmpty) {
        attachmentUrls = [];
        for (final file in request.attachmentFiles!) {
          final fileName =
              'rescues/${DateTime.now().microsecondsSinceEpoch}_${file.name}';
          await supabase.storage
              .from('files')
              .upload(fileName, File(file.path));
          final url = supabase.storage.from('files').getPublicUrl(fileName);
          attachmentUrls.add(url);
        }
      }

      // Build insert map from request, overriding user and adding server-managed fields
      final insertMap = request.toMap();
      insertMap['user'] = userId;
      if (attachmentUrls != null) {
        insertMap['attachments'] = attachmentUrls;
      }

      debugPrint('Final metadata: ${insertMap['metadata']}');
      final response = await supabase
          .from('rescues')
          .insert({
            ...insertMap,
            'status': 'pending',
            'reported_at': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      return Result.success(response['id']);
    } catch (e) {
      debugPrint('Error creating rescue: $e');
      return Result.error('Failed to create rescue request: ${e.toString()}');
    }
  }

  Future<Result<List<Rescue>>> getRescues({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await supabase
          .from('rescues')
          .select('*, user:users(*)')
          .eq('user', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      List<Rescue> rescues = [];
      for (final item in response) {
        final result = RescueMapper.fromMap(item);
        rescues.add(result);
      }
      return Result.success(rescues);
    } catch (e) {
      debugPrint('Error fetching rescues: $e');
      return Result.error('Failed to fetch rescues: ${e.toString()}');
    }
  }

  Future<Result<Rescue>> getRescueById(String id) async {
    try {
      final response = await supabase
          .from('rescues')
          .select('*, user:users(*)')
          .eq('id', id)
          .single();

      final result = RescueMapper.fromMap(response);
      return Result.success(result);
    } catch (e) {
      debugPrint('Error fetching rescue: $e');
      return Result.error('Failed to fetch rescue: ${e.toString()}');
    }
  }

  Future<Result<String>> updateRescueStatus(
    String rescueId,
    RescueStatus status,
  ) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == RescueStatus.completed) {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await supabase.from('rescues').update(updateData).eq('id', rescueId);

      return Result.success('Rescue status updated successfully');
    } catch (e) {
      debugPrint('Error updating rescue status: $e');
      return Result.error('Failed to update rescue status: ${e.toString()}');
    }
  }
}
