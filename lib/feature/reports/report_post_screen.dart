import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/reports/report_model.dart';
import 'package:amayalert/feature/reports/report_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class ReportPostScreen extends StatefulWidget {
  final int postId;
  final String? postContent;

  const ReportPostScreen({super.key, required this.postId, this.postContent});

  @override
  State<ReportPostScreen> createState() => _ReportPostScreenState();
}

class _ReportPostScreenState extends State<ReportPostScreen> {
  String? _selectedReason;
  final TextEditingController _customReasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reason for reporting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    EasyLoading.show(status: 'Submitting report...');

    try {
      final repository = context.read<ReportRepository>();

      // Use custom reason if "Other" is selected and custom text is provided
      final reason =
          _selectedReason == ReportReasons.other &&
              _customReasonController.text.isNotEmpty
          ? _customReasonController.text.trim()
          : _selectedReason!;

      final result = await repository.reportPost(
        postId: widget.postId,
        reason: reason,
        reportedBy: userId,
      );

      if (result.isSuccess) {
        EasyLoading.showSuccess('Post reported successfully');
        if (mounted) {
          context.router.pop(true); // Return true to indicate successful report
        }
      } else {
        EasyLoading.showError(result.error);
      }
    } catch (e) {
      EasyLoading.showError('Failed to submit report: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.black),
          onPressed: () => context.router.pop(),
        ),
        title: const CustomText(
          text: 'Report Post',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post preview
            if (widget.postContent != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      text: 'Reporting this post:',
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      text: widget.postContent!.length > 100
                          ? '${widget.postContent!.substring(0, 100)}...'
                          : widget.postContent!,
                      fontSize: 14,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Information section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: CustomText(
                      text:
                          'Help us understand what\'s happening with this post',
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reason selection
            const CustomText(
              text: 'Why are you reporting this post?',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: ReportReasons.all.length,
                itemBuilder: (context, index) {
                  final reason = ReportReasons.all[index];
                  final isSelected = _selectedReason == reason;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.05)
                          : null,
                    ),
                    child: RadioListTile<String>(
                      title: CustomText(
                        text: reason,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      value: reason,
                      groupValue: _selectedReason,
                      onChanged: (value) {
                        setState(() {
                          _selectedReason = value;
                        });
                      },
                      activeColor: AppColors.primary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Custom reason input for "Other"
            if (_selectedReason == ReportReasons.other) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customReasonController,
                decoration: InputDecoration(
                  hintText: 'Please specify the reason...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
            ],

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const CustomText(
                        text: 'Submit Report',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Disclaimer
            Center(
              child: CustomText(
                text: 'Reports are reviewed by our moderation team',
                fontSize: 12,
                color: Colors.grey[600],
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
