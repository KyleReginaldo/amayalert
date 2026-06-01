import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String? userID = supabase.auth.currentUser?.id;

final supabase = Supabase.instance.client;

class Hotline {
  final String label;
  final List<String> phoneNumbers;
  final List<String> landlines;
  final IconData icon;
  final Color? color;
  final Gradient? gradient;
  final String category;

  Hotline(
    this.label,
    this.phoneNumbers,
    this.landlines,
    this.icon, {
    required this.category,
    this.color,
    this.gradient,
  });

  factory Hotline.fromDb(Map<String, dynamic> row) {
    final category = (row['category'] as String?) ?? '';
    return Hotline(
      (row['name'] as String?) ?? '',
      List<String>.from((row['phones'] as List?) ?? []),
      List<String>.from((row['landlines'] as List?) ?? []),
      _iconForCategory(category),
      category: category,
      color: _colorForCategory(category),
      gradient: _gradientForCategory(category),
    );
  }

  static IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'police':
        return LucideIcons.siren;
      case 'fire':
        return LucideIcons.flame;
      case 'ambulance':
        return LucideIcons.ambulance;
      default:
        return LucideIcons.hospital;
    }
  }

  static Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'police':
        return const Color(0xFF3B82F6);
      case 'fire':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF10B981);
    }
  }

  static Gradient _gradientForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'police':
        return const LinearGradient(
          colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'fire':
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF34D399), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}
