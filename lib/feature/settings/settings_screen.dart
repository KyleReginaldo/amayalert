import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool get _isGuestUser {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.isAnonymous ?? false;
  }

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
        userID = null;
        Navigator.of(context).pop(); // Remove loading dialog
        context.router.popUntilRoot();
        context.router.replace(MainRoute());
        // context.router.push(SignInRoute());
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch phone call to $phoneNumber'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making phone call: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Amayalert App Inquiry', 'body': 'Hello'},
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch email to $email'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening email: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openFacebookPage() async {
    // Try multiple Facebook URL formats

    try {
      final Uri facebookUri = Uri.parse(
        "https://www.facebook.com/amaya.singko",
      );
      if (await canLaunchUrl(facebookUri)) {
        await launchUrl(facebookUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Can\'t go to facebook'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('error: $e');
    }
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

            // Security Section (only for non-guest users)
            if (!_isGuestUser) ...[
              _buildSection([
                _buildSimpleTile(
                  icon: LucideIcons.key,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () {
                    context.router.push(const ChangePasswordRoute());
                  },
                ),
                // _buildSimpleTile(
                //   icon: LucideIcons.mailX,
                //   title: 'Reset Password via Email',
                //   subtitle: 'Send password reset email',
                //   onTap: () {
                //     context.router.push(const ForgotPasswordRoute());
                //   },
                // ),
              ]),
              const SizedBox(height: 16),
            ],

            // Community Information Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.building,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    text: 'Barangay Information',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            // Community Information Section
            _buildSection([
              _buildSimpleTile(
                icon: LucideIcons.mapPin,
                title: 'Barangay Amaya V',
                subtitle: 'Tanza, Cavite',
                onTap: null,
              ),
              _buildSimpleTile(
                icon: LucideIcons.users,
                title: 'Population',
                subtitle: '2,983 residents',
                onTap: null,
              ),
              _buildSimpleTile(
                icon: LucideIcons.phone,
                title: 'Contact Number',
                subtitle: '0938-619-5287',
                onTap: () => _makePhoneCall('09386195287'),
              ),
              _buildSimpleTile(
                icon: LucideIcons.mail,
                title: 'Email',
                subtitle: 'amayavtanzacavite@gmail.com',
                onTap: () => _sendEmail('amayavtanzacavite@gmail.com'),
              ),
              _buildSimpleTile(
                icon: LucideIcons.facebook,
                title: 'Facebook Page',
                subtitle: 'Amaya Singko',
                onTap: () => _openFacebookPage(),
              ),
              _buildSimpleTile(
                icon: LucideIcons.user,
                title: 'Barangay Captain',
                subtitle: 'Mark Christiann A. Gumale',
                onTap: null,
              ),
            ]),

            const SizedBox(height: 16),

            // App Information Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.smartphone,
                    size: 18,
                    color: AppColors.gray600,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    text: 'App Information',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray600,
                  ),
                ],
              ),
            ),

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
