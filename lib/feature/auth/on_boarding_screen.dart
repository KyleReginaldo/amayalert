// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/buttons/custom_buttons.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/constant/constant.dart';

@RoutePage()
class OnBoardingScreen extends StatefulWidget implements AutoRouteWrapper {
  final void Function(bool success)? onResult;

  const OnBoardingScreen({super.key, this.onResult});

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ProfileRepository>(),
      child: this,
    );
  }

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  void completeOnboarding() {
    // sl<SharedPreferences>().setBool('onboarding_done', true);
    widget.onResult?.call(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/amaya.jpg'),
            fit: BoxFit.cover,
            opacity: 0.4,
          ),
          color: Colors.black,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            CustomText(
              text: 'Welcome to',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            CustomText(
              text: 'AMAYALERT',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            Spacer(),
            CustomElevatedButton(
              label: 'Sign In',
              onPressed: () async {
                bool? reload = await context.router.push(SignInRoute());
                if (reload == true) {
                  completeOnboarding();
                }
              },
              backgroundColor: AppTheme.lightTheme.primaryColor,
              foregroundColor: Colors.white,
              borderRadius: 50,
            ),
            SizedBox(height: 10),
            CustomOutlinedButton(
              label: 'Create an Account',
              onPressed: () async {
                bool? reload = await context.router.push(SignUpRoute());
                if (reload == true) {
                  completeOnboarding();
                }
              },
              borderRadius: 50,
              foregroundColor: Color(0xFF0BA6DF),
              borderColor: Color(0xFF0BA6DF),
            ),
            SizedBox(height: 10),
            CustomOutlinedButton(
              label: 'Continue as Guest',

              onPressed: () async {
                final auth = await supabase.auth.signInAnonymously();
                debugPrint('anon user: ${auth.user}');
                if (auth.user != null) {
                  await supabase.from('users').insert({
                    'full_name': 'Guest User',
                    'id': auth.user!.id,
                    'email':
                        'guest_${DateTime.now().millisecondsSinceEpoch}@gmail.com',
                  });
                  if (mounted) {
                    context.read<ProfileRepository>().clear();
                    userID = supabase.auth.currentUser?.id;
                  }
                  completeOnboarding();
                }
              },
              borderRadius: 50,
              icon: LucideIcons.hatGlasses,
              foregroundColor: Color.fromARGB(255, 255, 255, 255),
              borderColor: Color.fromARGB(255, 255, 255, 255),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
