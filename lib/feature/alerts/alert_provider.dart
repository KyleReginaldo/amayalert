import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/alerts/alert_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlertProvider {
  final supabase = Supabase.instance.client;

  Future<Result<String>> createAlert({
    required CreateAlertRequest request,
  }) async {
    try {
      final response = await supabase
          .from('alert')
          .insert(request.toJson())
          .select()
          .single();

      if (response.isNotEmpty) {
        return Result.success('Alert created successfully');
      } else {
        return Result.error('Failed to create alert');
      }
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<List<Alert>>> getAlerts() async {
    try {
      final response = await supabase
          .from('alert')
          .select()
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      final alerts = response.map((json) => AlertMapper.fromMap(json)).toList();
      return Result.success(alerts);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<List<Alert>>> getActiveAlerts() async {
    try {
      final response = await supabase
          .from('alert')
          .select()
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(5); // Get only latest 5 active alerts

      final alerts = response.map((json) => AlertMapper.fromMap(json)).toList();
      return Result.success(alerts);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<Alert>> getAlert(int alertId) async {
    try {
      final response = await supabase
          .from('alert')
          .select()
          .eq('id', alertId)
          .single();

      final alert = AlertMapper.fromMap(response);
      return Result.success(alert);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<String>> updateAlert({
    required int alertId,
    required UpdateAlertRequest request,
  }) async {
    try {
      final updateData = request.toMap();

      final response = await supabase
          .from('alert')
          .update(updateData)
          .eq('id', alertId)
          .select()
          .single();

      if (response.isNotEmpty) {
        return Result.success('Alert updated successfully');
      } else {
        return Result.error('Failed to update alert');
      }
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  Future<Result<String>> deleteAlert(int alertId) async {
    try {
      // Soft delete by setting deleted_at timestamp
      await supabase
          .from('alert')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', alertId);

      return Result.success('Alert deleted successfully');
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Subscribe to real-time alert updates
  RealtimeChannel subscribeToAlerts({
    required Function(Alert alert) onNewAlert,
    required Function(Alert alert) onAlertUpdated,
    required Function(int alertId) onAlertDeleted,
  }) {
    final channel = supabase
        .channel('alerts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'alert',
          callback: (payload) {
            try {
              final alert = AlertMapper.fromMap(payload.newRecord);
              onNewAlert(alert);
            } catch (e) {
              debugPrint('Error parsing new alert: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'alert',
          callback: (payload) {
            try {
              final alert = AlertMapper.fromMap(payload.newRecord);
              onAlertUpdated(alert);
            } catch (e) {
              debugPrint('Error parsing updated alert: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'alert',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'deleted_at',
            value: null,
          ),
          callback: (payload) {
            try {
              if (payload.newRecord['deleted_at'] != null) {
                final alertId = payload.newRecord['id'] as int;
                onAlertDeleted(alertId);
              }
            } catch (e) {
              debugPrint('Error parsing deleted alert: $e');
            }
          },
        );

    channel.subscribe();
    return channel;
  }
}
