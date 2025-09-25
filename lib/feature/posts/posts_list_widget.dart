import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    LucideIcons.user,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text:
                            'User ${post.user.substring(0, 8)}...', // Shortened user ID
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: post.visibility == PostVisibility.public
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.visibility == PostVisibility.public
                            ? LucideIcons.globe
                            : LucideIcons.lock,
                        size: 12,
                        color: post.visibility == PostVisibility.public
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      CustomText(
                        text: post.visibility.value.toUpperCase(),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: post.visibility == PostVisibility.public
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Post content
            CustomText(text: post.content, fontSize: 14),

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
              children: [
                if (post.updatedAt != null &&
                    post.updatedAt != post.createdAt) ...[
                  Icon(
                    Icons.edit,
                    size: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  CustomText(
                    text: 'Edited ${timeago.format(post.updatedAt!)}',
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
