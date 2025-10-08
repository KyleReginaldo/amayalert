import 'dart:async';

import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _latlng;
  double _currentZoom = 17.0;
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;

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

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const CustomText(
          text: 'Amayalert Map',
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Colors.white,
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
            child: Container(
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
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search location...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(LucideIcons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
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
              ],
            ),
          ),

          // Zoom Controls

          // Current Location Button
        ],
      ),
    );
  }
}
