import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
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
  bool get _isGuest =>
      Supabase.instance.client.auth.currentUser?.isAnonymous ?? false;

  // ── Actions ───────────────────────────────────────────────────────────────

  void _signOut() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Signing out…',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
    try {
      await OneSignal.logout();
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        userID = null;
        Navigator.of(context).pop();
        context.router.popUntilRoot();
        context.router.replace(MainRoute());
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Sign Out',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $url')),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: const Icon(LucideIcons.arrowLeft,
              color: AppColors.textPrimaryLight, size: 20),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── Barangay card ───────────────────────────────────────────
          _barangayCard(),
          const SizedBox(height: 24),

          // ── Account ─────────────────────────────────────────────────
          if (!_isGuest) ...[
            _sectionHeader('Account'),
            _group([
              _tile(
                icon: LucideIcons.key,
                color: AppColors.primary,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () => context.router.push(const ChangePasswordRoute()),
              ),
            ]),
            const SizedBox(height: 24),
          ],

          // ── Contact ──────────────────────────────────────────────────
          _sectionHeader('Barangay Contact'),
          _group([
            _tile(
              icon: LucideIcons.phone,
              color: AppColors.success,
              title: '0938-619-5287',
              subtitle: 'Tap to call',
              onTap: () => _launch('tel:09386195287'),
            ),
            _tile(
              icon: LucideIcons.mail,
              color: AppColors.info,
              title: 'amayavtanzacavite@gmail.com',
              subtitle: 'Tap to send email',
              onTap: () => _launch(
                  'mailto:amayavtanzacavite@gmail.com?subject=Amayalert Inquiry'),
            ),
            _tile(
              icon: LucideIcons.facebook,
              color: const Color(0xFF1877F2),
              title: 'Amaya Singko',
              subtitle: 'Facebook page',
              onTap: () => _launch('https://www.facebook.com/amaya.singko'),
            ),
          ]),
          const SizedBox(height: 24),

          // ── About ─────────────────────────────────────────────────────
          _sectionHeader('About'),
          _group([
            _tile(
              icon: LucideIcons.shield,
              color: AppColors.primary,
              title: 'Privacy Policy',
              onTap: () => context.router.push(WebViewRoute(
                  url: 'https://www.amayalert.site/privacy-policy',
                  title: 'Privacy Policy')),
            ),
            _tile(
              icon: LucideIcons.fileText,
              color: AppColors.gray600,
              title: 'Terms of Service',
              onTap: () => context.router.push(WebViewRoute(
                  url: 'https://www.amayalert.site/terms-of-service',
                  title: 'Terms of Service')),
            ),
            _tile(
              icon: LucideIcons.messageCircle,
              color: AppColors.success,
              title: 'Help & Support',
              onTap: () => context.router.push(WebViewRoute(
                  url: 'https://www.amayalert.site/contact-us',
                  title: 'Help & Support')),
            ),
            _tile(
              icon: LucideIcons.info,
              color: AppColors.gray400,
              title: 'App Version',
              trailing: const Text('1.0.0',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray400,
                      fontWeight: FontWeight.w500)),
            ),
          ]),

          const SizedBox(height: 32),

          // ── Sign out ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _showSignOutDialog,
              icon: const Icon(LucideIcons.logOut, size: 18),
              label: const Text('Sign Out',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _barangayCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF2E80F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.shield,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barangay Amaya V',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 3),
                Text('Tanza, Cavite',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 2),
                Text('Pop. 2,983 · Capt. Mark Christiann A. Gumale',
                    style: TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.gray400,
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _group(List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i < tiles.length - 1)
              const Divider(height: 1, indent: 54, color: AppColors.border),
          ],
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.gray400)),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              const Icon(LucideIcons.chevronRight,
                  size: 16, color: AppColors.gray300),
          ],
        ),
      ),
    );
  }
}
