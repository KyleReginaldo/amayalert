import 'dart:async';
import 'dart:convert';

import 'package:amayalert/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LocationPrediction {
  final double lat;
  final double lng;
  final String description;
  final String? mainText;
  final String? secondaryText;

  const LocationPrediction({
    required this.lat,
    required this.lng,
    required this.description,
    this.mainText,
    this.secondaryText,
  });
}

/// Search field backed by Nominatim (OpenStreetMap) — completely free, no API key.
class CustomGooglePlacesTextField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(LocationPrediction)? onSuggestionClicked;
  final void Function(LocationPrediction)? onPlaceDetailsWithCoordinatesReceived;
  final String? hintText;
  final double? width;
  final double? radius;
  final Color? borderColor;
  final Color? fillColor;
  final bool lastTextField;
  final VoidCallback? onTap;
  final TextStyle? style;
  final FocusNode? focusNode;

  const CustomGooglePlacesTextField({
    super.key,
    required this.controller,
    this.onSuggestionClicked,
    this.onPlaceDetailsWithCoordinatesReceived,
    this.hintText,
    this.width,
    this.radius,
    this.borderColor,
    this.fillColor,
    this.lastTextField = false,
    this.onTap,
    this.style,
    this.focusNode,
  });

  @override
  State<CustomGooglePlacesTextField> createState() =>
      _CustomGooglePlacesTextFieldState();
}

class _CustomGooglePlacesTextFieldState
    extends State<CustomGooglePlacesTextField> {
  final _suggestions = <LocationPrediction>[];
  Timer? _debounce;
  bool _loading = false;
  late final FocusNode _focus;
  OverlayEntry? _overlay;
  final _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus) _hideOverlay();
    });
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hideOverlay();
    if (widget.focusNode == null) _focus.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final query = widget.controller.text.trim();
    if (query.length < 3) {
      _debounce?.cancel();
      _hideOverlay();
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final uri = Uri.parse('https://nominatim.openstreetmap.org/search').replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': '5',
          'addressdetails': '1',
        },
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'AmayAlert/1.0 (flutter)'})
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List;
        final results = list.map((item) {
          final displayName = item['display_name'] as String;
          final parts = displayName.split(', ');
          return LocationPrediction(
            lat: double.parse(item['lat'] as String),
            lng: double.parse(item['lon'] as String),
            description: displayName,
            mainText: parts.isNotEmpty ? parts.first : displayName,
            secondaryText: parts.length > 1 ? parts.skip(1).join(', ') : null,
          );
        }).toList();

        setState(() {
          _suggestions
            ..clear()
            ..addAll(results);
          _loading = false;
        });

        if (results.isNotEmpty) _showOverlay();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectResult(LocationPrediction result) {
    widget.controller.text = result.description;
    widget.onSuggestionClicked?.call(result);
    widget.onPlaceDetailsWithCoordinatesReceived?.call(result);
    _hideOverlay();
    _focus.unfocus();
  }

  void _showOverlay() {
    _hideOverlay();
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(widget.radius ?? 8),
            child: _SuggestionList(
              suggestions: List.from(_suggestions),
              loading: _loading,
              onSelect: _selectResult,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius ?? 8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focus,
          style: widget.style ?? const TextStyle(fontSize: 15, color: Colors.black87),
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Search location...',
            hintStyle: const TextStyle(
              fontSize: 15,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Icon(LucideIcons.search, size: 20, color: AppColors.gray800),
            filled: true,
            fillColor: widget.fillColor ?? Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius ?? 8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius ?? 8),
              borderSide: BorderSide(
                color: widget.borderColor ?? AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  final List<LocationPrediction> suggestions;
  final bool loading;
  final void Function(LocationPrediction) onSelect;

  const _SuggestionList({
    required this.suggestions,
    required this.loading,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('No results found', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: suggestions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final s = suggestions[i];
        return ListTile(
          dense: true,
          leading: const Icon(LucideIcons.mapPin, size: 16, color: AppColors.primary),
          title: Text(
            s.mainText ?? s.description,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: s.secondaryText != null
              ? Text(
                  s.secondaryText!,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          onTap: () => onSelect(s),
        );
      },
    );
  }
}
