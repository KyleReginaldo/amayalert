import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/posts/post_provider.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../../dependency.dart';

/// Show a modal bottom sheet with comments for a post and an input to add a new comment.
Future<void> showCommentsForPost(BuildContext context, int postId) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CommentsSheet(postId: postId),
  );
}

class _CommentsSheet extends StatefulWidget {
  final int postId;
  const _CommentsSheet({required this.postId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostRepository>().getCommentsForPost(widget.postId);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<PostRepository>(),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                const CustomText(
                  text: 'Comments',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Consumer<PostRepository>(
                    builder: (context, repo, _) {
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
                        controller: scrollController,
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = comments[index];
                          return GestureDetector(
                            onTap: () {
                              if (c.user != null) {
                                context.router.push(
                                  UserProfileRoute(
                                    userId: c.user!.id,
                                    userName: c.user!.fullName,
                                  ),
                                );
                              }
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: c.user?.profilePicture != null
                                    ? NetworkImage(c.user!.profilePicture!)
                                          as ImageProvider
                                    : null,
                                child: c.user?.profilePicture == null
                                    ? Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                        size: 18,
                                      )
                                    : null,
                              ),
                              title: CustomText(text: c.comment ?? ''),
                              subtitle: CustomText(
                                text: c.user?.fullName ?? 'Unknown',
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                              trailing: CustomText(
                                text: '${c.createdAt.toLocal()}'.split(' ')[0],
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
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
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
