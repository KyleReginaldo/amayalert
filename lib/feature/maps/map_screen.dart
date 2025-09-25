import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@RoutePage()
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _latlng;
  GoogleMapController? _mapController;
  double _currentZoom = 17.0;

  final Completer<GoogleMapController> _controllerCompleter = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _controllerCompleter.complete(controller);
    _setMapStyle();
  }

  Future<void> _setMapStyle() async {
    try {
      final String style = await rootBundle.loadString(
        'assets/json/map_style.json',
      );
      _mapController?.setMapStyle(style);
    } catch (e) {
      debugPrint('Map style not found: $e');
    }
  }

  void getCurrentLocation() async {
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
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _latlng != null
          ? GoogleMap(
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              initialCameraPosition: CameraPosition(
                target: _latlng!,
                zoom: _currentZoom,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            )
          : LinearProgressIndicator(),
    );
  }
}
