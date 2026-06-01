import 'package:amayalert/core/services/badge_service.dart';
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
import 'package:timeago/timeago.dart' as timeago;

import '../../core/constant/constant.dart';
import '../../core/router/app_route.gr.dart';

@RoutePage()
class MessageScreen extends StatefulWidget implements AutoRouteWrapper {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();

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

class _MessageScreenState extends State<MessageScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    BadgeService().clearUnreadCount();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileRepository>().getUserProfile(userID ?? '');
      _loadConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadConversations() {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) {
      context.read<EnhancedMessageRepository>().loadConversations(uid);
      context.read<EnhancedMessageRepository>().subscribeToUserMessages(uid);
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _query = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileRepository>().profile;
    final isGuest = profile?.fullName == 'Guest User';

    return ChangeNotifierProvider.value(
      value: sl<EnhancedMessageRepository>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          surfaceTintColor: Colors.white,
          centerTitle: false,
          title: _showSearch
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    hintStyle: const TextStyle(
                        color: AppColors.gray400, fontSize: 15),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                )
              : const Text(
                  'Community',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
          actions: [
            IconButton(
              onPressed: _toggleSearch,
              icon: Icon(
                _showSearch ? LucideIcons.x : LucideIcons.search,
                color: AppColors.textSecondaryLight,
                size: 20,
              ),
            ),
            if (!isGuest && !_showSearch)
              IconButton(
                onPressed: () =>
                    context.router.push(const NewConversationRoute()),
                icon: const Icon(
                  LucideIcons.pen,
                  color: AppColors.textSecondaryLight,
                  size: 20,
                ),
              ),
            const SizedBox(width: 4),
          ],
        ),
        body: Consumer<EnhancedMessageRepository>(
          builder: (context, repo, _) {
            // ── Loading ────────────────────────────────────────────────
            if (repo.isLoading) return const _SkeletonList();

            // ── Error ─────────────────────────────────────────────────
            if (repo.errorMessage != null) {
              return _EmptyState(
                icon: LucideIcons.wifiOff,
                title: 'Connection error',
                subtitle: 'Couldn\'t load your conversations.',
                actionLabel: 'Try Again',
                onAction: () {
                  repo.clearError();
                  _loadConversations();
                },
              );
            }

            // ── Guest ─────────────────────────────────────────────────
            if (isGuest) {
              return _EmptyState(
                icon: LucideIcons.messageCircle,
                title: 'Sign in to chat',
                subtitle:
                    'Create an account to start conversations with other residents.',
                actionLabel: 'Sign In',
                onAction: () async {
                  final reload =
                      await context.router.push<bool>(SignInRoute());
                  if (reload == true) _loadConversations();
                },
              );
            }

            // ── Empty ─────────────────────────────────────────────────
            final all = repo.conversations;
            final filtered = _query.isEmpty
                ? all
                : all
                    .where((c) => c.participantName
                        .toLowerCase()
                        .contains(_query))
                    .toList();

            if (all.isEmpty) {
              return _EmptyState(
                icon: LucideIcons.messageCircle,
                title: 'No conversations yet',
                subtitle: 'Start a conversation with a community member.',
                actionLabel: 'New Message',
                onAction: () =>
                    context.router.push(const NewConversationRoute()),
              );
            }

            if (filtered.isEmpty) {
              return _EmptyState(
                icon: LucideIcons.searchX,
                title: 'No results for "$_query"',
                subtitle: 'Try a different name.',
              );
            }

            // ── List ──────────────────────────────────────────────────
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => _loadConversations(),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  indent: 76,
                  color: AppColors.border,
                ),
                itemBuilder: (context, i) => _ConversationTile(
                  conversation: filtered[i],
                  onTap: () => context.router.push(ChatRoute(
                    otherUserId: filtered[i].participantId,
                    otherUserName: filtered[i].participantName,
                    otherUserPhone: filtered[i].phoneNumber,
                  )),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Conversation tile ─────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0 &&
        conversation.lastMessage?.sender == conversation.participantId &&
        conversation.lastMessage?.seenAt == null;

    final timeStr = conversation.lastActivity != null
        ? timeago.format(conversation.lastActivity!, locale: 'en_short')
        : '';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────────────────────
            _Avatar(
              name: conversation.participantName,
              imageUrl: conversation.participantProfilePicture,
            ),
            const SizedBox(width: 12),

            // ── Content ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.participantName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeStr.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? AppColors.primary
                                : AppColors.gray400,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Last message + badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage == null
                              ? 'No messages yet'
                              : conversation.lastMessage!.hasAttachment
                                  ? '📎 Attachment'
                                  : conversation.lastMessage!.content,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? AppColors.textPrimaryLight
                                : AppColors.gray500,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : '${conversation.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
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

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _Avatar({required this.name, this.imageUrl});

  // Deterministic color from name — avoids same color for all conversations
  Color _color() {
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
    final idx = name.isEmpty ? 0 : name.codeUnitAt(0) % palette.length;
    return palette[idx];
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _Initials(initial, color),
              )
            : _Initials(initial, color),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String initial;
  final Color color;
  const _Initials(this.initial, this.color);

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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
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
      padding: EdgeInsets.zero,
      itemCount: 7,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 76, color: AppColors.border),
      itemBuilder: (_, _) => const _SkeletonTile(),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _Bone(width: 50, height: 50, radius: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Bone(width: 130, height: 13, radius: 6),
                    const Spacer(),
                    _Bone(width: 36, height: 10, radius: 5),
                  ],
                ),
                const SizedBox(height: 8),
                _Bone(width: double.infinity, height: 11, radius: 5),
              ],
            ),
          ),
        ],
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
