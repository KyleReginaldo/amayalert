import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/posts/post_provider.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../dependency.dart';

@RoutePage()
class CommentsScreen extends StatefulWidget implements AutoRouteWrapper {
  final int postId;
  const CommentsScreen({required this.postId, super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<PostRepository>(),
      child: this,
    );
  }
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request comments using the provider that's injected via
      // `wrappedRoute`. Using the BuildContext keeps us consistent with
      // the widget tree and avoids touching the service locator here.
      try {
        // use context.read inside the post-frame callback where context is valid
        final repo = context.read<PostRepository>();
        repo.getCommentsForPost(widget.postId);
      } catch (_) {
        // fallback to service locator if provider isn't available for some reason
        sl<PostRepository>().getCommentsForPost(widget.postId);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void postComment({
    required int postId,
    required String userId,
    required String comment,
  }) async {
    EasyLoading.show();
    final result = await PostProvider().createPostComment(
      userId: userId,
      postId: postId,
      comment: comment,
    );
    if (result.isError) {
      EasyLoading.dismiss();
      EasyLoading.showToast('Failed to comment');
    } else {
      EasyLoading.dismiss();
      EasyLoading.showToast('Comment posted');
      sl<PostRepository>().getCommentsForPost(widget.postId);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // `wrappedRoute` already injects the repository via a
    // ChangeNotifierProvider.value, so we don't re-wrap here.
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Comments',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<PostRepository>(
                builder: (context, repo, child) {
                  final comments = repo.comments;
                  if (repo.isLoading && comments.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (comments.isEmpty) {
                    return Center(
                      child: CustomText(
                        text: 'No comments yet. Be the first to comment!',
                        color: AppColors.textSecondaryLight,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    itemCount: comments.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      final isPending = c.id < 0;
                      final author = c.user;
                      final authorName = author?.fullName ?? 'Unknown';
                      String initials(String name) {
                        final parts = name.split(' ');
                        if (parts.isEmpty) return '';
                        final first = parts.first.isNotEmpty
                            ? parts.first[0]
                            : '';
                        final second = parts.length > 1 && parts[1].isNotEmpty
                            ? parts[1][0]
                            : '';
                        return (first + second).toUpperCase();
                      }

                      debugPrint('profile picture: ${author?.profilePicture}');

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar or initials
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: author?.profilePicture != null
                                  ? NetworkImage(author!.profilePicture!)
                                        as ImageProvider
                                  : null,
                              child: author?.profilePicture == null
                                  ? Text(
                                      initials(authorName),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            // Name, time and comment
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomText(
                                          text: authorName,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        children: [
                                          CustomText(
                                            text: timeago.format(
                                              c.createdAt.toLocal(),
                                            ),
                                            fontSize: 12,
                                            color: AppColors.textSecondaryLight,
                                          ),
                                          if (isPending) ...[
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  CustomText(
                                    text: c.comment ?? '',
                                    fontSize: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _controller,
                      hint: 'Write a comment...',
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;
                      postComment(
                        postId: widget.postId,
                        userId: userID ?? "",
                        comment: text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
