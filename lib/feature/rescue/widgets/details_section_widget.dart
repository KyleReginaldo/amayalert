import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DetailsSectionWidget extends StatelessWidget {
  final Rescue rescue;
  const DetailsSectionWidget({super.key, required this.rescue});

  @override
  Widget build(BuildContext context) {
    final rows = <_Row>[];

    if (rescue.emergencyType != null) {
      rows.add(_Row(LucideIcons.siren, 'Emergency Type',
          rescue.emergencyTypeLabel, AppColors.danger));
    }
    if (rescue.victimCount != null) {
      rows.add(_Row(LucideIcons.users, 'People Affected',
          _victimText(), AppColors.info));
    }
    if (rescue.user != null) {
      rows.add(_Row(LucideIcons.user, 'Reported By',
          rescue.user!.displayName, AppColors.primary));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

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
                  child: const Icon(LucideIcons.info,
                      size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                const Text('Additional Information',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: rows.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: 14, color: AppColors.border),
            itemBuilder: (_, i) {
              final r = rows[i];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: r.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(r.icon, size: 14, color: r.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.label,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.gray400)),
                          const SizedBox(height: 2),
                          Text(r.value,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryLight)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _victimText() {
    final f = rescue.femaleCount ?? 0;
    final m = rescue.maleCount ?? 0;
    final parts = <String>[];
    if (f > 0) parts.add('$f female${f > 1 ? 's' : ''}');
    if (m > 0) parts.add('$m male${m > 1 ? 's' : ''}');
    if (parts.isEmpty) return 'Not specified';
    final total = f + m;
    return parts.length == 1
        ? parts.first
        : '${parts.join(', ')} · $total total';
  }
}

class _Row {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _Row(this.icon, this.label, this.value, this.color);
}
