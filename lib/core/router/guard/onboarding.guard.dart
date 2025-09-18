import 'package:auto_route/auto_route.dart';

class OnboardingGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Use the current auth state synchronously here. Attaching a listener
    // inside `onNavigation` can cause multiple events and lead to calling
    // `resolver.next()` more than once which triggers an assertion in
    // auto_route. Check the current user/session and decide once.

    resolver.next(true);
  }
}
