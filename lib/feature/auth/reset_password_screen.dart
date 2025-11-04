import 'dart:convert';

import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/buttons/custom_buttons.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    EasyLoading.show(status: 'Updating password...');

    try {
      // Get the email and user_id from the most recent valid verification
      final verification = await supabase
          .from('phone_verifications')
          .select('email, user_id')
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (verification == null) {
        EasyLoading.showError(
          'Verification session expired. Please restart the process.',
        );
        return;
      }

      final email = verification['email'] as String;
      final userId = verification['user_id'] as String?;

      debugPrint('Found verification for email: $email');
      debugPrint('User ID from verification: $userId');

      // Get the user ID if not available in verification
      String? actualUserId = userId;
      if (actualUserId == null || actualUserId.isEmpty) {
        // Try to get user by email from your user/profile table
        final userProfile = await supabase
            .from('users') // Change this to your actual user table name
            .select('id')
            .eq('email', email)
            .single();

        actualUserId = userProfile['id'] as String;
        debugPrint('Found user ID from profiles: $actualUserId');
      }

      debugPrint('Using user ID: $actualUserId');

      // Since you don't have RPC or password_resets table,
      // let's use Supabase's built-in password update
      final response = await http.post(
        Uri.parse('https://amayalert.site/api/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'PostmanRuntime/7.39.0',
        },
        body: jsonEncode({
          'userId': actualUserId,
          'newPassword': _newPasswordController.text,
        }),
      );
      debugPrint('API response data: ${response.body}');
      if (response.statusCode == 200) {
        debugPrint('Password reset successful via API');
      } else {
        debugPrint(
          'Failed to reset password via API: ${response.statusCode} - ${response.body}',
        );
        EasyLoading.showError('Failed to reset password. Please try again.');
        return;
      }

      // Clean up the verification record
      await supabase.from('phone_verifications').delete().eq('email', email);

      EasyLoading.showSuccess(
        'Password reset completed! You can now sign in with your new password.',
      );

      if (mounted) {
        context.router.popUntilRoot();
      }
    } catch (e) {
      debugPrint('General error: $e');
      EasyLoading.showError('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
      EasyLoading.dismiss();
    }
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    List<String> errors = [];

    if (value.length < 8) {
      errors.add('At least 8 characters');
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      errors.add('One uppercase letter');
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      errors.add('One lowercase letter');
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      errors.add('One number');
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      errors.add('One special character');
    }

    if (errors.isNotEmpty) {
      return 'Password must contain: ${errors.join(', ')}';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
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
        automaticallyImplyLeading: false,
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
                text: 'Set New Password',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              const CustomText(
                text: 'Create a strong password for your account',
                fontSize: 16,
                color: AppColors.gray600,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // New Password Field
              const CustomText(
                text: 'New Password',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _newPasswordController,
                hint: 'Enter your new password',
                obscureText: _obscureNewPassword,
                validator: _validateNewPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: AppColors.textSecondaryLight,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Confirm Password Field
              const CustomText(
                text: 'Confirm Password',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _confirmPasswordController,
                hint: 'Confirm your new password',
                obscureText: _obscureConfirmPassword,
                validator: _validateConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? LucideIcons.eyeOff
                        : LucideIcons.eye,
                    color: AppColors.textSecondaryLight,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Update Password Button
              CustomElevatedButton(
                label: 'Update Password',
                onPressed: _isLoading ? null : _handleResetPassword,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                size: ButtonSize.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
