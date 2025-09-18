import 'dart:io';

import 'package:amayalert/core/dto/user.dto.dart';
import 'package:amayalert/core/theme/theme.dart';
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
    phoneNumberController.text = widget.profile.phoneNumber;

    // Normalize gender to match dropdown values
    final profileGender = widget.profile.gender.toLowerCase();
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
                  onTap: () => _getImage(ImageSource.camera),
                ),
                _ImagePickerOption(
                  icon: LucideIcons.image,
                  label: 'Gallery',
                  onTap: () => _getImage(ImageSource.gallery),
                ),
                if (selectedProfileImage != null ||
                    widget.profile.profilePicture != null)
                  _ImagePickerOption(
                    icon: LucideIcons.trash2,
                    label: 'Remove',
                    onTap: () => _removeImage(),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }

    Navigator.pop(context);
  }

  void _removeImage() {
    setState(() {
      selectedProfileImage = null;
    });
    Navigator.pop(context);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Pop back to profile screen
        context.router.maybePop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: CustomText(
          text: 'Edit Profile',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimaryLight),
          onPressed: () => context.router.pop(),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : CustomText(
                      text: 'Save',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Main Profile Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 3,
                                  ),
                                ),
                                child: selectedProfileImage != null
                                    ? ClipOval(
                                        child: Image.file(
                                          selectedProfileImage!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      )
                                    : widget.profile.profilePicture == null
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.primary,
                                      )
                                    : ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              widget.profile.profilePicture!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.primary),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                                Icons.person,
                                                size: 50,
                                                color: AppColors.primary,
                                              ),
                                        ),
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: selectedProfileImage != null
                                    ? 'Photo Selected'
                                    : 'Edit Photo',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimaryLight,
                              ),
                              CustomText(
                                text: selectedProfileImage != null
                                    ? 'Tap to change photo'
                                    : 'Tap to add a profile photo',
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Full Name
                    CustomText(
                      text: 'Full Name',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryLight,
                    ),
                    SizedBox(height: 6),
                    CustomTextField(
                      controller: fullNameController,
                      hint: 'Enter your full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Email
                    CustomText(
                      text: 'Email Address',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryLight,
                    ),
                    SizedBox(height: 6),
                    CustomTextField(
                      controller: emailController,
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Phone Number
                    CustomText(
                      text: 'Phone Number',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryLight,
                    ),
                    SizedBox(height: 6),
                    CustomTextField(
                      controller: phoneNumberController,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Gender
                    CustomText(
                      text: 'Gender',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryLight,
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedGender,
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
                            DropdownMenuItem<String>(
                              value: 'Male',
                              child: CustomText(text: 'Male'),
                            ),
                            DropdownMenuItem<String>(
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
                    SizedBox(height: 16),

                    // Birth Date
                    CustomText(
                      text: 'Birth Date',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryLight,
                    ),
                    SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedBirthDate ?? DateTime(2000),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: selectedBirthDate != null
                                  ? '${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}'
                                  : 'Select your birth date',
                              color: selectedBirthDate != null
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
                  ],
                ),
              ),
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
              color: AppColors.primary.withOpacity(0.1),
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
