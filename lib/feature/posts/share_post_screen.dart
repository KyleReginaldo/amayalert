import 'package:amayalert/core/dto/post.dto.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constant/constant.dart';

@RoutePage()
class SharePostScreen extends StatefulWidget implements AutoRouteWrapper {
  final int postId;
  final String? previewContent;

  const SharePostScreen({required this.postId, this.previewContent, super.key});

  @override
  State<SharePostScreen> createState() => _SharePostScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<PostRepository>(),
      child: this,
    );
  }
}

class _SharePostScreenState extends State<SharePostScreen> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    final uid = userID ?? '';
    if (uid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in to share a post')));
      return;
    }

    setState(() => _isSubmitting = true);

    final dto = CreatePostDTO(
      content: text,
      visibility: 'public',
      sharedPost: widget.postId,
    );
    final repo = context.read<PostRepository>();
    final result = await repo.createPost(userId: uid, dto: dto);
    setState(() => _isSubmitting = false);
    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post shared')));
        // Refresh posts in repo already done by createPost
        context.router.pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Share Post',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.previewContent != null) ...[
                CustomText(
                  text: 'Original',
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomText(text: widget.previewContent!, fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
              CustomText(
                text: 'Add a title or comment',
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _controller,
                hint: 'Say something about this...',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const CustomText(text: 'Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
