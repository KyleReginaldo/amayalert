import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationServicesEnabled = true;

  void _signOut() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 16),
                const CustomText(
                  text: 'Signing out...',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ),
      );

      // Sign out from Supabase
      await OneSignal.logout();
      await Supabase.instance.client.auth.signOut();

      // Navigate to sign in screen and clear all routes
      if (mounted) {
        Navigator.of(context).pop(); // Remove loading dialog
        context.router.popUntilRoot();
        context.router.push(SignInRoute());
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        Navigator.of(context).pop(); // Remove loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const CustomText(
          text: 'Sign Out',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        content: const CustomText(
          text: 'Are you sure you want to sign out?',
          fontSize: 15,
          color: Colors.black54,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.gray300),
                    ),
                  ),
                  child: const CustomText(
                    text: 'Cancel',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _signOut();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const CustomText(
                    text: 'Sign Out',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const CustomText(
          text: 'Settings',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.gray50,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Notifications Section
            _buildSection([
              _buildSimpleTile(
                icon: LucideIcons.bell,
                title: 'Push Notifications',
                trailing: Switch.adaptive(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              _buildSimpleTile(
                icon: LucideIcons.mapPin,
                title: 'Location Services',
                trailing: Switch.adaptive(
                  value: _locationServicesEnabled,
                  onChanged: (value) {
                    setState(() {
                      _locationServicesEnabled = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // About Section
            _buildSection([
              _buildSimpleTile(
                icon: LucideIcons.shield,
                title: 'Privacy Policy',
                onTap: () {
                  context.router.push(
                    WebViewRoute(
                      url: 'https://www.amayalert.site/privacy-policy',
                      title: 'Privacy Policy',
                    ),
                  );
                },
              ),
              _buildSimpleTile(
                icon: LucideIcons.fileText,
                title: 'Terms of Service',
                onTap: () {
                  context.router.push(
                    WebViewRoute(
                      url: 'https://www.amayalert.site/terms-of-service',
                      title: 'Terms of Service',
                    ),
                  );
                },
              ),
              _buildSimpleTile(
                icon: LucideIcons.messageCircle,
                title: 'Help & Support',
                onTap: () {
                  context.router.push(
                    WebViewRoute(
                      url: 'https://www.amayalert.site/contact-us',
                      title: 'Help & Support',
                    ),
                  );
                },
              ),
              _buildSimpleTile(
                icon: LucideIcons.info,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: null,
              ),
            ]),

            const SizedBox(height: 32),

            // Sign Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _showSignOutDialog,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.logOut, size: 18),
                      const SizedBox(width: 8),
                      const CustomText(
                        text: 'Sign Out',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSimpleTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.gray600),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: title,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      CustomText(
                        text: subtitle,
                        fontSize: 13,
                        color: AppColors.gray500,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppColors.gray400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
