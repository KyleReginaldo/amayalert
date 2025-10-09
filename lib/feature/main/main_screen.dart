import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/services/badge_service.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/notification_badge.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../core/router/app_route.gr.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    onesignalLogin();
    super.initState();
  }

  void onesignalLogin() async {
    if (userID != null) {
      await OneSignal.login(userID!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: [
        HomeRoute(),
        MessageRoute(),
        MapRoute(),
        ActivityRoute(),
        ProfileRoute(),
      ],

      bottomNavigationBuilder: (_, tabsRouter) {
        return ListenableBuilder(
          listenable: BadgeService(),
          builder: (context, _) {
            return BottomNavigationBar(
              currentIndex: tabsRouter.activeIndex,
              selectedItemColor: AppTheme.lightTheme.primaryColor,
              unselectedItemColor: AppTheme.lightTheme.disabledColor,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: false,
              showSelectedLabels: false,
              onTap: tabsRouter.setActiveIndex,
              items: [
                const BottomNavigationBarItem(
                  label: '',
                  icon: Icon(LucideIcons.house),
                ),
                BottomNavigationBarItem(
                  label: '',
                  icon: NotificationBadge(
                    count: BadgeService().unreadMessageCount,
                    child: const Icon(LucideIcons.messageCircle),
                  ),
                ),
                const BottomNavigationBarItem(
                  label: '',
                  icon: Icon(LucideIcons.mapPin),
                ),
                const BottomNavigationBarItem(
                  label: '',
                  icon: Icon(LucideIcons.bell),
                ),
                const BottomNavigationBarItem(
                  label: '',
                  icon: Icon(LucideIcons.circleUser),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
