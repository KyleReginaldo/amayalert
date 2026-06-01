import 'dart:io';

import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/dto/post.dto.dart';
import 'package:amayalert/core/services/chat_filter_service.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../dependency.dart';

@RoutePage()
class CreatePostsScreen extends StatefulWidget implements AutoRouteWrapper {
  const CreatePostsScreen({super.key});

  @override
  State<CreatePostsScreen> createState() => _CreatePostsScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ProfileRepository>(),
      child: this,
    );
  }
}

class _CreatePostsScreenState extends State<CreatePostsScreen> {
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _postRepository = PostRepository();

  final List<XFile> _selectedImages = [];
  static const int _maxImages = 5;
  final PostVisibility _selectedVisibility = PostVisibility.public;
  bool _isLoading = false;

  String? _locationAddress;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileRepository>().getUserProfile(userID ?? '');
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // ── Location ─────────────────────────────────────────────────────────────

  Future<void> _getLocation() async {
    if (_locationAddress != null) {
      // Already have location — offer to remove
      setState(() => _locationAddress = null);
      return;
    }

    setState(() => _isLoadingLocation = true);
    try {
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.street != null && p.street!.isNotEmpty) p.street!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty)
            p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
        ];
        if (mounted) {
          setState(() {
            _locationAddress = parts.isNotEmpty
                ? parts.join(', ')
                : 'Current location';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not get location: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  Future<void> _showImageSourceDialog() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 photos allowed.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera, color: AppColors.primary),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image, color: AppColors.primary),
                title: Text(
                    'Gallery${_selectedImages.isNotEmpty ? ' (${_selectedImages.length}/$_maxImages)' : ''}'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages(ImageSource source) async {
    final remaining = _maxImages - _selectedImages.length;
    if (remaining <= 0) return;
    try {
      if (source == ImageSource.camera) {
        final img = await _imagePicker.pickImage(
          source: source, maxWidth: 1080, maxHeight: 1080, imageQuality: 85,
        );
        if (img != null) setState(() => _selectedImages.add(img));
      } else {
        final imgs = await _imagePicker.pickMultiImage(
          maxWidth: 1080, maxHeight: 1080, imageQuality: 85,
        );
        if (imgs.isNotEmpty) {
          setState(() => _selectedImages.addAll(imgs.take(remaining)));
          if (imgs.length > remaining && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added $remaining photo${remaining == 1 ? '' : 's'} (max 5).')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _createPost() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) return;

    if (!ChatFilterService.isAppropriateMessage(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ChatFilterService.getDetailedBlockReason(text))),
      );
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    EasyLoading.show(status: 'Posting...');

    try {
      // Prepend location to content if set: "@Brgy. Amaya, Tanza\nHello po"
      final finalContent = _locationAddress != null
          ? '@$_locationAddress\n$text'
          : text;

      final result = await _postRepository.createPost(
        userId: userId,
        dto: CreatePostDTO(
          content: finalContent,
          visibility: _selectedVisibility.value,
          imageFiles: _selectedImages.isNotEmpty ? _selectedImages : null,
        ),
      );

      if (result.isSuccess) {
        EasyLoading.showSuccess('Post created successfully!');
        if (mounted) context.router.pop();
      } else {
        EasyLoading.showError(result.error);
      }
    } catch (e) {
      EasyLoading.showError('Failed to create post: $e');
    } finally {
      setState(() => _isLoading = false);
      EasyLoading.dismiss();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileRepository>().profile;
    final name = profile?.fullName ?? '';
    final avatarColor = _avatarColor(name);
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final canPost = (_contentController.text.trim().isNotEmpty) && !_isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: const Icon(
            LucideIcons.x,
            color: AppColors.textPrimaryLight,
            size: 20,
          ),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: canPost ? _createPost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.gray200,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // ── User info row ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: profile?.profilePicture != null
                        ? Image.network(
                            profile!.profilePicture!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              initial,
                              style: TextStyle(
                                color: avatarColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'You',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.public_rounded,
                            size: 11,
                            color: AppColors.gray500,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Public',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.gray500,
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

          // ── Text field ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _contentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimaryLight,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: "What's happening in Amaya V?",
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: AppColors.gray400,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  // ── Location chip ─────────────────────────────────
                  if (_locationAddress != null) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _getLocation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.mapPin,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _locationAddress!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              LucideIcons.x,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Image strip ───────────────────────────────────
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length +
                            (_selectedImages.length < _maxImages ? 1 : 0),
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          // "+ add" button at the end
                          if (i == _selectedImages.length) {
                            return GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.border,
                                      width: 1.5),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(LucideIcons.plus,
                                        size: 20,
                                        color: AppColors.gray400),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_selectedImages.length}/$_maxImages',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.gray400),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImages[i].path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4, right: 4,
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedImages.removeAt(i)),
                                  child: Container(
                                    width: 22, height: 22,
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.x,
                                        color: Colors.white, size: 13),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Bottom toolbar ─────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    _ToolbarButton(
                      icon: LucideIcons.image,
                      label: _selectedImages.isNotEmpty
                          ? '${_selectedImages.length}/$_maxImages photos'
                          : 'Photo',
                      active: _selectedImages.isNotEmpty,
                      onTap: _showImageSourceDialog,
                    ),
                    _isLoadingLocation
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : _ToolbarButton(
                            icon: LucideIcons.mapPin,
                            label: _locationAddress != null
                                ? 'Remove location'
                                : 'Location',
                            active: _locationAddress != null,
                            onTap: _getLocation,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _avatarColor(String name) {
    const palette = [
      Color(0xFF1D6BF3),
      Color(0xFF2E7D32),
      Color(0xFFDC2626),
      Color(0xFF7C3AED),
      Color(0xFFF59E0B),
      Color(0xFF0891B2),
    ];
    return palette[name.isEmpty ? 0 : name.codeUnitAt(0) % palette.length];
  }
}

// ── Toolbar button ─────────────────────────────────────────────────────────────

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.gray500;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
