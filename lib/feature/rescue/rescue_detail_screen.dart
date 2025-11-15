import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/buttons/custom_buttons.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:amayalert/feature/rescue/rescue_provider.dart';
import 'package:amayalert/feature/rescue/widgets/attachments_section_widget.dart';
import 'package:amayalert/feature/rescue/widgets/contact_section_widget.dart';
import 'package:amayalert/feature/rescue/widgets/details_section_widget.dart';
import 'package:amayalert/feature/rescue/widgets/location_section_widget.dart';
import 'package:amayalert/feature/rescue/widgets/status_header_widget.dart';
import 'package:amayalert/feature/rescue/widgets/title_section_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.value), backgroundColor: Colors.green),
        );
      }
      _loadRescue(); // Reload to show updated status
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error)));
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
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  if (_rescue?.status != RescueStatus.cancelled)
                    PopupMenuItem(
                      value: 'Cancel',
                      child: Row(
                        children: const [
                          Icon(LucideIcons.x, size: 16, color: AppColors.error),
                          SizedBox(width: 8),
                          CustomText(text: 'Cancel', color: AppColors.error),
                        ],
                      ),
                      onTap: () {
                        _updateStatus(RescueStatus.cancelled);
                      },
                    ),
                ];
              },
            ),
          ],
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

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Opacity(
            opacity: rescue.status == RescueStatus.cancelled ? 0.5 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Header
                StatusHeaderWidget(rescue: rescue),
                const SizedBox(height: 16),

                // Title Section
                TitleSectionWidget(rescue: rescue),
                const SizedBox(height: 16),

                // Details Section
                DetailsSectionWidget(rescue: rescue),
                const SizedBox(height: 16),

                // Location Section
                LocationSectionWidget(rescue: rescue),
                const SizedBox(height: 16),

                // Contact Section
                ContactSectionWidget(rescue: rescue),
                const SizedBox(height: 16),

                // Attachments Section
                AttachmentsSectionWidget(rescue: rescue),
                const SizedBox(height: 16),

                // Timestamp Section
                // TimestampSectionWidget(rescue: rescue),
                // const SizedBox(height: 32),

                // Action Buttons
                // ActionButtonsWidget(rescue: rescue, onUpdateStatus: _updateStatus),
              ],
            ),
          ),
        ),
        if (rescue.status == RescueStatus.cancelled)
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/cancelled.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.x, color: AppColors.error, size: 24),
                      CustomText(
                        text: "This emergency has been cancelled",
                        fontSize: 16,
                        // color: AppColors.gray900,
                      ),
                    ],
                  ),
                  CustomElevatedButton(
                    label: 'Go Back',
                    size: ButtonSize.sm,
                    icon: LucideIcons.arrowLeft,
                    isFullWidth: false,
                    onPressed: () {
                      context.router.pop();
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
