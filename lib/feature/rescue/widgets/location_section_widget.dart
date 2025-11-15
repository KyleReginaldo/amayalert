import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LocationSectionWidget extends StatelessWidget {
  final Rescue rescue;

  const LocationSectionWidget({super.key, required this.rescue});

  @override
  Widget build(BuildContext context) {
    // Don't show the widget if there's no location information
    if ((rescue.address == null || rescue.address!.isEmpty) &&
        (rescue.lat == null || rescue.lng == null)) {
      return const SizedBox.shrink();
    }

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
              Icon(LucideIcons.mapPin, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Location',
                fontSize: 14,
                color: AppColors.gray800,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Address (if available)
          if (rescue.address != null && rescue.address!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                spacing: 8,
                children: [
                  Icon(LucideIcons.mapPin, color: AppColors.primary, size: 18),
                  Expanded(
                    child: CustomText(
                      text: rescue.address!,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (rescue.lat != null && rescue.lng != null)
              const SizedBox(height: 12),
          ],

          // GPS Coordinates (if available)
          if (rescue.lat != null && rescue.lng != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.crosshair,
                    color: AppColors.gray600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'GPS Coordinates',
                          fontSize: 12,
                          color: AppColors.gray600,
                        ),
                        const SizedBox(height: 2),
                        CustomText(
                          text:
                              'Lat: ${rescue.lat!.toStringAsFixed(6)}, Lng: ${rescue.lng!.toStringAsFixed(6)}',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // No location info available
          if ((rescue.address == null || rescue.address!.isEmpty) &&
              (rescue.lat == null || rescue.lng == null)) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.mapPin, color: AppColors.gray500, size: 18),
                  const SizedBox(width: 8),
                  CustomText(
                    text: 'Location information not available',
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
