// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:amayalert/feature/profile/profile_model.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

part 'rescue_model.mapper.dart';

@MappableEnum(caseStyle: CaseStyle.snakeCase)
enum RescueStatus { pending, inProgress, completed, cancelled }

@MappableEnum(caseStyle: CaseStyle.snakeCase)
enum EmergencyType {
  medical,
  fire,
  flood,
  accident,
  violence,
  naturalDisaster,
  other,
}

extension EmergencyTypeExtension on EmergencyType {
  String get name {
    switch (this) {
      case EmergencyType.medical:
        return 'medical';
      case EmergencyType.fire:
        return 'fire';
      case EmergencyType.flood:
        return 'flood';
      case EmergencyType.accident:
        return 'accident';
      case EmergencyType.violence:
        return 'violence';
      case EmergencyType.naturalDisaster:
        return 'natural_disaster';
      case EmergencyType.other:
        return 'other';
    }
  }

  IconData get icon {
    switch (this) {
      case EmergencyType.medical:
        return LucideIcons.heartPulse;
      case EmergencyType.fire:
        return LucideIcons.flame;
      case EmergencyType.flood:
        return LucideIcons.waves;
      case EmergencyType.accident:
        return LucideIcons.car;
      case EmergencyType.violence:
        return LucideIcons.handFist;
      case EmergencyType.naturalDisaster:
        return LucideIcons.shrub;
      case EmergencyType.other:
        return LucideIcons.lifeBuoy;
    }
  }
}

@MappableEnum(caseStyle: CaseStyle.snakeCase)
enum RescuePriority {
  low(1, 'Low', 'Non-urgent situation'),
  medium(2, 'Medium', 'Moderate urgency'),
  high(3, 'High', 'Urgent situation'),
  critical(4, 'Critical', 'Life-threatening emergency');

  const RescuePriority(this.value, this.label, this.description);
  final int value;
  final String label;
  final String description;
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Rescue with RescueMappable {
  final String id;
  final String title;
  final String? description;
  final double? lat;
  final double? lng;
  final RescueStatus status;
  final int priority;
  final DateTime reportedAt;
  final DateTime? scheduledFor;
  final DateTime? completedAt;
  final String? emergencyType;
  final int? femaleCount;
  final int? maleCount;
  final String? contactPhone;
  final String? email;
  final String? importantInformation;
  final Profile? user;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? address;

  const Rescue({
    required this.id,
    required this.title,
    this.description,
    this.lat,
    this.lng,
    required this.status,
    required this.priority,
    required this.reportedAt,
    this.scheduledFor,
    this.completedAt,
    this.emergencyType,
    this.femaleCount,
    this.maleCount,
    this.contactPhone,
    this.email,
    this.importantInformation,
    this.user,
    this.attachments,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.address,
  });

  String get priorityLabel {
    return RescuePriority.values
        .firstWhere(
          (p) => p.value == priority,
          orElse: () => RescuePriority.low,
        )
        .label;
  }

  String get statusLabel {
    switch (status) {
      case RescueStatus.pending:
        return 'Pending';
      case RescueStatus.inProgress:
        return 'In Progress';
      case RescueStatus.completed:
        return 'Completed';
      case RescueStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Total victim count from male and female counts
  int? get victimCount {
    if (femaleCount == null && maleCount == null) return null;
    return (femaleCount ?? 0) + (maleCount ?? 0);
  }

  // Get emergency type label for display
  String get emergencyTypeLabel {
    if (emergencyType == null) return 'Other Emergency';
    return _getEmergencyTypeLabel(emergencyType!);
  }

  static String _getEmergencyTypeLabel(String type) {
    switch (type) {
      case 'medical':
        return 'Medical Emergency';
      case 'fire':
        return 'Fire';
      case 'flood':
        return 'Flood';
      case 'accident':
        return 'Accident';
      case 'violence':
        return 'Violence/Crime';
      case 'naturalDisaster':
        return 'Natural Disaster';
      case 'other':
      default:
        return 'Other Emergency';
    }
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class CreateRescueRequest with CreateRescueRequestMappable {
  final String title;
  final String? description;
  final double? lat;
  final double? lng;
  // Use enum for input; map to int (value) when sending to DB
  final RescuePriority priority;
  final EmergencyType emergencyType;
  final int? femaleCount;
  final int? maleCount;
  final String? contactPhone;
  final String? importantInformation;
  final DateTime? scheduledFor;
  final String? user;
  final String email;
  // Image files to upload as attachments
  final List<XFile>? attachmentFiles;
  // Optional additional metadata provided by caller; merged with computed
  final Map<String, dynamic>? metadata;
  final String? address;

  const CreateRescueRequest({
    required this.title,
    this.description,
    this.lat,
    this.lng,
    required this.priority,
    required this.emergencyType,
    this.femaleCount,
    this.maleCount,
    this.contactPhone,
    this.importantInformation,
    this.scheduledFor,
    this.user,
    required this.email,
    this.attachmentFiles,
    this.metadata,
    this.address,
  });

  // Computed metadata based on fields, merged with any provided metadata
  Map<String, dynamic>? buildMetadata() =>
      metadata == null ? null : {...metadata!};

  // Override toMap to ensure DB-compatible payload
  @override
  Map<String, dynamic> toMap() => {
    'title': title.trim(),
    'description': description,
    'priority': priority.value,
    // status, reported_at, created_at, updated_at handled by provider
    'lat': lat,
    'lng': lng,
    'metadata': buildMetadata(),
    'reported_at': null, // will be filled by provider if needed
    'scheduled_for': scheduledFor?.toIso8601String(),
    'user': user,
    // New top-level fields per schema
    'emergency_type': emergencyType.name,
    'female_count': femaleCount,
    'male_count': maleCount,
    'contact_phone': contactPhone,
    'important_information': importantInformation,
    'email': email,
    'address': address,
    // attachments will be handled separately in the provider
  };
}
