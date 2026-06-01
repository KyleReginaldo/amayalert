import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/view_map_button.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LocationSectionWidget extends StatelessWidget {
  final Rescue rescue;

  const LocationSectionWidget({super.key, required this.rescue});

  bool get _hasAddress =>
      rescue.address != null && rescue.address!.isNotEmpty;
  bool get _hasCoords =>
      rescue.lat != null && rescue.lng != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasAddress && !_hasCoords) return const SizedBox.shrink();

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
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(LucideIcons.mapPin,
                      size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // ── Address ─────────────────────────────────────────────────
          if (_hasAddress)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.navigation,
                      size: 14, color: AppColors.gray400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rescue.address!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimaryLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Map ─────────────────────────────────────────────────────
          if (_hasCoords) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12)),
              child: MapPreview(
                lat: rescue.lat!,
                lng: rescue.lng!,
                height: 180,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ] else
            const SizedBox(height: 12),
        ],
      ),
    );
  }
}
