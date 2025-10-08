// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'evacuation_center_model.dart';

class EvacuationStatusMapper extends EnumMapper<EvacuationStatus> {
  EvacuationStatusMapper._();

  static EvacuationStatusMapper? _instance;
  static EvacuationStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EvacuationStatusMapper._());
    }
    return _instance!;
  }

  static EvacuationStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  EvacuationStatus decode(dynamic value) {
    switch (value) {
      case r'open':
        return EvacuationStatus.open;
      case r'closed':
        return EvacuationStatus.closed;
      case r'full':
        return EvacuationStatus.full;
      case r'maintenance':
        return EvacuationStatus.maintenance;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(EvacuationStatus self) {
    switch (self) {
      case EvacuationStatus.open:
        return r'open';
      case EvacuationStatus.closed:
        return r'closed';
      case EvacuationStatus.full:
        return r'full';
      case EvacuationStatus.maintenance:
        return r'maintenance';
    }
  }
}

extension EvacuationStatusMapperExtension on EvacuationStatus {
  String toValue() {
    EvacuationStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<EvacuationStatus>(this) as String;
  }
}

class EvacuationCenterMapper extends ClassMapperBase<EvacuationCenter> {
  EvacuationCenterMapper._();

  static EvacuationCenterMapper? _instance;
  static EvacuationCenterMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EvacuationCenterMapper._());
      EvacuationStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EvacuationCenter';

  static int _$id(EvacuationCenter v) => v.id;
  static const Field<EvacuationCenter, int> _f$id = Field('id', _$id);
  static String _$name(EvacuationCenter v) => v.name;
  static const Field<EvacuationCenter, String> _f$name = Field('name', _$name);
  static String _$address(EvacuationCenter v) => v.address;
  static const Field<EvacuationCenter, String> _f$address = Field(
    'address',
    _$address,
  );
  static double _$latitude(EvacuationCenter v) => v.latitude;
  static const Field<EvacuationCenter, double> _f$latitude = Field(
    'latitude',
    _$latitude,
  );
  static double _$longitude(EvacuationCenter v) => v.longitude;
  static const Field<EvacuationCenter, double> _f$longitude = Field(
    'longitude',
    _$longitude,
  );
  static int? _$capacity(EvacuationCenter v) => v.capacity;
  static const Field<EvacuationCenter, int> _f$capacity = Field(
    'capacity',
    _$capacity,
    opt: true,
  );
  static int? _$currentOccupancy(EvacuationCenter v) => v.currentOccupancy;
  static const Field<EvacuationCenter, int> _f$currentOccupancy = Field(
    'currentOccupancy',
    _$currentOccupancy,
    key: r'current_occupancy',
    opt: true,
  );
  static EvacuationStatus? _$status(EvacuationCenter v) => v.status;
  static const Field<EvacuationCenter, EvacuationStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
  );
  static String? _$contactName(EvacuationCenter v) => v.contactName;
  static const Field<EvacuationCenter, String> _f$contactName = Field(
    'contactName',
    _$contactName,
    key: r'contact_name',
    opt: true,
  );
  static String? _$contactPhone(EvacuationCenter v) => v.contactPhone;
  static const Field<EvacuationCenter, String> _f$contactPhone = Field(
    'contactPhone',
    _$contactPhone,
    key: r'contact_phone',
    opt: true,
  );
  static List<String>? _$photos(EvacuationCenter v) => v.photos;
  static const Field<EvacuationCenter, List<String>> _f$photos = Field(
    'photos',
    _$photos,
    opt: true,
  );
  static String? _$createdBy(EvacuationCenter v) => v.createdBy;
  static const Field<EvacuationCenter, String> _f$createdBy = Field(
    'createdBy',
    _$createdBy,
    key: r'created_by',
    opt: true,
  );
  static DateTime _$createdAt(EvacuationCenter v) => v.createdAt;
  static const Field<EvacuationCenter, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime? _$updatedAt(EvacuationCenter v) => v.updatedAt;
  static const Field<EvacuationCenter, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
    opt: true,
  );
  static double _$occupancyPercentage(EvacuationCenter v) =>
      v.occupancyPercentage;
  static const Field<EvacuationCenter, double> _f$occupancyPercentage = Field(
    'occupancyPercentage',
    _$occupancyPercentage,
    key: r'occupancy_percentage',
    mode: FieldMode.member,
  );
  static bool _$isFull(EvacuationCenter v) => v.isFull;
  static const Field<EvacuationCenter, bool> _f$isFull = Field(
    'isFull',
    _$isFull,
    key: r'is_full',
    mode: FieldMode.member,
  );
  static bool _$isAvailable(EvacuationCenter v) => v.isAvailable;
  static const Field<EvacuationCenter, bool> _f$isAvailable = Field(
    'isAvailable',
    _$isAvailable,
    key: r'is_available',
    mode: FieldMode.member,
  );
  static int _$hashCode(EvacuationCenter v) => v.hashCode;
  static const Field<EvacuationCenter, int> _f$hashCode = Field(
    'hashCode',
    _$hashCode,
    key: r'hash_code',
    mode: FieldMode.member,
  );

  @override
  final MappableFields<EvacuationCenter> fields = const {
    #id: _f$id,
    #name: _f$name,
    #address: _f$address,
    #latitude: _f$latitude,
    #longitude: _f$longitude,
    #capacity: _f$capacity,
    #currentOccupancy: _f$currentOccupancy,
    #status: _f$status,
    #contactName: _f$contactName,
    #contactPhone: _f$contactPhone,
    #photos: _f$photos,
    #createdBy: _f$createdBy,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #occupancyPercentage: _f$occupancyPercentage,
    #isFull: _f$isFull,
    #isAvailable: _f$isAvailable,
    #hashCode: _f$hashCode,
  };

  static EvacuationCenter _instantiate(DecodingData data) {
    return EvacuationCenter(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      address: data.dec(_f$address),
      latitude: data.dec(_f$latitude),
      longitude: data.dec(_f$longitude),
      capacity: data.dec(_f$capacity),
      currentOccupancy: data.dec(_f$currentOccupancy),
      status: data.dec(_f$status),
      contactName: data.dec(_f$contactName),
      contactPhone: data.dec(_f$contactPhone),
      photos: data.dec(_f$photos),
      createdBy: data.dec(_f$createdBy),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EvacuationCenter fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EvacuationCenter>(map);
  }

  static EvacuationCenter fromJson(String json) {
    return ensureInitialized().decodeJson<EvacuationCenter>(json);
  }
}

mixin EvacuationCenterMappable {
  String toJson() {
    return EvacuationCenterMapper.ensureInitialized()
        .encodeJson<EvacuationCenter>(this as EvacuationCenter);
  }

  Map<String, dynamic> toMap() {
    return EvacuationCenterMapper.ensureInitialized()
        .encodeMap<EvacuationCenter>(this as EvacuationCenter);
  }

  EvacuationCenterCopyWith<EvacuationCenter, EvacuationCenter, EvacuationCenter>
  get copyWith =>
      _EvacuationCenterCopyWithImpl<EvacuationCenter, EvacuationCenter>(
        this as EvacuationCenter,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EvacuationCenterMapper.ensureInitialized().stringifyValue(
      this as EvacuationCenter,
    );
  }

  @override
  bool operator ==(Object other) {
    return EvacuationCenterMapper.ensureInitialized().equalsValue(
      this as EvacuationCenter,
      other,
    );
  }

  @override
  int get hashCode {
    return EvacuationCenterMapper.ensureInitialized().hashValue(
      this as EvacuationCenter,
    );
  }
}

extension EvacuationCenterValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EvacuationCenter, $Out> {
  EvacuationCenterCopyWith<$R, EvacuationCenter, $Out>
  get $asEvacuationCenter =>
      $base.as((v, t, t2) => _EvacuationCenterCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EvacuationCenterCopyWith<$R, $In extends EvacuationCenter, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get photos;
  $R call({
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
  });
  EvacuationCenterCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _EvacuationCenterCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EvacuationCenter, $Out>
    implements EvacuationCenterCopyWith<$R, EvacuationCenter, $Out> {
  _EvacuationCenterCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EvacuationCenter> $mapper =
      EvacuationCenterMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get photos =>
      $value.photos != null
      ? ListCopyWith(
          $value.photos!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(photos: v),
        )
      : null;
  @override
  $R call({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    Object? capacity = $none,
    Object? currentOccupancy = $none,
    Object? status = $none,
    Object? contactName = $none,
    Object? contactPhone = $none,
    Object? photos = $none,
    Object? createdBy = $none,
    DateTime? createdAt,
    Object? updatedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (address != null) #address: address,
      if (latitude != null) #latitude: latitude,
      if (longitude != null) #longitude: longitude,
      if (capacity != $none) #capacity: capacity,
      if (currentOccupancy != $none) #currentOccupancy: currentOccupancy,
      if (status != $none) #status: status,
      if (contactName != $none) #contactName: contactName,
      if (contactPhone != $none) #contactPhone: contactPhone,
      if (photos != $none) #photos: photos,
      if (createdBy != $none) #createdBy: createdBy,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
    }),
  );
  @override
  EvacuationCenter $make(CopyWithData data) => EvacuationCenter(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    address: data.get(#address, or: $value.address),
    latitude: data.get(#latitude, or: $value.latitude),
    longitude: data.get(#longitude, or: $value.longitude),
    capacity: data.get(#capacity, or: $value.capacity),
    currentOccupancy: data.get(#currentOccupancy, or: $value.currentOccupancy),
    status: data.get(#status, or: $value.status),
    contactName: data.get(#contactName, or: $value.contactName),
    contactPhone: data.get(#contactPhone, or: $value.contactPhone),
    photos: data.get(#photos, or: $value.photos),
    createdBy: data.get(#createdBy, or: $value.createdBy),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  EvacuationCenterCopyWith<$R2, EvacuationCenter, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EvacuationCenterCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CreateEvacuationCenterRequestMapper
    extends ClassMapperBase<CreateEvacuationCenterRequest> {
  CreateEvacuationCenterRequestMapper._();

  static CreateEvacuationCenterRequestMapper? _instance;
  static CreateEvacuationCenterRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = CreateEvacuationCenterRequestMapper._(),
      );
      EvacuationStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CreateEvacuationCenterRequest';

  static String _$name(CreateEvacuationCenterRequest v) => v.name;
  static const Field<CreateEvacuationCenterRequest, String> _f$name = Field(
    'name',
    _$name,
  );
  static String _$address(CreateEvacuationCenterRequest v) => v.address;
  static const Field<CreateEvacuationCenterRequest, String> _f$address = Field(
    'address',
    _$address,
  );
  static double _$latitude(CreateEvacuationCenterRequest v) => v.latitude;
  static const Field<CreateEvacuationCenterRequest, double> _f$latitude = Field(
    'latitude',
    _$latitude,
  );
  static double _$longitude(CreateEvacuationCenterRequest v) => v.longitude;
  static const Field<CreateEvacuationCenterRequest, double> _f$longitude =
      Field('longitude', _$longitude);
  static int? _$capacity(CreateEvacuationCenterRequest v) => v.capacity;
  static const Field<CreateEvacuationCenterRequest, int> _f$capacity = Field(
    'capacity',
    _$capacity,
    opt: true,
  );
  static int? _$currentOccupancy(CreateEvacuationCenterRequest v) =>
      v.currentOccupancy;
  static const Field<CreateEvacuationCenterRequest, int> _f$currentOccupancy =
      Field(
        'currentOccupancy',
        _$currentOccupancy,
        key: r'current_occupancy',
        opt: true,
      );
  static EvacuationStatus? _$status(CreateEvacuationCenterRequest v) =>
      v.status;
  static const Field<CreateEvacuationCenterRequest, EvacuationStatus>
  _f$status = Field('status', _$status, opt: true);
  static String? _$contactName(CreateEvacuationCenterRequest v) =>
      v.contactName;
  static const Field<CreateEvacuationCenterRequest, String> _f$contactName =
      Field('contactName', _$contactName, key: r'contact_name', opt: true);
  static String? _$contactPhone(CreateEvacuationCenterRequest v) =>
      v.contactPhone;
  static const Field<CreateEvacuationCenterRequest, String> _f$contactPhone =
      Field('contactPhone', _$contactPhone, key: r'contact_phone', opt: true);
  static List<String>? _$photos(CreateEvacuationCenterRequest v) => v.photos;
  static const Field<CreateEvacuationCenterRequest, List<String>> _f$photos =
      Field('photos', _$photos, opt: true);
  static String? _$createdBy(CreateEvacuationCenterRequest v) => v.createdBy;
  static const Field<CreateEvacuationCenterRequest, String> _f$createdBy =
      Field('createdBy', _$createdBy, key: r'created_by', opt: true);

  @override
  final MappableFields<CreateEvacuationCenterRequest> fields = const {
    #name: _f$name,
    #address: _f$address,
    #latitude: _f$latitude,
    #longitude: _f$longitude,
    #capacity: _f$capacity,
    #currentOccupancy: _f$currentOccupancy,
    #status: _f$status,
    #contactName: _f$contactName,
    #contactPhone: _f$contactPhone,
    #photos: _f$photos,
    #createdBy: _f$createdBy,
  };

  static CreateEvacuationCenterRequest _instantiate(DecodingData data) {
    return CreateEvacuationCenterRequest(
      name: data.dec(_f$name),
      address: data.dec(_f$address),
      latitude: data.dec(_f$latitude),
      longitude: data.dec(_f$longitude),
      capacity: data.dec(_f$capacity),
      currentOccupancy: data.dec(_f$currentOccupancy),
      status: data.dec(_f$status),
      contactName: data.dec(_f$contactName),
      contactPhone: data.dec(_f$contactPhone),
      photos: data.dec(_f$photos),
      createdBy: data.dec(_f$createdBy),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CreateEvacuationCenterRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CreateEvacuationCenterRequest>(map);
  }

  static CreateEvacuationCenterRequest fromJson(String json) {
    return ensureInitialized().decodeJson<CreateEvacuationCenterRequest>(json);
  }
}

mixin CreateEvacuationCenterRequestMappable {
  String toJson() {
    return CreateEvacuationCenterRequestMapper.ensureInitialized()
        .encodeJson<CreateEvacuationCenterRequest>(
          this as CreateEvacuationCenterRequest,
        );
  }

  Map<String, dynamic> toMap() {
    return CreateEvacuationCenterRequestMapper.ensureInitialized()
        .encodeMap<CreateEvacuationCenterRequest>(
          this as CreateEvacuationCenterRequest,
        );
  }

  CreateEvacuationCenterRequestCopyWith<
    CreateEvacuationCenterRequest,
    CreateEvacuationCenterRequest,
    CreateEvacuationCenterRequest
  >
  get copyWith =>
      _CreateEvacuationCenterRequestCopyWithImpl<
        CreateEvacuationCenterRequest,
        CreateEvacuationCenterRequest
      >(this as CreateEvacuationCenterRequest, $identity, $identity);
  @override
  String toString() {
    return CreateEvacuationCenterRequestMapper.ensureInitialized()
        .stringifyValue(this as CreateEvacuationCenterRequest);
  }

  @override
  bool operator ==(Object other) {
    return CreateEvacuationCenterRequestMapper.ensureInitialized().equalsValue(
      this as CreateEvacuationCenterRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return CreateEvacuationCenterRequestMapper.ensureInitialized().hashValue(
      this as CreateEvacuationCenterRequest,
    );
  }
}

extension CreateEvacuationCenterRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CreateEvacuationCenterRequest, $Out> {
  CreateEvacuationCenterRequestCopyWith<$R, CreateEvacuationCenterRequest, $Out>
  get $asCreateEvacuationCenterRequest => $base.as(
    (v, t, t2) =>
        _CreateEvacuationCenterRequestCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CreateEvacuationCenterRequestCopyWith<
  $R,
  $In extends CreateEvacuationCenterRequest,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get photos;
  $R call({
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
  });
  CreateEvacuationCenterRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CreateEvacuationCenterRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CreateEvacuationCenterRequest, $Out>
    implements
        CreateEvacuationCenterRequestCopyWith<
          $R,
          CreateEvacuationCenterRequest,
          $Out
        > {
  _CreateEvacuationCenterRequestCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<CreateEvacuationCenterRequest> $mapper =
      CreateEvacuationCenterRequestMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get photos =>
      $value.photos != null
      ? ListCopyWith(
          $value.photos!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(photos: v),
        )
      : null;
  @override
  $R call({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    Object? capacity = $none,
    Object? currentOccupancy = $none,
    Object? status = $none,
    Object? contactName = $none,
    Object? contactPhone = $none,
    Object? photos = $none,
    Object? createdBy = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (address != null) #address: address,
      if (latitude != null) #latitude: latitude,
      if (longitude != null) #longitude: longitude,
      if (capacity != $none) #capacity: capacity,
      if (currentOccupancy != $none) #currentOccupancy: currentOccupancy,
      if (status != $none) #status: status,
      if (contactName != $none) #contactName: contactName,
      if (contactPhone != $none) #contactPhone: contactPhone,
      if (photos != $none) #photos: photos,
      if (createdBy != $none) #createdBy: createdBy,
    }),
  );
  @override
  CreateEvacuationCenterRequest $make(CopyWithData data) =>
      CreateEvacuationCenterRequest(
        name: data.get(#name, or: $value.name),
        address: data.get(#address, or: $value.address),
        latitude: data.get(#latitude, or: $value.latitude),
        longitude: data.get(#longitude, or: $value.longitude),
        capacity: data.get(#capacity, or: $value.capacity),
        currentOccupancy: data.get(
          #currentOccupancy,
          or: $value.currentOccupancy,
        ),
        status: data.get(#status, or: $value.status),
        contactName: data.get(#contactName, or: $value.contactName),
        contactPhone: data.get(#contactPhone, or: $value.contactPhone),
        photos: data.get(#photos, or: $value.photos),
        createdBy: data.get(#createdBy, or: $value.createdBy),
      );

  @override
  CreateEvacuationCenterRequestCopyWith<
    $R2,
    CreateEvacuationCenterRequest,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CreateEvacuationCenterRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class UpdateEvacuationCenterRequestMapper
    extends ClassMapperBase<UpdateEvacuationCenterRequest> {
  UpdateEvacuationCenterRequestMapper._();

  static UpdateEvacuationCenterRequestMapper? _instance;
  static UpdateEvacuationCenterRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = UpdateEvacuationCenterRequestMapper._(),
      );
      EvacuationStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'UpdateEvacuationCenterRequest';

  static String? _$name(UpdateEvacuationCenterRequest v) => v.name;
  static const Field<UpdateEvacuationCenterRequest, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static String? _$address(UpdateEvacuationCenterRequest v) => v.address;
  static const Field<UpdateEvacuationCenterRequest, String> _f$address = Field(
    'address',
    _$address,
    opt: true,
  );
  static double? _$latitude(UpdateEvacuationCenterRequest v) => v.latitude;
  static const Field<UpdateEvacuationCenterRequest, double> _f$latitude = Field(
    'latitude',
    _$latitude,
    opt: true,
  );
  static double? _$longitude(UpdateEvacuationCenterRequest v) => v.longitude;
  static const Field<UpdateEvacuationCenterRequest, double> _f$longitude =
      Field('longitude', _$longitude, opt: true);
  static int? _$capacity(UpdateEvacuationCenterRequest v) => v.capacity;
  static const Field<UpdateEvacuationCenterRequest, int> _f$capacity = Field(
    'capacity',
    _$capacity,
    opt: true,
  );
  static int? _$currentOccupancy(UpdateEvacuationCenterRequest v) =>
      v.currentOccupancy;
  static const Field<UpdateEvacuationCenterRequest, int> _f$currentOccupancy =
      Field(
        'currentOccupancy',
        _$currentOccupancy,
        key: r'current_occupancy',
        opt: true,
      );
  static EvacuationStatus? _$status(UpdateEvacuationCenterRequest v) =>
      v.status;
  static const Field<UpdateEvacuationCenterRequest, EvacuationStatus>
  _f$status = Field('status', _$status, opt: true);
  static String? _$contactName(UpdateEvacuationCenterRequest v) =>
      v.contactName;
  static const Field<UpdateEvacuationCenterRequest, String> _f$contactName =
      Field('contactName', _$contactName, key: r'contact_name', opt: true);
  static String? _$contactPhone(UpdateEvacuationCenterRequest v) =>
      v.contactPhone;
  static const Field<UpdateEvacuationCenterRequest, String> _f$contactPhone =
      Field('contactPhone', _$contactPhone, key: r'contact_phone', opt: true);
  static List<String>? _$photos(UpdateEvacuationCenterRequest v) => v.photos;
  static const Field<UpdateEvacuationCenterRequest, List<String>> _f$photos =
      Field('photos', _$photos, opt: true);
  static bool _$isEmpty(UpdateEvacuationCenterRequest v) => v.isEmpty;
  static const Field<UpdateEvacuationCenterRequest, bool> _f$isEmpty = Field(
    'isEmpty',
    _$isEmpty,
    key: r'is_empty',
    mode: FieldMode.member,
  );

  @override
  final MappableFields<UpdateEvacuationCenterRequest> fields = const {
    #name: _f$name,
    #address: _f$address,
    #latitude: _f$latitude,
    #longitude: _f$longitude,
    #capacity: _f$capacity,
    #currentOccupancy: _f$currentOccupancy,
    #status: _f$status,
    #contactName: _f$contactName,
    #contactPhone: _f$contactPhone,
    #photos: _f$photos,
    #isEmpty: _f$isEmpty,
  };

  static UpdateEvacuationCenterRequest _instantiate(DecodingData data) {
    return UpdateEvacuationCenterRequest(
      name: data.dec(_f$name),
      address: data.dec(_f$address),
      latitude: data.dec(_f$latitude),
      longitude: data.dec(_f$longitude),
      capacity: data.dec(_f$capacity),
      currentOccupancy: data.dec(_f$currentOccupancy),
      status: data.dec(_f$status),
      contactName: data.dec(_f$contactName),
      contactPhone: data.dec(_f$contactPhone),
      photos: data.dec(_f$photos),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UpdateEvacuationCenterRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UpdateEvacuationCenterRequest>(map);
  }

  static UpdateEvacuationCenterRequest fromJson(String json) {
    return ensureInitialized().decodeJson<UpdateEvacuationCenterRequest>(json);
  }
}

mixin UpdateEvacuationCenterRequestMappable {
  String toJson() {
    return UpdateEvacuationCenterRequestMapper.ensureInitialized()
        .encodeJson<UpdateEvacuationCenterRequest>(
          this as UpdateEvacuationCenterRequest,
        );
  }

  Map<String, dynamic> toMap() {
    return UpdateEvacuationCenterRequestMapper.ensureInitialized()
        .encodeMap<UpdateEvacuationCenterRequest>(
          this as UpdateEvacuationCenterRequest,
        );
  }

  UpdateEvacuationCenterRequestCopyWith<
    UpdateEvacuationCenterRequest,
    UpdateEvacuationCenterRequest,
    UpdateEvacuationCenterRequest
  >
  get copyWith =>
      _UpdateEvacuationCenterRequestCopyWithImpl<
        UpdateEvacuationCenterRequest,
        UpdateEvacuationCenterRequest
      >(this as UpdateEvacuationCenterRequest, $identity, $identity);
  @override
  String toString() {
    return UpdateEvacuationCenterRequestMapper.ensureInitialized()
        .stringifyValue(this as UpdateEvacuationCenterRequest);
  }

  @override
  bool operator ==(Object other) {
    return UpdateEvacuationCenterRequestMapper.ensureInitialized().equalsValue(
      this as UpdateEvacuationCenterRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return UpdateEvacuationCenterRequestMapper.ensureInitialized().hashValue(
      this as UpdateEvacuationCenterRequest,
    );
  }
}

extension UpdateEvacuationCenterRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UpdateEvacuationCenterRequest, $Out> {
  UpdateEvacuationCenterRequestCopyWith<$R, UpdateEvacuationCenterRequest, $Out>
  get $asUpdateEvacuationCenterRequest => $base.as(
    (v, t, t2) =>
        _UpdateEvacuationCenterRequestCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class UpdateEvacuationCenterRequestCopyWith<
  $R,
  $In extends UpdateEvacuationCenterRequest,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get photos;
  $R call({
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
  });
  UpdateEvacuationCenterRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _UpdateEvacuationCenterRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UpdateEvacuationCenterRequest, $Out>
    implements
        UpdateEvacuationCenterRequestCopyWith<
          $R,
          UpdateEvacuationCenterRequest,
          $Out
        > {
  _UpdateEvacuationCenterRequestCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<UpdateEvacuationCenterRequest> $mapper =
      UpdateEvacuationCenterRequestMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get photos =>
      $value.photos != null
      ? ListCopyWith(
          $value.photos!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(photos: v),
        )
      : null;
  @override
  $R call({
    Object? name = $none,
    Object? address = $none,
    Object? latitude = $none,
    Object? longitude = $none,
    Object? capacity = $none,
    Object? currentOccupancy = $none,
    Object? status = $none,
    Object? contactName = $none,
    Object? contactPhone = $none,
    Object? photos = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != $none) #name: name,
      if (address != $none) #address: address,
      if (latitude != $none) #latitude: latitude,
      if (longitude != $none) #longitude: longitude,
      if (capacity != $none) #capacity: capacity,
      if (currentOccupancy != $none) #currentOccupancy: currentOccupancy,
      if (status != $none) #status: status,
      if (contactName != $none) #contactName: contactName,
      if (contactPhone != $none) #contactPhone: contactPhone,
      if (photos != $none) #photos: photos,
    }),
  );
  @override
  UpdateEvacuationCenterRequest $make(CopyWithData data) =>
      UpdateEvacuationCenterRequest(
        name: data.get(#name, or: $value.name),
        address: data.get(#address, or: $value.address),
        latitude: data.get(#latitude, or: $value.latitude),
        longitude: data.get(#longitude, or: $value.longitude),
        capacity: data.get(#capacity, or: $value.capacity),
        currentOccupancy: data.get(
          #currentOccupancy,
          or: $value.currentOccupancy,
        ),
        status: data.get(#status, or: $value.status),
        contactName: data.get(#contactName, or: $value.contactName),
        contactPhone: data.get(#contactPhone, or: $value.contactPhone),
        photos: data.get(#photos, or: $value.photos),
      );

  @override
  UpdateEvacuationCenterRequestCopyWith<
    $R2,
    UpdateEvacuationCenterRequest,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _UpdateEvacuationCenterRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

