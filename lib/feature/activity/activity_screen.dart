import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
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
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const CustomText(
          text: 'Activity',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.gray50,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              context.read<ActivityRepository>().refresh();
            },
            icon: Icon(LucideIcons.refreshCw, color: AppColors.gray600),
          ),
          Consumer<ActivityRepository>(
            builder: (context, activityRepo, _) {
              final userActivities = activityRepo.activities
                  .where((a) => a.userId == userID)
                  .toList();

              if (userActivities.isEmpty) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppColors.gray600),
                onSelected: (value) {
                  if (value == 'delete_all') {
                    _showDeleteAllConfirmation();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.trash2,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        CustomText(
                          text: 'Delete All My Activities',
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ActivityRepository>(
        builder: (context, activityRepo, child) {
          if (activityRepo.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (activityRepo.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.x, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  CustomText(
                    text: 'Error loading activities',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: activityRepo.error!,
                    fontSize: 14,
                    color: AppColors.gray600,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => activityRepo.loadActivities(),
                    child: const CustomText(text: 'Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildFilterSection(activityRepo),

                const SizedBox(height: 16),

                _buildActivitiesList(activityRepo.activities),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(ActivityRepository activityRepo) {
    final filters = <Map<String, dynamic>>[
      {'label': 'All', 'type': null, 'icon': LucideIcons.list},
      {
        'label': 'Posts',
        'type': ActivityType.post,
        'icon': LucideIcons.messageSquare,
      },
      {'label': 'Alerts', 'type': ActivityType.alert, 'icon': LucideIcons.zap},
      {
        'label': 'Evacuations',
        'type': ActivityType.evacuation,
        'icon': LucideIcons.mapPin,
      },
      {
        'label': 'Rescues',
        'type': ActivityType.rescue,
        'icon': LucideIcons.shield,
      },
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = activityRepo.selectedFilter == filter['type'];

          return GestureDetector(
            onTap: () =>
                activityRepo.setFilter(filter['type'] as ActivityType?),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.gray300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.gray600,
                  ),
                  const SizedBox(width: 6),
                  CustomText(
                    text: filter['label'] as String,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.gray700,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivitiesList(List<Activity> activities) {
    if (activities.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.inbox, size: 48, color: AppColors.gray400),
              const SizedBox(height: 16),
              CustomText(
                text: 'No activities found',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (context, index) =>
            Divider(color: AppColors.gray200, height: 24),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityItem(activity);
        },
      ),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    final typeConfig = _getActivityTypeConfig(activity.type);
    final currentUserId = userID; // Get current user ID from constants
    final canDelete =
        activity.userId == currentUserId && activity.userId != 'system';

    return GestureDetector(
      onTap: () => _navigateToActivityDetail(activity),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeConfig['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                typeConfig['icon'],
                size: 20,
                color: typeConfig['color'],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: activity.title,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      CustomText(
                        text: timeago.format(activity.createdAt),
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                      if (canDelete) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showDeleteConfirmation(activity),
                          child: Icon(
                            LucideIcons.trash2,
                            size: 16,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: activity.description,
                    fontSize: 13,
                    color: AppColors.gray600,
                    maxLines: 2,
                  ),
                  if (activity.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 12,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: CustomText(
                            text: activity.location!,
                            fontSize: 12,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (activity.userName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.user,
                          size: 12,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                        CustomText(
                          text: activity.userName!,
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.eye, size: 12, color: AppColors.gray400),
                      const SizedBox(width: 4),
                      CustomText(
                        text: 'Tap to view details',
                        fontSize: 11,
                        color: AppColors.gray400,
                      ),
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

  Map<String, dynamic> _getActivityTypeConfig(ActivityType type) {
    switch (type) {
      case ActivityType.post:
        return {'icon': LucideIcons.messageSquare, 'color': AppColors.primary};
      case ActivityType.alert:
        return {'icon': LucideIcons.zap, 'color': AppColors.warning};
      case ActivityType.evacuation:
        return {'icon': LucideIcons.mapPin, 'color': AppColors.error};
      case ActivityType.rescue:
        return {'icon': LucideIcons.shield, 'color': AppColors.success};
    }
  }

  void _navigateToActivityDetail(Activity activity) {
    // Use MaterialPageRoute for now since the route isn't set up in AutoRouter yet
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: sl<ActivityRepository>(),
          child: ActivityDetailScreen(activity: activity),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Activity activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Delete Activity',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text:
                    'Are you sure you want to delete this ${activity.type.name}?',
                fontSize: 16,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: activity.title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: activity.description,
                      fontSize: 12,
                      color: AppColors.gray600,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const CustomText(
                text: 'This action cannot be undone.',
                fontSize: 14,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: CustomText(text: 'Cancel', color: AppColors.gray600),
            ),
            ElevatedButton(
              onPressed: () => _deleteActivity(activity),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const CustomText(
                text: 'Delete',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteActivity(Activity activity) async {
    Navigator.of(context).pop(); // Close dialog

    EasyLoading.show(status: 'Deleting ${activity.type.name}...');

    try {
      final activityRepo = context.read<ActivityRepository>();
      final success = await activityRepo.deleteActivity(activity, userID ?? '');

      EasyLoading.dismiss();

      if (success) {
        final typeName =
            activity.type.name[0].toUpperCase() +
            activity.type.name.substring(1);
        EasyLoading.showSuccess('$typeName deleted successfully');
      } else {
        EasyLoading.showError('Failed to delete ${activity.type.name}');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
    }
  }

  void _showDeleteAllConfirmation() {
    final activityRepo = context.read<ActivityRepository>();
    final userActivities = activityRepo.activities
        .where((a) => a.userId == userID)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Delete All Activities',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'Are you sure you want to delete all your activities?',
                fontSize: 16,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'This will delete:',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),
                    ...ActivityType.values.map((type) {
                      final count = userActivities
                          .where((a) => a.type == type)
                          .length;
                      if (count > 0) {
                        final typeName =
                            type.name[0].toUpperCase() + type.name.substring(1);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                _getActivityTypeConfig(type)['icon'],
                                size: 16,
                                color: _getActivityTypeConfig(type)['color'],
                              ),
                              const SizedBox(width: 8),
                              CustomText(
                                text: '$count $typeName${count > 1 ? 's' : ''}',
                                fontSize: 12,
                                color: AppColors.gray600,
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const CustomText(
                text: 'This action cannot be undone.',
                fontSize: 14,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: CustomText(text: 'Cancel', color: AppColors.gray600),
            ),
            ElevatedButton(
              onPressed: () => _deleteAllActivities(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const CustomText(
                text: 'Delete All',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllActivities() async {
    Navigator.of(context).pop(); // Close dialog

    EasyLoading.show(status: 'Deleting all activities...');

    try {
      final activityRepo = context.read<ActivityRepository>();
      final results = await activityRepo.deleteAllUserActivities(userID ?? '');

      EasyLoading.dismiss();

      final totalDeleted =
          results['posts']! +
          results['alerts']! +
          results['evacuations']! +
          results['rescues']!;
      final errors = results['errors']!;

      if (totalDeleted > 0) {
        if (errors > 0) {
          EasyLoading.showToast(
            'Deleted $totalDeleted activities with $errors errors',
          );
        } else {
          EasyLoading.showSuccess(
            'Successfully deleted $totalDeleted activities',
          );
        }
      } else {
        EasyLoading.showError('Failed to delete activities');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
    }
  }
}
