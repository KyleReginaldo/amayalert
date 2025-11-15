import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/reports/report_model.dart';
import 'package:amayalert/feature/reports/report_provider.dart';
import 'package:flutter/material.dart';

class ReportRepository extends ChangeNotifier {
  final ReportProvider _reportProvider;

  ReportRepository({ReportProvider? provider})
    : _reportProvider = provider ?? ReportProvider();

  List<Report> _reports = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Map<int, bool> _postReportStatus =
      {}; // Track if user has reported each post
  final Map<int, Map<String, int>> _postReportStats =
      {}; // Track report stats per post

  // Getters
  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<int, bool> get postReportStatus => _postReportStatus;
  Map<int, Map<String, int>> get postReportStats => _postReportStats;

  /// Create a report for a post
  Future<Result<String>> reportPost({
    required int postId,
    required String reason,
    required String reportedBy,
  }) async {
    try {
      _setLoading(true);

      final request = CreateReportRequest(
        post: postId,
        reason: reason,
        reportedBy: reportedBy,
      );

      final result = await _reportProvider.createReport(request: request);

      if (result.isSuccess) {
        // Update local state to reflect that user has reported this post
        _postReportStatus[postId] = true;

        // Refresh reports if we're tracking them
        if (_reports.isNotEmpty) {
          await loadReports();
        }

        // Update post report stats
        await loadPostReportStats(postId);

        _clearError();
        notifyListeners();
      } else {
        _setError(result.error);
      }

      return result;
    } finally {
      _setLoading(false);
    }
  }

  /// Load all reports (for admin users)
  Future<void> loadReports() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _reportProvider.getReports();

      if (result.isSuccess) {
        _reports = result.value;
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Load reports for a specific post
  Future<void> loadPostReports(int postId) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _reportProvider.getPostReports(postId);

      if (result.isSuccess) {
        _reports = result.value;
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Load reports made by current user
  Future<void> loadUserReports(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _reportProvider.getUserReports(userId);

      if (result.isSuccess) {
        _reports = result.value;
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user has reported a specific post
  Future<void> checkUserReportStatus({
    required int postId,
    required String userId,
  }) async {
    final result = await _reportProvider.hasUserReportedPost(
      postId: postId,
      userId: userId,
    );

    if (result.isSuccess) {
      _postReportStatus[postId] = result.value;
      notifyListeners();
    }
  }

  /// Check if user has reported multiple posts
  Future<void> checkMultiplePostReportStatus({
    required List<int> postIds,
    required String userId,
  }) async {
    for (final postId in postIds) {
      await checkUserReportStatus(postId: postId, userId: userId);
    }
  }

  /// Load report statistics for a post
  Future<void> loadPostReportStats(int postId) async {
    final result = await _reportProvider.getPostReportStats(postId);

    if (result.isSuccess) {
      _postReportStats[postId] = result.value;
      notifyListeners();
    }
  }

  /// Load report statistics for multiple posts
  Future<void> loadMultiplePostReportStats(List<int> postIds) async {
    for (final postId in postIds) {
      await loadPostReportStats(postId);
    }
  }

  /// Delete a report (for admin users)
  Future<Result<String>> deleteReport(int reportId) async {
    try {
      _setLoading(true);

      final result = await _reportProvider.deleteReport(reportId);

      if (result.isSuccess) {
        // Remove from local list
        _reports.removeWhere((report) => report.id == reportId);
        _clearError();
        notifyListeners();
      } else {
        _setError(result.error);
      }

      return result;
    } finally {
      _setLoading(false);
    }
  }

  /// Get the count of reports for a specific post
  int getPostReportCount(int postId) {
    if (_postReportStats.containsKey(postId)) {
      return _postReportStats[postId]!.values.fold(0, (a, b) => a + b);
    }
    return 0;
  }

  /// Check if current user has reported a post
  bool hasUserReportedPost(int postId) {
    return _postReportStatus[postId] ?? false;
  }

  /// Clear all report data
  void clearData() {
    _reports.clear();
    _postReportStatus.clear();
    _postReportStats.clear();
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
