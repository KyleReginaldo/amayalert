import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:amayalert/feature/rescue/rescue_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

@RoutePage()
class RescueListScreen extends StatefulWidget {
  const RescueListScreen({super.key});

  @override
  State<RescueListScreen> createState() => _RescueListScreenState();
}

class _RescueListScreenState extends State<RescueListScreen> {
  final _rescueProvider = RescueProvider();
  List<Rescue> _rescues = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRescues();
  }

  Future<void> _loadRescues() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _rescueProvider.getRescues();

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _rescues = result.value;
      } else {
        _error = result.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldLight,
        elevation: 0,
        title: const CustomText(
          text: 'Emergency Requests',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            onPressed: _loadRescues,
            icon: Icon(LucideIcons.refreshCw, color: AppColors.gray600),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create rescue screen
          context.router.push(const CreateRescueRoute());
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Report Emergency'),
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
            CustomText(
              text: 'Error loading rescues',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: _error!,
              color: AppColors.gray600,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadRescues, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_rescues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.shield, size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            CustomText(
              text: 'No emergency requests',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: 'All clear! No active emergency requests at the moment.',
              color: AppColors.gray500,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRescues,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _rescues.length,
        itemBuilder: (context, index) {
          final rescue = _rescues[index];
          return _buildRescueCard(rescue);
        },
      ),
    );
  }

  Widget _buildRescueCard(Rescue rescue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to rescue detail screen
            context.router.pushNamed('/rescue-detail/${rescue.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Header with status and priority
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(rescue.status).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(rescue.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomText(
                        text: rescue.statusLabel,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(rescue.priority),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.zap, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          CustomText(
                            text: rescue.priorityLabel,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    CustomText(
                      text: timeago.format(rescue.reportedAt),
                      fontSize: 12,
                      color: AppColors.gray600,
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and emergency type
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomText(
                            text: rescue.title,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (rescue.emergencyType != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gray100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomText(
                              text: _getEmergencyTypeLabel(
                                rescue.emergencyType!,
                              ),
                              fontSize: 10,
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Description
                    if (rescue.description != null) ...[
                      const SizedBox(height: 8),
                      CustomText(
                        text: rescue.description!,
                        fontSize: 14,
                        color: AppColors.gray600,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Location
                    if (rescue.lat != null && rescue.lng != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 16,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: CustomText(
                              text:
                                  'Lat: ${rescue.lat!.toStringAsFixed(4)}, '
                                  'Lng: ${rescue.lng!.toStringAsFixed(4)}',
                              fontSize: 12,
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Additional info
                    if (rescue.victimCount != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.users,
                            size: 16,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 6),
                          CustomText(
                            text: '${rescue.victimCount} people affected',
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ],
                      ),
                    ],

                    // Images
                    if (rescue.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: rescue.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.gray200,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  rescue.imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.gray200,
                                      child: Icon(
                                        LucideIcons.imageOff,
                                        color: AppColors.gray500,
                                        size: 20,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: AppColors.gray200,
                                          child: Icon(
                                            LucideIcons.image,
                                            color: AppColors.gray400,
                                            size: 20,
                                          ),
                                        );
                                      },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
        return 'Medical';
      case 'fire':
        return 'Fire';
      case 'flood':
        return 'Flood';
      case 'accident':
        return 'Accident';
      case 'violence':
        return 'Violence';
      case 'naturalDisaster':
        return 'Natural Disaster';
      case 'other':
      default:
        return 'Emergency';
    }
  }
}
