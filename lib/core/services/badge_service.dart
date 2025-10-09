import 'package:flutter/foundation.dart';

/// Service to manage unread message badge count
class BadgeService extends ChangeNotifier {
  static final BadgeService _instance = BadgeService._internal();
  factory BadgeService() => _instance;
  BadgeService._internal();

  int _unreadMessageCount = 0;
  int get unreadMessageCount => _unreadMessageCount;

  /// Update the unread message count
  void updateUnreadMessageCount(int count) {
    if (_unreadMessageCount != count) {
      _unreadMessageCount = count;
      notifyListeners();
    }
  }

  /// Add to unread count
  void incrementUnreadCount([int increment = 1]) {
    _unreadMessageCount += increment;
    notifyListeners();
  }

  /// Reset unread count
  void clearUnreadCount() {
    if (_unreadMessageCount > 0) {
      _unreadMessageCount = 0;
      notifyListeners();
    }
  }

  /// Calculate total unread count from conversations
  int calculateTotalUnreadCount(List<dynamic> conversations) {
    int total = 0;
    for (final conversation in conversations) {
      if (conversation.unreadCount != null) {
        total += conversation.unreadCount as int;
      }
    }
    return total;
  }
}
