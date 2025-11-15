import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

class StatusHeaderWidget extends StatelessWidget {
  final Rescue rescue;

  const StatusHeaderWidget({super.key, required this.rescue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(rescue.status).withValues(alpha: 0.1),
          width: 1,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getPriorityColor(rescue.priority),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _getPriorityColor(
                        rescue.priority,
                      ).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.zap, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    CustomText(
                      text: rescue.priorityLabel,
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
              Icon(
                _getStatusIcon(rescue.status),
                size: 20,
                color: _getStatusColor(rescue.status),
              ),
            ],
          ),

          const SizedBox(height: 8),
          if (rescue.emergencyType != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getEmergencyTypeIcon(rescue.emergencyType!),
                      size: 14,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    CustomText(
                      text: rescue.emergencyTypeLabel,
                      fontSize: 14,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    'Reported',
                    timeago.format(rescue.reportedAt),
                    LucideIcons.clock,
                    AppColors.gray600,
                  ),
                ),
                Container(width: 1, height: 30, color: AppColors.gray300),
                Expanded(
                  child: _buildInfoColumn(
                    'ID',
                    '#${rescue.id.substring(0, 8)}',
                    LucideIcons.hash,
                    AppColors.gray600,
                  ),
                ),
                if (rescue.victimCount != null) ...[
                  Container(width: 1, height: 30, color: AppColors.gray300),
                  Expanded(
                    child: _buildInfoColumn(
                      'Affected',
                      '${rescue.victimCount} people',
                      LucideIcons.users,
                      AppColors.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        CustomText(
          text: label,
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 2),
        CustomText(
          text: value,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.gray800,
        ),
      ],
    );
  }

  IconData _getStatusIcon(RescueStatus status) {
    switch (status) {
      case RescueStatus.pending:
        return LucideIcons.clock;
      case RescueStatus.inProgress:
        return LucideIcons.loader;
      case RescueStatus.completed:
        return LucideIcons.check;
      case RescueStatus.cancelled:
        return LucideIcons.x;
    }
  }

  IconData _getEmergencyTypeIcon(String emergencyType) {
    switch (emergencyType.toLowerCase()) {
      case 'medical':
        return LucideIcons.heart;
      case 'fire':
        return LucideIcons.flame;
      case 'flood':
        return LucideIcons.waves;
      case 'accident':
        return LucideIcons.car;
      case 'violence':
        return LucideIcons.shield;
      case 'natural_disaster':
        return LucideIcons.zap;
      default:
        return LucideIcons.info;
    }
  }

  Color _getStatusColor(RescueStatus status) {
    switch (status) {
      case RescueStatus.pending:
        return Colors.orange;
      case RescueStatus.inProgress:
        return Colors.blue;
      case RescueStatus.completed:
        return Colors.green;
      case RescueStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getPriorityColor(int priority) {
    if (priority <= 1) return Colors.green;
    if (priority == 2) return Colors.orange;
    if (priority == 3) return Colors.red;
    return const Color(0xFF8B0000);
  }
}
