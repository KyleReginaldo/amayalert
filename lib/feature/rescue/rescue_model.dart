import 'package:dart_mappable/dart_mappable.dart';
import 'package:image_picker/image_picker.dart';

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

  List<String> get imageUrls {
    if (metadata == null) return [];
    final images = metadata!['images'] as List<dynamic>?;
    return images?.cast<String>() ?? [];
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
  final int priority;
  final DateTime? scheduledFor;
  final String? user;
  final Map<String, dynamic>? metadata;

  const CreateRescueRequest({
    required this.title,
    this.description,
    this.lat,
    this.lng,
    required this.priority,
    this.scheduledFor,
    this.user,
    this.metadata,
  });
}

class CreateRescueDTO {
  final String title;
  final String? description;
  final double? lat;
  final double? lng;
  final RescuePriority priority;
  final EmergencyType emergencyType;
  final int? victimCount;
  final String? contactPhone;
  final String? additionalInfo;
  final List<XFile> images;
  final DateTime? scheduledFor;

  CreateRescueDTO({
    required this.title,
    this.description,
    this.lat,
    this.lng,
    required this.priority,
    required this.emergencyType,
    this.victimCount,
    this.contactPhone,
    this.additionalInfo,
    this.images = const [],
    this.scheduledFor,
  });

  Map<String, dynamic> get metadata => {
    'emergency_type': emergencyType.name,
    if (victimCount != null) 'victim_count': victimCount,
    if (contactPhone != null) 'contact_phone': contactPhone,
    if (additionalInfo != null) 'additional_info': additionalInfo,
    // Images will be added after upload in the provider
  };
}
