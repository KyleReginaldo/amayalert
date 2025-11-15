import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TitleSectionWidget extends StatelessWidget {
  final Rescue rescue;

  const TitleSectionWidget({super.key, required this.rescue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.fileText, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Emergency Details',
                fontSize: 14,
                color: AppColors.gray800,
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomText(
            text: rescue.title,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
          if (rescue.description != null) ...[
            const SizedBox(height: 8),
            CustomText(
              text: 'Description',
              fontSize: 13,
              color: AppColors.gray600,
            ),
            CustomText(
              text: rescue.description!,
              fontSize: 14,
              color: AppColors.gray800,
            ),
          ],
        ],
      ),
    );
  }
}
