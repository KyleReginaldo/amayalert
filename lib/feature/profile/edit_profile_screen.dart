import 'dart:io';

import 'package:amayalert/core/dto/user.dto.dart';
import 'package:amayalert/core/services/smtp_mailer.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/buttons/custom_buttons.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/maps/custom_google_places_field.dart';
import 'package:amayalert/feature/profile/profile_model.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/router/app_route.gr.dart';

@RoutePage()
class EditProfileScreen extends StatefulWidget {
  final Profile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  String? _selectedSuffix;
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();

  String? selectedGender;
  DateTime? selectedBirthDate;
  File? selectedProfileImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  bool _hasChanges = false;
  Profile? _originalProfile;

  @override
  void initState() {
    super.initState();
    _originalProfile = widget.profile;
    _populateFields();
  }

  void _populateFields() {
    // If name parts exist use them; otherwise fall back to splitting fullName
    if (widget.profile.firstName != null || widget.profile.lastName != null) {
      firstNameController.text = widget.profile.firstName ?? '';
      middleNameController.text = widget.profile.middleName ?? '';
      lastNameController.text = widget.profile.lastName ?? '';
    } else {
      final parts = widget.profile.fullName.trim().split(RegExp(r'\s+'));
      if (parts.length == 1) {
        firstNameController.text = parts[0];
      } else if (parts.length == 2) {
        firstNameController.text = parts[0];
        lastNameController.text = parts[1];
      } else {
        firstNameController.text = parts.first;
        lastNameController.text = parts.last;
        middleNameController.text = parts
            .sublist(1, parts.length - 1)
            .join(' ');
      }
    }
    _selectedSuffix = widget.profile.suffix;
    emailController.text = widget.profile.email;
    if (widget.profile.phoneNumber != null) {
      phoneNumberController.text = widget.profile.phoneNumber!;
    }

    // Normalize gender to match dropdown values
    final profileGender = widget.profile.gender?.toLowerCase();
    if (profileGender == 'male') {
      selectedGender = 'Male';
    } else if (profileGender == 'female') {
      selectedGender = 'Female';
    } else {
      selectedGender = widget.profile.gender;
    }

    selectedBirthDate = widget.profile.birthDate;
    addressController.text = widget.profile.address ?? '';

    // Listen for changes
    firstNameController.addListener(_onFieldChanged);
    middleNameController.addListener(_onFieldChanged);
    lastNameController.addListener(_onFieldChanged);
    emailController.addListener(_onFieldChanged);
    phoneNumberController.addListener(_onFieldChanged);
    addressController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final hasChanges =
        firstNameController.text != (_originalProfile?.firstName ?? '') ||
        middleNameController.text != (_originalProfile?.middleName ?? '') ||
        lastNameController.text != (_originalProfile?.lastName ?? '') ||
        _selectedSuffix != _originalProfile?.suffix ||
        emailController.text != _originalProfile?.email ||
        phoneNumberController.text != _originalProfile?.phoneNumber ||
        selectedGender != _originalProfile?.gender ||
        selectedBirthDate != _originalProfile?.birthDate ||
        addressController.text != (_originalProfile?.address ?? '') ||
        selectedProfileImage != null;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  static const _suffixes = ['Jr.', 'Sr.', 'II', 'III', 'IV'];

  Widget _buildSuffixDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSuffix,
          hint: const Text(
            'None',
            style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondaryLight,
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
          onChanged: (v) {
            setState(() => _selectedSuffix = v);
            _onFieldChanged();
          },
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            CustomText(
              text: 'Select Profile Photo',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImagePickerOption(
                  icon: LucideIcons.camera,
                  label: 'Camera',
                  // close sheet immediately then open camera
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.camera);
                  },
                ),
                _ImagePickerOption(
                  icon: LucideIcons.image,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.gallery);
                  },
                ),
                if (selectedProfileImage != null ||
                    widget.profile.profilePicture != null)
                  _ImagePickerOption(
                    icon: LucideIcons.trash2,
                    label: 'Remove',
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage();
                    },
                  ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          selectedProfileImage = File(image.path);
        });
        _onFieldChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _removeImage() {
    setState(() {
      selectedProfileImage = null;
    });
    _onFieldChanged();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || !_hasChanges) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileRepository = GetIt.instance<ProfileRepository>();
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Convert File to XFile if image was selected
      XFile? imageFile;
      if (selectedProfileImage != null) {
        imageFile = XFile(selectedProfileImage!.path);
      }

      // Create UpdateUserDTO with the form data
      final updateDto = UpdateUserDTO(
        firstName:
            firstNameController.text.trim() != (widget.profile.firstName ?? '')
            ? firstNameController.text.trim()
            : null,
        middleName:
            middleNameController.text.trim() !=
                (widget.profile.middleName ?? '')
            ? middleNameController.text.trim()
            : null,
        lastName:
            lastNameController.text.trim() != (widget.profile.lastName ?? '')
            ? lastNameController.text.trim()
            : null,
        suffix: _selectedSuffix != widget.profile.suffix
            ? _selectedSuffix
            : null,
        gender: selectedGender != widget.profile.gender ? selectedGender : null,
        birthDate: selectedBirthDate != widget.profile.birthDate
            ? selectedBirthDate
            : null,
        imageFile: imageFile,
        address: addressController.text.trim() != (widget.profile.address ?? '')
            ? addressController.text.trim()
            : null,
      );

      // Call the repository method
      final success = await profileRepository.updateUserProfile(
        userId: userId,
        dto: updateDto,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Pop back to profile screen
          context.router.maybePop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startPhoneChangeFlow() async {
    final profileRepository = GetIt.instance<ProfileRepository>();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    String newPhone = '';

    final sendResult = await showDialog<bool?>(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          title: const Text('Change phone number'),
          content: TextField(
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Enter new phone number',
            ),
            onChanged: (v) => newPhone = v.trim(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            CustomElevatedButton(
              label: 'Send OTP',
              isFullWidth: false,

              onPressed: () {
                if (newPhone.isEmpty) return;
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );

    if (sendResult != true || newPhone.isEmpty) return;

    // Request OTP via server
    final email = emailController.text.trim();
    final sendOtpResult = await sendEmailOtp(email, newPhone);
    if (sendOtpResult.isError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: ${sendOtpResult.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP sent to your email')));
    }
    // Push a dedicated OTP verification screen which handles entry, resend and server verification.
    final sentCode = sendOtpResult.value;
    final verificationResult = await context.router.push<bool>(
      OtpVerificationRoute(
        email: email,
        sentOtp: sentCode,
        newPhone: newPhone,
        userId: userId,
      ),
    );

    // If verification failed or was cancelled, stop the flow
    if (verificationResult != true) return;

    // Refresh profile and update UI
    await profileRepository.getUserProfile(userId);
    final updated = profileRepository.profile;
    if (updated != null) {
      setState(() {
        phoneNumberController.text = updated.phoneNumber ?? '';
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Phone number updated')));
    }
  }

  Future<void> _startEmailChangeFlow() async {
    final profileRepository = GetIt.instance<ProfileRepository>();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    String newEmail = '';

    final confirmResult = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          title: const Text('Change email address'),
          content: TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter new email address',
            ),
            onChanged: (v) => newEmail = v.trim(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            CustomElevatedButton(
              label: 'Update',
              isFullWidth: false,
              onPressed: () {
                if (newEmail.isEmpty || !newEmail.contains('@')) return;
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );

    if (confirmResult != true || newEmail.isEmpty) return;

    // Show loading
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Updating email...')));
    }

    // Call the changeEmail method
    final result = await profileRepository.changeEmail(userId, newEmail);

    if (result.isError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update email: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Refresh profile and update UI
    await profileRepository.getUserProfile(userId);
    final updated = profileRepository.profile;
    if (updated != null) {
      setState(() {
        emailController.text = updated.email;
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email address updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.profile.firstName?.isNotEmpty == true
        ? widget.profile.firstName![0].toUpperCase()
        : widget.profile.fullName.isNotEmpty
        ? widget.profile.fullName[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: AppColors.textPrimaryLight,
            size: 20,
          ),
          onPressed: () => context.router.pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Avatar ──────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: selectedProfileImage != null
                              ? Image.file(
                                  selectedProfileImage!,
                                  fit: BoxFit.cover,
                                )
                              : widget.profile.profilePicture != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.profile.profilePicture!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  widget.profile.displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Center(
                child: Text(
                  widget.profile.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray400,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Name ────────────────────────────────────────────────
              _sectionLabel('Name'),
              const SizedBox(height: 8),
              _card(
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            'First Name *',
                            firstNameController,
                            hint: 'Juan',
                            validator: (v) =>
                                v!.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            'Last Name *',
                            lastNameController,
                            hint: 'Dela Cruz',
                            validator: (v) =>
                                v!.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _field(
                            'Middle Name',
                            middleNameController,
                            hint: 'Santos',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Suffix'),
                              const SizedBox(height: 6),
                              _buildSuffixDropdown(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Contact ─────────────────────────────────────────────
              _sectionLabel('Contact'),
              const SizedBox(height: 8),
              _card(
                Column(
                  children: [
                    _label('Email'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: emailController,
                      hint: 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                      suffixIcon: IconButton(
                        color: AppColors.primary,
                        onPressed: _startEmailChangeFlow,
                        icon: const Icon(LucideIcons.pencil, size: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _label('Phone'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: phoneNumberController,
                      hint: '+63XXXXXXXXXX',
                      readOnly: true,
                      keyboardType: TextInputType.phone,
                      suffixIcon: IconButton(
                        color: AppColors.primary,
                        onPressed: _startPhoneChangeFlow,
                        icon: const Icon(LucideIcons.pencil, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Personal ─────────────────────────────────────────────
              _sectionLabel('Personal'),
              const SizedBox(height: 8),
              _card(
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Sex'),
                              const SizedBox(height: 6),
                              Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedGender,
                                    hint: const Text(
                                      'Select',
                                      style: TextStyle(
                                        color: AppColors.gray400,
                                        fontSize: 14,
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: const Icon(
                                      LucideIcons.chevronDown,
                                      size: 16,
                                      color: AppColors.gray500,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Male',
                                        child: Text(
                                          'Male',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Female',
                                        child: Text(
                                          'Female',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      setState(() => selectedGender = v);
                                      _onFieldChanged();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Birth Date'),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        selectedBirthDate ?? DateTime(2000),
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => selectedBirthDate = picked);
                                    _onFieldChanged();
                                  }
                                },
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.calendar,
                                        size: 16,
                                        color: AppColors.gray500,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        selectedBirthDate != null
                                            ? '${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}'
                                            : 'Select',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: selectedBirthDate != null
                                              ? AppColors.textPrimaryLight
                                              : AppColors.gray400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Address ─────────────────────────────────────────────
              _sectionLabel('Address'),
              const SizedBox(height: 8),
              _card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Home Address'),
                    const SizedBox(height: 6),
                    CustomGooglePlacesTextField(
                      controller: addressController,
                      hintText: 'Enter your address',
                      onSuggestionClicked: (result) {
                        addressController
                            .selection = TextSelection.fromPosition(
                          TextPosition(offset: addressController.text.length),
                        );
                        _onFieldChanged();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: (_hasChanges && !_isLoading) ? _saveProfile : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.gray200,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _hasChanges ? 'Save Changes' : 'No Changes',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Widget _card(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );

  Widget _sectionLabel(String text) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.gray400,
      letterSpacing: 0.7,
    ),
  );

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondaryLight,
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    String? Function(String?)? validator,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      const SizedBox(height: 6),
      CustomTextField(controller: controller, hint: hint, validator: validator),
    ],
  );
}

class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          SizedBox(height: 8),
          CustomText(
            text: label,
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }
}
