import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DetailsSectionWidget extends StatelessWidget {
  final Rescue rescue;

  const DetailsSectionWidget({super.key, required this.rescue});

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
              Icon(LucideIcons.info, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Additional Information',
                fontSize: 14,
                color: AppColors.gray800,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (rescue.emergencyType != null) ...[
            CustomText(
              text: "Emergency Type",
              fontSize: 14,
              color: AppColors.gray600,
            ),
            CustomText(text: rescue.emergencyTypeLabel),
            SizedBox(height: 8),
          ],
          if (rescue.victimCount != null) ...[
            CustomText(
              text: "People affected includes",
              fontSize: 14,
              color: AppColors.gray600,
            ),
            CustomText(text: _buildVictimCountText(rescue)),
            SizedBox(height: 8),
          ],
          if (rescue.importantInformation != null) ...[
            CustomText(
              text: "Important Information",
              fontSize: 14,
              color: AppColors.gray600,
            ),
            CustomText(
              text: rescue.importantInformation!,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 8),
          ],
          if (rescue.user != null) ...[
            CustomText(
              text: "Reported By",
              fontSize: 14,
              color: AppColors.gray600,
            ),
            CustomText(
              text: rescue.user!.fullName,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ],
        ],
      ),
    );
  }

  String _buildVictimCountText(Rescue rescue) {
    final femaleCount = rescue.femaleCount;
    final maleCount = rescue.maleCount;

    if (femaleCount == null && maleCount == null) return 'Not specified';

    final parts = <String>[];
    if (femaleCount != null && femaleCount > 0) {
      parts.add('$femaleCount female${femaleCount > 1 ? 's' : ''}');
    }
    if (maleCount != null && maleCount > 0) {
      parts.add('$maleCount male${maleCount > 1 ? 's' : ''}');
    }

    if (parts.isEmpty) return 'Not specified';
    if (parts.length == 1) return parts.first;
    return '${parts.join(', ')} (Total: ${(femaleCount ?? 0) + (maleCount ?? 0)})';
  }
}
