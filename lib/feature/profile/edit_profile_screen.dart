import 'dart:io';

import 'package:amayalert/core/dto/user.dto.dart';
import 'package:amayalert/core/services/smtp_mailer.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/buttons/custom_buttons.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
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
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();

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
    fullNameController.text = widget.profile.fullName;
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

    // Listen for changes
    fullNameController.addListener(_onFieldChanged);
    emailController.addListener(_onFieldChanged);
    phoneNumberController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final hasChanges =
        fullNameController.text != _originalProfile?.fullName ||
        emailController.text != _originalProfile?.email ||
        phoneNumberController.text != _originalProfile?.phoneNumber ||
        selectedGender != _originalProfile?.gender ||
        selectedBirthDate != _originalProfile?.birthDate ||
        selectedProfileImage != null;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
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
        fullName: fullNameController.text.trim() != widget.profile.fullName
            ? fullNameController.text.trim()
            : null,
        gender: selectedGender != widget.profile.gender ? selectedGender : null,
        birthDate: selectedBirthDate != widget.profile.birthDate
            ? selectedBirthDate
            : null,
        imageFile: imageFile,
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimaryLight),
          onPressed: () => context.router.pop(),
        ),
        actions: [
          if (_hasChanges)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size(64, 36),
                  backgroundColor: _isLoading
                      ? Colors.grey[200]
                      : AppColors.primary.withOpacity(0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with avatar and brief info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.12), Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.85),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.16),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: selectedProfileImage != null
                            ? Image.file(
                                selectedProfileImage!,
                                fit: BoxFit.cover,
                              )
                            : (widget.profile.profilePicture != null
                                  ? CachedNetworkImage(
                                      imageUrl: widget.profile.profilePicture!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Text(
                                        widget.profile.fullName.isNotEmpty
                                            ? widget.profile.fullName[0]
                                                  .toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.profile.fullName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.profile.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _pickImage,
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Main Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    CustomText(
                      text: 'Full name',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: fullNameController,
                      hint: 'Enter your full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Full name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Email
                    CustomText(
                      text: 'Email',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: emailController,
                      hint: 'Your email',
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Email is required';
                        if (!value.contains('@'))
                          return 'Enter a valid email address';
                        return null;
                      },
                      suffixIcon: IconButton(
                        color: AppColors.primary,
                        onPressed: _startEmailChangeFlow,
                        icon: Icon(LucideIcons.pencil),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Phone Number + Change button
                    CustomText(
                      text: 'Phone',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 10),
                    // keep field flexible for different devices
                    CustomTextField(
                      controller: phoneNumberController,
                      hint: 'Enter your phone number',
                      readOnly: true,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Phone number is required';
                        return null;
                      },
                      suffixIcon: IconButton(
                        color: AppColors.primary,
                        onPressed: _startPhoneChangeFlow,
                        icon: Icon(LucideIcons.pencil),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender and Birth Date on one row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: 'Gender',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedGender,
                                    hint: CustomText(
                                      text: 'Select',
                                      color: AppColors.textSecondaryLight,
                                    ),
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'Male',
                                        child: CustomText(text: 'Male'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Female',
                                        child: CustomText(text: 'Female'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender = value;
                                      });
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
                              CustomText(
                                text: 'Birth date',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        selectedBirthDate ?? DateTime(2000),
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      selectedBirthDate = picked;
                                    });
                                    _onFieldChanged();
                                  }
                                },
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        text: selectedBirthDate != null
                                            ? '${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}'
                                            : 'Select',
                                        color: AppColors.textPrimaryLight,
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: AppColors.textSecondaryLight,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
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
