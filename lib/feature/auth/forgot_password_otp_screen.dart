import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/services/smtp_mailer.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/buttons/custom_buttons.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pinput/pinput.dart';

@RoutePage()
class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;

  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleVerifyOtp() async {
    if (_pinController.text.trim().length != 6) {
      EasyLoading.showError('Please enter a valid 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    EasyLoading.show(status: 'Verifying OTP...');

    try {
      // Verify OTP with database
      final response = await supabase
          .from('phone_verifications')
          .select()
          .eq('email', widget.email)
          .eq('code', _pinController.text.trim())
          .gte('expires_at', DateTime.now().toIso8601String())
          .maybeSingle();

      if (response != null) {
        // OTP is valid, navigate to reset password screen
        EasyLoading.dismiss();
        if (mounted) {
          context.router.push(ResetPasswordRoute());
        }
      } else {
        EasyLoading.showError('Invalid or expired OTP. Please try again.');
      }
    } catch (e) {
      EasyLoading.showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleResendOtp() async {
    setState(() {
      _isResending = true;
    });

    EasyLoading.show(status: 'Resending OTP...');

    try {
      final result = await sendForgotPasswordOtp(widget.email);
      if (result.isSuccess) {
        EasyLoading.showSuccess('OTP sent successfully!');
      } else {
        EasyLoading.showError(result.error);
      }
    } catch (e) {
      EasyLoading.showError('Failed to resend OTP: $e');
    } finally {
      setState(() {
        _isResending = false;
      });
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const CustomText(
          text: 'Verify Code',
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
                text: 'Enter Verification Code',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              CustomText(
                text: 'Code sent to ${widget.email}',
                fontSize: 16,
                color: AppColors.gray600,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // OTP Field
              Pinput(
                length: 6,
                controller: _pinController,
                focusNode: _focusNode,
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray300),
                    color: Colors.white,
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 2),
                    color: Colors.white,
                  ),
                ),
                submittedPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                    color: AppColors.primary.withOpacity(0.05),
                  ),
                ),
                errorPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 2),
                    color: Colors.red.withOpacity(0.05),
                  ),
                ),
                separatorBuilder: (index) => const SizedBox(width: 12),
                validator: (value) {
                  if (value == null || value.length != 6) {
                    return 'Please enter a valid 6-digit code';
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'Code must contain only digits';
                  }
                  return null;
                },
                onCompleted: (pin) {
                  // Auto-verify when 6 digits are entered
                  _handleVerifyOtp();
                },
                onChanged: (value) {
                  // Clear any previous error state
                  if (_formKey.currentState?.validate() == false) {
                    setState(() {});
                  }
                },
              ),

              const SizedBox(height: 32),

              // Verify Button
              CustomElevatedButton(
                label: 'Verify Code',
                onPressed: _isLoading ? null : _handleVerifyOtp,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                size: ButtonSize.lg,
              ),

              const SizedBox(height: 24),

              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomText(
                    text: 'Didn\'t receive the code? ',
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                  TextButton(
                    onPressed: _isResending ? null : _handleResendOtp,
                    child: CustomText(
                      text: _isResending ? 'Resending...' : 'Resend',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isResending
                          ? AppColors.gray400
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Back Button
              CustomTextButton(
                label: 'Back',
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
