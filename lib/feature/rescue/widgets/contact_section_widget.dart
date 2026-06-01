import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSectionWidget extends StatelessWidget {
  final Rescue rescue;
  const ContactSectionWidget({super.key, required this.rescue});

  bool get _hasPhone =>
      rescue.contactPhone != null && rescue.contactPhone!.isNotEmpty;
  bool get _hasEmail =>
      rescue.email != null && rescue.email!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasPhone && !_hasEmail) return const SizedBox.shrink();

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
                  child: const Icon(LucideIcons.phone,
                      size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                const Text('Contact',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          if (_hasPhone)
            InkWell(
              onTap: () => _call(rescue.contactPhone!, context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.phone,
                          size: 16, color: AppColors.success),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Phone',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.gray400)),
                          const SizedBox(height: 2),
                          Text(rescue.contactPhone!,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryLight)),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight,
                        size: 16, color: AppColors.gray300),
                  ],
                ),
              ),
            ),

          if (_hasPhone && _hasEmail)
            const Divider(height: 1, indent: 14, color: AppColors.border),

          if (_hasEmail)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.mail,
                        size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.gray400)),
                        const SizedBox(height: 2),
                        Text(rescue.email!,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _call(String number, BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot call $number')),
      );
    }
  }
}
