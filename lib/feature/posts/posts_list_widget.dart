import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:amayalert/feature/reports/report_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostsListWidget extends StatefulWidget {
  const PostsListWidget({super.key});

  @override
  State<PostsListWidget> createState() => _PostsListWidgetState();
}

class _PostsListWidgetState extends State<PostsListWidget> {
  @override
  void initState() {
    super.initState();
    // Load posts when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostRepository>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostRepository>(
      builder: (context, postRepository, child) {
        if (postRepository.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (postRepository.errorMessage != null) {
          debugPrint('Error loading posts: ${postRepository.errorMessage}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                const SizedBox(height: 16),
                CustomText(
                  text: 'Error loading posts',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: postRepository.errorMessage!,
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    postRepository.clearError();
                    postRepository.loadPosts();
                  },
                  child: const CustomText(text: 'Retry'),
                ),
              ],
            ),
          );
        }

        if (postRepository.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.messageSquare,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                CustomText(
                  text: 'No posts yet',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: 'Be the first to share something!',
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.router.push(const CreatePostsRoute());
                  },
                  icon: const Icon(LucideIcons.plus),
                  label: const CustomText(text: 'Create Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await postRepository.loadPosts();
          },
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: postRepository.posts.length,
            itemBuilder: (context, index) {
              final post = postRepository.posts[index];
              return PostCard(post: post);
            },
          ),
        );
      },
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  // Simple function to show report dialog and submit report
  Future<void> _showReportDialog(BuildContext context) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    // Show simple report dialog
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('Why are you reporting this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Spam'),
            child: const Text('Spam'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Inappropriate Content'),
            child: const Text('Inappropriate'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Other'),
            child: const Text('Other'),
          ),
        ],
      ),
    );

    if (reason != null) {
      // Submit report
      final reportRepository = context.read<ReportRepository>();
      final result = await reportRepository.reportPost(
        postId: post.id,
        reason: reason,
        reportedBy: currentUserId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isSuccess ? 'Post reported successfully' : result.error,
            ),
            backgroundColor: result.isSuccess ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.router.push(
                    UserProfileRoute(
                      userId: post.user.id,
                      userName: post.user.fullName,
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: post.user.profilePicture != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: post.user.profilePicture!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 36,
                              height: 36,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              LucideIcons.user,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        )
                      : Icon(
                          LucideIcons.user,
                          color: AppColors.primary,
                          size: 20,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.router.push(
                          UserProfileRoute(
                            userId: post.user.id,
                            userName: post.user.fullName,
                          ),
                        );
                      },
                      child: CustomText(
                        text: post.user.fullName, // Shortened user ID
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    CustomText(
                      text: timeago.format(post.createdAt),
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ],
                ),
              ),
              // Visibility indicator
              InkWell(
                onTap: () => _showReportDialog(context),
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.gray600,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Post content
          CustomText(text: post.content, fontSize: 14),

          // If this post is a share of another post, show the shared post
          if (post.sharedPost != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.router.push(
                            UserProfileRoute(
                              userId: post.sharedPost!.user.id,
                              userName: post.sharedPost!.user.fullName,
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.08,
                          ),
                          child: post.sharedPost!.user.profilePicture != null
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        post.sharedPost!.user.profilePicture!,
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  LucideIcons.user,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.router.push(
                                  UserProfileRoute(
                                    userId: post.sharedPost!.user.id,
                                    userName: post.sharedPost!.user.fullName,
                                  ),
                                );
                              },
                              child: CustomText(
                                text: post.sharedPost!.user.fullName,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            CustomText(
                              text: timeago.format(post.sharedPost!.createdAt),
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: post.sharedPost!.content,
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                  if (post.sharedPost!.mediaUrl != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: post.sharedPost!.mediaUrl!,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(height: 120, color: Colors.grey.shade200),
                        errorWidget: (context, url, error) => Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Post image (if available)
          if (post.mediaUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: post.mediaUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],

          // Post footer
          const SizedBox(height: 12),
          Row(
            spacing: 8,
            children: [
              if (post.updatedAt != null &&
                  post.updatedAt != post.createdAt) ...[
                Icon(Icons.edit, size: 12, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                CustomText(
                  text: 'Edited ${timeago.format(post.updatedAt!)}',
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
              ],
              // Comment icon with cached comment count badge — opens full screen comments
              Consumer<PostRepository>(
                builder: (context, repo, _) {
                  // final count = repo.comments.length;
                  return InkWell(
                    onTap: () {
                      context.router.push(CommentsRoute(postId: post.id));
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            LucideIcons.messageCircle,
                            size: 20,
                            color: AppColors.gray600,
                          ),
                        ),
                        if (post.comments != null && post.comments!.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CustomText(
                                text: post.comments!.length.toString(),
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              InkWell(
                onTap: () async {
                  // Open share screen and refresh when shared
                  final didShare = await context.router.push<bool>(
                    SharePostRoute(
                      postId: post.sharedPost?.id ?? post.id,
                      previewContent: post.sharedPost?.content ?? post.content,
                    ),
                  );
                  if (didShare == true) {
                    // reload posts to show the shared post
                    context.read<PostRepository>().loadPosts();
                  }
                },

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    LucideIcons.share,
                    color: AppColors.gray600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
