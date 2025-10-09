import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RescueProvider {
  final supabase = Supabase.instance.client;

  Future<Result<String>> createRescue({
    required String userId,
    required CreateRescueDTO dto,
  }) async {
    try {
      // Prepare metadata
      final metadata = Map<String, dynamic>.from(dto.metadata);
      debugPrint('Final metadata: $metadata');

      // Create rescue request
      final rescueRequest = CreateRescueRequest(
        title: dto.title,
        description: dto.description,
        lat: dto.lat,
        lng: dto.lng,
        priority: dto.priority.value,
        scheduledFor: dto.scheduledFor,
        user: userId,
        metadata: metadata,
      );

      // Insert into database
      final response = await supabase
          .from('rescues')
          .insert({
            'title': rescueRequest.title,
            'description': rescueRequest.description,
            'lat': rescueRequest.lat,
            'lng': rescueRequest.lng,
            'priority': rescueRequest.priority,
            'status': 'pending',
            'reported_at': DateTime.now().toIso8601String(),
            'scheduled_for': rescueRequest.scheduledFor?.toIso8601String(),
            'user': rescueRequest.user,
            'metadata': rescueRequest.metadata,
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
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await supabase
          .from('rescues')
          .select('*')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final rescues = (response as List).map((item) {
        return Rescue(
          id: item['id'],
          title: item['title'],
          description: item['description'],
          lat: item['lat']?.toDouble(),
          lng: item['lng']?.toDouble(),
          status: RescueStatus.values.firstWhere(
            (s) => s.name == item['status'],
            orElse: () => RescueStatus.pending,
          ),
          priority: item['priority'] ?? 1,
          reportedAt: DateTime.parse(item['reported_at']),
          scheduledFor: item['scheduled_for'] != null
              ? DateTime.parse(item['scheduled_for'])
              : null,
          completedAt: item['completed_at'] != null
              ? DateTime.parse(item['completed_at'])
              : null,
          user: item['user'],
          metadata: item['metadata'],
          createdAt: DateTime.parse(item['created_at']),
          updatedAt: DateTime.parse(item['updated_at']),
        );
      }).toList();

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
          .select('*')
          .eq('id', id)
          .single();

      final rescue = Rescue(
        id: response['id'],
        title: response['title'],
        description: response['description'],
        lat: response['lat']?.toDouble(),
        lng: response['lng']?.toDouble(),
        status: RescueStatus.values.firstWhere(
          (s) => s.name == response['status'],
          orElse: () => RescueStatus.pending,
        ),
        priority: response['priority'] ?? 1,
        reportedAt: DateTime.parse(response['reported_at']),
        scheduledFor: response['scheduled_for'] != null
            ? DateTime.parse(response['scheduled_for'])
            : null,
        completedAt: response['completed_at'] != null
            ? DateTime.parse(response['completed_at'])
            : null,
        user: response['user'],
        metadata: response['metadata'],
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: DateTime.parse(response['updated_at']),
      );

      return Result.success(rescue);
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
