import 'package:amayalert/core/constant/constant.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/activity/activity_model.dart';
import 'package:amayalert/feature/activity/activity_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late Activity _activity;

  @override
  void initState() {
    super.initState();
    _activity = widget.activity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: CustomText(
          text: '${_getTypeLabel(_activity.type)} Details',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          if (_canDeleteActivity())
            IconButton(
              onPressed: () => _showDeleteConfirmation(),
              icon: Icon(LucideIcons.trash2, color: AppColors.error),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type and Status Header
          _buildTypeHeader(),
          const SizedBox(height: 24),

          // Title and Description
          _buildTitleSection(),
          const SizedBox(height: 24),

          // User Information
          _buildUserSection(),
          const SizedBox(height: 24),

          // Location (if available)
          if (_activity.location != null) ...[
            _buildLocationSection(),
            const SizedBox(height: 24),
          ],

          // Metadata (if available)
          if (_activity.metadata != null && _activity.metadata!.isNotEmpty) ...[
            _buildMetadataSection(),
            const SizedBox(height: 24),
          ],

          // Timestamps
          _buildTimestampSection(),
          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTypeHeader() {
    final typeConfig = _getActivityTypeConfig(_activity.type);

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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: typeConfig['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              typeConfig['icon'],
              size: 24,
              color: typeConfig['color'],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: _getTypeLabel(_activity.type),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: typeConfig['color'],
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: timeago.format(_activity.createdAt),
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
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
              Icon(LucideIcons.fileText, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Details',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomText(
            text: _activity.title,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: _activity.description,
            fontSize: 14,
            color: AppColors.gray600,
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection() {
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
              Icon(LucideIcons.user, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Created By',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  LucideIcons.user,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: _activity.userName ?? 'Unknown User',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    CustomText(
                      text: _activity.userId == 'system'
                          ? 'System Generated'
                          : 'User Activity',
                      fontSize: 12,
                      color: AppColors.gray600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.mapPin, color: AppColors.gray600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    text: _activity.location!,
                    fontSize: 14,
                    color: AppColors.gray700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
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
              Icon(LucideIcons.info, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Additional Information',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildMetadataItems(),
        ],
      ),
    );
  }

  List<Widget> _buildMetadataItems() {
    final metadata = _activity.metadata!;
    List<Widget> items = [];

    metadata.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        items.add(_buildMetadataRow(_formatKey(key), value.toString()));
      }
    });

    return items;
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: CustomText(
              text: label,
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampSection() {
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
              Icon(LucideIcons.clock, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Timeline',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimestampRow('Created', _activity.createdAt),
        ],
      ),
    );
  }

  Widget _buildTimestampRow(String label, DateTime timestamp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text: label, fontSize: 14, color: AppColors.gray600),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomText(
              text: timeago.format(timestamp),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            CustomText(
              text: '${timestamp.day}/${timestamp.month}/${timestamp.year}',
              fontSize: 12,
              color: AppColors.gray600,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_activity.type == ActivityType.rescue) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToRescueDetail(),
              icon: const Icon(LucideIcons.shield),
              label: const Text('View Rescue Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_activity.metadata?['contact_phone'] != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _makePhoneCall(_activity.metadata!['contact_phone']),
              icon: const Icon(LucideIcons.phone),
              label: const Text('Call Contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_canDeleteActivity())
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirmation(),
              icon: const Icon(LucideIcons.trash2),
              label: const Text('Delete Activity'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _canDeleteActivity() {
    final currentUserId = userID;
    return _activity.userId == currentUserId && _activity.userId != 'system';
  }

  void _navigateToRescueDetail() {
    final rescueId = _activity.metadata?['rescue_id']?.toString();
    if (rescueId != null) {
      context.router.pushNamed('/rescue-detail/$rescueId');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Delete Activity',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text:
                    'Are you sure you want to delete this ${_activity.type.name}?',
                fontSize: 16,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: _activity.title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: _activity.description,
                      fontSize: 12,
                      color: AppColors.gray600,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const CustomText(
                text: 'This action cannot be undone.',
                fontSize: 14,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: CustomText(text: 'Cancel', color: AppColors.gray600),
            ),
            ElevatedButton(
              onPressed: () => _deleteActivity(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const CustomText(
                text: 'Delete',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteActivity() async {
    Navigator.of(context).pop(); // Close dialog

    EasyLoading.show(status: 'Deleting ${_activity.type.name}...');

    try {
      final activityRepo = context.read<ActivityRepository>();
      final success = await activityRepo.deleteActivity(
        _activity,
        userID ?? '',
      );

      EasyLoading.dismiss();

      if (success) {
        final typeName =
            _activity.type.name[0].toUpperCase() +
            _activity.type.name.substring(1);
        EasyLoading.showSuccess('$typeName deleted successfully');

        // Go back to activity list
        if (mounted) {
          context.router.pop();
        }
      } else {
        EasyLoading.showError('Failed to delete ${_activity.type.name}');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
    }
  }

  String _getTypeLabel(ActivityType type) {
    switch (type) {
      case ActivityType.post:
        return 'Post';
      case ActivityType.alert:
        return 'Alert';
      case ActivityType.evacuation:
        return 'Evacuation Center';
      case ActivityType.rescue:
        return 'Rescue Operation';
    }
  }

  Map<String, dynamic> _getActivityTypeConfig(ActivityType type) {
    switch (type) {
      case ActivityType.post:
        return {'icon': LucideIcons.messageSquare, 'color': AppColors.primary};
      case ActivityType.alert:
        return {'icon': LucideIcons.zap, 'color': AppColors.warning};
      case ActivityType.evacuation:
        return {'icon': LucideIcons.mapPin, 'color': AppColors.error};
      case ActivityType.rescue:
        return {'icon': LucideIcons.shield, 'color': AppColors.success};
    }
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }
}
