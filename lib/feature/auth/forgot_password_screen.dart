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
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

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

    EasyLoading.show(status: 'Sending reset email...');

    try {
      final result = await AuthProvider().resetPassword(
        email: _emailController.text.trim(),
      );

      if (result.isSuccess) {
        setState(() {
          _emailSent = true;
        });
        EasyLoading.showSuccess('Reset email sent successfully!');
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

  void _handleResendEmail() async {
    setState(() {
      _isLoading = true;
    });

    EasyLoading.show(status: 'Resending email...');

    try {
      final result = await AuthProvider().resetPassword(
        email: _emailController.text.trim(),
      );

      if (result.isSuccess) {
        EasyLoading.showSuccess('Reset email sent again!');
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Image/Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        _emailSent ? LucideIcons.mailCheck : LucideIcons.mail,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomText(
                      text: _emailSent
                          ? 'Check Your Email'
                          : 'Forgot Password?',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      text: _emailSent
                          ? 'We\'ve sent password reset instructions to your email address.'
                          : 'No worries! Enter your email address and we\'ll send you instructions to reset your password.',
                      fontSize: 16,
                      color: AppColors.gray600,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (!_emailSent) ...[
                // Email Field
                const CustomText(
                  text: 'Email Address',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 8),
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

                const SizedBox(height: 24),

                // Send Reset Email Button
                CustomElevatedButton(
                  label: 'Send Reset Email',
                  onPressed: _isLoading ? null : _handleSendResetEmail,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  size: ButtonSize.lg,
                  icon: _isLoading ? null : LucideIcons.send,
                ),
              ] else ...[
                // Email sent success state
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.check,
                            size: 20,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 8),
                          CustomText(
                            text: 'Email Sent Successfully',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CustomText(
                        text: 'Reset instructions sent to:',
                        fontSize: 14,
                        color: Colors.green.shade600,
                      ),
                      CustomText(
                        text: _emailController.text.trim(),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons for email sent state
                CustomElevatedButton(
                  label: 'Resend Email',
                  onPressed: _isLoading ? null : _handleResendEmail,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  size: ButtonSize.lg,
                  icon: _isLoading ? null : LucideIcons.refreshCw,
                ),

                const SizedBox(height: 12),

                CustomOutlinedButton(
                  label: 'Try Different Email',
                  onPressed: () {
                    setState(() {
                      _emailSent = false;
                      _emailController.clear();
                    });
                  },
                  borderColor: AppColors.primary,
                  foregroundColor: AppColors.primary,
                  size: ButtonSize.lg,
                ),
              ],

              const SizedBox(height: 24),

              // Back to Sign In
              CustomTextButton(
                label: 'Back to Sign In',
                onPressed: () {
                  context.router.pop();
                },
                foregroundColor: AppColors.gray600,
              ),

              const SizedBox(height: 16),

              // Instructions
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
                          LucideIcons.info,
                          size: 18,
                          color: AppColors.gray600,
                        ),
                        const SizedBox(width: 8),
                        const CustomText(
                          text: 'What happens next?',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep(
                      '1',
                      'Check your email inbox (and spam folder)',
                    ),
                    _buildInstructionStep(
                      '2',
                      'Click the reset link in the email',
                    ),
                    _buildInstructionStep('3', 'Enter your new password'),
                    _buildInstructionStep(
                      '4',
                      'Sign in with your new password',
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

  Widget _buildInstructionStep(String stepNumber, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomText(
                text: stepNumber,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              text: instruction,
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
