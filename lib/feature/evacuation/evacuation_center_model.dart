import 'package:dart_mappable/dart_mappable.dart';

part 'evacuation_center_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class EvacuationCenter {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int? capacity;
  final int? currentOccupancy;
  final EvacuationStatus? status;
  final String? contactName;
  final String? contactPhone;
  final List<String>? photos;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EvacuationCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.capacity,
    this.currentOccupancy,
    this.status,
    this.contactName,
    this.contactPhone,
    this.photos,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  EvacuationCenter copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? capacity,
    int? currentOccupancy,
    EvacuationStatus? status,
    String? contactName,
    String? contactPhone,
    List<String>? photos,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EvacuationCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      status: status ?? this.status,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      photos: photos ?? this.photos,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate occupancy percentage
  double get occupancyPercentage {
    if (capacity == null || capacity == 0 || currentOccupancy == null) {
      return 0.0;
    }
    return (currentOccupancy! / capacity!) * 100;
  }

  /// Check if evacuation center is full
  bool get isFull {
    if (capacity == null || currentOccupancy == null) return false;
    return currentOccupancy! >= capacity!;
  }

  /// Check if evacuation center is available
  bool get isAvailable {
    return status == EvacuationStatus.open && !isFull;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EvacuationCenter &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.capacity == capacity &&
        other.currentOccupancy == currentOccupancy &&
        other.status == status &&
        other.contactName == contactName &&
        other.contactPhone == contactPhone &&
        other.photos == photos &&
        other.createdBy == createdBy &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      address,
      latitude,
      longitude,
      capacity,
      currentOccupancy,
      status,
      contactName,
      contactPhone,
      photos,
      createdBy,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'EvacuationCenter(id: $id, name: $name, address: $address, '
        'latitude: $latitude, longitude: $longitude, capacity: $capacity, '
        'currentOccupancy: $currentOccupancy, status: $status)';
  }
}

@MappableEnum(caseStyle: CaseStyle.snakeCase)
enum EvacuationStatus {
  open,
  closed,
  full,
  maintenance;

  String get value {
    switch (this) {
      case EvacuationStatus.open:
        return 'open';
      case EvacuationStatus.closed:
        return 'closed';
      case EvacuationStatus.full:
        return 'full';
      case EvacuationStatus.maintenance:
        return 'maintenance';
    }
  }

  static EvacuationStatus fromString(String? value) {
    if (value == null) return EvacuationStatus.closed;

    switch (value.toLowerCase()) {
      case 'open':
        return EvacuationStatus.open;
      case 'closed':
        return EvacuationStatus.closed;
      case 'full':
        return EvacuationStatus.full;
      case 'maintenance':
        return EvacuationStatus.maintenance;
      default:
        return EvacuationStatus.closed;
    }
  }

  String get displayName {
    switch (this) {
      case EvacuationStatus.open:
        return 'Open';
      case EvacuationStatus.closed:
        return 'Closed';
      case EvacuationStatus.full:
        return 'Full';
      case EvacuationStatus.maintenance:
        return 'Under Maintenance';
    }
  }
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class CreateEvacuationCenterRequest {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int? capacity;
  final int? currentOccupancy;
  final EvacuationStatus? status;
  final String? contactName;
  final String? contactPhone;
  final List<String>? photos;
  final String? createdBy;

  const CreateEvacuationCenterRequest({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.capacity,
    this.currentOccupancy,
    this.status,
    this.contactName,
    this.contactPhone,
    this.photos,
    this.createdBy,
  });
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class UpdateEvacuationCenterRequest {
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? capacity;
  final int? currentOccupancy;
  final EvacuationStatus? status;
  final String? contactName;
  final String? contactPhone;
  final List<String>? photos;

  const UpdateEvacuationCenterRequest({
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.capacity,
    this.currentOccupancy,
    this.status,
    this.contactName,
    this.contactPhone,
    this.photos,
  });

  bool get isEmpty =>
      name == null &&
      address == null &&
      latitude == null &&
      longitude == null &&
      capacity == null &&
      currentOccupancy == null &&
      status == null &&
      contactName == null &&
      contactPhone == null &&
      photos == null;
}
