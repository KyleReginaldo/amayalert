import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/feature/reports/report_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget that provides report functionality for posts
/// Add this to your existing post widget to enable reporting
class PostReportButton extends StatelessWidget {
  final int postId;
  final String? postContent;
  final VoidCallback? onReported;

  const PostReportButton({
    super.key,
    required this.postId,
    this.postContent,
    this.onReported,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Consumer<ReportRepository>(
      builder: (context, reportRepository, child) {
        final hasReported = reportRepository.hasUserReportedPost(postId);

        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
          itemBuilder: (context) => [
            if (!hasReported && currentUserId != null)
              const PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(LucideIcons.flag, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Report Post'),
                  ],
                ),
              ),
            if (hasReported)
              const PopupMenuItem<String>(
                value: 'reported',
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Already Reported',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
          onSelected: (value) async {
            if (value == 'report') {
              final result = await context.router.push(
                ReportPostRoute(postId: postId, postContent: postContent),
              );

              if (result == true && onReported != null) {
                onReported!();
              }
            }
          },
        );
      },
    );
  }
}

/// Example of how to integrate into your existing post widgets
///
/// ```dart
/// class ExistingPostWidget extends StatelessWidget {
///   final Post post;
///
///   @override
///   Widget build(BuildContext context) {
///     return Card(
///       child: Column(
///         children: [
///           // Your existing post header
///           Row(
///             children: [
///               // Avatar, username etc.
///               const Spacer(),
///               // Add the report button here
///               PostReportButton(
///                 postId: post.id,
///                 postContent: post.content,
///                 onReported: () {
///                   // Optional: Show feedback or refresh data
///                   ScaffoldMessenger.of(context).showSnackBar(
///                     const SnackBar(content: Text('Post reported')),
///                   );
///                 },
///               ),
///             ],
///           ),
///           // Your existing post content
///         ],
///       ),
///     );
///   }
/// }
/// ```

/// Simple report button for quick integration
class SimpleReportButton extends StatelessWidget {
  final int postId;
  final String? postContent;

  const SimpleReportButton({super.key, required this.postId, this.postContent});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportRepository>(
      builder: (context, reportRepository, child) {
        final hasReported = reportRepository.hasUserReportedPost(postId);

        if (hasReported) {
          return const SizedBox.shrink(); // Hide button if already reported
        }

        return TextButton.icon(
          onPressed: () {
            context.router.push(
              ReportPostRoute(postId: postId, postContent: postContent),
            );
          },
          icon: const Icon(LucideIcons.flag, size: 16),
          label: const Text('Report'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            textStyle: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }
}

/// Utility mixin to add report functionality to existing widgets
mixin PostReportMixin<T extends StatefulWidget> on State<T> {
  /// Check if current user has reported a post
  Future<void> checkReportStatus(int postId) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null) {
      final reportRepository = context.read<ReportRepository>();
      await reportRepository.checkUserReportStatus(
        postId: postId,
        userId: currentUserId,
      );
    }
  }

  /// Navigate to report screen
  Future<bool?> navigateToReportPost(int postId, [String? postContent]) async {
    return await context.router.push<bool>(
      ReportPostRoute(postId: postId, postContent: postContent),
    );
  }

  /// Quick report method with confirmation dialog
  Future<void> quickReport(int postId, String reason) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Text(
          'Are you sure you want to report this post for "$reason"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Report'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId != null) {
        final reportRepository = context.read<ReportRepository>();
        await reportRepository.reportPost(
          postId: postId,
          reason: reason,
          reportedBy: currentUserId,
        );
      }
    }
  }
}
