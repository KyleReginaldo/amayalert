import 'package:amayalert/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Embedded non-interactive map showing a pinned location.
/// Tap opens Google Maps in the external app.
class MapPreview extends StatelessWidget {
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

  Future<void> _openMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(10);
    final point = LatLng(lat, lng);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            // ── Non-interactive map ──────────────────────────────────
            AbsorbPointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.amayalert.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 32,
                        height: 40,
                        alignment: Alignment.bottomCenter,
                        child: const Icon(
                          LucideIcons.mapPin,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Tap interceptor ──────────────────────────────────────
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _openMaps(context),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),

            // ── "Open Maps" badge ────────────────────────────────────
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _openMaps(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                      Icon(LucideIcons.map, size: 13, color: AppColors.primary),
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
