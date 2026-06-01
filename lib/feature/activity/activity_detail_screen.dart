import 'dart:convert';

import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/feature/activity/activity_model.dart';
import 'package:amayalert/feature/activity/activity_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../posts/post_media_grid.dart';

@RoutePage()
class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;
  const ActivityDetailScreen({super.key, required this.activity});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late final Activity _a = widget.activity;

  bool get _canDelete => _a.userId == userID && _a.userId != 'system';

  // ── Type config ───────────────────────────────────────────────────────────

  static _TypeConfig _config(ActivityType t) => switch (t) {
    ActivityType.post => _TypeConfig(
      LucideIcons.messageSquare,
      AppColors.primary,
      'Post',
    ),
    ActivityType.alert => _TypeConfig(
      LucideIcons.siren,
      AppColors.warning,
      'Alert',
    ),
    ActivityType.evacuation => _TypeConfig(
      LucideIcons.mapPin,
      AppColors.danger,
      'Evacuation Center',
    ),
    ActivityType.rescue => _TypeConfig(
      LucideIcons.shield,
      AppColors.success,
      'Rescue Operation',
    ),
  };

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cfg = _config(_a.type);

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: AppColors.textPrimaryLight,
            size: 20,
          ),
        ),
        title: Text(
          cfg.label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          if (_canDelete)
            IconButton(
              onPressed: _showDeleteDialog,
              icon: const Icon(
                LucideIcons.trash2,
                color: AppColors.danger,
                size: 20,
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Type + time banner ─────────────────────────────────────
            _banner(cfg),
            const SizedBox(height: 14),

            // ── Title & description ────────────────────────────────────
            _card(
              children: [
                Text(
                  _a.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _a.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                    height: 1.55,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Meta chips (user, location, time) ─────────────────────
            _card(
              children: [
                _infoRow(
                  LucideIcons.user,
                  _a.userName ?? 'Unknown',
                  _a.userId == 'system' ? 'System' : 'Resident',
                ),
                if (_a.location != null) ...[
                  const Divider(height: 20, color: AppColors.border),
                  _infoRow(LucideIcons.mapPin, _a.location!, 'Location'),
                ],
                const Divider(height: 20, color: AppColors.border),
                _infoRow(
                  LucideIcons.clock,
                  timeago.format(_a.createdAt),
                  '${_a.createdAt.day}/${_a.createdAt.month}/${_a.createdAt.year}',
                ),
              ],
            ),

            // ── Metadata ───────────────────────────────────────────────
            if (_a.metadata != null && _a.metadata!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _sectionLabel('Additional Information'),
              const SizedBox(height: 6),
              ..._buildMetadataWidgets(),
            ],

            const SizedBox(height: 24),

            // ── Action buttons ─────────────────────────────────────────
            if (_a.type == ActivityType.rescue &&
                _a.metadata?['rescue_id'] != null)
              _primaryButton(
                icon: LucideIcons.shield,
                label: 'View Rescue Details',
                color: AppColors.primary,
                onTap: () {
                  final id = _a.metadata!['rescue_id'].toString();
                  context.router.push(RescueDetailRoute(rescueId: id));
                },
              ),

            if (_a.metadata?['contact_phone'] != null) ...[
              const SizedBox(height: 10),
              _primaryButton(
                icon: LucideIcons.phone,
                label: 'Call Contact',
                color: AppColors.success,
                onTap: () => _call(_a.metadata!['contact_phone'].toString()),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _banner(_TypeConfig cfg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cfg.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cfg.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cfg.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(cfg.icon, size: 22, color: cfg.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cfg.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cfg.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeago.format(_a.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: cfg.color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(IconData icon, String primary, String secondary) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 16, color: AppColors.gray500),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                secondary,
                style: const TextStyle(fontSize: 12, color: AppColors.gray400),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.gray400,
        letterSpacing: 0.7,
      ),
    );
  }

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not call $number')));
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Delete activity',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will permanently remove this activity. This cannot be undone.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _deleteActivity,
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteActivity() async {
    Navigator.pop(context);
    EasyLoading.show(status: 'Deleting…');
    try {
      final ok = await context.read<ActivityRepository>().deleteActivity(
        _a,
        userID ?? '',
      );
      EasyLoading.dismiss();
      if (ok) {
        EasyLoading.showSuccess('Deleted');
        if (mounted) context.router.pop();
      } else {
        EasyLoading.showError('Failed to delete');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $e');
    }
  }

  // Returns true when a string looks like an image URL
  static bool _isImageUrl(String s) {
    if (!s.startsWith('http')) return false;
    final lower = s.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.contains('/files/') || // Supabase Storage bucket
        lower.contains('supabase') && lower.contains('storage');
  }

  List<Widget> _buildMetadataWidgets() {
    const skip = {
      'contact_phone',
      'rescue_id',
      'media_urls',
      'media_url',
      'attachments',
    };
    final meta = _a.metadata!;

    // ─── DEBUG ────────────────────────────────────────────────────────────
    debugPrint('=== ACTIVITY METADATA (${_a.type.name}) ===');
    meta.forEach((k, v) => debugPrint('  $k (${v.runtimeType}): $v'));
    // ─────────────────────────────────────────────────────────────────────

    // ── 1. Always use media_urls / media_url as the image source ─────────
    final imageUrls = <String>[];

    final rawUrls = meta['media_urls'];
    if (rawUrls is List && rawUrls.isNotEmpty) {
      // Dart List<dynamic> — Supabase TEXT[] or JSON array
      imageUrls.addAll(rawUrls.map((e) => e.toString()));
    } else if (rawUrls is String && rawUrls.trim().isNotEmpty) {
      // Might be a JSON-encoded array string: "[\"url1\",\"url2\"]"
      try {
        final decoded = jsonDecode(rawUrls);
        if (decoded is List) {
          imageUrls.addAll(decoded.map((e) => e.toString()));
        } else {
          imageUrls.add(rawUrls); // plain single URL string
        }
      } catch (_) {
        imageUrls.add(rawUrls); // not JSON — treat as a single URL
      }
    } else {
      // No media_urls — check attachments (rescue activities)
      final rawAttach = meta['attachments'];
      if (rawAttach is List && rawAttach.isNotEmpty) {
        imageUrls.addAll(rawAttach.map((e) => e.toString()));
      } else if (rawAttach is String && rawAttach.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(rawAttach);
          if (decoded is List) {
            imageUrls.addAll(decoded.map((e) => e.toString()));
          } else {
            imageUrls.add(rawAttach);
          }
        } catch (_) {
          imageUrls.add(rawAttach);
        }
      } else {
        // Final fallback — single media_url
        final single = meta['media_url']?.toString() ?? '';
        if (single.isNotEmpty) imageUrls.add(single);
      }
    }

    // ── 2. Remaining fields — detect any stray image URLs too ─────────────
    final entries = meta.entries
        .where(
          (e) =>
              e.value != null &&
              e.value.toString().isNotEmpty &&
              !skip.contains(e.key),
        )
        .toList();

    final textRows = <Widget>[];

    for (final e in entries) {
      final value = e.value;

      if (value is List) {
        for (final item in value) {
          final s = item.toString();
          if (_isImageUrl(s)) {
            imageUrls.add(s);
          } else if (s.isNotEmpty) {
            textRows.add(_metaRow(_formatKey(e.key), s));
          }
        }
        continue;
      }

      final s = value.toString();
      if (_isImageUrl(s)) {
        imageUrls.add(s);
      } else {
        textRows.add(_metaRow(_formatKey(e.key), s));
      }
    }

    final widgets = <Widget>[];

    // Text fields card
    if (textRows.isNotEmpty) {
      widgets.add(_card(children: textRows));
    }

    // Images section
    if (imageUrls.isNotEmpty) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 10));
      widgets.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: PostMediaGrid(urls: imageUrls),
        ),
      );
    }

    return widgets;
  }

  Widget _metaRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.gray500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    ),
  );

  String _formatKey(String key) => key
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
      .join(' ');
}

class _TypeConfig {
  final IconData icon;
  final Color color;
  final String label;
  const _TypeConfig(this.icon, this.color, this.label);
}
