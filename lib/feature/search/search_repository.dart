import 'package:amayalert/feature/activity/activity_repository.dart';
import 'package:amayalert/feature/alerts/alert_repository.dart';
import 'package:amayalert/feature/evacuation/evacuation_repository.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:flutter/foundation.dart';

import 'search_model.dart';

class SearchRepository extends ChangeNotifier {
  final PostRepository postRepository;
  final AlertRepository alertRepository;
  final EvacuationRepository evacuationRepository;
  final ActivityRepository activityRepository;

  SearchRepository({
    required this.postRepository,
    required this.alertRepository,
    required this.evacuationRepository,
    required this.activityRepository,
  });

  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  String _currentQuery = '';

  List<SearchResult> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get currentQuery => _currentQuery;

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    _currentQuery = query;
    _isSearching = true;
    _searchResults.clear();
    notifyListeners();

    try {
      final results = <SearchResult>[];

      // Search through posts
      final posts = postRepository.posts;
      for (final post in posts) {
        if (_matchesQuery(post.content, query) ||
            _matchesQuery(post.user.fullName, query)) {
          results.add(
            SearchResult(
              id: post.id.toString(),
              type: SearchResultType.post,
              title: post.user.fullName,
              description: post.content,
              subtitle: 'Post • ${_formatDate(post.createdAt)}',
              metadata: {
                'user_id': post.user.id,
                'created_at': post.createdAt.toIso8601String(),
                'visibility': post.visibility.name,
                'has_media': post.hasMedia,
              },
            ),
          );
        }
      }

      // Search through alerts
      final alerts = alertRepository.alerts;
      for (final alert in alerts) {
        if (_matchesQuery(alert.title, query) ||
            _matchesQuery(alert.description, query) ||
            _matchesQuery(alert.location ?? '', query)) {
          results.add(
            SearchResult(
              id: alert.id.toString(),
              type: SearchResultType.alert,
              title: alert.title,
              description: alert.description,
              subtitle:
                  'Alert • ${alert.level.name.toUpperCase()} • ${_formatDate(alert.createdAt)}',
              metadata: {
                'level': alert.level.name,
                'status': alert.status.name,
                'location': alert.location,
                'latitude': alert.latitude,
                'longitude': alert.longitude,
                'is_active': alert.isActive,
              },
            ),
          );
        }
      }

      // Search through evacuation centers
      final evacuationCenters = evacuationRepository.centers;
      for (final center in evacuationCenters) {
        if (_matchesQuery(center.name, query) ||
            _matchesQuery(center.address, query) ||
            _matchesQuery(center.contactName ?? '', query)) {
          results.add(
            SearchResult(
              id: center.id.toString(),
              type: SearchResultType.evacuation,
              title: center.name,
              description: center.address,
              subtitle: 'Evacuation Center • ${_getEvacuationStatus(center)}',
              metadata: {
                'capacity': center.capacity,
                'current_occupancy': center.currentOccupancy,
                'status': center.status?.name,
                'latitude': center.latitude,
                'longitude': center.longitude,
                'contact_name': center.contactName,
                'contact_phone': center.contactPhone,
              },
            ),
          );
        }
      }

      // Search through activities
      final activities = activityRepository.activities;
      for (final activity in activities) {
        if (_matchesQuery(activity.title, query) ||
            _matchesQuery(activity.description, query) ||
            _matchesQuery(activity.location ?? '', query) ||
            _matchesQuery(activity.userName ?? '', query)) {
          results.add(
            SearchResult(
              id: activity.id,
              type: SearchResultType.activity,
              title: activity.title,
              description: activity.description,
              subtitle:
                  '${activity.type.name.toUpperCase()} • ${activity.userName ?? 'Unknown'} • ${_formatDate(activity.createdAt)}',
              metadata: {
                'activity_type': activity.type.name,
                'user_name': activity.userName,
                'location': activity.location,
                'created_at': activity.createdAt.toIso8601String(),
                'user_id': activity.userId,
                ...?activity.metadata,
              },
            ),
          );
        }
      }

      // Sort results by relevance and date
      results.sort((a, b) {
        // First, prioritize exact matches
        final aExact =
            _isExactMatch(a.title, query) ||
            _isExactMatch(a.description, query);
        final bExact =
            _isExactMatch(b.title, query) ||
            _isExactMatch(b.description, query);

        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;

        // Then sort by type priority (alerts first, then posts, etc.)
        final aTypePriority = _getTypePriority(a.type);
        final bTypePriority = _getTypePriority(b.type);

        if (aTypePriority != bTypePriority) {
          return aTypePriority.compareTo(bTypePriority);
        }

        // Finally, sort by date (newest first)
        final aDate =
            DateTime.tryParse(a.metadata['created_at'] ?? '') ?? DateTime.now();
        final bDate =
            DateTime.tryParse(b.metadata['created_at'] ?? '') ?? DateTime.now();
        return bDate.compareTo(aDate);
      });

      _searchResults = results;
    } catch (e) {
      debugPrint('Error during search: $e');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void _clearSearch() {
    _currentQuery = '';
    _searchResults.clear();
    _isSearching = false;
    notifyListeners();
  }

  bool _matchesQuery(String text, String query) {
    return text.toLowerCase().contains(query.toLowerCase());
  }

  bool _isExactMatch(String text, String query) {
    return text.toLowerCase() == query.toLowerCase();
  }

  int _getTypePriority(SearchResultType type) {
    switch (type) {
      case SearchResultType.alert:
        return 1;
      case SearchResultType.evacuation:
        return 2;
      case SearchResultType.activity:
        return 3;
      case SearchResultType.post:
        return 4;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getEvacuationStatus(dynamic center) {
    final capacity = center.capacity;
    final occupancy = center.currentOccupancy ?? 0;

    if (capacity != null) {
      final available = capacity - occupancy;
      return 'Available: $available/$capacity';
    }

    return center.status?.name.toUpperCase() ?? 'UNKNOWN';
  }

  void clearSearch() {
    _clearSearch();
  }
}
