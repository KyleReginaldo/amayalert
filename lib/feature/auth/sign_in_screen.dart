import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/services/auth_storage_service.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/buttons/custom_buttons.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/auth/auth_provider.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/text/custom_text.dart';

@RoutePage()
class SignInScreen extends StatefulWidget implements AutoRouteWrapper {
  final void Function(bool success)? onResult;
  const SignInScreen({super.key, this.onResult});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ProfileRepository>(),
      child: this,
    );
  }
}

class _SignInScreenState extends State<SignInScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscureText = true;
  bool rememberMe = false;
  late AuthStorageService _authStorage;

  @override
  void initState() {
    super.initState();
    _authStorage = sl<AuthStorageService>();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final savedCredentials = await _authStorage.getSavedCredentials();
    final isRememberMeEnabled = _authStorage.isRememberMeEnabled();

    if (mounted) {
      setState(() {
        rememberMe = isRememberMeEnabled;
        if (savedCredentials['email'] != null) {
          email.text = savedCredentials['email']!;
        }
        if (savedCredentials['password'] != null) {
          password.text = savedCredentials['password']!;
        }
      });
    }
  }

  void handleSignIn() async {
    EasyLoading.show(status: 'Signing In...');
    final result = await AuthProvider().signIn(
      email: email.text,
      password: password.text,
    );
    if (result.isError) {
      EasyLoading.dismiss();
      EasyLoading.showError(result.error);
    } else {
      // Save credentials based on remember me checkbox
      await _authStorage.saveCredentials(
        email: email.text,
        password: password.text,
        rememberMe: rememberMe,
      );

      EasyLoading.dismiss();
      if (mounted) {
        context.read<ProfileRepository>().clear();
        userID = supabase.auth.currentUser?.id;
        context.read<ProfileRepository>().getUserProfile(userID ?? "");
      }
      EasyLoading.showSuccess(result.value);

      if (mounted) {
        context.router.maybePop(true);
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/phone.png', height: 300),
            CustomText(
              text: 'Sign In',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
            CustomText(
              text: 'Welcome back, you\'ve been missed!',
              fontSize: 16,
              color: AppColors.textSecondaryLight,
            ),
            CustomText(text: 'Email'),
            CustomTextField(
              controller: email,
              hint: 'janet@example.com',
              validator: (value) {
                if (!value!.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            CustomText(text: 'Password'),
            CustomTextField(
              controller: password,
              hint: '********',
              obscureText: obscureText,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondaryLight,
                ),
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
              ),
            ),
            CheckboxListTile.adaptive(
              value: rememberMe,
              onChanged: (value) {
                setState(() {
                  rememberMe = value ?? false;
                });
              },
              title: CustomText(text: 'Remember me'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            ),
            CustomElevatedButton(label: 'Sign In', onPressed: handleSignIn),
            CustomTextButton(
              label: 'Forgot password?',
              onPressed: () {
                context.router.push(const ForgotPasswordRoute());
              },
            ),
          ],
        ),
      ),
    );
  }
}
