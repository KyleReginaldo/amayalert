import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/services/smtp_mailer.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/buttons/custom_buttons.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    EasyLoading.show(status: 'Sending verification code...');

    try {
      final result = await sendForgotPasswordOtp(_emailController.text.trim());

      if (result.isSuccess) {
        EasyLoading.showSuccess('Verification code sent successfully!');

        // Navigate to OTP verification screen
        if (mounted) {
          context.router.push(
            ForgotPasswordOtpRoute(email: _emailController.text.trim()),
          );
        }
      } else {
        EasyLoading.showError(result.error);
      }
    } catch (e) {
      debugPrint('An error occured: $e');
      EasyLoading.showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      EasyLoading.dismiss();
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const CustomText(
          text: 'Reset Password',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.gray50,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Title
              const CustomText(
                text: 'Forgot Password?',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              const CustomText(
                text: 'Enter your email to receive a verification code',
                fontSize: 16,
                color: AppColors.gray600,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Email Field
              CustomTextField(
                controller: _emailController,
                hint: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                prefixIcon: Icon(
                  LucideIcons.mail,
                  size: 20,
                  color: AppColors.gray500,
                ),
              ),

              const SizedBox(height: 32),

              // Send Button
              CustomElevatedButton(
                label: 'Send Code',
                onPressed: _isLoading ? null : _handleSendResetEmail,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                size: ButtonSize.lg,
              ),

              const SizedBox(height: 24),

              // Back to Sign In
              CustomTextButton(
                label: 'Back to Sign In',
                onPressed: () {
                  context.router.pop();
                },
                foregroundColor: AppColors.gray600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
