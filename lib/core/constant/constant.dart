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
  final String category; // e.g. Hospital, Police, Fire, Ambulance

  Hotline(
    this.label,
    this.phoneNumbers,
    this.landlines,
    this.icon, {
    required this.category,
    this.color,
    this.gradient,
  });
}

List<Hotline> hotlines = [
  // Cavite - Tanza local contacts
  Hotline(
    'Tanza Specialist Medical Center',
    [
      '139', // Local emergency
      '0917 153 9400',
    ],
    ['+63 46 484 7777'],
    LucideIcons.hospital,
    category: 'Hospital',
    color: Color(0xFF10B981),
    gradient: LinearGradient(
      colors: [Color(0xFF34D399), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  Hotline(
    'Tanza Family General Hospital & Pharmacy',
    [],
    ['(046) 505-1285'],
    LucideIcons.hospital,
    category: 'Hospital',
    color: Color(0xFF10B981),
    gradient: LinearGradient(
      colors: [Color(0xFF6EE7B7), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  // Newly added hospitals / medical services
  Hotline(
    'Tanza Doctors Hospital',
    ['0917 636 6046'],
    [],
    LucideIcons.hospital,
    category: 'Hospital',
    color: Color(0xFF10B981),
    gradient: LinearGradient(
      colors: [Color(0xFF34D399), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  Hotline(
    'City of General Trias Doctors Medical Center, Inc',
    [],
    ['(046) 416-2222'],
    LucideIcons.hospital,
    category: 'Hospital',
    color: Color(0xFF10B981),
    gradient: LinearGradient(
      colors: [Color(0xFF6EE7B7), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  Hotline(
    'General Trias Maternity Hospital',
    [],
    ['(046) 437-0133'],
    LucideIcons.hospital,
    category: 'Hospital',
    color: Color(0xFF10B981),
    gradient: LinearGradient(
      colors: [Color(0xFF34D399), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  Hotline(
    'DATASTAT AMBULANCE SERVICES',
    ['0998 991 9950'],
    [],
    LucideIcons.ambulance,
    category: 'Ambulance',
    color: Color(0xFF10B981),
    gradient: LinearGradient(
      colors: [Color(0xFF6EE7B7), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  Hotline(
    'M. V. Santiago Medical Center',
    [],
    ['(046) 888-9570'],
    LucideIcons.hospital,
    category: 'Hospital',
    color: Color(0xFF10B981),
    gradient: LinearGradient(
      colors: [Color(0xFF34D399), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  Hotline(
    'Tanza Municipal Police Station',
    [
      '+63 905 330 0656', // Globe
      '+63 998 598 5614', // Smart (updated)
    ],
    ['437 6558'],
    LucideIcons.siren,
    category: 'Police',
    color: Color(0xFF3B82F6),
    gradient: LinearGradient(
      colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  Hotline(
    'BFP Tanza Fire Station Cavite',
    ['+63 908 336 5886'], // Smart (updated)
    ['505 6084'],
    LucideIcons.flame,
    category: 'Fire',
    color: Color(0xFFEF4444),
    gradient: LinearGradient(
      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
];
