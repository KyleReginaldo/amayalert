import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:amayalert/feature/rescue/rescue_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class CreateRescueScreen extends StatefulWidget {
  const CreateRescueScreen({super.key});

  @override
  State<CreateRescueScreen> createState() => _CreateRescueScreenState();
}

class _CreateRescueScreenState extends State<CreateRescueScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _victimCountController = TextEditingController();
  final _rescueProvider = RescueProvider();

  EmergencyType _selectedEmergencyType = EmergencyType.other;
  RescuePriority _selectedPriority = RescuePriority.medium;
  Position? _currentLocation;
  bool _isLoading = false;
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _additionalInfoController.dispose();
    _victimCountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);

    try {
      final permission = await Permission.location.request();
      if (permission.isGranted && mounted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (mounted) {
          setState(() => _currentLocation = position);
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _submitRescueRequest() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for your request')),
      );
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    setState(() => _isLoading = true);
    EasyLoading.show(status: 'Submitting rescue request...');

    try {
      // Validate required contact email
      final emailText = _emailController.text.trim();
      if (emailText.isEmpty) {
        EasyLoading.dismiss();
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a contact email.')),
        );
        return;
      }

      // Basic email format check
      final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
      if (!emailRegex.hasMatch(emailText)) {
        EasyLoading.dismiss();
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address.')),
        );
        return;
      }
      final request = CreateRescueRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        lat: _currentLocation?.latitude,
        lng: _currentLocation?.longitude,
        priority: _selectedPriority,
        emergencyType: _selectedEmergencyType,
        numberOfPeople: _victimCountController.text.isEmpty
            ? null
            : int.tryParse(_victimCountController.text),
        contactPhone: _contactController.text.trim().isEmpty
            ? null
            : '+63${_contactController.text.trim()}',
        importantInformation: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
        email: _emailController.text.trim(),
      );

      final result = await _rescueProvider.createRescue(
        userId: userId,
        request: request,
      );

      EasyLoading.dismiss();

      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rescue request submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.router.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.error)));
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldLight,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: const CustomText(
          text: 'Request Rescue',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Type Selection
            _buildSectionHeader('Emergency Type', LucideIcons.shield),
            const SizedBox(height: 12),
            _buildEmergencyTypeSelector(),

            const SizedBox(height: 24),

            // Priority Selection
            _buildSectionHeader('Priority Level', LucideIcons.zap),
            const SizedBox(height: 12),
            _buildPrioritySelector(),

            const SizedBox(height: 24),

            // Basic Information
            _buildSectionHeader('Emergency Details', LucideIcons.fileText),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _titleController,
              hint: 'Brief description of the emergency',
              label: 'Description',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _descriptionController,
              label: 'Additional details',
              hint: 'Additional details about the situation...',
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            // Additional Information
            _buildSectionHeader('Additional Information', LucideIcons.info),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _victimCountController,
                    hint: 'e.g. 10',
                    label: 'Number of people affected',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _contactController,
                    hint: 'e.g. 9923189664',
                    label: 'Contact phone',
                    prefixIcon: IconButton(
                      onPressed: null,
                      icon: CustomText(text: '+63'),
                    ),
                    maxLength: 10,

                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _emailController,
              hint: 'e.g. juandelacruz@example.com',
              label: 'Contact email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _additionalInfoController,
              hint: 'e.g. Wala na yung bubong nilipad na',
              label: 'Important information',
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Location
            _buildSectionHeader('Location', LucideIcons.mapPin),
            const SizedBox(height: 12),
            _buildLocationCard(),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRescueRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    : const Text(
                        'Submit Rescue Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        CustomText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ],
    );
  }

  Widget _buildEmergencyTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: EmergencyType.values.map((type) {
          return RadioListTile<EmergencyType>(
            value: type,
            groupValue: _selectedEmergencyType,
            onChanged: (value) {
              setState(() => _selectedEmergencyType = value!);
            },
            title: Text(_getEmergencyTypeLabel(type)),
            subtitle: Text(_getEmergencyTypeDescription(type)),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: RescuePriority.values.map((priority) {
          return RadioListTile<RescuePriority>(
            value: priority,
            groupValue: _selectedPriority,
            onChanged: (value) {
              setState(() => _selectedPriority = value!);
            },
            title: Row(
              children: [
                Icon(
                  LucideIcons.zap,
                  size: 16,
                  color: _getPriorityColor(priority),
                ),
                const SizedBox(width: 8),
                Text(
                  priority.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _getPriorityColor(priority),
                  ),
                ),
              ],
            ),
            subtitle: Text(priority.description),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.mapPin,
            color: _currentLocation != null ? Colors.green : AppColors.gray400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: _currentLocation != null
                      ? 'Current Location Detected'
                      : 'Getting location...',
                  fontWeight: FontWeight.w500,
                ),
                if (_currentLocation != null) ...[
                  const SizedBox(height: 4),
                  CustomText(
                    text:
                        'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}, '
                        'Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                    fontSize: 12,
                    color: AppColors.gray600,
                  ),
                ],
              ],
            ),
          ),
          if (_isLoadingLocation)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: _getCurrentLocation,
              icon: const Icon(LucideIcons.refreshCw, size: 20),
            ),
        ],
      ),
    );
  }

  String _getEmergencyTypeLabel(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return 'Medical Emergency';
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.flood:
        return 'Flood';
      case EmergencyType.accident:
        return 'Accident';
      case EmergencyType.violence:
        return 'Violence/Crime';
      case EmergencyType.naturalDisaster:
        return 'Natural Disaster';
      case EmergencyType.other:
        return 'Other Emergency';
    }
  }

  String _getEmergencyTypeDescription(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return 'Medical assistance needed';
      case EmergencyType.fire:
        return 'Fire-related emergency';
      case EmergencyType.flood:
        return 'Flood or water-related emergency';
      case EmergencyType.accident:
        return 'Vehicle or other accident';
      case EmergencyType.violence:
        return 'Safety threat or crime in progress';
      case EmergencyType.naturalDisaster:
        return 'Earthquake, typhoon, etc.';
      case EmergencyType.other:
        return 'Other type of emergency';
    }
  }

  Color _getPriorityColor(RescuePriority priority) {
    switch (priority) {
      case RescuePriority.low:
        return Colors.green;
      case RescuePriority.medium:
        return Colors.orange;
      case RescuePriority.high:
        return Colors.red;
      case RescuePriority.critical:
        return const Color(0xFF8B0000);
    }
  }
}
