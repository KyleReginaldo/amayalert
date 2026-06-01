import 'dart:convert';

import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/services/smtp_mailer.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/auth/auth_provider.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class PendingReviewScreen extends StatefulWidget {
  const PendingReviewScreen({super.key});

  @override
  State<PendingReviewScreen> createState() => _PendingReviewScreenState();
}

class _PendingReviewScreenState extends State<PendingReviewScreen> {
  // Email verification resend
  bool _resendingEmail = false;
  bool _resentEmail = false;

  // Admin notification resend
  bool _resendingAdmin = false;
  bool _resentAdmin = false;

  // Profile data
  String? _userStatus; // pending / approved / rejected
  String? _verificationStatus;
  String? _fullName;
  bool _loadingProfile = true;

  RealtimeChannel? _statusChannel;

  // ── Getters ───────────────────────────────────────────────────────────────

  bool get _emailVerified => _verificationStatus == 'verified';

  String? get _userEmail => Supabase.instance.client.auth.currentUser?.email;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  /// Show "resend admin notification" when verification is still pending/null
  bool get _needsAdminVerification =>
      _verificationStatus == null || _verificationStatus == 'pending';

  // ── Init ──────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _subscribeToStatus();
  }

  @override
  void dispose() {
    _statusChannel?.unsubscribe();
    super.dispose();
  }

  void _subscribeToStatus() {
    if (_userId == null) return;
    _statusChannel = Supabase.instance.client
        .channel('user-status-$_userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: _userId!,
          ),
          callback: (payload) {
            final newStatus = payload.newRecord['status'] as String?;
            final newVerification =
                payload.newRecord['verification_status'] as String?;
            if (!mounted) return;
            if (newStatus == 'approved') {
              _handleApproved();
            } else if (newStatus == 'rejected') {
              setState(() => _userStatus = 'rejected');
            }
            if (newVerification != null) {
              setState(() => _verificationStatus = newVerification);
            }
          },
        )
        .subscribe();
  }

  void _handleApproved() {
    final profileRepo = sl<ProfileRepository>();
    profileRepo.clear();
    profileRepo.getUserProfile(_userId!);
    context.router.replaceAll([const MainRoute()]);
  }

  Future<void> _loadProfile() async {
    if (_userId == null) return;
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select('status, verification_status, full_name')
          .eq('id', _userId!)
          .single();
      if (mounted) {
        setState(() {
          _userStatus = data['status'] as String?;
          _verificationStatus = data['verification_status'] as String?;
          debugPrint(
            'User status: $_userStatus, verification: $_verificationStatus',
          );
          _fullName = data['full_name'] as String?;
          if (_userStatus == 'approved') {
            _loadingProfile = true;
          } else {
            _loadingProfile = false;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  // ── Resend email verification ─────────────────────────────────────────────

  Future<void> _resendEmailVerification() async {
    if (_resendingEmail || _userEmail == null || _userId == null) return;
    setState(() => _resendingEmail = true);
    try {
      final result = await sendVerificationEmail(
        toEmail: _userEmail!,
        userId: _userId!,
        name: _fullName ?? _userEmail!,
      );
      if (!mounted) return;
      if (result.isSuccess) {
        setState(() => _resentEmail = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not send: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _resendingEmail = false);
    }
  }

  // ── Resend admin notification ─────────────────────────────────────────────

  Future<void> _resendAdminNotification() async {
    if (_resendingAdmin || _userId == null) return;
    setState(() => _resendingAdmin = true);
    try {
      final name = _fullName ?? _userEmail ?? 'Unknown';
      final verifyLink = 'https://amayalert.site/users?id=$_userId';

      await http.post(
        Uri.parse('https://amayalert.site/api/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': 'amayalert1@gmail.com',
          'subject': '[Resent] New Resident Registration — Verify ID',
          'html':
              '''
            <p>This is a resent notification. A resident is waiting for ID verification.</p>
            <table>
              <tr><td><b>Name</b></td><td>$name</td></tr>
              <tr><td><b>Email</b></td><td>${_userEmail ?? 'N/A'}</td></tr>
              <tr><td><b>User ID</b></td><td>$_userId</td></tr>
            </table>
            <br/>
            <a href="$verifyLink"
               style="background:#1D6BF3;color:#fff;padding:10px 20px;
                      border-radius:8px;text-decoration:none;font-weight:bold;">
              Review &amp; Verify on Admin Dashboard
            </a>
          ''',
          'type': 'single-email',
        }),
      );
      if (mounted) setState(() => _resentAdmin = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not resend notification. Try again later.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _resendingAdmin = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await AuthProvider().signOut();
              if (context.mounted) {
                context.router.replaceAll([OnBoardingRoute()]);
              }
            },
            icon: const Icon(
              LucideIcons.logOut,
              size: 16,
              color: AppColors.gray600,
            ),
            label: const Text(
              'Sign out',
              style: TextStyle(color: AppColors.gray600),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // ── 1. Email verification ─────────────────────────────────
            if (!_emailVerified) ...[
              _StatusCard(
                color: const Color(0xFFFFF8E1),
                borderColor: const Color(0xFFFFCC02),
                icon: LucideIcons.mail,
                iconColor: const Color(0xFFF59E0B),
                title: 'Verify your email',
                subtitle: _userEmail != null
                    ? 'A verification link was sent to $_userEmail. Click it to confirm your address.'
                    : 'Please verify your email address to continue.',
                action: _resentEmail
                    ? const _SentLabel('Verification email sent!')
                    : _ResendButton(
                        loading: _resendingEmail,
                        label: 'Resend verification email',
                        color: const Color(0xFFF59E0B),
                        onTap: _resendEmailVerification,
                      ),
              ),
              const SizedBox(height: 14),
            ] else ...[
              _StatusCard(
                color: const Color(0xFFF0FDF4),
                borderColor: AppColors.success,
                icon: LucideIcons.checkCheck,
                iconColor: AppColors.success,
                title: 'Email verified ✓',
                subtitle: 'Your email address has been confirmed.',
              ),
              const SizedBox(height: 14),
            ],

            // ── 2. ID / admin review ──────────────────────────────────
            if (_userStatus == 'rejected')
              const _StatusCard(
                color: Color(0xFFFFF0F0),
                borderColor: AppColors.danger,
                icon: LucideIcons.circleX,
                iconColor: AppColors.danger,
                title: 'Account Rejected',
                subtitle:
                    'Your ID verification was not approved. Please contact the barangay admin for assistance.',
              )
            else
              _StatusCard(
                color: const Color(0xFFFFF3E0),
                borderColor: const Color(0xFFF57C00),
                icon: LucideIcons.clock,
                iconColor: const Color(0xFFF57C00),
                title: 'Account Pending Review',
                subtitle:
                    'Your Barangay ID is being reviewed by the admin. You\'ll be notified once approved.',
                // Only show resend once profile has loaded and status is still pending
                action: _loadingProfile
                    ? null
                    : (_needsAdminVerification
                        ? (_resentAdmin
                            ? const _SentLabel('Notification resent to admin!')
                            : _ResendButton(
                                loading: _resendingAdmin,
                                label: 'Resend notification to admin',
                                color: const Color(0xFFF57C00),
                                onTap: _resendAdminNotification,
                              ))
                        : null),
              ),

            const SizedBox(height: 40),

            // ── Request Rescue ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.router.push(const CreateRescueRoute()),
                icon: const Icon(LucideIcons.siren, size: 20),
                label: const Text(
                  'Request Rescue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'You can still request emergency rescue while waiting for approval.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.gray400),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _SentLabel extends StatelessWidget {
  final String text;
  const _SentLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(LucideIcons.checkCheck, size: 14, color: AppColors.success),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ResendButton extends StatelessWidget {
  final bool loading;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ResendButton({
    required this.loading,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          loading
              ? SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Icon(LucideIcons.refreshCw, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? action;

  const _StatusCard({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
                if (action != null) ...[const SizedBox(height: 10), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
