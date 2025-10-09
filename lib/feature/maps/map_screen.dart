import 'dart:async';
import 'dart:math' as math;

import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/evacuation/evacuation_center_model.dart';
import 'package:amayalert/feature/evacuation/evacuation_repository.dart';
import 'package:amayalert/feature/maps/custom_google_places_field.dart';
import 'package:amayalert/feature/maps/directions_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../dependency.dart';

@RoutePage()
class MapScreen extends StatefulWidget implements AutoRouteWrapper {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<EvacuationRepository>(),
      child: this,
    );
  }
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  LatLng? _latlng;
  double _currentZoom = 17.0;
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _isEvacuationListExpanded = false;
  bool _isEvacuationListVisible = true;
  bool _isLoadingRoute = false;
  String? _routeInfo;

  late AnimationController _listAnimationController;
  late AnimationController _expandAnimationController;
  late Animation<double> _listSlideAnimation;
  late Animation<double> _expandAnimation;

  final Completer<GoogleMapController> _controllerCompleter = Completer();
  final TextEditingController _searchController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    _controllerCompleter.complete(controller);
  }

  Future<String> _getMapStyle() async {
    try {
      return await rootBundle.loadString('assets/json/map_style.json');
    } catch (e) {
      debugPrint('Map style not found: $e');
      return '[]'; // Return empty style if file not found
    }
  }

  void getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      LocationPermission permission = await Geolocator.checkPermission();
      bool approved =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (!approved) {
        permission = await Geolocator.requestPermission();
        approved =
            permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
      }

      if (approved) {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
          _latlng = LatLng(position.latitude, position.longitude);
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: _latlng!,
              infoWindow: const InfoWindow(title: 'Your Location'),
            ),
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Location permission denied';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _zoomIn() async {
    final GoogleMapController controller = await _controllerCompleter.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() async {
    final GoogleMapController controller = await _controllerCompleter.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  void _goToCurrentLocation() async {
    if (_latlng != null) {
      final GoogleMapController controller = await _controllerCompleter.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _latlng!, zoom: 17.0),
        ),
      );
    }
  }

  void _navigateToPlace(Prediction prediction) async {
    debugPrint('Navigating to place: ${prediction.description}');

    if (prediction.lat != null && prediction.lng != null) {
      final GoogleMapController controller = await _controllerCompleter.future;
      final searchLocation = LatLng(
        double.parse(prediction.lat!),
        double.parse(prediction.lng!),
      );

      // Clear existing search markers
      setState(() {
        _markers.removeWhere(
          (marker) => marker.markerId.value.startsWith('search_'),
        );
        _polylines.clear();
        _routeInfo = null;

        // Add marker for the searched location
        _markers.add(
          Marker(
            markerId: const MarkerId('search_location'),
            position: searchLocation,
            infoWindow: InfoWindow(
              title:
                  prediction.structuredFormatting?.mainText ?? 'Search Result',
              snippet:
                  prediction.structuredFormatting?.secondaryText ??
                  prediction.description,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      });

      // Animate camera to the searched location
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: searchLocation, zoom: 16.0),
        ),
      );

      // Get directions from current location to searched location if available
      if (_latlng != null) {
        setState(() {
          _isLoadingRoute = true;
        });

        try {
          final routePointsFuture = DirectionsService.getDirections(
            _latlng!,
            searchLocation,
          );
          final routeInfoFuture = DirectionsService.getRouteInfo(
            _latlng!,
            searchLocation,
          );

          final results = await Future.wait([
            routePointsFuture,
            routeInfoFuture,
          ]);
          final List<LatLng>? routePoints = results[0] as List<LatLng>?;
          final String? routeInfo = results[1] as String?;

          setState(() {
            _isLoadingRoute = false;
            _routeInfo = routeInfo;
          });

          if (routePoints != null && routePoints.isNotEmpty) {
            setState(() {
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId('route_to_search'),
                  points: routePoints,
                  color: Colors.blue,
                  width: 5,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                  jointType: JointType.round,
                ),
              );
            });

            // Adjust camera to show the entire route
            final bounds = _calculateBounds(routePoints);
            controller.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 100.0),
            );
          }
        } catch (e) {
          debugPrint('Error getting directions to search location: $e');
          setState(() {
            _isLoadingRoute = false;
            _routeInfo = null;
          });
        }
      }
    } else {
      debugPrint('No coordinates available for this place');
      // Show a message to user that location coordinates are not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: 'Unable to get coordinates for this location',
            color: Colors.white,
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Initialize animations
    _listSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _expandAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start with list visible
    _listAnimationController.value = 0.0;

    getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvacuationRepository>().getEvacuationCenters();
      // Add listener to update markers when centers are loaded
      context.read<EvacuationRepository>().addListener(
        _updateEvacuationCenterMarkers,
      );
    });
  }

  void _updateEvacuationCenterMarkers() {
    final evacuationCenters = context.read<EvacuationRepository>().centers;
    setState(() {
      // Remove existing evacuation center markers
      _markers.removeWhere(
        (marker) => marker.markerId.value.startsWith('evacuation_'),
      );

      // Add markers for all evacuation centers
      for (final center in evacuationCenters) {
        _markers.add(
          Marker(
            markerId: MarkerId('evacuation_${center.id}'),
            position: LatLng(center.latitude, center.longitude),
            infoWindow: InfoWindow(title: center.name, snippet: center.address),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listAnimationController.dispose();
    _expandAnimationController.dispose();
    // Remove listener to prevent memory leaks
    if (mounted) {
      context.read<EvacuationRepository>().removeListener(
        _updateEvacuationCenterMarkers,
      );
    }
    super.dispose();
  }

  Color _getGradientTopColor() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      // Morning - soft blue/purple gradient
      return const Color(0xFF64B5F6);
    } else if (hour < 17) {
      // Afternoon - warm golden/orange gradient
      return const Color(0xFFFFB74D);
    } else {
      // Evening - deep purple/pink gradient
      return const Color(0xFF7986CB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const CustomText(
          text: 'Amayalert Map',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        backgroundColor: _getGradientTopColor(),
        elevation: 0,
        surfaceTintColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          // Map Widget
          if (_latlng != null)
            FutureBuilder<String>(
              future: _getMapStyle(),
              builder: (context, snapshot) {
                return GoogleMap(
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  // style: snapshot.data,
                  initialCameraPosition: CameraPosition(
                    target: _latlng!,
                    zoom: _currentZoom,
                  ),
                  mapType: _currentMapType,
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // We'll use custom button
                  zoomControlsEnabled: false, // Custom zoom controls
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                );
              },
            )
          else if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  CustomText(
                    text: 'Getting your location...',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.mapPin, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  CustomText(
                    text: _errorMessage!,
                    fontSize: 16,
                    color: Colors.red,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: getCurrentLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const CustomText(
                      text: 'Retry',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: CustomGooglePlacesTextField(
              controller: _searchController,
              hintText: 'Search location...',
              onPlaceDetailsWithCoordinatesReceived: (prediction) {
                // This gets called when place is selected and coordinates are available
                debugPrint(
                  'Place selected with coordinates: ${prediction.description}',
                );
                _navigateToPlace(prediction);
              },
              onSuggestionClicked: (prediction) {
                // This gets called when user clicks on a suggestion in the dropdown
                debugPrint(
                  'User clicked on suggestion: ${prediction.description}',
                );
                // Just close the search and populate the text field
                if (prediction.description != null) {
                  _searchController.text = prediction.description!;
                }
                // Navigate to the place
                _navigateToPlace(prediction);
              },
            ),
          ),

          // Map Type Toggle
          Positioned(
            top: 80,
            right: 16,
            child: Column(
              spacing: 8,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleMapType,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          _currentMapType == MapType.normal
                              ? LucideIcons.satellite
                              : LucideIcons.map,
                          color: Colors.grey.shade700,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _zoomIn,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          LucideIcons.plus,
                          color: Colors.grey.shade700,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _zoomOut,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          LucideIcons.minus,
                          color: Colors.grey.shade700,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _goToCurrentLocation,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          LucideIcons.navigation,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                // Clear Route Button (only show when there are polylines)
                if (_polylines.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _clearRoute,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            LucideIcons.x,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Zoom Controls

          // Current Location Button

          // Evacuation Centers List
          if (_isEvacuationListVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildEvacuationCentersList(),
            ),

          // Toggle Button for Evacuation Centers List
          if (!_isEvacuationListVisible)
            Positioned(bottom: 20, right: 16, child: _buildShowListButton()),

          // Route Information Display
          if (_routeInfo != null || _isLoadingRoute)
            Positioned(top: 80, left: 16, child: _buildRouteInfoCard()),
        ],
      ),
    );
  }

  Widget _buildEvacuationCentersList() {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _listSlideAnimation.value * 300),
          child: Opacity(
            opacity: 1.0 - _listAnimationController.value,
            child: child,
          ),
        );
      },
      child: _buildEvacuationCentersContent(),
    );
  }

  Widget _buildEvacuationCentersContent() {
    final evacuationCenters = context.watch<EvacuationRepository>().centers;
    final isLoadingCenters = context.watch<EvacuationRepository>().isLoading;

    if (isLoadingCenters && evacuationCenters.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            CustomText(
              text: 'Loading evacuation centers...',
              fontSize: 14,
              color: Colors.grey,
            ),
          ],
        ),
      );
    }

    if (evacuationCenters.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(LucideIcons.mapPin, color: Colors.grey, size: 16),
            SizedBox(width: 12),
            CustomText(
              text: 'No evacuation centers found',
              fontSize: 14,
              color: Colors.grey,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(LucideIcons.building, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: CustomText(
                    text: 'Evacuation Centers',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CustomText(
                  text: '${evacuationCenters.length} available',
                  fontSize: 12,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _hideEvacuationList,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        LucideIcons.x,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Centers List with Animation
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final itemsToShow = _isEvacuationListExpanded
                  ? evacuationCenters.length
                  : math.min(2, evacuationCenters.length);

              final visibleItems = (itemsToShow * _expandAnimation.value)
                  .ceil();
              final actualItemsToShow = _isEvacuationListExpanded
                  ? math.max(visibleItems, 2)
                  : math.min(visibleItems + 2, evacuationCenters.length);

              return Column(
                children: evacuationCenters
                    .take(actualItemsToShow)
                    .map(
                      (center) => AnimatedContainer(
                        duration: Duration(
                          milliseconds:
                              150 + (evacuationCenters.indexOf(center) * 50),
                        ),
                        curve: Curves.easeOutCubic,
                        child: _buildCenterTile(center),
                      ),
                    )
                    .toList(),
              );
            },
          ),

          // Expand/Collapse Button with Animation
          if (evacuationCenters.length > 2)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleExpandList,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey, width: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: CustomText(
                          key: ValueKey(_isEvacuationListExpanded),
                          text: _isEvacuationListExpanded
                              ? 'Show Less'
                              : 'Show ${evacuationCenters.length - 2} More',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _isEvacuationListExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          LucideIcons.chevronDown,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCenterTile(EvacuationCenter center) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _focusOnCenter(center),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Indicator
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(center.status),
                ),
              ),
              const SizedBox(width: 12),

              // Center Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: center.name,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      text: center.address,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.users,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        CustomText(
                          text:
                              center.capacity != null &&
                                  center.currentOccupancy != null
                              ? '${center.currentOccupancy}/${center.capacity}'
                              : 'Capacity unknown',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              center.status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: CustomText(
                            text: center.status?.displayName ?? 'Unknown',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(center.status),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Distance/Direction Icon
              Icon(
                LucideIcons.navigation,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(EvacuationStatus? status) {
    switch (status) {
      case EvacuationStatus.open:
        return Colors.green;
      case EvacuationStatus.full:
        return Colors.orange;
      case EvacuationStatus.closed:
        return Colors.red;
      case EvacuationStatus.maintenance:
        return Colors.grey;
      case null:
        return Colors.grey;
    }
  }

  void _focusOnCenter(EvacuationCenter center) async {
    final GoogleMapController controller = await _controllerCompleter.future;

    // Hide the evacuation list with animation
    _hideEvacuationList();

    setState(() {
      // Clear previous evacuation center markers and polylines
      _markers.removeWhere(
        (marker) => marker.markerId.value.startsWith('evacuation_'),
      );
      _polylines.clear();

      // Add marker for the selected evacuation center
      _markers.add(
        Marker(
          markerId: MarkerId('evacuation_${center.id}'),
          position: LatLng(center.latitude, center.longitude),
          infoWindow: InfoWindow(title: center.name, snippet: center.address),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });

    // Get directions from current location to evacuation center
    if (_latlng != null) {
      setState(() {
        _isLoadingRoute = true;
        _routeInfo = null;
      });

      try {
        final destination = LatLng(center.latitude, center.longitude);

        // Get both route points and route info
        final routePointsFuture = DirectionsService.getDirections(
          _latlng!,
          destination,
        );
        final routeInfoFuture = DirectionsService.getRouteInfo(
          _latlng!,
          destination,
        );

        final results = await Future.wait([routePointsFuture, routeInfoFuture]);
        final List<LatLng>? routePoints = results[0] as List<LatLng>?;
        final String? routeInfo = results[1] as String?;

        debugPrint(
          '🗺️ Map Screen: Received ${routePoints?.length ?? 0} route points',
        );
        debugPrint('🗺️ Map Screen: Route info: $routeInfo');

        setState(() {
          _isLoadingRoute = false;
          _routeInfo = routeInfo;
        });

        if (routePoints != null && routePoints.isNotEmpty) {
          debugPrint(
            '✅ Map Screen: Using API route with ${routePoints.length} points',
          );
          setState(() {
            // Add accurate polyline based on roads
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route_to_evacuation'),
                points: routePoints,
                color: Colors.blue,
                width: 5,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
                jointType: JointType.round,
              ),
            );
          });

          // Calculate bounds for the entire route
          final bounds = _calculateBounds(routePoints);
          controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
        } else {
          // Fallback to straight line if directions fail
          debugPrint('❌ Map Screen: API failed, using straight line fallback');
          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route_to_evacuation'),
                points: [_latlng!, LatLng(center.latitude, center.longitude)],
                color: Colors.red,
                width: 4,
                patterns: [PatternItem.dash(20), PatternItem.gap(10)],
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            );
          });

          final bounds = _calculateBounds([
            _latlng!,
            LatLng(center.latitude, center.longitude),
          ]);

          controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
        }
      } catch (e) {
        debugPrint('Error getting directions: $e');
        setState(() {
          _isLoadingRoute = false;
          _routeInfo = null;
        });

        // Fallback to straight line
        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route_to_evacuation'),
              points: [_latlng!, LatLng(center.latitude, center.longitude)],
              color: Colors.red,
              width: 4,
              patterns: [PatternItem.dash(20), PatternItem.gap(10)],
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );
        });
      }
    } else {
      // If no current location, just focus on the center
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(center.latitude, center.longitude),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _routeInfo = null;
      _isLoadingRoute = false;
      // Remove evacuation center markers but keep current location marker
      _markers.removeWhere(
        (marker) => marker.markerId.value.startsWith('evacuation_'),
      );
    });
  }

  void _hideEvacuationList() {
    _listAnimationController.forward().then((_) {
      setState(() {
        _isEvacuationListVisible = false;
      });
      _listAnimationController.reset();
    });
  }

  void _showEvacuationList() {
    setState(() {
      _isEvacuationListVisible = true;
    });
    _listAnimationController.forward().then((_) {
      _listAnimationController.reset();
    });
  }

  void _toggleExpandList() {
    if (_isEvacuationListExpanded) {
      _expandAnimationController.reverse().then((_) {
        setState(() {
          _isEvacuationListExpanded = false;
        });
      });
    } else {
      setState(() {
        _isEvacuationListExpanded = true;
      });
      _expandAnimationController.forward();
    }
  }

  Widget _buildShowListButton() {
    final evacuationCenters = context.watch<EvacuationRepository>().centers;

    if (evacuationCenters.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showEvacuationList,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.building, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                CustomText(
                  text: '${evacuationCenters.length}',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoadingRoute)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(LucideIcons.navigation, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          CustomText(
            text: _isLoadingRoute
                ? 'Calculating route...'
                : _routeInfo ?? 'Route info unavailable',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _isLoadingRoute ? Colors.grey : Colors.black87,
          ),
        ],
      ),
    );
  }
}
