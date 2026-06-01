import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/messages/enhanced_message_repository.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class NewConversationScreen extends StatefulWidget implements AutoRouteWrapper {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<EnhancedMessageRepository>()),
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
      ],
      child: this,
    );
  }
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUsers());
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({String? query}) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null && mounted) {
      await context.read<EnhancedMessageRepository>().loadAvailableUsers(
        currentUserId: uid,
        searchQuery: query,
      );
    }
  }

  void _onSearch() {
    final q = _searchController.text.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadUsers(query: q.isEmpty ? null : q.toLowerCase());
    });
  }

  void _startConversation(MessageUser user) {
    context.router.push(ChatRoute(
      otherUserId: user.id,
      otherUserName: user.fullName.isNotEmpty ? user.fullName : user.email,
      otherUserPhone: user.phoneNumber,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'New Message',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(LucideIcons.search,
                      size: 17, color: AppColors.gray400),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle:
                          TextStyle(color: AppColors.gray400, fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    onPressed: () => _searchController.clear(),
                    icon: const Icon(LucideIcons.x,
                        size: 16, color: AppColors.gray400),
                    padding: const EdgeInsets.only(right: 4),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── User list ───────────────────────────────────────────────
          Expanded(
            child: Consumer<EnhancedMessageRepository>(
              builder: (context, repo, _) {
                if (repo.isLoading) return const _SkeletonList();

                if (repo.errorMessage != null) {
                  return _EmptyState(
                    icon: LucideIcons.wifiOff,
                    title: 'Could not load users',
                    subtitle: 'Check your connection and try again.',
                    actionLabel: 'Retry',
                    onAction: () {
                      repo.clearError();
                      _loadUsers();
                    },
                  );
                }

                final users = repo.availableUsers;
                final hasQuery = _searchController.text.isNotEmpty;

                if (users.isEmpty) {
                  return _EmptyState(
                    icon: hasQuery ? LucideIcons.searchX : LucideIcons.users,
                    title: hasQuery ? 'No results found' : 'No users available',
                    subtitle: hasQuery
                        ? 'Try a different name or email.'
                        : 'Check back later.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: users.length + 1, // +1 for section header
                  separatorBuilder: (_, i) => i == 0
                      ? const SizedBox.shrink()
                      : const Divider(
                          height: 1,
                          indent: 72,
                          color: AppColors.border,
                        ),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          hasQuery
                              ? '${users.length} result${users.length == 1 ? '' : 's'}'
                              : '${users.length} resident${users.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray400,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      );
                    }
                    final user = users[i - 1];
                    return _UserTile(
                      user: user,
                      onTap: () => _startConversation(user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── User tile ─────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  final MessageUser user;
  final VoidCallback onTap;

  const _UserTile({required this.user, required this.onTap});

  Color _avatarColor() {
    const palette = [
      Color(0xFF1D6BF3),
      Color(0xFF2E7D32),
      Color(0xFFDC2626),
      Color(0xFF7C3AED),
      Color(0xFFF59E0B),
      Color(0xFF0891B2),
      Color(0xFFDB2777),
      Color(0xFF16A34A),
    ];
    final name = user.fullName;
    final idx = name.isEmpty ? 0 : name.codeUnitAt(0) % palette.length;
    return palette[idx];
  }

  @override
  Widget build(BuildContext context) {
    final name =
        user.fullName.isNotEmpty ? user.fullName : 'Unknown';
    final subtitle = user.phoneNumber.isNotEmpty
        ? user.phoneNumber
        : user.email;
    final color = _avatarColor();
    final initial = name.trim()[0].toUpperCase();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: user.profilePicture != null &&
                        user.profilePicture!.isNotEmpty
                    ? Image.network(
                        user.profilePicture!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _Initial(initial, color),
                      )
                    : _Initial(initial, color),
              ),
            ),
            const SizedBox(width: 12),

            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Action icon
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.messageCircle,
                  size: 16, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String initial;
  final Color color;
  const _Initial(this.initial, this.color);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w700,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 4),
      itemCount: 8,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 72, color: AppColors.border),
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            _Bone(width: 48, height: 48, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(width: 140, height: 13, radius: 6),
                  const SizedBox(height: 7),
                  _Bone(width: 100, height: 11, radius: 5),
                ],
              ),
            ),
            _Bone(width: 34, height: 34, radius: 17),
          ],
        ),
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _Bone(
      {required this.width, required this.height, required this.radius});

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
