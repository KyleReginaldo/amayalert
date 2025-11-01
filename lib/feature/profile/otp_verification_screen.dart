import 'dart:async';

import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../core/services/smtp_mailer.dart';
import '../../core/theme/theme.dart';

@RoutePage()
/// A simple, aesthetic OTP entry screen that also supports resending the OTP.
class OtpVerificationScreen extends StatefulWidget implements AutoRouteWrapper {
  final String email;
  final String sentOtp;
  final String newPhone;
  final String userId;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.sentOtp,
    required this.newPhone,
    required this.userId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ProfileRepository>(),
      child: this,
    );
  }
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isResending = false;
  String? _currentSentOtp;
  // removed hidden focus; Pinput will handle input
  Timer? _resendTimer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _currentSentOtp = widget.sentOtp;
  }

  @override
  void dispose() {
    _codeController.dispose();
    // no hidden focus to dispose
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    setState(() {
      _isResending = true;
      _secondsLeft = 30;
    });
    _startResendCountdown();
    final result = await sendEmailOtp(widget.email, widget.newPhone);
    setState(() => _isResending = false);
    if (result.isError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend OTP: ${result.error}')),
        );
      }
      return;
    }
    setState(() {
      _currentSentOtp = result.value;
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP resent to your email')));
    }
  }

  Future<void> _verify() async {
    final input = _codeController.text.trim();
    if (input.isEmpty) return;

    // First, local check against sent OTP
    if (_currentSentOtp == null || input != _currentSentOtp) {
      // no-op: verification flag removed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid code. Please try again.')),
        );
      }
      return;
    }

    // Then call the repository to perform server-side verification / update
    final profileRepository = sl<ProfileRepository>();
    final verify = await profileRepository.verifyPhoneChangeOtp(
      userId: widget.userId,
      newPhone: widget.newPhone,
      code: input,
    );

    // no-op: verification flag removed

    if (verify.isError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${verify.error}')),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number updated successfully')),
      );
    }

    // Return true to the caller to indicate success
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft -= 1;
        } else {
          _resendTimer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.18),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.shield, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Verify OTP',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Enter the 6-digit code sent to',
                    style: TextStyle(color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.email,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Pinput (responsive)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 12.0;
                      final availableWidth = constraints.maxWidth;
                      final rawBoxSize =
                          (availableWidth - spacing * (6 - 1)) / 6;
                      final boxSize = rawBoxSize.clamp(40.0, 56.0);

                      final defaultPinTheme = PinTheme(
                        width: boxSize,
                        height: boxSize * 1.05,
                        textStyle: TextStyle(
                          fontSize: boxSize * 0.45,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                          fontFamily: 'monospace',
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                      );

                      final focusedPinTheme = defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: AppColors.primary),
                        ),
                      );

                      return Center(
                        child: Pinput(
                          length: 6,
                          controller: _codeController,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          followingPinTheme: defaultPinTheme,
                          pinAnimationType: PinAnimationType.scale,
                          onChanged: (v) => setState(() {}),
                          onCompleted: (pin) async {
                            // auto-verify when completed
                            await _verify();
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: (_isResending || _secondsLeft > 0)
                            ? null
                            : _resend,
                        child: _isResending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _secondsLeft > 0
                                    ? 'Resend in ${_secondsLeft}s'
                                    : 'Resend code',
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
