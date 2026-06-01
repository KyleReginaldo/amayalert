import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:amayalert/feature/profile/profile_model.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/constant/constant.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget implements AutoRouteWrapper {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
        ChangeNotifierProvider.value(value: sl<PostRepository>()),
      ],
      child: this,
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileRepository>().getUserProfile(userID ?? '');
      context.read<PostRepository>().loadUserPosts(userID ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((ProfileRepository r) => r.profile);
    final isLoading = context.select((ProfileRepository r) => r.isLoading);
    final posts = context.select((PostRepository r) => r.userPosts);
    final isGuest = user?.email.contains('guest') ?? false;

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          if (!(user?.email.contains('guest') ?? true))
            IconButton(
              onPressed: () => context.router.push(const CreatePostsRoute()),
              icon: const Icon(
                LucideIcons.pen,
                color: AppColors.primary,
                size: 20,
              ),
              tooltip: 'New Post',
            ),
          IconButton(
            onPressed: () => context.router.push(SettingsRoute()),
            icon: const Icon(
              LucideIcons.settings,
              color: AppColors.textSecondaryLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isLoading
          ? const _ProfileSkeleton()
          : user == null
          ? _noUser(context)
          : _buildBody(context, user, posts, isGuest),
    );
  }

  // ── No-user / guest states ────────────────────────────────────────────────

  Widget _noUser(BuildContext context) {
    final hasUid = userID != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.user,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasUid ? 'Guest mode' : 'Not signed in',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              hasUid
                  ? 'You\'re browsing as a guest. Sign in to access your full profile.'
                  : 'Please sign in to view your profile.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.router.push(SignInRoute()),
              icon: const Icon(LucideIcons.logIn, size: 16),
              label: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main body ─────────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    await Future.wait([
      context.read<ProfileRepository>().getUserProfile(userID ?? ''),
      context.read<PostRepository>().loadUserPosts(userID ?? ''),
    ]);
  }

  Widget _buildBody(
    BuildContext context,
    Profile user,
    List<Post> posts,
    bool isGuest,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          _ProfileHeader(user: user, isGuest: isGuest, postCount: posts.length),

          // ── Divider + Posts label ──────────────────────────────────
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.messageSquare,
                  size: 15,
                  color: AppColors.gray500,
                ),
                const SizedBox(width: 6),
                Text(
                  'Posts (${posts.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                if (!isGuest)
                  GestureDetector(
                    onTap: () => context.router.push(const CreatePostsRoute()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.plus, size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'New Post',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Posts list ─────────────────────────────────────────────
          if (posts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.messageSquare,
                      size: 26,
                      color: AppColors.gray400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No posts yet',
                    style: TextStyle(fontSize: 14, color: AppColors.gray500),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: posts.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (_, i) => _PostTile(
                post: posts[i],
                onTap: () =>
                    context.router.push(PostDetailRoute(postId: posts[i].id)),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),    // Column
    ),      // SingleChildScrollView
  );        // RefreshIndicator
  }
}

// ── Profile header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final Profile user;
  final bool isGuest;
  final int postCount;

  const _ProfileHeader({
    required this.user,
    required this.isGuest,
    required this.postCount,
  });

  Color get _avatarColor {
    const palette = [
      Color(0xFF1D6BF3),
      Color(0xFF2E7D32),
      Color(0xFFDC2626),
      Color(0xFF7C3AED),
      Color(0xFFF59E0B),
      Color(0xFF0891B2),
    ];
    final name = user.fullName;
    return palette[name.isEmpty ? 0 : name.codeUnitAt(0) % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor;
    final initial = user.fullName.trim().isNotEmpty
        ? user.fullName.trim()[0].toUpperCase()
        : '?';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          // ── Avatar ─────────────────────────────────────────────────
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.25),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: user.profilePicture != null
                      ? CachedNetworkImage(
                          imageUrl: user.profilePicture!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) =>
                              _InitialsAvatar(initial: initial, color: color),
                        )
                      : _InitialsAvatar(initial: initial, color: color),
                ),
              ),
              if (!isGuest)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () =>
                        context.router.push(EditProfileRoute(profile: user)),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        LucideIcons.pen,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Name ────────────────────────────────────────────────────
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),

          // ── Extra info chips ─────────────────────────────────────────
          if (user.phoneNumber != null || user.address != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                if (user.phoneNumber != null)
                  _InfoChip(LucideIcons.phone, user.phoneNumber!),
                if (user.address != null)
                  _InfoChip(LucideIcons.mapPin, user.address!),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // ── Stats + Edit row ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isGuest) ...[
                OutlinedButton.icon(
                  onPressed: () =>
                      context.router.push(EditProfileRoute(profile: user)),
                  icon: const Icon(LucideIcons.pen, size: 14),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimaryLight,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initial;
  final Color color;
  const _InitialsAvatar({required this.initial, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.gray500),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final int count;
  final String label;
  const _StatBadge({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Post tile ─────────────────────────────────────────────────────────────────

class _PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  const _PostTile({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (post.hasMedia)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: post.mediaUrl!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.gray200,
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.gray100,
                    child: const Icon(
                      LucideIcons.imageOff,
                      color: AppColors.gray400,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.messageSquare,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.content.isNotEmpty)
                    Text(
                      post.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimaryLight,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        timeago.format(post.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.gray400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _VisibilityDot(post.visibility),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppColors.gray300,
            ),
          ],
        ),
      ),
    );
  }
}

class _VisibilityDot extends StatelessWidget {
  final PostVisibility v;
  const _VisibilityDot(this.v);

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (v) {
      PostVisibility.public => (Icons.public_rounded, AppColors.success),
      PostVisibility.friends => (Icons.people_outlined, AppColors.primary),
      PostVisibility.private => (Icons.lock_outline_rounded, AppColors.gray400),
    };
    return Icon(icon, size: 12, color: color);
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              children: [
                const _Bone(width: 88, height: 88, radius: 44),
                const SizedBox(height: 12),
                const _Bone(width: 140, height: 16, radius: 8),
                const SizedBox(height: 8),
                const _Bone(width: 200, height: 12, radius: 6),
                const SizedBox(height: 16),
                const _Bone(width: 100, height: 36, radius: 8),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          for (int i = 0; i < 4; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: const [
                  _Bone(width: 72, height: 72, radius: 8),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Bone(width: double.infinity, height: 12, radius: 6),
                        SizedBox(height: 6),
                        _Bone(width: 200, height: 11, radius: 5),
                        SizedBox(height: 6),
                        _Bone(width: 80, height: 10, radius: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double width, height, radius;
  const _Bone({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.gray200,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
