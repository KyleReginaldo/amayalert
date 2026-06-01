import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/feature/posts/post_media_grid.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AttachmentsSectionWidget extends StatelessWidget {
  final Rescue rescue;
  const AttachmentsSectionWidget({super.key, required this.rescue});

  @override
  Widget build(BuildContext context) {
    final urls = rescue.attachments;
    if (urls == null || urls.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(LucideIcons.image,
                      size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'Photos (${urls.length})',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12)),
            child: PostMediaGrid(urls: urls),
          ),
        ],
      ),
    );
  }
}
