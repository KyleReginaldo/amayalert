import 'dart:io';

import 'package:amayalert/core/dto/post.dto.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/posts/post_model.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class CreatePostsScreen extends StatefulWidget {
  const CreatePostsScreen({super.key});

  @override
  State<CreatePostsScreen> createState() => _CreatePostsScreenState();
}

class _CreatePostsScreenState extends State<CreatePostsScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final PostRepository _postRepository = PostRepository();

  XFile? _selectedImage;
  PostVisibility _selectedVisibility = PostVisibility.public;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Image'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
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
      _selectedImage = null;
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some content for your post'),
        ),
      );
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    EasyLoading.show(status: 'Creating post...');

    try {
      final createPostDTO = CreatePostDTO(
        content: _contentController.text.trim(),
        visibility: _selectedVisibility.value,
        imageFile: _selectedImage,
      );

      final result = await _postRepository.createPost(
        userId: userId,
        dto: createPostDTO,
      );

      if (result.isSuccess) {
        EasyLoading.showSuccess('Post created successfully!');
        if (mounted) {
          context.router.pop(); // Go back to previous screen
        }
      } else {
        EasyLoading.showError(result.error);
      }
    } catch (e) {
      EasyLoading.showError('Failed to create post: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const CustomText(text: 'Create Post'),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _createPost,
              style: ButtonStyle().copyWith(
                foregroundColor: const WidgetStatePropertyAll(
                  AppColors.primary,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const CustomText(text: 'Post', color: AppColors.primary),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content input
              Expanded(
                child: TextField(
                  controller: _contentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'What\'s on your mind?',
                    hintText: 'Type your detailed message here...',
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),

              // Image preview
              if (_selectedImage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Visibility selector
              Row(
                children: [
                  const Icon(Icons.visibility, size: 20),
                  const SizedBox(width: 8),
                  const CustomText(text: 'Visibility:'),
                  const SizedBox(width: 16),
                  DropdownButton<PostVisibility>(
                    value: _selectedVisibility,
                    onChanged: (PostVisibility? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedVisibility = newValue;
                        });
                      }
                    },
                    items: PostVisibility.values.map((
                      PostVisibility visibility,
                    ) {
                      return DropdownMenuItem<PostVisibility>(
                        value: visibility,
                        child: Row(
                          children: [
                            Icon(
                              visibility == PostVisibility.public
                                  ? Icons.public
                                  : Icons.lock,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            CustomText(text: visibility.value.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showImageSourceDialog,
                      icon: const Icon(LucideIcons.camera),
                      label: CustomText(
                        text: _selectedImage != null
                            ? 'Change Image'
                            : 'Add Image',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
