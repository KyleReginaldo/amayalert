import 'dart:async';
import 'dart:io';

import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:amayalert/feature/rescue/rescue_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
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
  final _maleCountController = TextEditingController();
  final _femaleCountController = TextEditingController();
  final _addressController = TextEditingController();
  final _rescueProvider = RescueProvider();
  final _imagePicker = ImagePicker();

  final _otherTypeController = TextEditingController();

  EmergencyType _selectedEmergencyType = EmergencyType.other;
  RescuePriority _selectedPriority = RescuePriority.medium;
  Position? _currentLocation;
  String? _currentAddress;
  bool _isLoading = false;
  bool _isLoadingLocation = false;

  // Interactive map
  final MapController _mapController = MapController();
  Timer? _cameraIdleTimer;
  LatLng? _mapCenter;
  bool _isReverseGeocoding = false;
  bool _isMapInteracting = false;
  final List<XFile> _selectedImages = [];
  // Whether user signed in with Google (kept for future logic, not required for UI)
  bool _isGuestUser = false;
  String? _userEmail;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _additionalInfoController.dispose();
    _femaleCountController.dispose();
    _maleCountController.dispose();
    _addressController.dispose();
    _otherTypeController.dispose();
    _cameraIdleTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadAuthContext();
  }

  void _loadAuthContext() {
    final user = Supabase.instance.client.auth.currentUser;
    final provider = user?.appMetadata['provider']?.toString();
    setState(() {
      _userEmail = user?.email;
      _isGuestUser = provider == 'anonymous' || user == null;
    });
    // Pre-fill phone + affected count from registered profile
    if (user != null) _prefillFromProfile(user.id);
  }

  Future<void> _prefillFromProfile(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select('phone_number, gender')
          .eq('id', userId)
          .single();

      if (!mounted) return;

      // Pre-fill phone — strip the +63 prefix if present so it fits the field
      final phone = data['phone_number'] as String? ?? '';
      if (phone.isNotEmpty && _contactController.text.isEmpty) {
        final digits = phone.startsWith('+63')
            ? phone.substring(3)
            : phone.startsWith('63')
                ? phone.substring(2)
                : phone;
        _contactController.text = digits;
      }

      // Pre-fill affected count based on registered sex
      final gender = (data['gender'] as String? ?? '').toLowerCase();
      if (gender == 'female' && _femaleCountController.text.isEmpty) {
        _femaleCountController.text = '1';
      } else if (gender == 'male' && _maleCountController.text.isEmpty) {
        _maleCountController.text = '1';
      }
    } catch (_) {
      // Non-critical — leave fields empty
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
      _currentAddress = null;
      _addressController.clear();
    });

    try {
      final permission = await Permission.location.request();
      if (permission.isGranted && mounted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (mounted) {
          setState(() => _currentLocation = position);
          _getAddressFromCoordinates(position.latitude, position.longitude);
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

  Future<void> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        final addressComponents = <String>[];

        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressComponents.add(placemark.street!);
        }
        if (placemark.subLocality != null &&
            placemark.subLocality!.isNotEmpty) {
          addressComponents.add(placemark.subLocality!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressComponents.add(placemark.locality!);
        }
        if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.isNotEmpty) {
          addressComponents.add(placemark.administrativeArea!);
        }

        final address = addressComponents.join(', ');
        if (mounted) {
          setState(() {
            _currentAddress = address.isNotEmpty
                ? address
                : 'Address not available';
            _addressController.text = _currentAddress!;
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      if (mounted) {
        setState(() {
          _currentAddress = 'Address not available';
          _addressController.text = _currentAddress!;
        });
      }
    }
  }

  static const int _maxImages = 5;

  Future<void> _showImageSourceDialog() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $_maxImages photos allowed.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImages(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImages(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImages(ImageSource source) async {
    try {
      final remaining = _maxImages - _selectedImages.length;
      if (remaining <= 0) return;

      if (source == ImageSource.camera) {
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          maxWidth: 1080,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (image != null) {
          setState(() => _selectedImages.add(image));
        }
      } else {
        final List<XFile> images = await _imagePicker.pickMultiImage(
          maxWidth: 1080,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (images.isNotEmpty) {
          // Only add up to the remaining slots
          setState(() {
            _selectedImages.addAll(images.take(remaining));
          });
          if (images.length > remaining && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Only $remaining more photo${remaining == 1 ? '' : 's'} added (max $_maxImages).',
                ),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  // ── Interactive map callbacks ─────────────────────────────────────────────

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _mapCenter = camera.center;
    if (!_isReverseGeocoding && mounted) {
      setState(() => _isReverseGeocoding = true);
      _addressController.text = 'Finding address…';
    }
    _cameraIdleTimer?.cancel();
    _cameraIdleTimer = Timer(const Duration(milliseconds: 600), _onCameraIdle);
  }

  void _onCameraIdle() async {
    final center = _mapCenter;
    if (center == null) return;
    // Update _currentLocation so the submit uses the dragged pin
    setState(() {
      _currentLocation = Position(
        latitude: center.latitude,
        longitude: center.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    });
    await _getAddressFromCoordinates(center.latitude, center.longitude);
    if (mounted) setState(() => _isReverseGeocoding = false);
  }

  Future<void> _submitRescueRequest() async {
    // If "Other" selected, require the custom type field
    if (_selectedEmergencyType == EmergencyType.other &&
        _otherTypeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the type of emergency')),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for your request')),
      );
      return;
    }

    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please allow location access or wait for location to be detected',
          ),
        ),
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
      // Determine contact email from signed-in user (none for guest)
      final String? emailToUse = _isGuestUser ? null : _userEmail;

      final request = CreateRescueRequest(
        title: _selectedEmergencyType == EmergencyType.other
            ? '${_otherTypeController.text.trim()}: ${_titleController.text.trim()}'
            : _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        lat: _currentLocation?.latitude,
        lng: _currentLocation?.longitude,
        priority: _selectedPriority,
        emergencyType: _selectedEmergencyType,
        femaleCount: _femaleCountController.text.isEmpty
            ? null
            : int.tryParse(_femaleCountController.text),
        maleCount: _maleCountController.text.isEmpty
            ? null
            : int.tryParse(_maleCountController.text),
        contactPhone: _contactController.text.trim().isEmpty
            ? null
            : '+63${_contactController.text.trim()}',
        importantInformation: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
        email: emailToUse ?? '',
        attachmentFiles: _selectedImages.isNotEmpty ? _selectedImages : null,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
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
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: AppColors.textPrimaryLight,
            size: 20,
          ),
        ),
        title: const Text(
          'Request Rescue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: AppColors.danger),
        ),
      ),
      body: SingleChildScrollView(
        physics: _isMapInteracting
            ? const NeverScrollableScrollPhysics()
            : const ScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Emergency Type ─────────────────────────────────────────
            _sectionLabel('Emergency Type', LucideIcons.siren, required: true),
            const SizedBox(height: 8),
            _buildEmergencyTypeChips(),
            if (_selectedEmergencyType == EmergencyType.other) ...[
              const SizedBox(height: 10),
              CustomTextField(
                controller: _otherTypeController,
                hint: 'e.g. Gas leak, Tree fall, Power outage…',
                label: 'Specify emergency type *',
                prefixIcon: const Icon(
                  LucideIcons.pencil,
                  size: 16,
                  color: AppColors.gray500,
                ),
              ),
            ],
            const SizedBox(height: 14),

            // ── Priority ───────────────────────────────────────────────
            _sectionLabel('Priority', LucideIcons.zap),
            const SizedBox(height: 8),
            _buildPriorityRow(),
            const SizedBox(height: 14),

            // ── Incident Report (merged card) ──────────────────────────
            _sectionLabel(
              'Incident Report',
              LucideIcons.fileText,
              required: true,
            ),
            const SizedBox(height: 8),
            _card(
              child: Column(
                children: [
                  CustomTextField(
                    controller: _titleController,
                    hint: 'Brief description of the emergency',
                    label: 'Description *',
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Additional details',
                    hint: 'What is happening? Any specific needs?',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _maleCountController,
                          hint: '0',
                          label: 'Male affected',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomTextField(
                          controller: _femaleCountController,
                          hint: '0',
                          label: 'Female affected',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _contactController,
                    hint: '9XXXXXXXXX',
                    label: 'Contact Number',
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇵🇭', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          const Text(
                            '+63',
                            style: TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 16,
                            color: AppColors.gray300,
                            margin: const EdgeInsets.only(left: 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Location ───────────────────────────────────────────────
            _sectionLabel('Location', LucideIcons.mapPin, required: true),
            const SizedBox(height: 8),
            _buildLocationCard(),
            const SizedBox(height: 14),

            // ── Attachments ────────────────────────────────────────────
            _sectionLabel('Attachments', LucideIcons.paperclip),
            const SizedBox(height: 8),
            _buildAttachmentsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _submitRescueRequest,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(LucideIcons.siren, size: 20),
            label: Text(
              _isLoading ? 'Submitting...' : 'Submit Emergency Request',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String title, IconData icon, {bool required = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  static const _typeColors = {
    EmergencyType.medical: AppColors.danger,
    EmergencyType.fire: Color(0xFFF97316),
    EmergencyType.flood: AppColors.info,
    EmergencyType.accident: Color(0xFFD97706),
    EmergencyType.violence: Color(0xFF7C3AED),
    EmergencyType.naturalDisaster: Color(0xFF0D9488),
    EmergencyType.other: AppColors.gray500,
  };

  static const _typeLabels = {
    EmergencyType.medical: 'Medical',
    EmergencyType.fire: 'Fire',
    EmergencyType.flood: 'Flood',
    EmergencyType.accident: 'Accident',
    EmergencyType.violence: 'Violence',
    EmergencyType.naturalDisaster: 'Disaster',
    EmergencyType.other: 'Other',
  };

  Widget _buildEmergencyTypeChips() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: EmergencyType.values.map((type) {
        final color = _typeColors[type]!;
        final label = _typeLabels[type]!;
        final selected = _selectedEmergencyType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedEmergencyType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? color : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type.icon,
                  size: 14,
                  color: selected ? color : AppColors.gray400,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? color : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityRow() {
    final data = [
      (RescuePriority.low, AppColors.success, 'Low'),
      (RescuePriority.medium, AppColors.warning, 'Medium'),
      (RescuePriority.high, AppColors.danger, 'High'),
      (RescuePriority.critical, const Color(0xFF7F1D1D), 'Critical'),
    ];

    return Row(
      children: data.map((item) {
        final (priority, color, label) = item;
        final selected = _selectedPriority == priority;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPriority = priority),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? color : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selected ? color : AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.zap,
                    size: 13,
                    color: selected ? Colors.white : color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Icon(
                  LucideIcons.mapPin,
                  size: 16,
                  color: _currentLocation != null
                      ? AppColors.success
                      : AppColors.gray400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _isLoadingLocation
                        ? 'Getting your location…'
                        : _currentLocation != null
                            ? 'Drag the map to adjust pin'
                            : 'Location unavailable',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _currentLocation != null
                          ? AppColors.textSecondaryLight
                          : AppColors.gray400,
                    ),
                  ),
                ),
                if (_isLoadingLocation)
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(LucideIcons.refreshCw,
                        size: 16, color: AppColors.gray500),
                    tooltip: 'Re-detect location',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 32, minHeight: 32),
                  ),
              ],
            ),
          ),

          if (_currentLocation != null) ...[
            // ── Draggable map ────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(0)),
              child: SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    // Pause the parent scroll while finger is on the map
                    Listener(
                      onPointerDown: (_) =>
                          setState(() => _isMapInteracting = true),
                      onPointerUp: (_) =>
                          setState(() => _isMapInteracting = false),
                      onPointerCancel: (_) =>
                          setState(() => _isMapInteracting = false),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            _currentLocation!.latitude,
                            _currentLocation!.longitude,
                          ),
                          initialZoom: 17,
                          onPositionChanged: _onPositionChanged,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all &
                                ~InteractiveFlag.rotate,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c', 'd'],
                            userAgentPackageName: 'com.amayalert.app',
                          ),
                        ],
                      ),
                    ),

                    // Fixed center crosshair pin
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.mapPin,
                              size: 32, color: AppColors.danger),
                          SizedBox(height: 4),
                          // Shadow dot under the pin
                          SizedBox(
                            width: 8, height: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(4)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Address field (auto-updated) ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: CustomTextField(
                controller: _addressController,
                hint: 'Address will appear here…',
                prefixIcon: Icon(
                  _isReverseGeocoding
                      ? LucideIcons.loader
                      : LucideIcons.mapPin,
                  size: 16,
                  color: _isReverseGeocoding
                      ? AppColors.primary
                      : AppColors.gray500,
                ),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ElevatedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: const Icon(LucideIcons.mapPin, size: 16),
                label: const Text('Detect my location'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // String _getEmergencyTypeLabel(EmergencyType type) {
  //   switch (type) {
  //     case EmergencyType.medical:
  //       return 'Medical Emergency';
  //     case EmergencyType.fire:
  //       return 'Fire';
  //     case EmergencyType.flood:
  //       return 'Flood';
  //     case EmergencyType.accident:
  //       return 'Accident';
  //     case EmergencyType.violence:
  //       return 'Violence/Crime';
  //     case EmergencyType.naturalDisaster:
  //       return 'Natural Disaster';
  //     case EmergencyType.other:
  //       return 'Other Emergency';
  //   }
  // }

  // String _getEmergencyTypeDescription(EmergencyType type) {
  //   switch (type) {
  //     case EmergencyType.medical:
  //       return 'Medical assistance needed';
  //     case EmergencyType.fire:
  //       return 'Fire-related emergency';
  //     case EmergencyType.flood:
  //       return 'Flood or water-related emergency';
  //     case EmergencyType.accident:
  //       return 'Vehicle or other accident';
  //     case EmergencyType.violence:
  //       return 'Safety threat or crime in progress';
  //     case EmergencyType.naturalDisaster:
  //       return 'Earthquake, typhoon, etc.';
  //     case EmergencyType.other:
  //       return 'Other type of emergency';
  //   }
  // }

  Widget _buildAttachmentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Add photos button
          InkWell(
            onTap: _showImageSourceDialog,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gray300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.camera, color: AppColors.gray600),
                  const SizedBox(width: 8),
                  CustomText(text: 'Add photos', color: AppColors.gray600),
                  const Spacer(),
                  Icon(
                    LucideIcons.chevronRight,
                    color: AppColors.gray400,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Selected images grid
          if (_selectedImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            CustomText(
              text: '${_selectedImages.length}/$_maxImages photos selected',
              fontSize: 14,
              color: AppColors.gray600,
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_selectedImages[index].path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.x,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
