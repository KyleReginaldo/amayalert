import 'package:dart_mappable/dart_mappable.dart';

part 'evacuation_center_model.mapper.dart';

/// Evacuation Center model based on database schema
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

  factory EvacuationCenter.fromJson(Map<String, dynamic> json) {
    return EvacuationCenter(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      capacity: json['capacity'] as int?,
      currentOccupancy: json['current_occupancy'] as int?,
      status: json['status'] != null
          ? EvacuationStatus.fromString(json['status'] as String)
          : null,
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'] as List)
          : null,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'current_occupancy': currentOccupancy,
      'status': status?.value,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'photos': photos,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'current_occupancy': currentOccupancy,
      'status': status?.value,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'photos': photos,
      'created_by': createdBy,
    };
  }

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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'current_occupancy': currentOccupancy,
      'status': status?.value,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'photos': photos,
      'created_by': createdBy,
    };
  }
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (name != null) json['name'] = name;
    if (address != null) json['address'] = address;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (capacity != null) json['capacity'] = capacity;
    if (currentOccupancy != null) json['current_occupancy'] = currentOccupancy;
    if (status != null) json['status'] = status!.value;
    if (contactName != null) json['contact_name'] = contactName;
    if (contactPhone != null) json['contact_phone'] = contactPhone;
    if (photos != null) json['photos'] = photos;

    json['updated_at'] = DateTime.now().toIso8601String();

    return json;
  }

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
