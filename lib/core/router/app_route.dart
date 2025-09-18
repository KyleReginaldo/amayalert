import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/router/guard/onboarding.guard.dart';
import 'package:auto_route/auto_route.dart';

import 'guard/auth.dart.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    CustomRoute(
      page: MainRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      initial: true,
      guards: [OnboardingGuard(), AuthGuard()],
      children: [
        CustomRoute(
          page: HomeRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          page: MessageRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          page: MapRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          page: ActivityRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          page: ProfileRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
      ],
    ),
    CustomRoute(
      page: SignInRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: SignUpRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: OnBoardingRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: EditProfileRoute.page,
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: CreatePostsRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
    ),
  ];
}
