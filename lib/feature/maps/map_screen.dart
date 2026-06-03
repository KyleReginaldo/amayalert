import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/evacuation/evacuation_center_model.dart';
import 'package:amayalert/feature/evacuation/evacuation_repository.dart';
import 'package:amayalert/feature/maps/custom_google_places_field.dart';
import 'package:amayalert/feature/maps/directions_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
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
  bool _isSatellite = false;

  LatLng? _searchMarkerPos;
  bool _showAllEvacMarkers = true;
  int? _focusedEvacId;
  final List<Polyline> _polylines = [];

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

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  double? _heading;
  StreamSubscription<CompassEvent>? _compassSub;

  bool _isNavigating = false;
  StreamSubscription<Position>? _locationSub;

  // CartoDB Positron (light_all) — clean, light gray, closest to Grab Maps style
  String get _tileUrl => _isSatellite
      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
      : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

  List<String> get _tileSubdomains =>
      _isSatellite ? const [] : const ['a', 'b', 'c', 'd'];

  // ── Location ───────────────────────────────────────────────────────────────

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

  // ── Map controls ───────────────────────────────────────────────────────────

  void _toggleMapType() => setState(() => _isSatellite = !_isSatellite);

  void _zoomIn() {
    _mapController.move(_mapController.camera.center, _currentZoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.camera.center, _currentZoom - 1);
  }

  void _goToCurrentLocation() {
    if (_latlng != null) {
      _mapController.move(_latlng!, 17.0);
      setState(() => _currentZoom = 17.0);
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  void _navigateToPlace(LocationPrediction result) async {
    final searchLocation = LatLng(result.lat, result.lng);

    setState(() {
      _searchMarkerPos = searchLocation;
      _polylines.clear();
      _routeInfo = null;
    });

    _mapController.move(searchLocation, 16.0);
    setState(() => _currentZoom = 16.0);

    if (_latlng != null) {
      setState(() => _isLoadingRoute = true);

      try {
        final results = await Future.wait([
          DirectionsService.getDirections(_latlng!, searchLocation),
          DirectionsService.getRouteInfo(_latlng!, searchLocation),
        ]);
        final routePoints = results[0] as List<LatLng>?;
        final routeInfo = results[1] as String?;

        setState(() {
          _isLoadingRoute = false;
          _routeInfo = routeInfo;
        });

        if (routePoints != null && routePoints.isNotEmpty) {
          setState(() {
            _polylines
              ..add(
                Polyline(
                  points: routePoints,
                  color: Colors.white,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  strokeJoin: StrokeJoin.round,
                ),
              )
              ..add(
                Polyline(
                  points: routePoints,
                  color: const Color(0xFF1D6BF3),
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  strokeJoin: StrokeJoin.round,
                ),
              );
          });
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(routePoints),
              padding: const EdgeInsets.all(100),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error getting directions to search: $e');
        setState(() {
          _isLoadingRoute = false;
          _routeInfo = null;
        });
      }
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

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

    getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvacuationRepository>().getEvacuationCenters();
    });

    _compassSub = FlutterCompass.events?.listen((event) {
      final h = event.heading;
      // Guard: flutter_compass can fire NaN on some devices
      if (!mounted || h == null || !h.isFinite) return;
      setState(() => _heading = h);
    });
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _compassSub?.cancel();
    _searchController.dispose();
    _listAnimationController.dispose();
    _expandAnimationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ── Navigation mode ────────────────────────────────────────────────────────

  void _startNavigation() {
    setState(() {
      _isNavigating = true;
      _currentZoom = 18.0;
    });
    if (_latlng != null) {
      _mapController.move(_latlng!, 18.0);
    }

    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      if (!mounted) return;
      // Guard against NaN GPS values (can happen briefly on some devices)
      if (!pos.latitude.isFinite || !pos.longitude.isFinite) return;
      final newPos = LatLng(pos.latitude, pos.longitude);
      setState(() => _latlng = newPos);
      _mapController.move(newPos, _currentZoom);
    });
  }

  void _stopNavigation() {
    _locationSub?.cancel();
    _locationSub = null;
    setState(() => _isNavigating = false);
  }

  // ── Markers ────────────────────────────────────────────────────────────────

  List<Marker> _buildMarkers(List<EvacuationCenter> centers) {
    final markers = <Marker>[];

    // Current location — nav arrow (navigation mode) OR blue dot + cone
    if (_latlng != null) {
      if (_isNavigating) {
        // Waze / Google Maps-style directional arrow
        markers.add(Marker(
          point: _latlng!,
          width: 60,
          height: 60,
          child: Transform.rotate(
            angle: (_heading ?? 0) * math.pi / 180,
            child: CustomPaint(
              size: const Size(60, 60),
              painter: const _NavArrow(),
            ),
          ),
        ));
      } else {
        // Default: accuracy ring + heading cone + blue dot
        markers.add(Marker(
          point: _latlng!,
          width: 72,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D6BF3).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1D6BF3).withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
              ),
              if (_heading != null)
                Transform.rotate(
                  angle: _heading! * math.pi / 180,
                  child: CustomPaint(
                    size: const Size(72, 72),
                    painter: const _HeadingCone(),
                  ),
                ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D6BF3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D6BF3).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
      }
    }

    // Search result pin (red)
    if (_searchMarkerPos != null) {
      markers.add(Marker(
        point: _searchMarkerPos!,
        width: 44,
        height: 54,
        alignment: Alignment.bottomCenter,
        child: _MapPin(color: Colors.red, icon: LucideIcons.search),
      ));
    }

    // Evacuation center pins (brand blue)
    const evac = Color(0xFF1D6BF3);
    void addEvacMarker(EvacuationCenter c) {
      markers.add(Marker(
        point: LatLng(c.latitude, c.longitude),
        width: 44,
        height: 54,
        alignment: Alignment.bottomCenter,
        child: const _MapPin(color: evac, icon: LucideIcons.building),
      ));
    }

    if (_showAllEvacMarkers) {
      for (final c in centers) addEvacMarker(c);
    } else if (_focusedEvacId != null) {
      for (final c in centers.where((c) => c.id == _focusedEvacId)) {
        addEvacMarker(c);
      }
    }

    return markers;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final evacuationCenters = context.watch<EvacuationRepository>().centers;

    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            // ── Full-screen map ──────────────────────────────────────────
            if (_latlng != null)
              Positioned.fill(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _latlng!,
                    initialZoom: _currentZoom,
                    onPositionChanged: (camera, _) {
                      _currentZoom = camera.zoom;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _tileUrl,
                      subdomains: _tileSubdomains,
                      userAgentPackageName: 'com.amayalert.app',
                      maxNativeZoom: 19,
                    ),
                    PolylineLayer(polylines: _polylines),
                    MarkerLayer(markers: _buildMarkers(evacuationCenters)),
                    const SimpleAttributionWidget(
                      source: Text(
                        '© CARTO  ©  OpenStreetMap',
                        style: TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildMapPlaceholder(),

            // ── Top bar: back + search ───────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _MapBtn(
                    icon: LucideIcons.arrowLeft,
                    onTap: () => context.router.maybePop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _searchCard()),
                ],
              ),
            ),

            // ── Right controls ───────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 68,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MapBtn(
                    icon: _isSatellite
                        ? LucideIcons.map
                        : LucideIcons.satellite,
                    onTap: _toggleMapType,
                  ),
                  const SizedBox(height: 6),
                  _MapBtn(icon: LucideIcons.plus, onTap: _zoomIn),
                  const SizedBox(height: 6),
                  _MapBtn(icon: LucideIcons.minus, onTap: _zoomOut),
                  const SizedBox(height: 6),
                  _MapBtn(
                    icon: LucideIcons.navigation,
                    onTap: _goToCurrentLocation,
                    iconColor: AppColors.primary,
                  ),
                  if (_polylines.isNotEmpty && !_isNavigating) ...[
                    const SizedBox(height: 6),
                    _MapBtn(
                      icon: LucideIcons.play,
                      onTap: _startNavigation,
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 6),
                    _MapBtn(
                      icon: LucideIcons.x,
                      onTap: _clearRoute,
                      iconColor: AppColors.danger,
                    ),
                  ],
                  if (_isNavigating) ...[
                    const SizedBox(height: 6),
                    _MapBtn(
                      icon: LucideIcons.x,
                      onTap: _stopNavigation,
                      iconColor: AppColors.danger,
                    ),
                  ],
                  // ── Always-on compass ──────────────────────
                  if (_heading != null) ...[
                    const SizedBox(height: 6),
                    _CompassBtn(heading: _heading!),
                  ],
                ],
              ),
            ),

            // ── Compass rose (navigation mode) / Route info ──────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 68,
              left: 12,
              child: _isNavigating
                  ? _buildCompassRose()
                  : (_routeInfo != null || _isLoadingRoute)
                      ? _buildRouteInfoCard()
                      : const SizedBox.shrink(),
            ),

            // ── Evacuation panel / Navigation bar ────────────────────────
            if (_isNavigating)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildNavigationBar(),
              )
            else ...[
              if (_isEvacuationListVisible)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildEvacuationCentersList(evacuationCenters),
                ),
              if (!_isEvacuationListVisible)
                Positioned(
                  bottom: 24,
                  right: 12,
                  child: _buildShowListButton(evacuationCenters),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    if (_isLoading) {
      return Container(
        color: AppColors.gray100,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator.adaptive(),
              SizedBox(height: 16),
              Text(
                'Getting your location…',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      color: AppColors.gray100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.mapPin, size: 40, color: AppColors.gray400),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Location unavailable',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: getCurrentLocation,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomGooglePlacesTextField(
        controller: _searchController,
        hintText: 'Search location…',
        onPlaceDetailsWithCoordinatesReceived: _navigateToPlace,
        onSuggestionClicked: (result) {
          _searchController.text = result.description;
          _navigateToPlace(result);
        },
      ),
    );
  }

  Widget _buildEvacuationCentersList(List<EvacuationCenter> evacuationCenters) {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _listSlideAnimation.value * 300),
        child: Opacity(
          opacity: 1.0 - _listAnimationController.value,
          child: child,
        ),
      ),
      child: _buildEvacuationCentersContent(evacuationCenters),
    );
  }

  Widget _buildEvacuationCentersContent(
    List<EvacuationCenter> evacuationCenters,
  ) {
    final isLoadingCenters = context.watch<EvacuationRepository>().isLoading;

    if (isLoadingCenters && evacuationCenters.isEmpty) {
      return _panelWrap(
        const Row(
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
      return _panelWrap(
        const Row(
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
          Padding(
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

          // Centers list with animation
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final itemsToShow = _isEvacuationListExpanded
                  ? evacuationCenters.length
                  : math.min(2, evacuationCenters.length);
              final visibleItems = (itemsToShow * _expandAnimation.value)
                  .ceil();
              final actualItems = _isEvacuationListExpanded
                  ? math.max(visibleItems, 2)
                  : math.min(visibleItems + 2, evacuationCenters.length);

              return Column(
                children: evacuationCenters
                    .take(actualItems)
                    .map(
                      (c) => AnimatedContainer(
                        duration: Duration(
                          milliseconds:
                              150 + (evacuationCenters.indexOf(c) * 50),
                        ),
                        curve: Curves.easeOutCubic,
                        child: _buildCenterTile(c),
                      ),
                    )
                    .toList(),
              );
            },
          ),

          // Expand / collapse
          if (evacuationCenters.length > 2)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleExpandList,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: Container(
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

  Widget _panelWrap(Widget child) {
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
      child: child,
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
    _hideEvacuationList();

    final destination = LatLng(center.latitude, center.longitude);

    setState(() {
      _polylines.clear();
      _showAllEvacMarkers = false;
      _focusedEvacId = center.id;
    });

    if (_latlng == null) {
      _mapController.move(destination, 16.0);
      setState(() => _currentZoom = 16.0);
      return;
    }

    setState(() {
      _isLoadingRoute = true;
      _routeInfo = null;
    });

    try {
      final results = await Future.wait([
        DirectionsService.getDirections(_latlng!, destination),
        DirectionsService.getRouteInfo(_latlng!, destination),
      ]);
      final routePoints = results[0] as List<LatLng>?;
      final routeInfo = results[1] as String?;

      setState(() {
        _isLoadingRoute = false;
        _routeInfo = routeInfo;
      });

      if (routePoints != null && routePoints.isNotEmpty) {
        setState(() {
          _polylines
            ..add(
              Polyline(
                points: routePoints,
                color: Colors.white,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            )
            ..add(
              Polyline(
                points: routePoints,
                color: const Color(0xFF1D6BF3),
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            );
        });
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(routePoints),
            padding: const EdgeInsets.all(100),
          ),
        );
      } else {
        // Straight-line fallback
        setState(() {
          _polylines
            ..add(
              Polyline(
                points: [_latlng!, destination],
                color: Colors.white,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
              ),
            )
            ..add(
              Polyline(
                points: [_latlng!, destination],
                color: const Color(0xFFF59E0B),
                strokeWidth: 5,
                pattern: StrokePattern.dashed(segments: [10, 8]),
                strokeCap: StrokeCap.round,
              ),
            );
        });
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints([_latlng!, destination]),
            padding: const EdgeInsets.all(100),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting directions: $e');
      setState(() {
        _isLoadingRoute = false;
        _routeInfo = null;
        _polylines.add(
          Polyline(
            points: [_latlng!, destination],
            color: Colors.red,
            strokeWidth: 4,
            pattern: StrokePattern.dashed(segments: [20, 10]),
          ),
        );
      });
    }
  }

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _routeInfo = null;
      _isLoadingRoute = false;
      _showAllEvacMarkers = false;
      _focusedEvacId = null;
    });
  }

  void _hideEvacuationList() {
    _listAnimationController.forward().then((_) {
      setState(() => _isEvacuationListVisible = false);
      _listAnimationController.reset();
    });
  }

  void _showEvacuationList() {
    setState(() => _isEvacuationListVisible = true);
    _listAnimationController.forward().then(
      (_) => _listAnimationController.reset(),
    );
  }

  void _toggleExpandList() {
    if (_isEvacuationListExpanded) {
      _expandAnimationController.reverse().then((_) {
        setState(() => _isEvacuationListExpanded = false);
      });
    } else {
      setState(() => _isEvacuationListExpanded = true);
      _expandAnimationController.forward();
    }
  }

  Widget _buildShowListButton(List<EvacuationCenter> evacuationCenters) {
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

  Widget _buildCompassRose() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Transform.rotate(
            // Counter-rotate so the needle always points to geographic north
            // even as the map rotates to heading-up.
            angle: (_heading ?? 0) * math.pi / 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 3,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                Container(
                  width: 3,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppColors.gray400,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.navigation,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: 'Navigation Mode',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  text: 'Map is following your location',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _stopNavigation,
            icon: const Icon(LucideIcons.x, size: 15),
            label: const Text(
              'Stop',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
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

// ── Styled map pin (circle + triangle tail) ───────────────────────────────────

class _MapPin extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _MapPin({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 17),
        ),
        CustomPaint(
          size: const Size(14, 9),
          painter: _PinTail(color),
        ),
      ],
    );
  }
}

class _PinTail extends CustomPainter {
  final Color color;
  const _PinTail(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      ui.Path()
        ..moveTo(size.width / 2, size.height)
        ..lineTo(0, 0)
        ..lineTo(size.width, 0)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

/// Paints a gradient cone pointing "up" (north). Rotate the widget to the
/// compass heading so the cone points in the direction the user is facing.
class _HeadingCone extends CustomPainter {
  const _HeadingCone();

  static const _blue = Color(0xFF1D6BF3);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(cx, cy),
        Offset(cx, 0),
        [
          _blue.withValues(alpha: 0.0),
          _blue.withValues(alpha: 0.55),
        ],
      );

    canvas.drawPath(
      ui.Path()
        ..moveTo(cx, cy)
        ..lineTo(cx - 15, 2)
        ..lineTo(cx + 15, 2)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Waze / Google Maps navigation arrow ───────────────────────────────────────
/// Paints a teardrop navigation arrow pointing "up" (north at 0°).
/// Wrap with Transform.rotate(angle: heading * pi / 180) to orient it.

class _NavArrow extends CustomPainter {
  const _NavArrow();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Arrow shape: pointed tip at top, curved/concave base at bottom
    final path = ui.Path()
      ..moveTo(cx, 4)
      ..lineTo(cx - 18, cy + 20)
      ..quadraticBezierTo(cx, cy + 6, cx + 18, cy + 20)
      ..close();

    // Drop shadow
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Body fill
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill,
    );

    // White outline
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Subtle highlight wedge at the leading tip
    canvas.drawPath(
      ui.Path()
        ..moveTo(cx, 7)
        ..lineTo(cx - 7, cy - 2)
        ..lineTo(cx, cy - 8)
        ..close(),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Always-on compass button ───────────────────────────────────────────────────

class _CompassBtn extends StatelessWidget {
  final double heading;
  const _CompassBtn({required this.heading});

  static String _cardinal(double h) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((h + 22.5) / 45).floor() % 8];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: SizedBox(
        width: 40,
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Needle — red end = direction you're facing, rotates with heading
            Transform.rotate(
              angle: heading * math.pi / 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 3,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                      ),
                    ),
                  ),
                  Container(
                    width: 3,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(2),
                        bottomRight: Radius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            // Cardinal direction label
            Text(
              _cardinal(heading),
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map control button ─────────────────────────────────────────────────────────

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _MapBtn({required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: iconColor ?? AppColors.gray700),
        ),
      ),
    );
  }
}
