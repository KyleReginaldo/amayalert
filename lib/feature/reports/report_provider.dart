import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/reports/report_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportProvider {
  final supabase = Supabase.instance.client;

  /// Create a new report for a post
  Future<Result<String>> createReport({
    required CreateReportRequest request,
  }) async {
    try {
      // Check if user has already reported this post
      final existingReport = await supabase
          .from('reports')
          .select()
          .eq('post', request.post)
          .eq('reported_by', request.reportedBy)
          .maybeSingle();

      if (existingReport != null) {
        return Result.error('You have already reported this post');
      }

      // Check if the post exists
      final post = await supabase
          .from('posts')
          .select('id, user')
          .eq('id', request.post)
          .maybeSingle();

      if (post == null) {
        return Result.error('Post not found');
      }

      // Prevent users from reporting their own posts
      if (post['user'] == request.reportedBy) {
        return Result.error('You cannot report your own post');
      }

      // Create the report
      final response = await supabase
          .from('reports')
          .insert(request.toMap())
          .select()
          .single();

      if (response.isNotEmpty) {
        debugPrint('Report created successfully: ${response['id']}');
        return Result.success('Post reported successfully');
      } else {
        return Result.error('Failed to create report');
      }
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Get all reports (for admin users)
  Future<Result<List<Report>>> getReports() async {
    try {
      final response = await supabase
          .from('reports')
          .select('*, posts!inner(*), users!inner(*)')
          .order('created_at', ascending: false);

      List<Report> reports = [];
      for (final json in response) {
        reports.add(ReportMapper.fromMap(json));
      }

      return Result.success(reports);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Get reports for a specific post
  Future<Result<List<Report>>> getPostReports(int postId) async {
    try {
      final response = await supabase
          .from('reports')
          .select('*, users!inner(*)')
          .eq('post', postId)
          .order('created_at', ascending: false);

      List<Report> reports = [];
      for (final json in response) {
        reports.add(ReportMapper.fromMap(json));
      }

      return Result.success(reports);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Get reports made by a specific user
  Future<Result<List<Report>>> getUserReports(String userId) async {
    try {
      final response = await supabase
          .from('reports')
          .select('*, posts!inner(*)')
          .eq('reported_by', userId)
          .order('created_at', ascending: false);

      List<Report> reports = [];
      for (final json in response) {
        reports.add(ReportMapper.fromMap(json));
      }

      return Result.success(reports);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Check if a user has reported a specific post
  Future<Result<bool>> hasUserReportedPost({
    required int postId,
    required String userId,
  }) async {
    try {
      final report = await supabase
          .from('reports')
          .select()
          .eq('post', postId)
          .eq('reported_by', userId)
          .maybeSingle();

      return Result.success(report != null);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Delete a report (for admin users)
  Future<Result<String>> deleteReport(int reportId) async {
    try {
      await supabase.from('reports').delete().eq('id', reportId);

      return Result.success('Report deleted successfully');
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Get report statistics for a post
  Future<Result<Map<String, int>>> getPostReportStats(int postId) async {
    try {
      final response = await supabase
          .from('reports')
          .select('reason')
          .eq('post', postId);

      Map<String, int> stats = {};
      for (final report in response) {
        final reason = report['reason'] as String;
        stats[reason] = (stats[reason] ?? 0) + 1;
      }

      return Result.success(stats);
    } on PostgrestException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }
}
