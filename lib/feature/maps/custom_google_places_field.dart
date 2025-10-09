import 'package:amayalert/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomGooglePlacesTextField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(Prediction)? onSuggestionClicked;
  final void Function(Prediction)? onPlaceDetailsWithCoordinatesReceived;
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
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(radius ?? 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GooglePlacesAutoCompleteTextFormField(
        textEditingController: controller,
        googleAPIKey: "AIzaSyBNz2Rw-czYEUJmlTabDKfqRtM9jeXOPgY",
        focusNode: focusNode,
        style: style ?? const TextStyle(fontSize: 15, color: Colors.black87),
        inputDecoration: InputDecoration(
          // ✅ Use this instead
          hintText: hintText ?? 'Search location...',
          hintStyle: const TextStyle(
            fontSize: 15,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: Icon(
            LucideIcons.search,
            size: 20,
            color: AppColors.gray800,
          ),
          filled: true,
          fillColor: fillColor ?? Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius ?? 8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius ?? 8),
            borderSide: BorderSide(
              color: borderColor ?? AppColors.primary,
              width: 2,
            ),
          ),
        ),

        getPlaceDetailWithLatLng: (Prediction? prediction) {
          // Handle place selection with coordinates
          if (prediction != null &&
              onPlaceDetailsWithCoordinatesReceived != null) {
            onPlaceDetailsWithCoordinatesReceived!(prediction);
          }
        },
        itmClick: (Prediction? prediction) {
          // When user clicks on a suggestion item in the list
          if (prediction != null && onSuggestionClicked != null) {
            onSuggestionClicked!(prediction);
          }
        },
      ),
    );
  }
}
