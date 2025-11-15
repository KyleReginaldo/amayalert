import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

class TimestampSectionWidget extends StatelessWidget {
  final Rescue rescue;

  const TimestampSectionWidget({super.key, required this.rescue});

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
              Icon(LucideIcons.clock, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Timeline',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimestampRow('Created', rescue.createdAt),
          _buildTimestampRow('Reported', rescue.reportedAt),
          if (rescue.scheduledFor != null)
            _buildTimestampRow('Scheduled', rescue.scheduledFor!),
          if (rescue.completedAt != null)
            _buildTimestampRow('Completed', rescue.completedAt!),
          _buildTimestampRow('Last Updated', rescue.updatedAt),
        ],
      ),
    );
  }

  Widget _buildTimestampRow(String label, DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: label, fontSize: 14, color: AppColors.gray600),
          CustomText(
            text: timeago.format(timestamp),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
