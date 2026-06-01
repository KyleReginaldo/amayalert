import 'dart:convert';
import 'dart:io';

import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constant/constant.dart';
import '../../core/dto/user.dto.dart';
import '../../core/router/app_route.gr.dart';
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
  int _currentStep = 0;

  // Step 1 controllers
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  String? _selectedSuffix;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Step 2 controllers
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  int? gender; // 0 = male, 1 = female
  DateTime? birthDate;

  // Step 3
  File? idImageFile;
  bool isTermsAccepted = false;
  bool _hasReadTerms = false;
  bool _hasReadPrivacyPolicy = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() => setState(() {}));
    phoneNumberController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    final errors = <String>[];
    if (value.length < 8) errors.add('At least 8 characters');
    if (!RegExp(r'[A-Z]').hasMatch(value)) errors.add('One uppercase letter');
    if (!RegExp(r'[a-z]').hasMatch(value)) errors.add('One lowercase letter');
    if (!RegExp(r'[0-9]').hasMatch(value)) errors.add('One number');
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      errors.add('One special character');
    }
    if (errors.isNotEmpty) return 'Password must contain: ${errors.join(', ')}';
    return null;
  }

  bool _validateStep1() {
    if (firstNameController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter your first name');
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter your last name');
      return false;
    }
    if (!emailController.text.contains('@')) {
      EasyLoading.showError('Please enter a valid email address');
      return false;
    }
    final pwErr = _validatePassword(passwordController.text);
    if (pwErr != null) {
      EasyLoading.showError(pwErr);
      return false;
    }
    if (confirmPasswordController.text != passwordController.text) {
      EasyLoading.showError('Passwords do not match');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (phoneNumberController.text.trim().length != 10) {
      EasyLoading.showError('Please enter a valid 10-digit phone number');
      return false;
    }
    if (gender == null) {
      EasyLoading.showError('Please select your gender');
      return false;
    }
    if (birthDate == null) {
      EasyLoading.showError('Please select your birth date');
      return false;
    }
    if (addressController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter your home address');
      return false;
    }
    return true;
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _nextStep() {
    if (_currentStep == 0 && !_validateStep1()) return;
    if (_currentStep == 1 && !_validateStep2()) return;
    setState(() => _currentStep++);
  }

  void _previousStep() => setState(() => _currentStep--);

  // ── Image picker ──────────────────────────────────────────────────────────

  Future<void> _sendAdminVerificationEmail(
    String userId,
    String userEmail,
    String name,
  ) async {
    // Link to admin users page with the user pre-selected for review
    final verifyLink = 'https://amayalert.site/users?id=$userId';

    final body = jsonEncode({
      'to': 'amayalert1@gmail.com',
      'subject': 'New Resident Registration — Verify ID',
      'html':
          '''
        <p>A new resident has registered and is waiting for ID verification.</p>
        <table>
          <tr><td><b>Name</b></td><td>$name</td></tr>
          <tr><td><b>Email</b></td><td>$userEmail</td></tr>
          <tr><td><b>User ID</b></td><td>$userId</td></tr>
        </table>
        <br/>
        <a href="$verifyLink"
           style="background:#1D6BF3;color:#fff;padding:10px 20px;
                  border-radius:8px;text-decoration:none;font-weight:bold;">
          Review &amp; Verify on Admin Dashboard
        </a>
        <p style="color:#888;font-size:12px;margin-top:16px;">
          Clicking the button opens the admin users page filtered to this resident.
        </p>
      ''',
      'type': 'single-email',
    });

    await http.post(
      Uri.parse('https://amayalert.site/api/email'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
  }

  Future<void> _pickIdImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) setState(() => idImageFile = File(image.path));
  }

  // ── Terms dialogs ─────────────────────────────────────────────────────────

  Future<void> _showTermsDialog() async {
    _hasReadTerms = true;
    await _showCustomDialog('Terms of Service', _termsContent, isTerms: true);
  }

  Future<void> _showPrivacyPolicyDialog() async {
    _hasReadPrivacyPolicy = true;
    await _showCustomDialog('Privacy Policy', _privacyContent, isTerms: false);
  }

  Future<void> _showCustomDialog(
    String title,
    String content, {
    required bool isTerms,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  // ── Create account ────────────────────────────────────────────────────────

  Future<void> _handleCreateAccount() async {
    if (idImageFile == null) {
      EasyLoading.showError('Please upload your Barangay ID');
      return;
    }
    if (!isTermsAccepted) {
      EasyLoading.showError(
        'Please accept the Terms of Service and Privacy Policy',
      );
      return;
    }

    EasyLoading.show(status: 'Creating account...');

    final result = await AuthProvider().signUp(
      dto: CreateUserDTO(
        firstName: firstNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        suffix: _selectedSuffix,
        email: emailController.text.trim(),
        password: passwordController.text,
        phoneNumber: '+63${phoneNumberController.text.trim()}',
        gender: gender == 0 ? 'Male' : 'Female',
        birthDate: birthDate!,
        address: addressController.text.trim(),
      ),
    );

    if (result.isError) {
      EasyLoading.dismiss();
      EasyLoading.showError(result.error);
      return;
    }

    // Upload ID image after account is created
    EasyLoading.show(status: 'Uploading ID...');
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final ext = idImageFile!.path.split('.').last;
        final path =
            'id_${userId}_${DateTime.now().microsecondsSinceEpoch}.$ext';
        final response = await supabase.storage
            .from('files')
            .upload(path, idImageFile!);
        final imageUrl = supabase.storage.from('').getPublicUrl(response);
        await supabase
            .from('users')
            .update({'id_picture': imageUrl})
            .eq('id', userId);
      }
    } catch (_) {
      // Non-critical; proceed to pending screen
    }

    // Send admin notification with verification link
    try {
      final userId = supabase.auth.currentUser?.id;
      final userEmail = supabase.auth.currentUser?.email ?? '';
      final name =
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
      if (userId != null) {
        await _sendAdminVerificationEmail(userId, userEmail, name);
      }
    } catch (_) {
      // Non-critical
    }

    EasyLoading.dismiss();

    if (mounted) {
      context.read<ProfileRepository>().clear();
      userID = supabase.auth.currentUser?.id;
      context.router.replaceAll([const PendingReviewRoute()]);
    }
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepNode(0, LucideIcons.user, 'Account'),
        _buildStepConnector(0),
        _buildStepNode(1, LucideIcons.clipboardList, 'Details'),
        _buildStepConnector(1),
        _buildStepNode(2, LucideIcons.shield, 'Verify'),
      ],
    );
  }

  Widget _buildStepNode(int step, IconData icon, String label) {
    final isCompleted = _currentStep > step;
    final isActive = _currentStep == step;
    final color = (isActive || isCompleted)
        ? AppColors.primary
        : AppColors.gray400;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primary
                : isActive
                ? AppColors.primary
                : AppColors.gray100,
            shape: BoxShape.circle,
            border: Border.all(
              color: (isActive || isCompleted)
                  ? AppColors.primary
                  : AppColors.gray300,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Icon(
            isCompleted ? LucideIcons.check : icon,
            color: (isActive || isCompleted) ? Colors.white : AppColors.gray400,
            size: 18,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int afterStep) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          gradient: _currentStep > afterStep
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primary],
                )
              : null,
          color: _currentStep > afterStep ? null : AppColors.gray200,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              if (title.endsWith(' *'))
                Text.rich(
                  TextSpan(
                    text: title.substring(0, title.length - 2),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    children: const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    final pw = passwordController.text;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password Requirements:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          _reqItem('At least 8 characters', pw.length >= 8),
          _reqItem('One uppercase letter (A-Z)', RegExp(r'[A-Z]').hasMatch(pw)),
          _reqItem('One lowercase letter (a-z)', RegExp(r'[a-z]').hasMatch(pw)),
          _reqItem('One number (0-9)', RegExp(r'[0-9]').hasMatch(pw)),
          _reqItem(
            'One special character (!@#\$%^&*)',
            RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pw),
          ),
        ],
      ),
    );
  }

  Widget _reqItem(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? LucideIcons.checkCheck : LucideIcons.x,
            size: 13,
            color: met ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: met ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _suffixes = ['Jr.', 'Sr.', 'II', 'III', 'IV'];

  Widget _buildSuffixDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSuffix,
          hint: const Text(
            'None',
            style: TextStyle(color: AppColors.gray400, fontSize: 14),
          ),
          isExpanded: true,
          icon: const Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: AppColors.gray500,
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('None', style: TextStyle(fontSize: 14)),
            ),
            ..._suffixes.map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
          onChanged: (v) => setState(() => _selectedSuffix = v),
        ),
      ),
    );
  }

  Widget _buildGenderToggle() {
    return Row(
      children: [
        Expanded(child: _genderButton(0, LucideIcons.personStanding, 'Male')),
        const SizedBox(width: 12),
        Expanded(child: _genderButton(1, LucideIcons.personStanding, 'Female')),
      ],
    );
  }

  Widget _genderButton(int value, IconData icon, String label) {
    final selected = gender == value;
    return GestureDetector(
      onTap: () => setState(() => gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.gray300,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.primary : AppColors.gray500,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.gray600,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdUploadArea() {
    if (idImageFile != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              idImageFile!,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _pickIdImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  LucideIcons.pencil,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickIdImage,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.cloudUpload,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap to upload ID',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'JPG, PNG — clear and readable',
              style: TextStyle(color: AppColors.gray500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: isTermsAccepted,
            activeColor: AppColors.primary,
            onChanged: (value) async {
              if (value == true) {
                if (!_hasReadTerms) await _showTermsDialog();
                if (_hasReadTerms && !_hasReadPrivacyPolicy)
                  await _showPrivacyPolicyDialog();
                if (_hasReadTerms && _hasReadPrivacyPolicy)
                  setState(() => isTermsAccepted = true);
              } else {
                setState(() => isTermsAccepted = false);
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'I agree to the ',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimaryLight,
              ),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _showTermsDialog,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _showPrivacyPolicyDialog,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Step content builders ─────────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      children: [
        _buildSectionCard(
          icon: LucideIcons.user,
          title: 'Personal Information',
          children: [
            // First + Last on one row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('First Name *'),
                      CustomTextField(
                        controller: firstNameController,
                        hint: 'Juan',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Last Name *'),
                      CustomTextField(
                        controller: lastNameController,
                        hint: 'Dela Cruz',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Middle Name + Suffix on one row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Middle Name'),
                      CustomTextField(
                        controller: middleNameController,
                        hint: 'Santos',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_fieldLabel('Suffix'), _buildSuffixDropdown()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _fieldLabel('Email Address'),
            CustomTextField(
              controller: emailController,
              hint: 'juan@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(
                LucideIcons.mail,
                color: AppColors.gray500,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          icon: LucideIcons.lockKeyhole,
          title: 'Password',
          children: [
            _fieldLabel('Password'),
            CustomTextField(
              controller: passwordController,
              hint: '••••••••',
              obscureText: obscurePassword,
              prefixIcon: const Icon(
                LucideIcons.lockKeyhole,
                color: AppColors.gray500,
                size: 18,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  color: AppColors.gray500,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => obscurePassword = !obscurePassword),
              ),
            ),
            if (passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildPasswordRequirements(),
            ],
            const SizedBox(height: 14),
            _fieldLabel('Confirm Password'),
            CustomTextField(
              controller: confirmPasswordController,
              hint: '••••••••',
              obscureText: obscureConfirmPassword,
              prefixIcon: const Icon(
                LucideIcons.lockKeyhole,
                color: AppColors.gray500,
                size: 18,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  color: AppColors.gray500,
                  size: 20,
                ),
                onPressed: () => setState(
                  () => obscureConfirmPassword = !obscureConfirmPassword,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final phoneLen = phoneNumberController.text.length;
    return Column(
      children: [
        _buildSectionCard(
          icon: LucideIcons.phone,
          title: 'Contact',
          children: [
            _fieldLabel('Phone Number'),
            Stack(
              children: [
                CustomTextField(
                  controller: phoneNumberController,
                  hint: '9XXXXXXXXX',
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇵🇭', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          '+63',
                          style: const TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: AppColors.gray300,
                          margin: const EdgeInsets.only(left: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          icon: LucideIcons.clipboardList,
          title: 'About You',
          children: [
            _fieldLabel('Sex'),
            _buildGenderToggle(),
            const SizedBox(height: 14),
            _fieldLabel('Birth Date'),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: birthDate ?? DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => birthDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      color: AppColors.gray500,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      birthDate != null
                          ? '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}'
                          : 'Select birth date',
                      style: TextStyle(
                        color: birthDate != null
                            ? AppColors.textPrimaryLight
                            : AppColors.gray500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _fieldLabel('Home Address'),
            GooglePlacesAutoCompleteTextFormField(
              textEditingController: addressController,
              googleAPIKey: dotenv.get('GOOGLE_MAP'),
              debounceTime: 400,
              countries: const ['ph'],
              inputDecoration: InputDecoration(
                hintText: 'Enter your address',
                hintStyle: const TextStyle(color: AppColors.gray500),
                prefixIcon: const Icon(
                  LucideIcons.mapPin,
                  color: AppColors.gray500,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.gray300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.gray300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              itmClick: (Prediction prediction) {
                addressController.text = prediction.description ?? '';
                addressController.selection = TextSelection.fromPosition(
                  TextPosition(offset: addressController.text.length),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        _buildSectionCard(
          icon: LucideIcons.idCard,
          title: 'Barangay ID *',
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.info, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Upload a photo of your Barangay Amaya V ID or clearance to verify your residency.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildIdUploadArea(),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          icon: LucideIcons.fileText,
          title: 'Terms & Privacy',
          children: [_buildTermsCheckbox()],
        ),
      ],
    );
  }

  // ── Navigation buttons ────────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    if (_currentStep == 0) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 6),
              Icon(LucideIcons.arrowRight, size: 18),
            ],
          ),
        ),
      );
    }

    if (_currentStep == 2) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.gray300),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.arrowLeft,
                    size: 16,
                    color: AppColors.textSecondaryLight,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Previous',
                    style: TextStyle(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: _handleCreateAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 6),
                  Icon(LucideIcons.userCheck, size: 18),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Step 1 → 2
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: _previousStep,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: AppColors.gray300),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.arrowLeft,
                  size: 16,
                  color: AppColors.textSecondaryLight,
                ),
                SizedBox(width: 4),
                Text(
                  'Previous',
                  style: TextStyle(color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 6),
                Icon(LucideIcons.arrowRight, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrowLeft,
            size: 20,
            color: AppColors.textPrimaryLight,
          ),
          onPressed: _currentStep == 0
              ? () => context.router.maybePop()
              : _previousStep,
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.shield,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${_currentStep + 1} of 3',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ['Account', 'Details', 'Verify'][_currentStep],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: AppColors.gray200,
            color: AppColors.primary,
            minHeight: 3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            _buildStepIndicator(),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(_currentStep),
                child: _currentStep == 0
                    ? _buildStep1()
                    : _currentStep == 1
                    ? _buildStep2()
                    : _buildStep3(),
              ),
            ),
            const SizedBox(height: 20),
            _buildBottomButtons(),
            if (_currentStep == 0) ...[
              const SizedBox(height: 16),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray500,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.router.maybePop(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Static text content ───────────────────────────────────────────────────

  static const _termsContent = '''Agreement to Terms
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

Privacy and Data
Your use of Amayalert is also governed by our Privacy Policy.

Limitation of Liability
Amayalert and its operators shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.

Governing Law
These terms shall be interpreted and governed in accordance with the laws of the jurisdiction in which Amayalert operates.''';

  static const _privacyContent = '''Introduction
Welcome to Amayalert. We are committed to protecting your privacy and ensuring the security of your personal information while providing emergency services.

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
4. Opt-out of non-emergency comms''';
}
