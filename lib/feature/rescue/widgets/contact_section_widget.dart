import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSectionWidget extends StatelessWidget {
  final Rescue rescue;

  const ContactSectionWidget({super.key, required this.rescue});

  @override
  Widget build(BuildContext context) {
    // Check if there's any contact information to display
    final hasContactPhone =
        rescue.contactPhone != null && rescue.contactPhone!.isNotEmpty;
    final hasEmail = rescue.email != null && rescue.email!.isNotEmpty;

    if (!hasContactPhone && !hasEmail) return const SizedBox.shrink();

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
              Icon(
                LucideIcons.personStanding,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Contact Information',
                fontSize: 14,
                color: AppColors.gray800,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Phone contact
          if (hasContactPhone) ...[
            InkWell(
              onTap: () => _makePhoneCall(rescue.contactPhone!, context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.phone, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    CustomText(
                      text: rescue.contactPhone!,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            if (hasEmail) const SizedBox(height: 8),
          ],

          // Email contact
          if (hasEmail) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.mail, color: AppColors.gray600, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomText(
                      text: rescue.email!,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone call to $phoneNumber'),
          ),
        );
      }
    }
  }
}
