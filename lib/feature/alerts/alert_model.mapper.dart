// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'alert_model.dart';

class AlertLevelMapper extends EnumMapper<AlertLevel> {
  AlertLevelMapper._();

  static AlertLevelMapper? _instance;
  static AlertLevelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AlertLevelMapper._());
    }
    return _instance!;
  }

  static AlertLevel fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  AlertLevel decode(dynamic value) {
    switch (value) {
      case r'low':
        return AlertLevel.low;
      case r'medium':
        return AlertLevel.medium;
      case r'high':
        return AlertLevel.high;
      case r'critical':
        return AlertLevel.critical;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(AlertLevel self) {
    switch (self) {
      case AlertLevel.low:
        return r'low';
      case AlertLevel.medium:
        return r'medium';
      case AlertLevel.high:
        return r'high';
      case AlertLevel.critical:
        return r'critical';
    }
  }
}

extension AlertLevelMapperExtension on AlertLevel {
  String toValue() {
    AlertLevelMapper.ensureInitialized();
    return MapperContainer.globals.toValue<AlertLevel>(this) as String;
  }
}

class AlertMapper extends ClassMapperBase<Alert> {
  AlertMapper._();

  static AlertMapper? _instance;
  static AlertMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AlertMapper._());
      AlertLevelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Alert';

  static int _$id(Alert v) => v.id;
  static const Field<Alert, int> _f$id = Field('id', _$id);
  static String _$user(Alert v) => v.user;
  static const Field<Alert, String> _f$user = Field('user', _$user);
  static String _$title(Alert v) => v.title;
  static const Field<Alert, String> _f$title = Field('title', _$title);
  static String _$description(Alert v) => v.description;
  static const Field<Alert, String> _f$description = Field(
    'description',
    _$description,
  );
  static AlertLevel _$level(Alert v) => v.level;
  static const Field<Alert, AlertLevel> _f$level = Field('level', _$level);
  static AlertStatus _$status(Alert v) => v.status;
  static const Field<Alert, AlertStatus> _f$status = Field('status', _$status);
  static String? _$location(Alert v) => v.location;
  static const Field<Alert, String> _f$location = Field(
    'location',
    _$location,
    opt: true,
  );
  static double? _$latitude(Alert v) => v.latitude;
  static const Field<Alert, double> _f$latitude = Field(
    'latitude',
    _$latitude,
    opt: true,
  );
  static double? _$longitude(Alert v) => v.longitude;
  static const Field<Alert, double> _f$longitude = Field(
    'longitude',
    _$longitude,
    opt: true,
  );
  static DateTime _$createdAt(Alert v) => v.createdAt;
  static const Field<Alert, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime? _$updatedAt(Alert v) => v.updatedAt;
  static const Field<Alert, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
    opt: true,
  );
  static DateTime? _$resolvedAt(Alert v) => v.resolvedAt;
  static const Field<Alert, DateTime> _f$resolvedAt = Field(
    'resolvedAt',
    _$resolvedAt,
    key: r'resolved_at',
    opt: true,
  );
  static bool _$isActive(Alert v) => v.isActive;
  static const Field<Alert, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    key: r'is_active',
    mode: FieldMode.member,
  );
  static bool _$isResolved(Alert v) => v.isResolved;
  static const Field<Alert, bool> _f$isResolved = Field(
    'isResolved',
    _$isResolved,
    key: r'is_resolved',
    mode: FieldMode.member,
  );
  static bool _$hasLocation(Alert v) => v.hasLocation;
  static const Field<Alert, bool> _f$hasLocation = Field(
    'hasLocation',
    _$hasLocation,
    key: r'has_location',
    mode: FieldMode.member,
  );
  static int _$hashCode(Alert v) => v.hashCode;
  static const Field<Alert, int> _f$hashCode = Field(
    'hashCode',
    _$hashCode,
    key: r'hash_code',
    mode: FieldMode.member,
  );

  @override
  final MappableFields<Alert> fields = const {
    #id: _f$id,
    #user: _f$user,
    #title: _f$title,
    #description: _f$description,
    #level: _f$level,
    #status: _f$status,
    #location: _f$location,
    #latitude: _f$latitude,
    #longitude: _f$longitude,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #resolvedAt: _f$resolvedAt,
    #isActive: _f$isActive,
    #isResolved: _f$isResolved,
    #hasLocation: _f$hasLocation,
    #hashCode: _f$hashCode,
  };

  static Alert _instantiate(DecodingData data) {
    return Alert(
      id: data.dec(_f$id),
      user: data.dec(_f$user),
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      level: data.dec(_f$level),
      status: data.dec(_f$status),
      location: data.dec(_f$location),
      latitude: data.dec(_f$latitude),
      longitude: data.dec(_f$longitude),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
      resolvedAt: data.dec(_f$resolvedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Alert fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Alert>(map);
  }

  static Alert fromJson(String json) {
    return ensureInitialized().decodeJson<Alert>(json);
  }
}

mixin AlertMappable {
  String toJson() {
    return AlertMapper.ensureInitialized().encodeJson<Alert>(this as Alert);
  }

  Map<String, dynamic> toMap() {
    return AlertMapper.ensureInitialized().encodeMap<Alert>(this as Alert);
  }

  AlertCopyWith<Alert, Alert, Alert> get copyWith =>
      _AlertCopyWithImpl<Alert, Alert>(this as Alert, $identity, $identity);
  @override
  String toString() {
    return AlertMapper.ensureInitialized().stringifyValue(this as Alert);
  }

  @override
  bool operator ==(Object other) {
    return AlertMapper.ensureInitialized().equalsValue(this as Alert, other);
  }

  @override
  int get hashCode {
    return AlertMapper.ensureInitialized().hashValue(this as Alert);
  }
}

extension AlertValueCopy<$R, $Out> on ObjectCopyWith<$R, Alert, $Out> {
  AlertCopyWith<$R, Alert, $Out> get $asAlert =>
      $base.as((v, t, t2) => _AlertCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AlertCopyWith<$R, $In extends Alert, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    String? user,
    String? title,
    String? description,
    AlertLevel? level,
    AlertStatus? status,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  });
  AlertCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AlertCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Alert, $Out>
    implements AlertCopyWith<$R, Alert, $Out> {
  _AlertCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Alert> $mapper = AlertMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    String? user,
    String? title,
    String? description,
    AlertLevel? level,
    AlertStatus? status,
    Object? location = $none,
    Object? latitude = $none,
    Object? longitude = $none,
    DateTime? createdAt,
    Object? updatedAt = $none,
    Object? resolvedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (user != null) #user: user,
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (level != null) #level: level,
      if (status != null) #status: status,
      if (location != $none) #location: location,
      if (latitude != $none) #latitude: latitude,
      if (longitude != $none) #longitude: longitude,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
      if (resolvedAt != $none) #resolvedAt: resolvedAt,
    }),
  );
  @override
  Alert $make(CopyWithData data) => Alert(
    id: data.get(#id, or: $value.id),
    user: data.get(#user, or: $value.user),
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    level: data.get(#level, or: $value.level),
    status: data.get(#status, or: $value.status),
    location: data.get(#location, or: $value.location),
    latitude: data.get(#latitude, or: $value.latitude),
    longitude: data.get(#longitude, or: $value.longitude),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    resolvedAt: data.get(#resolvedAt, or: $value.resolvedAt),
  );

  @override
  AlertCopyWith<$R2, Alert, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AlertCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CreateAlertRequestMapper extends ClassMapperBase<CreateAlertRequest> {
  CreateAlertRequestMapper._();

  static CreateAlertRequestMapper? _instance;
  static CreateAlertRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CreateAlertRequestMapper._());
      AlertLevelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CreateAlertRequest';

  static String _$user(CreateAlertRequest v) => v.user;
  static const Field<CreateAlertRequest, String> _f$user = Field(
    'user',
    _$user,
  );
  static String _$title(CreateAlertRequest v) => v.title;
  static const Field<CreateAlertRequest, String> _f$title = Field(
    'title',
    _$title,
  );
  static String _$description(CreateAlertRequest v) => v.description;
  static const Field<CreateAlertRequest, String> _f$description = Field(
    'description',
    _$description,
  );
  static AlertLevel _$level(CreateAlertRequest v) => v.level;
  static const Field<CreateAlertRequest, AlertLevel> _f$level = Field(
    'level',
    _$level,
  );
  static String? _$location(CreateAlertRequest v) => v.location;
  static const Field<CreateAlertRequest, String> _f$location = Field(
    'location',
    _$location,
    opt: true,
  );
  static double? _$latitude(CreateAlertRequest v) => v.latitude;
  static const Field<CreateAlertRequest, double> _f$latitude = Field(
    'latitude',
    _$latitude,
    opt: true,
  );
  static double? _$longitude(CreateAlertRequest v) => v.longitude;
  static const Field<CreateAlertRequest, double> _f$longitude = Field(
    'longitude',
    _$longitude,
    opt: true,
  );

  @override
  final MappableFields<CreateAlertRequest> fields = const {
    #user: _f$user,
    #title: _f$title,
    #description: _f$description,
    #level: _f$level,
    #location: _f$location,
    #latitude: _f$latitude,
    #longitude: _f$longitude,
  };

  static CreateAlertRequest _instantiate(DecodingData data) {
    return CreateAlertRequest(
      user: data.dec(_f$user),
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      level: data.dec(_f$level),
      location: data.dec(_f$location),
      latitude: data.dec(_f$latitude),
      longitude: data.dec(_f$longitude),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CreateAlertRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CreateAlertRequest>(map);
  }

  static CreateAlertRequest fromJson(String json) {
    return ensureInitialized().decodeJson<CreateAlertRequest>(json);
  }
}

mixin CreateAlertRequestMappable {
  String toJson() {
    return CreateAlertRequestMapper.ensureInitialized()
        .encodeJson<CreateAlertRequest>(this as CreateAlertRequest);
  }

  Map<String, dynamic> toMap() {
    return CreateAlertRequestMapper.ensureInitialized()
        .encodeMap<CreateAlertRequest>(this as CreateAlertRequest);
  }

  CreateAlertRequestCopyWith<
    CreateAlertRequest,
    CreateAlertRequest,
    CreateAlertRequest
  >
  get copyWith =>
      _CreateAlertRequestCopyWithImpl<CreateAlertRequest, CreateAlertRequest>(
        this as CreateAlertRequest,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CreateAlertRequestMapper.ensureInitialized().stringifyValue(
      this as CreateAlertRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return CreateAlertRequestMapper.ensureInitialized().equalsValue(
      this as CreateAlertRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return CreateAlertRequestMapper.ensureInitialized().hashValue(
      this as CreateAlertRequest,
    );
  }
}

extension CreateAlertRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CreateAlertRequest, $Out> {
  CreateAlertRequestCopyWith<$R, CreateAlertRequest, $Out>
  get $asCreateAlertRequest => $base.as(
    (v, t, t2) => _CreateAlertRequestCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CreateAlertRequestCopyWith<
  $R,
  $In extends CreateAlertRequest,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? user,
    String? title,
    String? description,
    AlertLevel? level,
    String? location,
    double? latitude,
    double? longitude,
  });
  CreateAlertRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CreateAlertRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CreateAlertRequest, $Out>
    implements CreateAlertRequestCopyWith<$R, CreateAlertRequest, $Out> {
  _CreateAlertRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CreateAlertRequest> $mapper =
      CreateAlertRequestMapper.ensureInitialized();
  @override
  $R call({
    String? user,
    String? title,
    String? description,
    AlertLevel? level,
    Object? location = $none,
    Object? latitude = $none,
    Object? longitude = $none,
  }) => $apply(
    FieldCopyWithData({
      if (user != null) #user: user,
      if (title != null) #title: title,
      if (description != null) #description: description,
      if (level != null) #level: level,
      if (location != $none) #location: location,
      if (latitude != $none) #latitude: latitude,
      if (longitude != $none) #longitude: longitude,
    }),
  );
  @override
  CreateAlertRequest $make(CopyWithData data) => CreateAlertRequest(
    user: data.get(#user, or: $value.user),
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    level: data.get(#level, or: $value.level),
    location: data.get(#location, or: $value.location),
    latitude: data.get(#latitude, or: $value.latitude),
    longitude: data.get(#longitude, or: $value.longitude),
  );

  @override
  CreateAlertRequestCopyWith<$R2, CreateAlertRequest, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CreateAlertRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class UpdateAlertRequestMapper extends ClassMapperBase<UpdateAlertRequest> {
  UpdateAlertRequestMapper._();

  static UpdateAlertRequestMapper? _instance;
  static UpdateAlertRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UpdateAlertRequestMapper._());
      AlertLevelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'UpdateAlertRequest';

  static String? _$title(UpdateAlertRequest v) => v.title;
  static const Field<UpdateAlertRequest, String> _f$title = Field(
    'title',
    _$title,
    opt: true,
  );
  static String? _$description(UpdateAlertRequest v) => v.description;
  static const Field<UpdateAlertRequest, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static AlertLevel? _$level(UpdateAlertRequest v) => v.level;
  static const Field<UpdateAlertRequest, AlertLevel> _f$level = Field(
    'level',
    _$level,
    opt: true,
  );
  static AlertStatus? _$status(UpdateAlertRequest v) => v.status;
  static const Field<UpdateAlertRequest, AlertStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
  );
  static String? _$location(UpdateAlertRequest v) => v.location;
  static const Field<UpdateAlertRequest, String> _f$location = Field(
    'location',
    _$location,
    opt: true,
  );
  static double? _$latitude(UpdateAlertRequest v) => v.latitude;
  static const Field<UpdateAlertRequest, double> _f$latitude = Field(
    'latitude',
    _$latitude,
    opt: true,
  );
  static double? _$longitude(UpdateAlertRequest v) => v.longitude;
  static const Field<UpdateAlertRequest, double> _f$longitude = Field(
    'longitude',
    _$longitude,
    opt: true,
  );
  static bool _$isEmpty(UpdateAlertRequest v) => v.isEmpty;
  static const Field<UpdateAlertRequest, bool> _f$isEmpty = Field(
    'isEmpty',
    _$isEmpty,
    key: r'is_empty',
    mode: FieldMode.member,
  );

  @override
  final MappableFields<UpdateAlertRequest> fields = const {
    #title: _f$title,
    #description: _f$description,
    #level: _f$level,
    #status: _f$status,
    #location: _f$location,
    #latitude: _f$latitude,
    #longitude: _f$longitude,
    #isEmpty: _f$isEmpty,
  };

  static UpdateAlertRequest _instantiate(DecodingData data) {
    return UpdateAlertRequest(
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      level: data.dec(_f$level),
      status: data.dec(_f$status),
      location: data.dec(_f$location),
      latitude: data.dec(_f$latitude),
      longitude: data.dec(_f$longitude),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UpdateAlertRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UpdateAlertRequest>(map);
  }

  static UpdateAlertRequest fromJson(String json) {
    return ensureInitialized().decodeJson<UpdateAlertRequest>(json);
  }
}

mixin UpdateAlertRequestMappable {
  String toJson() {
    return UpdateAlertRequestMapper.ensureInitialized()
        .encodeJson<UpdateAlertRequest>(this as UpdateAlertRequest);
  }

  Map<String, dynamic> toMap() {
    return UpdateAlertRequestMapper.ensureInitialized()
        .encodeMap<UpdateAlertRequest>(this as UpdateAlertRequest);
  }

  UpdateAlertRequestCopyWith<
    UpdateAlertRequest,
    UpdateAlertRequest,
    UpdateAlertRequest
  >
  get copyWith =>
      _UpdateAlertRequestCopyWithImpl<UpdateAlertRequest, UpdateAlertRequest>(
        this as UpdateAlertRequest,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UpdateAlertRequestMapper.ensureInitialized().stringifyValue(
      this as UpdateAlertRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return UpdateAlertRequestMapper.ensureInitialized().equalsValue(
      this as UpdateAlertRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return UpdateAlertRequestMapper.ensureInitialized().hashValue(
      this as UpdateAlertRequest,
    );
  }
}

extension UpdateAlertRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UpdateAlertRequest, $Out> {
  UpdateAlertRequestCopyWith<$R, UpdateAlertRequest, $Out>
  get $asUpdateAlertRequest => $base.as(
    (v, t, t2) => _UpdateAlertRequestCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class UpdateAlertRequestCopyWith<
  $R,
  $In extends UpdateAlertRequest,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? title,
    String? description,
    AlertLevel? level,
    AlertStatus? status,
    String? location,
    double? latitude,
    double? longitude,
  });
  UpdateAlertRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _UpdateAlertRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UpdateAlertRequest, $Out>
    implements UpdateAlertRequestCopyWith<$R, UpdateAlertRequest, $Out> {
  _UpdateAlertRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UpdateAlertRequest> $mapper =
      UpdateAlertRequestMapper.ensureInitialized();
  @override
  $R call({
    Object? title = $none,
    Object? description = $none,
    Object? level = $none,
    Object? status = $none,
    Object? location = $none,
    Object? latitude = $none,
    Object? longitude = $none,
  }) => $apply(
    FieldCopyWithData({
      if (title != $none) #title: title,
      if (description != $none) #description: description,
      if (level != $none) #level: level,
      if (status != $none) #status: status,
      if (location != $none) #location: location,
      if (latitude != $none) #latitude: latitude,
      if (longitude != $none) #longitude: longitude,
    }),
  );
  @override
  UpdateAlertRequest $make(CopyWithData data) => UpdateAlertRequest(
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    level: data.get(#level, or: $value.level),
    status: data.get(#status, or: $value.status),
    location: data.get(#location, or: $value.location),
    latitude: data.get(#latitude, or: $value.latitude),
    longitude: data.get(#longitude, or: $value.longitude),
  );

  @override
  UpdateAlertRequestCopyWith<$R2, UpdateAlertRequest, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UpdateAlertRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

