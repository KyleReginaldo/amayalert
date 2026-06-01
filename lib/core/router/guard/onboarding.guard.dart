import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      try {
        final data = await Supabase.instance.client
            .from('users')
            .select('status, verification_status')
            .eq('id', userId)
            .single();
        final status = data['status'] as String?;
        final verificationStatus = data['verification_status'] as String?;
        if (status == 'pending' || verificationStatus == 'pending') {
          resolver.redirectUntil(const PendingReviewRoute());
          return;
        }
      } catch (_) {}
    }
    resolver.next(true);
  }
}
