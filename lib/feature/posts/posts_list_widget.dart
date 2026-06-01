import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/feature/posts/post_media_grid.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:amayalert/feature/reports/report_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostRepository>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostRepository>(
      builder: (context, repo, _) {
        // ── Loading ──────────────────────────────────────────────────────
        if (repo.isLoading) {
          return const _SkeletonList();
        }

        // ── Error ────────────────────────────────────────────────────────
        if (repo.errorMessage != null) {
          return _EmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Could not load posts',
            subtitle: 'Check your connection and try again.',
            actionLabel: 'Retry',
            onAction: () {
              repo.clearError();
              repo.loadPosts();
            },
          );
        }

        // ── Empty ────────────────────────────────────────────────────────
        if (repo.posts.isEmpty) {
          final isGuest =
              Supabase.instance.client.auth.currentUser?.isAnonymous ?? false;
          return _EmptyState(
            icon: LucideIcons.messageSquare,
            title: 'No posts yet',
            subtitle: 'Be the first to share something with the community!',
            actionLabel: isGuest ? null : 'Create a Post',
            onAction: isGuest
                ? null
                : () => context.router.push(const CreatePostsRoute()),
          );
        }

        // ── List ─────────────────────────────────────────────────────────
        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: repo.posts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => PostCard(post: repo.posts[index]),
        );
      },
    );
  }
}

// ── Post Card ─────────────────────────────────────────────────────────────────

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final commentCount = post.comments?.length ?? 0;
    final isOwner = post.user.id == userID;

    return GestureDetector(
      onTap: () => context.router.push(PostDetailRoute(postId: post.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 8, 0),
                child: Row(
                  children: [
                    _Avatar(post: post),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.user.fullName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                DateFormat(
                                  'MMM d, y · h:mm a',
                                ).format(post.createdAt),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.gray400,
                                ),
                              ),
                              const SizedBox(width: 6),
                              _VisibilityChip(visibility: post.visibility),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _MoreMenu(post: post, isOwner: isOwner),
                  ],
                ),
              ),

              // ── Location chip (if @location tag present) ───────────
              if (post.hasLocationTag)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          post.locationTag,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Content ────────────────────────────────────────────
              if (post.bodyContent.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                  child: Text(
                    post.bodyContent,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: AppColors.textPrimaryLight,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // ── Shared post embed ──────────────────────────────────
              if (post.sharedPost != null)
                _SharedPostEmbed(shared: post.sharedPost!),

              // ── Media ──────────────────────────────────────────────
              if (post.hasMedia) ...[
                const SizedBox(height: 10),
                PostMediaGrid(urls: post.allMediaUrls),
              ],

              if (!post.hasMedia) const SizedBox(height: 10),

              // ── Edited badge ───────────────────────────────────────
              if (post.updatedAt != null && post.updatedAt != post.createdAt)
                Padding(
                  padding: const EdgeInsets.only(left: 14, bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 11,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edited ${timeago.format(post.updatedAt!)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Actions ────────────────────────────────────────────
              const Divider(height: 1, color: AppColors.border),
              _ActionBar(post: post, commentCount: commentCount),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final Post post;
  const _Avatar({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.router.push(
        UserProfileRoute(userId: post.user.id, userName: post.user.fullName),
      ),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: post.user.profilePicture != null
              ? CachedNetworkImage(
                  imageUrl: post.user.profilePicture!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(color: AppColors.gray100),
                  errorWidget: (_, _, _) =>
                      _AvatarFallback(name: post.user.fullName),
                )
              : _AvatarFallback(name: post.user.fullName),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ── Visibility chip ───────────────────────────────────────────────────────────

class _VisibilityChip extends StatelessWidget {
  final PostVisibility visibility;
  const _VisibilityChip({required this.visibility});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (visibility) {
      PostVisibility.public => (Icons.public_rounded, AppColors.primary),
      PostVisibility.friends => (Icons.people_outlined, AppColors.success),
      PostVisibility.private => (Icons.lock_outline_rounded, AppColors.gray400),
    };
    return Icon(icon, size: 13, color: color);
  }
}

// ── More menu ─────────────────────────────────────────────────────────────────

class _MoreMenu extends StatelessWidget {
  final Post post;
  final bool isOwner;
  const _MoreMenu({required this.post, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.gray400,
        size: 20,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        if (!isOwner)
          PopupMenuItem(
            onTap: () => _report(context),
            child: const _MenuItem(
              icon: LucideIcons.flagTriangleLeft,
              label: 'Report Post',
              color: AppColors.danger,
            ),
          ),
        if (isOwner)
          PopupMenuItem(
            onTap: () => supabase.from('posts').delete().eq('id', post.id),
            child: const _MenuItem(
              icon: LucideIcons.trash2,
              label: 'Delete Post',
              color: AppColors.danger,
            ),
          ),
      ],
    );
  }

  Future<void> _report(BuildContext context) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ReportDialog(),
    );
    if (reason == null || !context.mounted) return;
    final result = await context.read<ReportRepository>().reportPost(
      postId: post.id,
      reason: reason,
      reportedBy: uid,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess ? 'Reported successfully' : result.error,
        ),
        backgroundColor: result.isSuccess
            ? AppColors.success
            : AppColors.danger,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color, fontSize: 14)),
      ],
    );
  }
}

class _ReportDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Report Post',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: const Text('Why are you reporting this post?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        for (final r in ['Spam', 'Inappropriate Content', 'Other'])
          TextButton(
            onPressed: () => Navigator.pop(context, r),
            child: Text(r),
          ),
      ],
    );
  }
}

// ── Shared post embed ─────────────────────────────────────────────────────────

class _SharedPostEmbed extends StatelessWidget {
  final Post shared;
  const _SharedPostEmbed({required this.shared});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: shared.user.profilePicture != null
                          ? CachedNetworkImage(
                              imageUrl: shared.user.profilePicture!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              alignment: Alignment.center,
                              child: Text(
                                shared.user.fullName.isNotEmpty
                                    ? shared.user.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shared.user.fullName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    timeago.format(shared.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            if (shared.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Text(
                  shared.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // Media
            if (shared.mediaUrl != null)
              CachedNetworkImage(
                imageUrl: shared.mediaUrl!,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(height: 140, color: AppColors.gray200),
                errorWidget: (_, _, _) =>
                    Container(height: 140, color: AppColors.gray200),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Action bar ────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final Post post;
  final int commentCount;
  const _ActionBar({required this.post, required this.commentCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          // Comment
          _ActionButton(
            icon: LucideIcons.messageCircle,
            label: commentCount > 0 ? '$commentCount' : 'Comment',
            onTap: () => context.router.push(CommentsRoute(postId: post.id)),
          ),

          // Share
          _ActionButton(
            icon: LucideIcons.share2,
            label: 'Share',
            onTap: () async {
              final did = await context.router.push<bool>(
                SharePostRoute(
                  postId: post.sharedPost?.id ?? post.id,
                  previewContent: post.sharedPost?.content ?? post.content,
                ),
              );
              if (did == true && context.mounted) {
                context.read<PostRepository>().loadPosts();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: AppColors.gray500),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gray500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

// ── Skeleton loader ───────────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Shimmer(width: 42, height: 42, radius: 21),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(width: 120, height: 12, radius: 6),
                  const SizedBox(height: 6),
                  _Shimmer(width: 80, height: 10, radius: 5),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Shimmer(width: double.infinity, height: 12, radius: 6),
          const SizedBox(height: 6),
          _Shimmer(width: 200, height: 12, radius: 6),
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _Shimmer({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
