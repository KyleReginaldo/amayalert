import 'package:amayalert/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Embedded non-interactive map showing a pinned location.
/// Tap opens Google Maps in the external app.
class MapPreview extends StatefulWidget {
  final double lat;
  final double lng;
  final double height;
  final BorderRadius? borderRadius;

  const MapPreview({
    super.key,
    required this.lat,
    required this.lng,
    this.height = 160,
    this.borderRadius,
  });

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  GoogleMapController? _controller;

  Future<void> _openMaps() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.lat},${widget.lng}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(10);
    final target = LatLng(widget.lat, widget.lng);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // ── Non-interactive map ──────────────────────────────────
            AbsorbPointer(
              child: GoogleMap(
                onMapCreated: (c) => _controller = c,
                initialCameraPosition: CameraPosition(
                  target: target,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('pin'),
                    position: target,
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                liteModeEnabled: true, // lightweight static-style render
              ),
            ),

            // ── Tap interceptor ──────────────────────────────────────
            Positioned.fill(
              child: GestureDetector(
                onTap: _openMaps,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),

            // ── "Open Maps" badge ────────────────────────────────────
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: _openMaps,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.map,
                          size: 13, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Open Maps',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin alias kept for backward compatibility.
class ViewMapButton extends StatelessWidget {
  final double lat;
  final double lng;
  final String? label;

  const ViewMapButton({
    super.key,
    required this.lat,
    required this.lng,
    this.label,
  });

  @override
  Widget build(BuildContext context) =>
      MapPreview(lat: lat, lng: lng, height: 140);
}
