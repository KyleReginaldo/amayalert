import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/buttons/custom_buttons.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:auto_route/auto_route.dart';
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
  final phoneNumberController = TextEditingController();

  int? gender; // 0 for male, 1 for female
  DateTime? birthDate;
  bool obscurePassword = true;

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

  void handleSignUp() async {
    final String fullName = fullNameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String phoneNumber = phoneNumberController.text;
    final int? genderValue = gender;
    final DateTime? birthDateValue = birthDate;

    // Validate password before proceeding
    final passwordValidation = _validatePassword(password);
    if (passwordValidation != null) {
      EasyLoading.showError(passwordValidation);
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
            CustomText(text: 'Full Name'),
            CustomTextField(
              controller: fullNameController,
              hint: 'John Doe',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            // Email Field
            CustomText(text: 'Email'),
            CustomTextField(
              controller: emailController,
              hint: 'janet@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            // Password Field
            CustomText(text: 'Password'),
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
            // Phone Number Field
            CustomText(text: 'Phone Number'),
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
            CustomText(text: 'Gender'),
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
            CustomText(text: 'Birth Date'),
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
            CustomElevatedButton(label: 'Sign Up', onPressed: handleSignUp),
          ],
        ),
      ),
    );
  }
}
