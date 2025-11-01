import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../router/app_route.dart';
import '../router/app_route.gr.dart';

class DeepLinkHandler {
  static StreamSubscription<AuthState>? _authSubscription;
  static AppRouter? _appRouter;

  static void initialize(AppRouter appRouter) {
    _appRouter = appRouter;
    _setupAuthListener();
  }

  static void _setupAuthListener() {
    // Listen for authentication state changes, including password recovery
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (kDebugMode) {
        print('Auth state changed: ${data.event}');
      }

      if (data.event == AuthChangeEvent.passwordRecovery) {
        if (kDebugMode) {
          print(
            'Password recovery event detected - navigating to reset password screen',
          );
        }
        // Navigate to reset password screen
        _navigateToResetPassword();
      }
    });
  }

  static void _navigateToResetPassword() {
    if (_appRouter != null) {
      if (kDebugMode) {
        print('Navigating to ResetPasswordRoute');
      }
      _appRouter!.push(const ResetPasswordRoute());
    } else {
      if (kDebugMode) {
        print('AppRouter is null - cannot navigate');
      }
    }
  }

  static void dispose() {
    _authSubscription?.cancel();
  }
}
