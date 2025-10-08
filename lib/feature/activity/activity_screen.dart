import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/activity/activity_model.dart';
import 'package:amayalert/feature/activity/activity_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: typeConfig['color'].withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(typeConfig['icon'], size: 20, color: typeConfig['color']),
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
                    Icon(LucideIcons.user, size: 12, color: AppColors.gray500),
                    const SizedBox(width: 4),
                    CustomText(
                      text: activity.userName!,
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
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
}
