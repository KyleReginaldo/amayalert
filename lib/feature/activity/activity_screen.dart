import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/activity/activity_detail_screen.dart';
import 'package:amayalert/feature/activity/activity_model.dart';
import 'package:amayalert/feature/activity/activity_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

@RoutePage()
class ActivityScreen extends StatefulWidget implements AutoRouteWrapper {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ActivityRepository>(),
      child: this,
    );
  }
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityRepository>().loadActivities();
    });
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
        centerTitle: false,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          Consumer<ActivityRepository>(
            builder: (_, repo, __) => IconButton(
              onPressed: repo.refresh,
              icon: const Icon(LucideIcons.refreshCw,
                  color: AppColors.gray500, size: 18),
            ),
          ),
          Consumer<ActivityRepository>(
            builder: (_, repo, __) {
              final mine = repo.activities.where((a) => a.userId == userID);
              if (mine.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: const Icon(LucideIcons.list,
                    color: AppColors.gray500, size: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onSelected: (v) {
                  if (v == 'delete_all') _showDeleteAllConfirmation();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        const Icon(LucideIcons.trash2,
                            size: 15, color: AppColors.danger),
                        const SizedBox(width: 8),
                        const Text('Clear all my activity',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.danger)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<ActivityRepository>(
        builder: (context, repo, _) {
          // Loading
          if (repo.isLoading) return const _SkeletonList();

          // Error
          if (repo.error != null) {
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
                    const Text('Could not load notifications',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(repo.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: repo.loadActivities,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // ── Filter chips ─────────────────────────────────────────
              _FilterBar(repo: repo),
              const Divider(height: 1, color: AppColors.border),

              // ── List ─────────────────────────────────────────────────
              Expanded(
                child: repo.activities.isEmpty
                    ? _empty()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async => repo.refresh(),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: repo.activities.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            indent: 68,
                            color: AppColors.border,
                          ),
                          itemBuilder: (ctx, i) => _ActivityTile(
                            activity: repo.activities[i],
                            onTap: () => _openDetail(repo.activities[i]),
                            onDelete: () =>
                                _showDeleteConfirmation(repo.activities[i]),
                            typeConfig: _typeConfig(repo.activities[i].type),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Map<String, dynamic> _typeConfig(ActivityType t) => switch (t) {
        ActivityType.post => {
            'icon': LucideIcons.messageSquare,
            'color': AppColors.primary,
            'label': 'Post',
          },
        ActivityType.alert => {
            'icon': LucideIcons.siren,
            'color': AppColors.warning,
            'label': 'Alert',
          },
        ActivityType.evacuation => {
            'icon': LucideIcons.mapPin,
            'color': AppColors.danger,
            'label': 'Evacuation',
          },
        ActivityType.rescue => {
            'icon': LucideIcons.shield,
            'color': AppColors.success,
            'label': 'Rescue',
          },
      };

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.inbox,
                  size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text('No notifications yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Activities will appear here.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondaryLight)),
          ],
        ),
      );

  void _openDetail(Activity a) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: sl<ActivityRepository>(),
            child: ActivityDetailScreen(activity: a),
          ),
        ),
      );

  // ── Delete dialogs ────────────────────────────────────────────────────────

  void _showDeleteConfirmation(Activity a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete activity',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text('Remove "${a.title}" from your activity?',
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondaryLight)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => _deleteActivity(a),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _deleteActivity(Activity a) async {
    Navigator.pop(context);
    EasyLoading.show(status: 'Deleting...');
    try {
      final ok = await context.read<ActivityRepository>()
          .deleteActivity(a, userID ?? '');
      EasyLoading.dismiss();
      ok
          ? EasyLoading.showSuccess('Deleted')
          : EasyLoading.showError('Failed to delete');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $e');
    }
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Clear all activity',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: const Text(
            'This will permanently delete all your activity. This cannot be undone.',
            style: TextStyle(
                fontSize: 14, color: AppColors.textSecondaryLight)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: _deleteAllActivities,
            child: const Text('Clear all',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _deleteAllActivities() async {
    Navigator.pop(context);
    EasyLoading.show(status: 'Clearing...');
    try {
      final results = await context.read<ActivityRepository>()
          .deleteAllUserActivities(userID ?? '');
      EasyLoading.dismiss();
      final n = (results['posts'] ?? 0) +
          (results['alerts'] ?? 0) +
          (results['evacuations'] ?? 0) +
          (results['rescues'] ?? 0);
      n > 0
          ? EasyLoading.showSuccess('Cleared $n activities')
          : EasyLoading.showError('Nothing to clear');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $e');
    }
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final ActivityRepository repo;
  const _FilterBar({required this.repo});

  static const _filters = [
    (null, 'All', LucideIcons.list),
    (ActivityType.post, 'Posts', LucideIcons.messageSquare),
    (ActivityType.alert, 'Alerts', LucideIcons.siren),
    (ActivityType.evacuation, 'Evacuations', LucideIcons.mapPin),
    (ActivityType.rescue, 'Rescues', LucideIcons.shield),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final (type, label, icon) = _filters[i];
          final selected = repo.selectedFilter == type;
          return GestureDetector(
            onTap: () => repo.setFilter(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.gray100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 13,
                      color: selected ? Colors.white : AppColors.gray500),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Activity tile ─────────────────────────────────────────────────────────────

class _ActivityTile extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Map<String, dynamic> typeConfig;

  const _ActivityTile({
    required this.activity,
    required this.onTap,
    required this.onDelete,
    required this.typeConfig,
  });

  @override
  Widget build(BuildContext context) {
    final color = typeConfig['color'] as Color;
    final icon = typeConfig['icon'] as IconData;
    final canDelete = activity.userId == userID && activity.userId != 'system';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeago.format(activity.createdAt, locale: 'en_short'),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.gray400),
                      ),
                      if (canDelete) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onDelete,
                          child: const Icon(LucideIcons.trash2,
                              size: 14, color: AppColors.danger),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    activity.description,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondaryLight),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activity.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin,
                            size: 11, color: AppColors.gray400),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            activity.location!,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.gray400),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
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
      itemCount: 8,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 68, color: AppColors.border),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Bone(width: 38, height: 38, radius: 19),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Bone(width: 140, height: 12, radius: 6),
                      const Spacer(),
                      _Bone(width: 36, height: 10, radius: 5),
                    ],
                  ),
                  const SizedBox(height: 7),
                  _Bone(width: double.infinity, height: 11, radius: 5),
                  const SizedBox(height: 4),
                  _Bone(width: 180, height: 11, radius: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double width, height, radius;
  const _Bone(
      {required this.width, required this.height, required this.radius});

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
