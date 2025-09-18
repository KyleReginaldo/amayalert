import 'package:amayalert/core/theme/theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/router/app_route.gr.dart';

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          selectedItemColor: AppTheme.lightTheme.primaryColor,
          unselectedItemColor: AppTheme.lightTheme.disabledColor,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          onTap: tabsRouter.setActiveIndex,
          items: const [
            BottomNavigationBarItem(label: '', icon: Icon(LucideIcons.house)),
            BottomNavigationBarItem(
              label: '',
              icon: Icon(LucideIcons.messageCircle),
            ),
            BottomNavigationBarItem(label: '', icon: Icon(LucideIcons.mapPin)),
            BottomNavigationBarItem(label: '', icon: Icon(LucideIcons.bell)),
            BottomNavigationBarItem(
              label: '',
              icon: Icon(LucideIcons.circleUser),
            ),
          ],
        );
      },
    );
  }
}
