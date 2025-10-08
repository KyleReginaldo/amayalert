import 'package:dart_mappable/dart_mappable.dart';

part 'alert_model.mapper.dart';

/// Alert model based on database schema
@MappableClass(caseStyle: CaseStyle.snakeCase)
class Alert with AlertMappable {
  final int id;
  final String user;
  final String title;
  final String description;
  final AlertLevel level;
  final AlertStatus status;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  const Alert({
    required this.id,
    required this.user,
    required this.title,
    required this.description,
    required this.level,
    required this.status,
    this.location,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  /// Check if alert is active
  bool get isActive {
    return status == AlertStatus.active;
  }

  /// Check if alert is resolved
  bool get isResolved {
    return status == AlertStatus.resolved;
  }

  /// Check if alert has location data
  bool get hasLocation {
    return latitude != null && longitude != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alert &&
        other.id == id &&
        other.user == user &&
        other.title == title &&
        other.description == description &&
        other.level == level &&
        other.status == status &&
        other.location == location &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.resolvedAt == resolvedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      user,
      title,
      description,
      level,
      status,
      location,
      latitude,
      longitude,
      createdAt,
      updatedAt,
      resolvedAt,
    );
  }

  @override
  String toString() {
    return 'Alert(id: $id, user: $user, title: $title, '
        'description: $description, level: $level, status: $status, '
        'location: $location, latitude: $latitude, longitude: $longitude, '
        'createdAt: $createdAt, updatedAt: $updatedAt, resolvedAt: $resolvedAt)';
  }
}

@MappableEnum()
/// Enum for alert severity levels
enum AlertLevel {
  low,
  medium,
  high,
  critical;

  /// Get the string value for database storage
  String get value {
    switch (this) {
      case AlertLevel.low:
        return 'low';
      case AlertLevel.medium:
        return 'medium';
      case AlertLevel.high:
        return 'high';
      case AlertLevel.critical:
        return 'critical';
    }
  }

  /// Create enum from string value
  static AlertLevel fromString(String? value) {
    if (value == null) return AlertLevel.low;

    switch (value.toLowerCase()) {
      case 'low':
        return AlertLevel.low;
      case 'medium':
        return AlertLevel.medium;
      case 'high':
        return AlertLevel.high;
      case 'critical':
        return AlertLevel.critical;
      default:
        return AlertLevel.low;
    }
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case AlertLevel.low:
        return 'Low';
      case AlertLevel.medium:
        return 'Medium';
      case AlertLevel.high:
        return 'High';
      case AlertLevel.critical:
        return 'Critical';
    }
  }

  /// Get color representation
  String get colorCode {
    switch (this) {
      case AlertLevel.low:
        return '#4CAF50'; // Green
      case AlertLevel.medium:
        return '#FF9800'; // Orange
      case AlertLevel.high:
        return '#F44336'; // Red
      case AlertLevel.critical:
        return '#9C27B0'; // Purple
    }
  }
}

/// Enum for alert status
enum AlertStatus {
  active,
  resolved,
  dismissed;

  /// Get the string value for database storage
  String get value {
    switch (this) {
      case AlertStatus.active:
        return 'active';
      case AlertStatus.resolved:
        return 'resolved';
      case AlertStatus.dismissed:
        return 'dismissed';
    }
  }

  /// Create enum from string value
  static AlertStatus fromString(String? value) {
    if (value == null) return AlertStatus.active;

    switch (value.toLowerCase()) {
      case 'active':
        return AlertStatus.active;
      case 'resolved':
        return AlertStatus.resolved;
      case 'dismissed':
        return AlertStatus.dismissed;
      default:
        return AlertStatus.active;
    }
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case AlertStatus.active:
        return 'Active';
      case AlertStatus.resolved:
        return 'Resolved';
      case AlertStatus.dismissed:
        return 'Dismissed';
    }
  }
}

/// Data class for creating new alerts
@MappableClass(caseStyle: CaseStyle.snakeCase)
class CreateAlertRequest with CreateAlertRequestMappable {
  final String user;
  final String title;
  final String description;
  final AlertLevel level;
  final String? location;
  final double? latitude;
  final double? longitude;

  const CreateAlertRequest({
    required this.user,
    required this.title,
    required this.description,
    required this.level,
    this.location,
    this.latitude,
    this.longitude,
  });
}

/// Data class for updating alerts
@MappableClass(caseStyle: CaseStyle.snakeCase)
class UpdateAlertRequest with UpdateAlertRequestMappable {
  final String? title;
  final String? description;
  final AlertLevel? level;
  final AlertStatus? status;
  final String? location;
  final double? latitude;
  final double? longitude;

  const UpdateAlertRequest({
    this.title,
    this.description,
    this.level,
    this.status,
    this.location,
    this.latitude,
    this.longitude,
  });

  bool get isEmpty =>
      title == null &&
      description == null &&
      level == null &&
      status == null &&
      location == null &&
      latitude == null &&
      longitude == null;
}
