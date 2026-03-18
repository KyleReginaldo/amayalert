import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/buttons/custom_buttons.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../../core/constant/constant.dart';
import '../../core/dto/user.dto.dart';
import '../../dependency.dart';
import '../profile/profile_repository.dart';
import 'auth_provider.dart';

@RoutePage()
class SignUpScreen extends StatefulWidget implements AutoRouteWrapper {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ProfileRepository>(),
      child: this,
    );
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneNumberController = TextEditingController();

  int? gender; // 0 for male, 1 for female
  DateTime? birthDate;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isTermsAccepted = false;
  bool _hasReadTerms = false;
  bool _hasReadPrivacyPolicy = false;

  @override
  void initState() {
    super.initState();
    // Add listener to password controller to update requirements in real-time
    passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
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

  Widget _buildPasswordRequirements() {
    final password = passwordController.text;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Password Requirements:',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
          SizedBox(height: 8),
          _buildRequirementItem('At least 8 characters', password.length >= 8),
          _buildRequirementItem(
            'One uppercase letter (A-Z)',
            RegExp(r'[A-Z]').hasMatch(password),
          ),
          _buildRequirementItem(
            'One lowercase letter (a-z)',
            RegExp(r'[a-z]').hasMatch(password),
          ),
          _buildRequirementItem(
            'One number (0-9)',
            RegExp(r'[0-9]').hasMatch(password),
          ),
          _buildRequirementItem(
            'One special character (!@#\$%^&*)',
            RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String requirement, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isMet ? Colors.green : Colors.red,
          ),
          SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: requirement,
              fontSize: 12,
              color: isMet ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTermsDialog() async {
    await _showCustomDialog(
      'Terms of Service',
      '''Agreement to Terms
By accessing and using Amayalert, you accept and agree to be bound by these terms and provisions.

Welcome to Amayalert ("Service"). These Terms of Service govern your use of our emergency alert and rescue coordination platform. If you do not agree to abide by these terms, please do not use this service.

Service Description
Amayalert is a comprehensive emergency alert and rescue coordination platform that provides:

Alert Services
• Emergency alert notifications via SMS and push notifications
• Real-time emergency communication tools

Coordination Services
• Rescue request reporting and coordination
• Evacuation center location and status info
• Emergency response coordination for auth personnel

User Responsibilities

Accurate Information
You agree to provide accurate, current, and complete information about yourself and maintain the accuracy of such information. This is crucial for emergency response effectiveness.

Emergency Use Only
You agree to use rescue request features only for genuine emergencies. False emergency reports may result in account suspension and legal consequences.

Device and Network Requirements
• Maintain a compatible mobile device
• Ensure network connectivity for comms
• Keep location services enabled
• Keep the application updated

Prohibited Activities
To ensure the safety and integrity of our emergency services, you may not:
• Submit false emergency reports or rescue requests
• Interfere with emergency response operations
• Use the service for commercial purposes without authorization
• Attempt to access administrative features without proper credentials
• Share your account credentials with unauthorized persons
• Use the service in any way that could harm emergency response efforts

Service Availability
While we strive to provide continuous service, Amayalert may be temporarily unavailable due to maintenance, technical issues, or circumstances beyond our control. We do not guarantee uninterrupted service and are not liable for service interruptions.

Emergency Limitations

Critical Notice
Amayalert is a supplementary emergency tool. In life-threatening situations, always contact local emergency services (911, 112, etc.) first.

Response Time Variations
Times may vary based on local emergency services

Technical Dependencies
Service depends on network and device functionality

Response Responsibility
We are not responsible for response actions/outcomes

Backup Methods
Always have backup emergency communication methods

Privacy and Data
Your use of Amayalert is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices regarding your personal information.

Limitation of Liability
Amayalert and its operators shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your use of the service.

Account Termination
We may terminate or suspend your account at any time for:
• Violation of these terms
• False emergency reporting
• Misuse of emergency services
• Failure to provide accurate info

Changes to Terms
We reserve the right to modify these terms at any time. We will notify users of significant changes via the application or email. Your continued use of the service after such modifications constitutes acceptance of the updated terms.

Governing Law
These terms shall be interpreted and governed in accordance with the laws of the jurisdiction in which Amayalert operates, without regard to conflict of law provisions.''',
      isTerms: true,
    );
  }

  Future<void> _showPrivacyPolicyDialog() async {
    await _showCustomDialog('Privacy Policy', '''Introduction
Welcome to Amayalert. We are committed to protecting your privacy and ensuring the security of your personal information while providing emergency services.

This Privacy Policy explains how Amayalert collects, uses, discloses, and safeguards your information when you use our emergency alert and rescue coordination mobile application and administrative dashboard.

Data We Collect

Personal Information
• Full name and contact info
• Phone number for SMS alerts
• Email address for account
• Optional profile picture
• Birth date and gender (for EMS)

Location & Emergency
• GPS coordinates for reports
• Location for evacuation info
• Address information
• Rescue requests data
• Responder communications

How We Use Your Information
We use your information exclusively for emergency services and safety purposes:
• Provide emergency alert notifications
• Coordinate rescue and emergency operations
• Send SMS alerts for safety warnings
• Direct you to nearest evacuation centers
• Improve emergency response services
• Communicate with responders on your behalf

Information Sharing
We may share your information only in these specific circumstances:

Emergency Responders
Local authorities, rescue teams, and medical personnel during active emergencies

Government Agencies
Disaster management offices and public safety departments

Service Providers
SMS gateway providers for alert delivery

Legal Requirements
When required by law or to protect public safety

Data Security
We implement comprehensive security measures to protect your personal information:
• End-to-end encryption for all data transmission
• Restricted access controls for authorized personnel only
• 24/7 security monitoring and threat detection

Your Rights
1. Access your personal information
2. Correct inaccurate information
3. Request deletion (subject to EMS laws)
4. Opt-out of non-emergency comms''', isTerms: false);
  }

  Future<void> _showCustomDialog(
    String title,
    String content, {
    required bool isTerms,
  }) async {
    if (isTerms) {
      _hasReadTerms = true;
    } else {
      _hasReadPrivacyPolicy = true;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Text(
                content,
                style: const TextStyle(height: 1.5, fontSize: 14),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text(
              'I Understand',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void handleSignUp() async {
    final String fullName = fullNameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;
    final String phoneNumber = phoneNumberController.text;
    final int? genderValue = gender;
    final DateTime? birthDateValue = birthDate;

    // Validate password before proceeding
    final passwordValidation = _validatePassword(password);
    if (passwordValidation != null) {
      EasyLoading.showError(passwordValidation);
      return;
    }

    if (password != confirmPassword) {
      EasyLoading.showError('Passwords do not match');
      return;
    }

    if (!isTermsAccepted) {
      EasyLoading.showError('Please accept the terms and conditions');
      return;
    }

    // Validate other required fields
    if (fullName.trim().isEmpty) {
      EasyLoading.showError('Please enter your full name');
      return;
    }
    if (!email.contains('@')) {
      EasyLoading.showError('Please enter a valid email address');
      return;
    }
    if (phoneNumber.trim().isEmpty) {
      EasyLoading.showError('Please enter your phone number');
      return;
    }
    if (genderValue == null) {
      EasyLoading.showError('Please select your gender');
      return;
    }
    if (birthDateValue == null) {
      EasyLoading.showError('Please select your birth date');
      return;
    }

    debugPrint('Full Name: $fullName');
    debugPrint('Email: $email');
    debugPrint('Password: $password');
    debugPrint('Phone: $phoneNumber');
    debugPrint('Gender: $genderValue');
    debugPrint('Birth Date: $birthDateValue');
    EasyLoading.show(status: 'Signing up...');

    final result = await AuthProvider().signUp(
      dto: CreateUserDTO(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: '+63$phoneNumber',
        gender: (genderValue == 0) ? 'Male' : 'Female',
        birthDate: birthDateValue,
      ),
    );
    if (result.isError) {
      EasyLoading.dismiss();
      EasyLoading.showError(result.error);
    } else {
      EasyLoading.dismiss();
      EasyLoading.showSuccess(result.value);
      if (mounted) {
        context.read<ProfileRepository>().clear();
        userID = supabase.auth.currentUser?.id;

        context.router.maybePop(true);
      }
    }
  }

  Widget _buildRequiredLabel(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(text: text),
        const Text(
          ' *',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ],
    );
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
            CustomText(
              text: 'Sign Up',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
            CustomText(
              text: 'Create your account to get started!',
              fontSize: 16,
              color: AppColors.textSecondaryLight,
            ),
            // Full Name Field
            _buildRequiredLabel('Full Name'),
            CustomTextField(
              controller: fullNameController,
              hint: 'John Doe',
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            // Email Field
            _buildRequiredLabel('Email'),
            CustomTextField(
              controller: emailController,
              hint: 'janet@example.com',
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            // Password Field
            _buildRequiredLabel('Password'),
            CustomTextField(
              controller: passwordController,
              hint: '********',
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondaryLight,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              validator: (value) {
                return _validatePassword(value);
              },
            ),
            // Password Requirements
            if (passwordController.text.isNotEmpty)
              _buildPasswordRequirements(),
            SizedBox(height: 16),
            // Confirm Password Field
            _buildRequiredLabel('Confirm Password'),
            CustomTextField(
              controller: confirmPasswordController,
              hint: '********',
              obscureText: obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.textSecondaryLight,
                ),
                onPressed: () {
                  setState(() {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ), // Phone Number Field
            _buildRequiredLabel('Phone Number'),
            CustomTextField(
              controller: phoneNumberController,
              prefixIcon: CustomTextButton(
                label: '+63',
                foregroundColor: AppColors.textSecondaryLight,
              ),
              hint: '9*********',
              maxLength: 10,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            // Gender Selection
            _buildRequiredLabel('Gender'),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: gender,
                  hint: CustomText(
                    text: 'Select your gender',
                    color: AppColors.textSecondaryLight,
                  ),
                  isExpanded: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondaryLight,
                  ),
                  items: [
                    DropdownMenuItem<int>(
                      value: 0,
                      child: CustomText(text: 'Male'),
                    ),
                    DropdownMenuItem<int>(
                      value: 1,
                      child: CustomText(text: 'Female'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
              ),
            ),
            // Birth Date Selection
            _buildRequiredLabel('Birth Date'),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: birthDate ?? DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != birthDate) {
                  setState(() {
                    birthDate = picked;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: birthDate != null
                          ? '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}'
                          : 'Select your birth date',
                      color: birthDate != null
                          ? AppColors.textPrimaryLight
                          : AppColors.textSecondaryLight,
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.textSecondaryLight,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Terms and Conditions Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isTermsAccepted,
                    onChanged: (value) async {
                      if (value == true) {
                        if (!_hasReadTerms) {
                          await _showTermsDialog();
                        }
                        if (_hasReadTerms && !_hasReadPrivacyPolicy) {
                          await _showPrivacyPolicyDialog();
                        }
                        if (_hasReadTerms && _hasReadPrivacyPolicy) {
                          setState(() {
                            isTermsAccepted = true;
                          });
                        }
                      } else {
                        setState(() {
                          isTermsAccepted = false;
                        });
                      }
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimaryLight,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _showTermsDialog();
                            },
                        ),
                        TextSpan(
                          text: ' and ',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _showPrivacyPolicyDialog();
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            CustomElevatedButton(label: 'Sign Up', onPressed: handleSignUp),
          ],
        ),
      ),
    );
  }
}
