// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';

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
  final String? user;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.user,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
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

  String? get emergencyType {
    return metadata?['emergency_type'] as String?;
  }

  int? get victimCount {
    return metadata?['victim_count'] as int?;
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
  final int? numberOfPeople;
  final String? contactPhone;
  final String? importantInformation;
  final DateTime? scheduledFor;
  final String? user;
  final String email;
  // Optional additional metadata provided by caller; merged with computed
  final Map<String, dynamic>? metadata;

  const CreateRescueRequest({
    required this.title,
    this.description,
    this.lat,
    this.lng,
    required this.priority,
    required this.emergencyType,
    this.numberOfPeople,
    this.contactPhone,
    this.importantInformation,
    this.scheduledFor,
    this.user,
    required this.email,
    this.metadata,
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
    'number_of_people': numberOfPeople,
    'contact_phone': contactPhone,
    'important_information': importantInformation,
    'email': email,
  };
}
