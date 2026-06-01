import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StatusHeaderWidget extends StatelessWidget {
  final Rescue rescue;
  const StatusHeaderWidget({super.key, required this.rescue});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(rescue.status);
    final priorityColor = _priorityColor(rescue.priority);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + priority + type row
          Row(
            children: [
              _badge(
                icon: _statusIcon(rescue.status),
                label: _statusLabel(rescue.status),
                bgColor: statusColor,
                textColor: Colors.white,
              ),
              const SizedBox(width: 8),
              _badge(
                icon: LucideIcons.zap,
                label: rescue.priorityLabel,
                bgColor: priorityColor.withValues(alpha: 0.12),
                textColor: priorityColor,
                borderColor: priorityColor.withValues(alpha: 0.4),
              ),
              const Spacer(),
              if (rescue.emergencyType != null)
                _badge(
                  icon: _typeIcon(rescue.emergencyType!),
                  label: rescue.emergencyTypeLabel,
                  bgColor: AppColors.danger.withValues(alpha: 0.08),
                  textColor: AppColors.danger,
                  borderColor: AppColors.danger.withValues(alpha: 0.3),
                ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Date + victims
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 13, color: AppColors.gray500),
              const SizedBox(width: 6),
              Text(
                DateFormat('MMM d, y · h:mm a').format(rescue.createdAt),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondaryLight),
              ),
              if (rescue.victimCount != null) ...[
                const SizedBox(width: 14),
                const Icon(LucideIcons.users,
                    size: 13, color: AppColors.gray500),
                const SizedBox(width: 6),
                Text(
                  '${rescue.victimCount} affected',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border:
              borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 0.3)),
          ],
        ),
      );

  String _statusLabel(RescueStatus s) => switch (s) {
        RescueStatus.pending => 'PENDING',
        RescueStatus.inProgress => 'IN PROGRESS',
        RescueStatus.completed => 'COMPLETED',
        RescueStatus.cancelled => 'CANCELLED',
      };

  Color _statusColor(RescueStatus s) => switch (s) {
        RescueStatus.pending => const Color(0xFFF59E0B),
        RescueStatus.inProgress => AppColors.primary,
        RescueStatus.completed => AppColors.success,
        RescueStatus.cancelled => AppColors.danger,
      };

  IconData _statusIcon(RescueStatus s) => switch (s) {
        RescueStatus.pending => LucideIcons.clock,
        RescueStatus.inProgress => LucideIcons.loader,
        RescueStatus.completed => LucideIcons.checkCheck,
        RescueStatus.cancelled => LucideIcons.x,
      };

  Color _priorityColor(int p) {
    if (p <= 1) return AppColors.success;
    if (p == 2) return const Color(0xFFF59E0B);
    if (p == 3) return AppColors.danger;
    return const Color(0xFF7F1D1D);
  }

  IconData _typeIcon(String type) => switch (type.toLowerCase()) {
        'medical' => LucideIcons.heartPulse,
        'fire' => LucideIcons.flame,
        'flood' => LucideIcons.waves,
        'accident' => LucideIcons.car,
        'violence' => LucideIcons.handFist,
        _ => LucideIcons.siren,
      };
}
