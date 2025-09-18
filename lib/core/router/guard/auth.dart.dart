import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      resolver.next(true);
    } else {
      resolver.redirectUntil(
        OnBoardingRoute(
          onResult: (success) {
            if (success) {
              resolver.next(true);
            }
          },
        ),
      );
    }
  }
}
