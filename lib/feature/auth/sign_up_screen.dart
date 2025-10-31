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

  void handleSignUp() async {
    final String fullName = fullNameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String phoneNumber = phoneNumberController.text;
    final int? genderValue = gender;
    final DateTime? birthDateValue = birthDate;

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
        birthDate: birthDateValue!,
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
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
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
