import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/feature/posts/post_media_grid.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

@RoutePage()
class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, @PathParam('id') required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await supabase
          .from('posts')
          .select('''
            *,
            user:user(*),
            comments:comments(*, user:user(*)),
            shared_post:shared_post(*, user:user(*))
          ''')
          .eq('id', widget.postId)
          .order('created_at', ascending: false)
          .single();
      setState(() {
        _post = PostMapper.fromMap(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openComments() async {
    final result =
        await context.router.push<bool>(CommentsRoute(postId: _post!.id));
    if (result == true) _loadPost();
  }

  Future<void> _openShare() async {
    final did = await context.router.push<bool>(SharePostRoute(
      postId: _post!.sharedPost?.id ?? _post!.id,
      previewContent: _post!.sharedPost?.content ?? _post!.content,
    ));
    if (did == true) _loadPost();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: const Icon(LucideIcons.arrowLeft,
              color: AppColors.textPrimaryLight, size: 20),
        ),
        title: const Text(
          'Post',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.wifiOff,
                    size: 28, color: AppColors.danger),
              ),
              const SizedBox(height: 16),
              const Text('Could not load post',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loadPost, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_post == null) {
      return const Center(
        child: Text('Post not found',
            style: TextStyle(fontSize: 15, color: AppColors.gray500)),
      );
    }

    final post = _post!;
    final commentCount = post.comments?.length ?? 0;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadPost,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Post card ─────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Avatar(
                          imageUrl: post.user.profilePicture,
                          name: post.user.fullName,
                          size: 46,
                          onTap: () => context.router.push(
                              UserProfileRoute(userId: post.user.id)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.router
                                .push(UserProfileRoute(userId: post.user.id)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.user.fullName,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimaryLight),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      timeago.format(post.createdAt),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.gray400),
                                    ),
                                    const SizedBox(width: 5),
                                    _visibilityIcon(post.visibility),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Location tag
                  if (post.hasLocationTag)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 13, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text(
                            post.locationTag,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                  // Body content
                  if (post.bodyContent.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Text(
                        post.bodyContent,
                        style: const TextStyle(
                            fontSize: 15,
                            height: 1.55,
                            color: AppColors.textPrimaryLight),
                      ),
                    ),

                  // Media (bento grid)
                  if (post.hasMedia) ...[
                    const SizedBox(height: 12),
                    PostMediaGrid(urls: post.allMediaUrls),
                  ],

                  // Shared post
                  if (post.sharedPost != null)
                    _SharedEmbed(shared: post.sharedPost!),

                  // Edited
                  if (post.updatedAt != null &&
                      post.updatedAt != post.createdAt)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined,
                              size: 11, color: AppColors.gray400),
                          const SizedBox(width: 4),
                          Text(
                            'Edited ${timeago.format(post.updatedAt!)}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.gray400),
                          ),
                        ],
                      ),
                    ),

                  // Action bar
                  const Divider(height: 1, color: AppColors.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 4),
                    child: Row(
                      children: [
                        _ActionBtn(
                          icon: LucideIcons.messageCircle,
                          label: commentCount > 0
                              ? '$commentCount Comment${commentCount == 1 ? '' : 's'}'
                              : 'Comment',
                          onTap: _openComments,
                        ),
                        _ActionBtn(
                          icon: LucideIcons.share2,
                          label: 'Share',
                          onTap: _openShare,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Comments section ─────────────────────────────────────
            if (commentCount > 0) ...[
              Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.messageSquare,
                              size: 15, color: AppColors.gray500),
                          const SizedBox(width: 6),
                          Text(
                            'Comments ($commentCount)',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryLight),
                          ),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount:
                          commentCount > 5 ? 5 : commentCount,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _CommentTile(comment: post.comments![i]),
                    ),
                    if (commentCount > 5)
                      TextButton(
                        onPressed: _openComments,
                        child: Text('View all $commentCount comments',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.messageCircle,
                            size: 24, color: AppColors.gray400),
                      ),
                      const SizedBox(height: 10),
                      const Text('No comments yet',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.gray500)),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _openComments,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          textStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Be the first to comment'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _visibilityIcon(PostVisibility v) {
    final (icon, color) = switch (v) {
      PostVisibility.public => (Icons.public_rounded, AppColors.success),
      PostVisibility.friends => (Icons.people_outlined, AppColors.primary),
      PostVisibility.private =>
        (Icons.lock_outline_rounded, AppColors.gray400),
    };
    return Icon(icon, size: 13, color: color);
  }
}

// ── Avatar ─────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final VoidCallback? onTap;

  const _Avatar(
      {required this.name, this.imageUrl, this.size = 40, this.onTap});

  Color get _color {
    const palette = [
      Color(0xFF1D6BF3), Color(0xFF2E7D32), Color(0xFFDC2626),
      Color(0xFF7C3AED), Color(0xFFF59E0B), Color(0xFF0891B2),
    ];
    return palette[name.isEmpty ? 0 : name.codeUnitAt(0) % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: color.withValues(alpha: 0.25), width: 2),
        ),
        child: ClipOval(
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl!, fit: BoxFit.cover,
                  errorWidget: (_, _, _) =>
                      _Initials(initial: initial, color: color, size: size))
              : _Initials(initial: initial, color: color, size: size),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String initial;
  final Color color;
  final double size;
  const _Initials(
      {required this.initial, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(initial,
          style: TextStyle(
              color: color,
              fontSize: size * 0.38,
              fontWeight: FontWeight.w700)),
    );
  }
}

// ── Action button ──────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});

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
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.gray500,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Shared embed ───────────────────────────────────────────────────────────────

class _SharedEmbed extends StatelessWidget {
  final Post shared;
  const _SharedEmbed({required this.shared});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _Avatar(name: shared.user.fullName,
                      imageUrl: shared.user.profilePicture, size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shared.user.fullName,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(timeago.format(shared.createdAt),
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.gray400)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (shared.bodyContent.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(shared.bodyContent,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                        height: 1.5)),
              ),
            if (shared.hasMedia)
              PostMediaGrid(urls: shared.allMediaUrls),
          ],
        ),
      ),
    );
  }
}

// ── Comment tile ───────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final dynamic comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final name = comment.user?.fullName ?? 'Unknown';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(
          name: name,
          imageUrl: comment.user?.profilePicture,
          size: 34,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight)),
                    const SizedBox(height: 3),
                    Text(comment.comment ?? '',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimaryLight,
                            height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  timeago.format(comment.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.gray400),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
