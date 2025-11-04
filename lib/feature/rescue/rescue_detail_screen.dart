import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:amayalert/feature/rescue/rescue_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class RescueDetailScreen extends StatefulWidget {
  final String rescueId;

  const RescueDetailScreen({super.key, required this.rescueId});

  @override
  State<RescueDetailScreen> createState() => _RescueDetailScreenState();
}

class _RescueDetailScreenState extends State<RescueDetailScreen> {
  final _rescueProvider = RescueProvider();
  Rescue? _rescue;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRescue();
  }

  Future<void> _loadRescue() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _rescueProvider.getRescueById(widget.rescueId);

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _rescue = result.value;
      } else {
        _error = result.error;
      }
    });
  }

  Future<void> _updateStatus(RescueStatus newStatus) async {
    final result = await _rescueProvider.updateRescueStatus(
      widget.rescueId,
      newStatus,
    );

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.value), backgroundColor: Colors.green),
      );
      _loadRescue(); // Reload to show updated status
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error)));
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone call to $phoneNumber'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldLight,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldLight,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.router.pop(),
            icon: const Icon(LucideIcons.arrowLeft),
          ),
          title: const CustomText(
            text: 'Emergency Details',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.x, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            CustomText(text: 'Error loading rescue details', fontSize: 18),
            const SizedBox(height: 8),
            CustomText(text: _error!, color: AppColors.gray600),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadRescue, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_rescue == null) {
      return const Center(
        child: CustomText(text: 'Rescue not found', fontSize: 18),
      );
    }

    final rescue = _rescue!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Priority Header
          _buildStatusHeader(rescue),
          const SizedBox(height: 24),

          // Title and Description
          _buildTitleSection(rescue),
          const SizedBox(height: 24),

          // Emergency Details
          _buildDetailsSection(rescue),
          const SizedBox(height: 24),

          // Location
          if (rescue.lat != null && rescue.lng != null) ...[
            _buildLocationSection(rescue),
            const SizedBox(height: 24),
          ],

          // Contact Information
          _buildContactSection(rescue),
          const SizedBox(height: 24),

          // Timestamps
          _buildTimestampSection(rescue),
          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(rescue),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(Rescue rescue) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(rescue.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomText(
                    text: rescue.statusLabel,
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(rescue.priority),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.zap, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      CustomText(
                        text: '${rescue.priorityLabel} Priority',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: 'Reported',
                fontSize: 12,
                color: AppColors.gray600,
              ),
              CustomText(
                text: timeago.format(rescue.reportedAt),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(Rescue rescue) {
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
                text: 'Emergency Details',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomText(
            text: rescue.title,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
          if (rescue.description != null) ...[
            const SizedBox(height: 8),
            CustomText(
              text: rescue.description!,
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsSection(Rescue rescue) {
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
          if (rescue.emergencyType != null)
            _buildDetailRow(
              'Emergency Type',
              _getEmergencyTypeLabel(rescue.emergencyType!),
            ),
          if (rescue.victimCount != null)
            _buildDetailRow('People Affected', '${rescue.victimCount} people'),
          if (rescue.metadata?['additional_info'] != null)
            _buildDetailRow(
              'Additional Info',
              rescue.metadata!['additional_info'],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  Widget _buildLocationSection(Rescue rescue) {
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
          CustomText(
            text:
                'Lat: ${rescue.lat!.toStringAsFixed(6)}\nLng: ${rescue.lng!.toStringAsFixed(6)}',
            fontSize: 14,
            color: AppColors.gray600,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(Rescue rescue) {
    final contactPhone = rescue.metadata?['contact_phone'] as String?;

    if (contactPhone == null) return const SizedBox.shrink();

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
              Icon(LucideIcons.phone, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const CustomText(
                text: 'Contact Information',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _makePhoneCall(contactPhone),
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
                    text: contactPhone,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampSection(Rescue rescue) {
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
          _buildTimestampRow('Reported', rescue.reportedAt),
          if (rescue.scheduledFor != null)
            _buildTimestampRow('Scheduled', rescue.scheduledFor!),
          if (rescue.completedAt != null)
            _buildTimestampRow('Completed', rescue.completedAt!),
          _buildTimestampRow('Last Updated', rescue.updatedAt),
        ],
      ),
    );
  }

  Widget _buildTimestampRow(String label, DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: label, fontSize: 14, color: AppColors.gray600),
          CustomText(
            text: timeago.format(timestamp),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Rescue rescue) {
    if (rescue.status == RescueStatus.completed ||
        rescue.status == RescueStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (rescue.status == RescueStatus.inProgress) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateStatus(RescueStatus.completed),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Mark as Completed'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _updateStatus(RescueStatus.cancelled),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel Request'),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(RescueStatus status) {
    switch (status) {
      case RescueStatus.pending:
        return Colors.orange;
      case RescueStatus.inProgress:
        return Colors.blue;
      case RescueStatus.completed:
        return Colors.green;
      case RescueStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getPriorityColor(int priority) {
    if (priority <= 1) return Colors.green;
    if (priority == 2) return Colors.orange;
    if (priority == 3) return Colors.red;
    return const Color(0xFF8B0000); // Critical
  }

  String _getEmergencyTypeLabel(String type) {
    switch (type) {
      case 'medical':
        return 'Medical Emergency';
      case 'fire':
        return 'Fire';
      case 'flood':
        return 'Flood';
      case 'accident':
        return 'Accident';
      case 'violence':
        return 'Violence/Crime';
      case 'naturalDisaster':
        return 'Natural Disaster';
      case 'other':
      default:
        return 'Other Emergency';
    }
  }
}
