import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'activity_model.dart';

class ActivityRepository extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  final List<Activity> _activities = [];
  ActivityStats? _stats;
  bool _isLoading = false;
  String? _error;
  ActivityType? _selectedFilter;

  List<Activity> get activities => _selectedFilter == null
      ? _activities
      : _activities
            .where((activity) => activity.type == _selectedFilter)
            .toList();
  ActivityStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ActivityType? get selectedFilter => _selectedFilter;

  void setFilter(ActivityType? filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> loadActivities() async {
    try {
      _isLoading = true;
      _error = null;
      _activities.clear();
      notifyListeners();

      await _testSupabaseConnection();

      await Future.wait([
        _loadPostActivities(),
        _loadAlertActivities(),
        _loadEvacuationActivities(),
        _loadRescueActivities(),
      ]);

      _activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _calculateStats();

      debugPrint('Loaded ${_activities.length} total activities');

      if (_activities.isEmpty) {
        debugPrint('No data found in any tables, adding test data...');
        _addTestData();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading activities: $e');
      _addTestData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPostActivities() async {
    try {
      debugPrint('Loading post activities...');

      dynamic response;
      try {
        response = await _supabase
            .from('posts')
            .select('*, users(full_name)')
            .order('created_at', ascending: false)
            .limit(50);
      } catch (joinError) {
        debugPrint('Join query failed, trying simple query: $joinError');
        response = await _supabase
            .from('posts')
            .select('*')
            .order('created_at', ascending: false)
            .limit(50);
      }

      debugPrint('Posts response: ${response.length} items');
      final postActivities = (response as List).map((post) {
        return Activity(
          id: post['id'].toString(),
          type: ActivityType.post,
          title: 'New Post',
          description: post['content'] ?? 'No content',
          location: null,
          createdAt: DateTime.parse(post['created_at']),
          userId: post['user'],
          userName: post['users']?['full_name'],
          metadata: {
            'post_id': post['id'],
            'media_url': post['media_url'],
            'visibility': post['visibility'],
          },
        );
      }).toList();

      _activities.addAll(postActivities);
      debugPrint('Added ${postActivities.length} post activities');
    } catch (e) {
      debugPrint('Error loading post activities: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _loadAlertActivities() async {
    try {
      debugPrint('Loading alert activities...');
      final response = await _supabase
          .from('alert')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);

      debugPrint('Alerts response: ${response.length} items');
      final alertActivities = (response as List).map((alert) {
        return Activity(
          id: alert['id'].toString(),
          type: ActivityType.alert,
          title: alert['title'] ?? 'Emergency Alert',
          description: _buildAlertDescription(alert),
          location: null,
          createdAt: DateTime.parse(alert['created_at']),
          userId: 'system',
          userName: 'Emergency System',
          metadata: {
            'alert_id': alert['id'],
            'alert_level': alert['alert_level'],
          },
        );
      }).toList();

      _activities.addAll(alertActivities);
      debugPrint('Added ${alertActivities.length} alert activities');
    } catch (e) {
      debugPrint('Error loading alert activities: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _loadEvacuationActivities() async {
    try {
      debugPrint('Loading evacuation activities...');

      dynamic response;
      try {
        response = await _supabase
            .from('evacuation_centers')
            .select('*, users(full_name)')
            .order('created_at', ascending: false)
            .limit(50);
      } catch (joinError) {
        debugPrint('Join query failed, trying simple query: $joinError');
        response = await _supabase
            .from('evacuation_centers')
            .select('*')
            .order('created_at', ascending: false)
            .limit(50);
      }

      debugPrint('Evacuation centers response: ${response.length} items');
      final evacuationActivities = (response as List).map((evacuation) {
        return Activity(
          id: evacuation['id'].toString(),
          type: ActivityType.evacuation,
          title: 'Evacuation Center: ${evacuation['name']}',
          description: _buildEvacuationDescription(evacuation),
          location: evacuation['address'],
          createdAt: DateTime.parse(evacuation['created_at']),
          userId: evacuation['created_by'] ?? 'system',
          userName: evacuation['users']?['full_name'] ?? 'Emergency Management',
          metadata: {
            'evacuation_id': evacuation['id'],
            'capacity': evacuation['capacity'],
            'current_occupancy': evacuation['current_occupancy'],
            'status': evacuation['status'],
            'latitude': evacuation['latitude'],
            'longitude': evacuation['longitude'],
            'contact_name': evacuation['contact_name'],
            'contact_phone': evacuation['contact_phone'],
          },
        );
      }).toList();

      _activities.addAll(evacuationActivities);
      debugPrint('Added ${evacuationActivities.length} evacuation activities');
    } catch (e) {
      debugPrint('Error loading evacuation activities: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _loadRescueActivities() async {
    try {
      debugPrint('Loading rescue activities...');

      dynamic response;
      try {
        response = await _supabase
            .from('rescues')
            .select('*, users(full_name)')
            .order('created_at', ascending: false)
            .limit(50);
      } catch (joinError) {
        debugPrint('Join query failed, trying simple query: $joinError');
        response = await _supabase
            .from('rescues')
            .select('*')
            .order('created_at', ascending: false)
            .limit(50);
      }

      debugPrint('Rescues response: ${response.length} items');
      final rescueActivities = (response as List).map((rescue) {
        return Activity(
          id: rescue['id'].toString(),
          type: ActivityType.rescue,
          title: rescue['title'] ?? 'Rescue Operation',
          description: _buildRescueDescription(rescue),
          location: rescue['lat'] != null && rescue['lng'] != null
              ? 'Lat: ${rescue['lat']}, Lng: ${rescue['lng']}'
              : null,
          createdAt: DateTime.parse(rescue['created_at']),
          userId: rescue['user'] ?? 'system',
          userName: rescue['users']?['full_name'] ?? 'Rescue Team',
          metadata: {
            'rescue_id': rescue['id'],
            'status': rescue['status'],
            'priority': rescue['priority'],
            'reported_at': rescue['reported_at'],
            'scheduled_for': rescue['scheduled_for'],
            'completed_at': rescue['completed_at'],
            'latitude': rescue['lat'],
            'longitude': rescue['lng'],
          },
        );
      }).toList();

      _activities.addAll(rescueActivities);
      debugPrint('Added ${rescueActivities.length} rescue activities');
    } catch (e) {
      debugPrint('Error loading rescue activities: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  void _calculateStats() {
    final posts = _activities.where((a) => a.type == ActivityType.post).length;
    final alerts = _activities
        .where((a) => a.type == ActivityType.alert)
        .length;
    final evacuations = _activities
        .where((a) => a.type == ActivityType.evacuation)
        .length;
    final rescues = _activities
        .where((a) => a.type == ActivityType.rescue)
        .length;

    _stats = ActivityStats(
      totalPosts: posts,
      totalAlerts: alerts,
      totalEvacuations: evacuations,
      totalRescues: rescues,
      totalActivities: _activities.length,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    _activities.clear();
    _stats = null;
    loadActivities();
  }

  /// Delete a user activity based on its type and ID
  Future<bool> deleteActivity(Activity activity, String currentUserId) async {
    try {
      // Check if user owns the activity
      if (activity.userId != currentUserId && activity.userId != 'system') {
        throw Exception('You can only delete your own activities');
      }

      bool success = false;

      switch (activity.type) {
        case ActivityType.post:
          success = await _deletePostActivity(activity);
          break;
        case ActivityType.alert:
          success = await _deleteAlertActivity(activity);
          break;
        case ActivityType.evacuation:
          success = await _deleteEvacuationActivity(activity);
          break;
        case ActivityType.rescue:
          success = await _deleteRescueActivity(activity);
          break;
      }

      if (success) {
        // Remove from local list
        _activities.removeWhere((a) => a.id == activity.id);
        _calculateStats();
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint('Error deleting activity: $e');
      return false;
    }
  }

  Future<bool> _deletePostActivity(Activity activity) async {
    try {
      final postId = int.parse(activity.id);

      // Check if post exists and user owns it
      final postCheck = await _supabase
          .from('posts')
          .select('user, media_url')
          .eq('id', postId)
          .single();

      if (postCheck['user'] != activity.userId) {
        throw Exception('You can only delete your own posts');
      }

      // Delete associated media if exists
      final mediaUrl = postCheck['media_url'] as String?;
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(mediaUrl);
          final filePath = uri.pathSegments.skip(4).join('/');
          await _supabase.storage.from('files').remove([filePath]);
        } catch (e) {
          debugPrint('Failed to delete media file: $e');
        }
      }

      // Delete post
      await _supabase.from('posts').delete().eq('id', postId);
      return true;
    } catch (e) {
      debugPrint('Error deleting post activity: $e');
      return false;
    }
  }

  Future<bool> _deleteAlertActivity(Activity activity) async {
    try {
      final alertId = int.parse(activity.id);
      await _supabase.from('alert').delete().eq('id', alertId);
      return true;
    } catch (e) {
      debugPrint('Error deleting alert activity: $e');
      return false;
    }
  }

  Future<bool> _deleteEvacuationActivity(Activity activity) async {
    try {
      final evacuationId = int.parse(activity.id);
      await _supabase
          .from('evacuation_centers')
          .delete()
          .eq('id', evacuationId);
      return true;
    } catch (e) {
      debugPrint('Error deleting evacuation activity: $e');
      return false;
    }
  }

  Future<bool> _deleteRescueActivity(Activity activity) async {
    try {
      final rescueId = int.parse(activity.id);
      await _supabase.from('rescues').delete().eq('id', rescueId);
      return true;
    } catch (e) {
      debugPrint('Error deleting rescue activity: $e');
      return false;
    }
  }

  /// Delete all activities for a specific user
  Future<Map<String, int>> deleteAllUserActivities(String userId) async {
    final results = {
      'posts': 0,
      'alerts': 0,
      'evacuations': 0,
      'rescues': 0,
      'errors': 0,
    };

    // Get all user activities
    final userActivities = _activities
        .where((a) => a.userId == userId)
        .toList();

    try {
      for (final activity in userActivities) {
        try {
          bool success = false;

          switch (activity.type) {
            case ActivityType.post:
              success = await _deletePostActivity(activity);
              if (success) results['posts'] = results['posts']! + 1;
              break;
            case ActivityType.alert:
              success = await _deleteAlertActivity(activity);
              if (success) results['alerts'] = results['alerts']! + 1;
              break;
            case ActivityType.evacuation:
              success = await _deleteEvacuationActivity(activity);
              if (success) results['evacuations'] = results['evacuations']! + 1;
              break;
            case ActivityType.rescue:
              success = await _deleteRescueActivity(activity);
              if (success) results['rescues'] = results['rescues']! + 1;
              break;
          }

          if (!success) {
            results['errors'] = results['errors']! + 1;
          }
        } catch (e) {
          debugPrint('Error deleting activity ${activity.id}: $e');
          results['errors'] = results['errors']! + 1;
        }
      }

      // Remove deleted activities from local list
      _activities.removeWhere((a) => a.userId == userId);
      _calculateStats();
      notifyListeners();

      return results;
    } catch (e) {
      debugPrint('Error deleting user activities: $e');
      results['errors'] = userActivities.length;
      return results;
    }
  }

  Future<void> testIndividualTables() async {
    debugPrint('=== Testing Individual Tables ===');

    try {
      final posts = await _supabase
          .from('posts')
          .select('id, content, created_at')
          .limit(1);
      debugPrint('Posts table: ${posts.length} records found');
    } catch (e) {
      debugPrint('Posts table error: $e');
    }

    try {
      final alerts = await _supabase
          .from('alert')
          .select('id, title, created_at')
          .limit(1);
      debugPrint('Alert table: ${alerts.length} records found');
    } catch (e) {
      debugPrint('Alert table error: $e');
    }

    try {
      final evacuations = await _supabase
          .from('evacuation_centers')
          .select('id, name, created_at')
          .limit(1);
      debugPrint(
        'Evacuation centers table: ${evacuations.length} records found',
      );
    } catch (e) {
      debugPrint('Evacuation centers table error: $e');
    }

    try {
      final rescues = await _supabase
          .from('rescues')
          .select('id, title, created_at')
          .limit(1);
      debugPrint('Rescues table: ${rescues.length} records found');
    } catch (e) {
      debugPrint('Rescues table error: $e');
    }

    debugPrint('=== End Table Tests ===');
  }

  String _buildEvacuationDescription(Map<String, dynamic> evacuation) {
    final capacity = evacuation['capacity'];
    final occupancy = evacuation['current_occupancy'] ?? 0;
    final status = evacuation['status'] ?? 'active';

    String description = '';

    if (capacity != null) {
      final availableSpaces = capacity - occupancy;
      description += 'Capacity: $capacity | Available: $availableSpaces | ';
    }

    description += 'Status: ${status.toString().toUpperCase()}';

    if (evacuation['contact_name'] != null) {
      description += ' | Contact: ${evacuation['contact_name']}';
    }

    return description;
  }

  String _buildRescueDescription(Map<String, dynamic> rescue) {
    final status = rescue['status'] ?? 'unknown';
    final priority = rescue['priority'] ?? 0;
    final description = rescue['description'] ?? 'Emergency rescue operation';

    String result = description;

    result += ' | Status: ${status.toString().toUpperCase()}';
    result += ' | Priority: $priority';

    if (rescue['scheduled_for'] != null) {
      final scheduledTime = DateTime.parse(rescue['scheduled_for']).toLocal();
      result +=
          ' | Scheduled: ${scheduledTime.day}/${scheduledTime.month}/${scheduledTime.year}';
    }

    if (rescue['completed_at'] != null) {
      final completedTime = DateTime.parse(rescue['completed_at']).toLocal();
      result +=
          ' | Completed: ${completedTime.day}/${completedTime.month}/${completedTime.year}';
    }

    return result;
  }

  String _buildAlertDescription(Map<String, dynamic> alert) {
    final content = alert['content'] ?? 'No description available';
    final alertLevel = alert['alert_level'];

    String description = content;

    if (alertLevel != null && alertLevel.toString().isNotEmpty) {
      description += ' | Level: ${alertLevel.toString().toUpperCase()}';
    }

    return description;
  }

  void _addTestData() {
    debugPrint('Adding test data for UI verification...');
    final testActivities = [
      Activity(
        id: 'test_post_1',
        type: ActivityType.post,
        title: 'Test Post',
        description: 'This is a test post to verify the UI is working',
        location: null,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        userId: 'test_user',
        userName: 'Test User',
      ),
      Activity(
        id: 'test_alert_1',
        type: ActivityType.alert,
        title: 'Test Alert',
        description: 'This is a test alert | Level: HIGH',
        location: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        userId: 'system',
        userName: 'Emergency System',
      ),
      Activity(
        id: 'test_evacuation_1',
        type: ActivityType.evacuation,
        title: 'Test Evacuation Center',
        description: 'Capacity: 100 | Available: 50 | Status: ACTIVE',
        location: 'Test Location',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        userId: 'system',
        userName: 'Emergency Management',
      ),
      Activity(
        id: 'test_rescue_1',
        type: ActivityType.rescue,
        title: 'Test Rescue Operation',
        description:
            'Emergency rescue test | Status: IN_PROGRESS | Priority: 5',
        location: 'Test Coordinates',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        userId: 'system',
        userName: 'Rescue Team',
      ),
    ];

    _activities.addAll(testActivities);
    _calculateStats();
    debugPrint('Added ${testActivities.length} test activities');
  }

  Future<void> _testSupabaseConnection() async {
    try {
      debugPrint('Testing Supabase connection...');
      final user = _supabase.auth.currentUser;
      debugPrint('Current user: ${user?.id ?? 'No user'}');

      // Test a simple query
      final testResponse = await _supabase
          .from('users')
          .select('count')
          .limit(1);

      debugPrint('Connection test successful: $testResponse');
    } catch (e) {
      debugPrint('Connection test failed: $e');
    }
  }
}
