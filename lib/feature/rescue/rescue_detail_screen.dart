import 'package:amayalert/core/constant/constant.dart';
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

  Future<void> _cancelRescue() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text(
          'Are you sure you want to cancel and delete this emergency request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _rescueProvider.deleteRescue(widget.rescueId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.value), backgroundColor: Colors.green),
      );
      context.router.pop(); // Go back to previous screen
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error)));
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
            (_rescue != null &&
                    _rescue!.user?.id == userID &&
                    _rescue!.status != RescueStatus.cancelled &&
                    _rescue!.status != RescueStatus.completed)
                ? CustomTextButton(
                    label: 'Cancel',
                    foregroundColor: Colors.red,
                    onPressed: () {
                      _cancelRescue();
                    },
                  )
                : SizedBox.shrink(),
          ],
        ),
        body: _buildBody(),
        // floatingActionButton:
        //     _rescue != null &&
        //         _rescue!.user?.id == userID &&
        //         _rescue!.status != RescueStatus.cancelled &&
        //         _rescue!.status != RescueStatus.completed
        //     ? FloatingActionButton(
        //         onPressed: _cancelRescue,
        //         backgroundColor: AppColors.error,
        //         // shape: const CircleBorder(),
        //         elevation: 4,
        //         tooltip: 'Cancel Request',
        //         child: const Icon(LucideIcons.x, color: Colors.white, size: 20),
        //       )
        //     : null,
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
