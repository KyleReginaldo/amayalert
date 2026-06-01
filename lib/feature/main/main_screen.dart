import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/services/badge_service.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/notification_badge.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/activity/activity_repository.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    _onesignalLogin();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToLocationChanges();
      sl<ActivityRepository>().loadActivities();
    });
    super.initState();
  }

  void _onesignalLogin() async {
    if (userID != null) await OneSignal.login(userID!);
  }

  void _listenToLocationChanges() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      if (userID != null) {
        await supabase.from('users').update({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }).eq('id', userID!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        HomeRoute(),
        MessageRoute(),
        ActivityRoute(),
        ProfileRoute(),
      ],
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _ReportFab(),
      bottomNavigationBuilder: (ctx, tabsRouter) {
        return ListenableBuilder(
          listenable: BadgeService(),
          builder: (context, _) {
            return _BottomNav(tabsRouter: tabsRouter);
          },
        );
      },
    );
  }
}

class _ReportFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.router.push(const CreateRescueRoute()),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final TabsRouter tabsRouter;
  const _BottomNav({required this.tabsRouter});

  @override
  Widget build(BuildContext context) {
    final badge = BadgeService();

    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: LucideIcons.house,
              label: 'Home',
              active: tabsRouter.activeIndex == 0,
              onTap: () => tabsRouter.setActiveIndex(0),
            ),
            _NavItem(
              icon: LucideIcons.messageCircle,
              label: 'Community',
              active: tabsRouter.activeIndex == 1,
              badge: badge.unreadMessageCount,
              onTap: () => tabsRouter.setActiveIndex(1),
            ),
            // Gap for FAB
            const SizedBox(width: 56),
            _NavItem(
              icon: LucideIcons.bell,
              label: 'Notifications',
              active: tabsRouter.activeIndex == 2,
              badge: badge.unreadActivityCount,
              onTap: () {
                tabsRouter.setActiveIndex(2);
                sl<ActivityRepository>().markActivitiesAsRead();
              },
            ),
            _ProfileNavItem(
              active: tabsRouter.activeIndex == 3,
              onTap: () => tabsRouter.setActiveIndex(3),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile nav item — shows real avatar when available ──────────────────────

class _ProfileNavItem extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _ProfileNavItem({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.gray400;
    final profile = sl<ProfileRepository>().profile;
    final hasPic = profile?.profilePicture != null;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              hasPic
                  ? Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: active
                              ? AppColors.primary
                              : AppColors.gray300,
                          width: active ? 2 : 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          profile!.profilePicture!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            LucideIcons.circleUser,
                            size: 22,
                            color: color,
                          ),
                        ),
                      ),
                    )
                  : Icon(LucideIcons.circleUser, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.gray400;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              badge > 0
                  ? NotificationBadge(
                      count: badge,
                      child: Icon(icon, color: color, size: 22),
                    )
                  : Icon(icon, color: color, size: 22),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
