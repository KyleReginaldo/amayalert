import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/buttons/custom_buttons.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/auth/auth_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    EasyLoading.show(status: 'Changing password...');

    try {
      final result = await AuthProvider().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (result.isSuccess) {
        EasyLoading.showSuccess(result.value);
        if (mounted) {
          // Clear form
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();

          // Go back to settings
          context.router.pop();
        }
      } else {
        EasyLoading.showError(result.error);
      }
    } catch (e) {
      EasyLoading.showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      EasyLoading.dismiss();
    }
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one symbol (!@#\$%^&*...)';
    }
    if (value == _currentPasswordController.text &&
        _currentPasswordController.text.isNotEmpty) {
      return 'New password must be different from current password';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
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
          text: 'Change Password',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.gray50,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 20,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomText(
                        text:
                            'Your password must be at least 8 characters long, contain uppercase and lowercase letters, numbers, and symbols.',
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Current Password Field
              const CustomText(
                text: 'Current Password',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _currentPasswordController,
                hint: 'Enter your current password',
                obscureText: _obscureCurrentPassword,
                validator: _validateCurrentPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? LucideIcons.eyeOff
                        : LucideIcons.eye,
                    color: AppColors.textSecondaryLight,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

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

              // Confirm New Password Field
              const CustomText(
                text: 'Confirm New Password',
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

              // Change Password Button
              CustomElevatedButton(
                label: 'Change Password',
                onPressed: _isLoading ? null : _handleChangePassword,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                size: ButtonSize.lg,
                icon: _isLoading ? null : LucideIcons.key,
              ),

              const SizedBox(height: 16),

              // Security tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.shield,
                          size: 18,
                          color: AppColors.gray600,
                        ),
                        const SizedBox(width: 8),
                        const CustomText(
                          text: 'Password Security Tips',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityTip(
                      'Use a mix of letters, numbers, and symbols',
                    ),
                    _buildSecurityTip('Make it at least 8 characters long'),
                    _buildSecurityTip('Avoid using personal information'),
                    _buildSecurityTip(
                      'Don\'t reuse passwords from other accounts',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(LucideIcons.check, size: 14, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: text,
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
