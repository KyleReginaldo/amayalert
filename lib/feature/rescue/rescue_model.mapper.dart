// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'rescue_model.dart';

class RescueStatusMapper extends EnumMapper<RescueStatus> {
  RescueStatusMapper._();

  static RescueStatusMapper? _instance;
  static RescueStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RescueStatusMapper._());
    }
    return _instance!;
  }

  static RescueStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  RescueStatus decode(dynamic value) {
    switch (value) {
      case r'pending':
        return RescueStatus.pending;
      case r'in_progress':
        return RescueStatus.inProgress;
      case r'completed':
        return RescueStatus.completed;
      case r'cancelled':
        return RescueStatus.cancelled;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(RescueStatus self) {
    switch (self) {
      case RescueStatus.pending:
        return r'pending';
      case RescueStatus.inProgress:
        return r'in_progress';
      case RescueStatus.completed:
        return r'completed';
      case RescueStatus.cancelled:
        return r'cancelled';
    }
  }
}

extension RescueStatusMapperExtension on RescueStatus {
  String toValue() {
    RescueStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<RescueStatus>(this) as String;
  }
}

class EmergencyTypeMapper extends EnumMapper<EmergencyType> {
  EmergencyTypeMapper._();

  static EmergencyTypeMapper? _instance;
  static EmergencyTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EmergencyTypeMapper._());
    }
    return _instance!;
  }

  static EmergencyType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  EmergencyType decode(dynamic value) {
    switch (value) {
      case r'medical':
        return EmergencyType.medical;
      case r'fire':
        return EmergencyType.fire;
      case r'flood':
        return EmergencyType.flood;
      case r'accident':
        return EmergencyType.accident;
      case r'violence':
        return EmergencyType.violence;
      case r'natural_disaster':
        return EmergencyType.naturalDisaster;
      case r'other':
        return EmergencyType.other;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(EmergencyType self) {
    switch (self) {
      case EmergencyType.medical:
        return r'medical';
      case EmergencyType.fire:
        return r'fire';
      case EmergencyType.flood:
        return r'flood';
      case EmergencyType.accident:
        return r'accident';
      case EmergencyType.violence:
        return r'violence';
      case EmergencyType.naturalDisaster:
        return r'natural_disaster';
      case EmergencyType.other:
        return r'other';
    }
  }
}

extension EmergencyTypeMapperExtension on EmergencyType {
  String toValue() {
    EmergencyTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<EmergencyType>(this) as String;
  }
}

class RescuePriorityMapper extends EnumMapper<RescuePriority> {
  RescuePriorityMapper._();

  static RescuePriorityMapper? _instance;
  static RescuePriorityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RescuePriorityMapper._());
    }
    return _instance!;
  }

  static RescuePriority fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  RescuePriority decode(dynamic value) {
    switch (value) {
      case r'low':
        return RescuePriority.low;
      case r'medium':
        return RescuePriority.medium;
      case r'high':
        return RescuePriority.high;
      case r'critical':
        return RescuePriority.critical;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(RescuePriority self) {
    switch (self) {
      case RescuePriority.low:
        return r'low';
      case RescuePriority.medium:
        return r'medium';
      case RescuePriority.high:
        return r'high';
      case RescuePriority.critical:
        return r'critical';
    }
  }
}

extension RescuePriorityMapperExtension on RescuePriority {
  String toValue() {
    RescuePriorityMapper.ensureInitialized();
    return MapperContainer.globals.toValue<RescuePriority>(this) as String;
  }
}

class RescueMapper extends ClassMapperBase<Rescue> {
  RescueMapper._();

  static RescueMapper? _instance;
  static RescueMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RescueMapper._());
      RescueStatusMapper.ensureInitialized();
      ProfileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Rescue';

  static String _$id(Rescue v) => v.id;
  static const Field<Rescue, String> _f$id = Field('id', _$id);
  static String _$title(Rescue v) => v.title;
  static const Field<Rescue, String> _f$title = Field('title', _$title);
  static String? _$description(Rescue v) => v.description;
  static const Field<Rescue, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static double? _$lat(Rescue v) => v.lat;
  static const Field<Rescue, double> _f$lat = Field('lat', _$lat, opt: true);
  static double? _$lng(Rescue v) => v.lng;
  static const Field<Rescue, double> _f$lng = Field('lng', _$lng, opt: true);
  static RescueStatus _$status(Rescue v) => v.status;
  static const Field<Rescue, RescueStatus> _f$status = Field(
    'status',
    _$status,
  );
  static int _$priority(Rescue v) => v.priority;
  static const Field<Rescue, int> _f$priority = Field('priority', _$priority);
  static DateTime _$reportedAt(Rescue v) => v.reportedAt;
  static const Field<Rescue, DateTime> _f$reportedAt = Field(
    'reportedAt',
    _$reportedAt,
    key: r'reported_at',
  );
  static DateTime? _$scheduledFor(Rescue v) => v.scheduledFor;
  static const Field<Rescue, DateTime> _f$scheduledFor = Field(
    'scheduledFor',
    _$scheduledFor,
    key: r'scheduled_for',
    opt: true,
  );
  static DateTime? _$completedAt(Rescue v) => v.completedAt;
  static const Field<Rescue, DateTime> _f$completedAt = Field(
    'completedAt',
    _$completedAt,
    key: r'completed_at',
    opt: true,
  );
  static String? _$emergencyType(Rescue v) => v.emergencyType;
  static const Field<Rescue, String> _f$emergencyType = Field(
    'emergencyType',
    _$emergencyType,
    key: r'emergency_type',
    opt: true,
  );
  static int? _$femaleCount(Rescue v) => v.femaleCount;
  static const Field<Rescue, int> _f$femaleCount = Field(
    'femaleCount',
    _$femaleCount,
    key: r'female_count',
    opt: true,
  );
  static int? _$maleCount(Rescue v) => v.maleCount;
  static const Field<Rescue, int> _f$maleCount = Field(
    'maleCount',
    _$maleCount,
    key: r'male_count',
    opt: true,
  );
  static String? _$contactPhone(Rescue v) => v.contactPhone;
  static const Field<Rescue, String> _f$contactPhone = Field(
    'contactPhone',
    _$contactPhone,
    key: r'contact_phone',
    opt: true,
  );
  static String? _$email(Rescue v) => v.email;
  static const Field<Rescue, String> _f$email = Field(
    'email',
    _$email,
    opt: true,
  );
  static String? _$importantInformation(Rescue v) => v.importantInformation;
  static const Field<Rescue, String> _f$importantInformation = Field(
    'importantInformation',
    _$importantInformation,
    key: r'important_information',
    opt: true,
  );
  static Profile? _$user(Rescue v) => v.user;
  static const Field<Rescue, Profile> _f$user = Field(
    'user',
    _$user,
    opt: true,
  );
  static List<String>? _$attachments(Rescue v) => v.attachments;
  static const Field<Rescue, List<String>> _f$attachments = Field(
    'attachments',
    _$attachments,
    opt: true,
  );
  static Map<String, dynamic>? _$metadata(Rescue v) => v.metadata;
  static const Field<Rescue, Map<String, dynamic>> _f$metadata = Field(
    'metadata',
    _$metadata,
    opt: true,
  );
  static DateTime _$createdAt(Rescue v) => v.createdAt;
  static const Field<Rescue, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime _$updatedAt(Rescue v) => v.updatedAt;
  static const Field<Rescue, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
  );
  static String _$priorityLabel(Rescue v) => v.priorityLabel;
  static const Field<Rescue, String> _f$priorityLabel = Field(
    'priorityLabel',
    _$priorityLabel,
    key: r'priority_label',
    mode: FieldMode.member,
  );
  static String _$statusLabel(Rescue v) => v.statusLabel;
  static const Field<Rescue, String> _f$statusLabel = Field(
    'statusLabel',
    _$statusLabel,
    key: r'status_label',
    mode: FieldMode.member,
  );
  static int? _$victimCount(Rescue v) => v.victimCount;
  static const Field<Rescue, int> _f$victimCount = Field(
    'victimCount',
    _$victimCount,
    key: r'victim_count',
    mode: FieldMode.member,
  );
  static String _$emergencyTypeLabel(Rescue v) => v.emergencyTypeLabel;
  static const Field<Rescue, String> _f$emergencyTypeLabel = Field(
    'emergencyTypeLabel',
    _$emergencyTypeLabel,
    key: r'emergency_type_label',
    mode: FieldMode.member,
  );

  @override
  final MappableFields<Rescue> fields = const {
    #id: _f$id,
    #title: _f$title,
    #description: _f$description,
    #lat: _f$lat,
    #lng: _f$lng,
    #status: _f$status,
    #priority: _f$priority,
    #reportedAt: _f$reportedAt,
    #scheduledFor: _f$scheduledFor,
    #completedAt: _f$completedAt,
    #emergencyType: _f$emergencyType,
    #femaleCount: _f$femaleCount,
    #maleCount: _f$maleCount,
    #contactPhone: _f$contactPhone,
    #email: _f$email,
    #importantInformation: _f$importantInformation,
    #user: _f$user,
    #attachments: _f$attachments,
    #metadata: _f$metadata,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #priorityLabel: _f$priorityLabel,
    #statusLabel: _f$statusLabel,
    #victimCount: _f$victimCount,
    #emergencyTypeLabel: _f$emergencyTypeLabel,
  };

  static Rescue _instantiate(DecodingData data) {
    return Rescue(
      id: data.dec(_f$id),
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      lat: data.dec(_f$lat),
      lng: data.dec(_f$lng),
      status: data.dec(_f$status),
      priority: data.dec(_f$priority),
      reportedAt: data.dec(_f$reportedAt),
      scheduledFor: data.dec(_f$scheduledFor),
      completedAt: data.dec(_f$completedAt),
      emergencyType: data.dec(_f$emergencyType),
      femaleCount: data.dec(_f$femaleCount),
      maleCount: data.dec(_f$maleCount),
      contactPhone: data.dec(_f$contactPhone),
      email: data.dec(_f$email),
      importantInformation: data.dec(_f$importantInformation),
      user: data.dec(_f$user),
      attachments: data.dec(_f$attachments),
      metadata: data.dec(_f$metadata),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Rescue fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Rescue>(map);
  }

  static Rescue fromJson(String json) {
    return ensureInitialized().decodeJson<Rescue>(json);
  }
}

mixin RescueMappable {
  String toJson() {
    return RescueMapper.ensureInitialized().encodeJson<Rescue>(this as Rescue);
  }

  Map<String, dynamic> toMap() {
    return RescueMapper.ensureInitialized().encodeMap<Rescue>(this as Rescue);
  }

  RescueCopyWith<Rescue, Rescue, Rescue> get copyWith =>
      _RescueCopyWithImpl<Rescue, Rescue>(this as Rescue, $identity, $identity);
  @override
  String toString() {
    return RescueMapper.ensureInitialized().stringifyValue(this as Rescue);
  }

  @override
  bool operator ==(Object other) {
    return RescueMapper.ensureInitialized().equalsValue(this as Rescue, other);
  }

  @override
  int get hashCode {
    return RescueMapper.ensureInitialized().hashValue(this as Rescue);
  }
}

extension RescueValueCopy<$R, $Out> on ObjectCopyWith<$R, Rescue, $Out> {
  RescueCopyWith<$R, Rescue, $Out> get $asRescue =>
      $base.as((v, t, t2) => _RescueCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RescueCopyWith<$R, $In extends Rescue, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ProfileCopyWith<$R, Profile, Profile>? get user;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get attachments;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get metadata;
  $R call({
    String? id,
    String? title,
    String? description,
    double? lat,
    double? lng,
    RescueStatus? status,
    int? priority,
    DateTime? reportedAt,
    DateTime? scheduledFor,
    DateTime? completedAt,
    String? emergencyType,
    int? femaleCount,
    int? maleCount,
    String? contactPhone,
    String? email,
    String? importantInformation,
    Profile? user,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  RescueCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RescueCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Rescue, $Out>
    implements RescueCopyWith<$R, Rescue, $Out> {
  _RescueCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Rescue> $mapper = RescueMapper.ensureInitialized();
  @override
  ProfileCopyWith<$R, Profile, Profile>? get user =>
      $value.user?.copyWith.$chain((v) => call(user: v));
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get attachments => $value.attachments != null
      ? ListCopyWith(
          $value.attachments!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(attachments: v),
        )
      : null;
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get metadata => $value.metadata != null
      ? MapCopyWith(
          $value.metadata!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(metadata: v),
        )
      : null;
  @override
  $R call({
    String? id,
    String? title,
    Object? description = $none,
    Object? lat = $none,
    Object? lng = $none,
    RescueStatus? status,
    int? priority,
    DateTime? reportedAt,
    Object? scheduledFor = $none,
    Object? completedAt = $none,
    Object? emergencyType = $none,
    Object? femaleCount = $none,
    Object? maleCount = $none,
    Object? contactPhone = $none,
    Object? email = $none,
    Object? importantInformation = $none,
    Object? user = $none,
    Object? attachments = $none,
    Object? metadata = $none,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (title != null) #title: title,
      if (description != $none) #description: description,
      if (lat != $none) #lat: lat,
      if (lng != $none) #lng: lng,
      if (status != null) #status: status,
      if (priority != null) #priority: priority,
      if (reportedAt != null) #reportedAt: reportedAt,
      if (scheduledFor != $none) #scheduledFor: scheduledFor,
      if (completedAt != $none) #completedAt: completedAt,
      if (emergencyType != $none) #emergencyType: emergencyType,
      if (femaleCount != $none) #femaleCount: femaleCount,
      if (maleCount != $none) #maleCount: maleCount,
      if (contactPhone != $none) #contactPhone: contactPhone,
      if (email != $none) #email: email,
      if (importantInformation != $none)
        #importantInformation: importantInformation,
      if (user != $none) #user: user,
      if (attachments != $none) #attachments: attachments,
      if (metadata != $none) #metadata: metadata,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != null) #updatedAt: updatedAt,
    }),
  );
  @override
  Rescue $make(CopyWithData data) => Rescue(
    id: data.get(#id, or: $value.id),
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    lat: data.get(#lat, or: $value.lat),
    lng: data.get(#lng, or: $value.lng),
    status: data.get(#status, or: $value.status),
    priority: data.get(#priority, or: $value.priority),
    reportedAt: data.get(#reportedAt, or: $value.reportedAt),
    scheduledFor: data.get(#scheduledFor, or: $value.scheduledFor),
    completedAt: data.get(#completedAt, or: $value.completedAt),
    emergencyType: data.get(#emergencyType, or: $value.emergencyType),
    femaleCount: data.get(#femaleCount, or: $value.femaleCount),
    maleCount: data.get(#maleCount, or: $value.maleCount),
    contactPhone: data.get(#contactPhone, or: $value.contactPhone),
    email: data.get(#email, or: $value.email),
    importantInformation: data.get(
      #importantInformation,
      or: $value.importantInformation,
    ),
    user: data.get(#user, or: $value.user),
    attachments: data.get(#attachments, or: $value.attachments),
    metadata: data.get(#metadata, or: $value.metadata),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  RescueCopyWith<$R2, Rescue, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _RescueCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CreateRescueRequestMapper extends ClassMapperBase<CreateRescueRequest> {
  CreateRescueRequestMapper._();

  static CreateRescueRequestMapper? _instance;
  static CreateRescueRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CreateRescueRequestMapper._());
      RescuePriorityMapper.ensureInitialized();
      EmergencyTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CreateRescueRequest';

  static String _$title(CreateRescueRequest v) => v.title;
  static const Field<CreateRescueRequest, String> _f$title = Field(
    'title',
    _$title,
  );
  static String? _$description(CreateRescueRequest v) => v.description;
  static const Field<CreateRescueRequest, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static double? _$lat(CreateRescueRequest v) => v.lat;
  static const Field<CreateRescueRequest, double> _f$lat = Field(
    'lat',
    _$lat,
    opt: true,
  );
  static double? _$lng(CreateRescueRequest v) => v.lng;
  static const Field<CreateRescueRequest, double> _f$lng = Field(
    'lng',
    _$lng,
    opt: true,
  );
  static RescuePriority _$priority(CreateRescueRequest v) => v.priority;
  static const Field<CreateRescueRequest, RescuePriority> _f$priority = Field(
    'priority',
    _$priority,
  );
  static EmergencyType _$emergencyType(CreateRescueRequest v) =>
      v.emergencyType;
  static const Field<CreateRescueRequest, EmergencyType> _f$emergencyType =
      Field('emergencyType', _$emergencyType, key: r'emergency_type');
  static int? _$femaleCount(CreateRescueRequest v) => v.femaleCount;
  static const Field<CreateRescueRequest, int> _f$femaleCount = Field(
    'femaleCount',
    _$femaleCount,
    key: r'female_count',
    opt: true,
  );
  static int? _$maleCount(CreateRescueRequest v) => v.maleCount;
  static const Field<CreateRescueRequest, int> _f$maleCount = Field(
    'maleCount',
    _$maleCount,
    key: r'male_count',
    opt: true,
  );
  static String? _$contactPhone(CreateRescueRequest v) => v.contactPhone;
  static const Field<CreateRescueRequest, String> _f$contactPhone = Field(
    'contactPhone',
    _$contactPhone,
    key: r'contact_phone',
    opt: true,
  );
  static String? _$importantInformation(CreateRescueRequest v) =>
      v.importantInformation;
  static const Field<CreateRescueRequest, String> _f$importantInformation =
      Field(
        'importantInformation',
        _$importantInformation,
        key: r'important_information',
        opt: true,
      );
  static DateTime? _$scheduledFor(CreateRescueRequest v) => v.scheduledFor;
  static const Field<CreateRescueRequest, DateTime> _f$scheduledFor = Field(
    'scheduledFor',
    _$scheduledFor,
    key: r'scheduled_for',
    opt: true,
  );
  static String? _$user(CreateRescueRequest v) => v.user;
  static const Field<CreateRescueRequest, String> _f$user = Field(
    'user',
    _$user,
    opt: true,
  );
  static String _$email(CreateRescueRequest v) => v.email;
  static const Field<CreateRescueRequest, String> _f$email = Field(
    'email',
    _$email,
  );
  static List<XFile>? _$attachmentFiles(CreateRescueRequest v) =>
      v.attachmentFiles;
  static const Field<CreateRescueRequest, List<XFile>> _f$attachmentFiles =
      Field(
        'attachmentFiles',
        _$attachmentFiles,
        key: r'attachment_files',
        opt: true,
      );
  static Map<String, dynamic>? _$metadata(CreateRescueRequest v) => v.metadata;
  static const Field<CreateRescueRequest, Map<String, dynamic>> _f$metadata =
      Field('metadata', _$metadata, opt: true);

  @override
  final MappableFields<CreateRescueRequest> fields = const {
    #title: _f$title,
    #description: _f$description,
    #lat: _f$lat,
    #lng: _f$lng,
    #priority: _f$priority,
    #emergencyType: _f$emergencyType,
    #femaleCount: _f$femaleCount,
    #maleCount: _f$maleCount,
    #contactPhone: _f$contactPhone,
    #importantInformation: _f$importantInformation,
    #scheduledFor: _f$scheduledFor,
    #user: _f$user,
    #email: _f$email,
    #attachmentFiles: _f$attachmentFiles,
    #metadata: _f$metadata,
  };

  static CreateRescueRequest _instantiate(DecodingData data) {
    return CreateRescueRequest(
      title: data.dec(_f$title),
      description: data.dec(_f$description),
      lat: data.dec(_f$lat),
      lng: data.dec(_f$lng),
      priority: data.dec(_f$priority),
      emergencyType: data.dec(_f$emergencyType),
      femaleCount: data.dec(_f$femaleCount),
      maleCount: data.dec(_f$maleCount),
      contactPhone: data.dec(_f$contactPhone),
      importantInformation: data.dec(_f$importantInformation),
      scheduledFor: data.dec(_f$scheduledFor),
      user: data.dec(_f$user),
      email: data.dec(_f$email),
      attachmentFiles: data.dec(_f$attachmentFiles),
      metadata: data.dec(_f$metadata),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CreateRescueRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CreateRescueRequest>(map);
  }

  static CreateRescueRequest fromJson(String json) {
    return ensureInitialized().decodeJson<CreateRescueRequest>(json);
  }
}

mixin CreateRescueRequestMappable {
  String toJson() {
    return CreateRescueRequestMapper.ensureInitialized()
        .encodeJson<CreateRescueRequest>(this as CreateRescueRequest);
  }

  Map<String, dynamic> toMap() {
    return CreateRescueRequestMapper.ensureInitialized()
        .encodeMap<CreateRescueRequest>(this as CreateRescueRequest);
  }

  CreateRescueRequestCopyWith<
    CreateRescueRequest,
    CreateRescueRequest,
    CreateRescueRequest
  >
  get copyWith =>
      _CreateRescueRequestCopyWithImpl<
        CreateRescueRequest,
        CreateRescueRequest
      >(this as CreateRescueRequest, $identity, $identity);
  @override
  String toString() {
    return CreateRescueRequestMapper.ensureInitialized().stringifyValue(
      this as CreateRescueRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return CreateRescueRequestMapper.ensureInitialized().equalsValue(
      this as CreateRescueRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return CreateRescueRequestMapper.ensureInitialized().hashValue(
      this as CreateRescueRequest,
    );
  }
}

extension CreateRescueRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CreateRescueRequest, $Out> {
  CreateRescueRequestCopyWith<$R, CreateRescueRequest, $Out>
  get $asCreateRescueRequest => $base.as(
    (v, t, t2) => _CreateRescueRequestCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CreateRescueRequestCopyWith<
  $R,
  $In extends CreateRescueRequest,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, XFile, ObjectCopyWith<$R, XFile, XFile>>?
  get attachmentFiles;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get metadata;
  $R call({
    String? title,
    String? description,
    double? lat,
    double? lng,
    RescuePriority? priority,
    EmergencyType? emergencyType,
    int? femaleCount,
    int? maleCount,
    String? contactPhone,
    String? importantInformation,
    DateTime? scheduledFor,
    String? user,
    String? email,
    List<XFile>? attachmentFiles,
    Map<String, dynamic>? metadata,
  });
  CreateRescueRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CreateRescueRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CreateRescueRequest, $Out>
    implements CreateRescueRequestCopyWith<$R, CreateRescueRequest, $Out> {
  _CreateRescueRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CreateRescueRequest> $mapper =
      CreateRescueRequestMapper.ensureInitialized();
  @override
  ListCopyWith<$R, XFile, ObjectCopyWith<$R, XFile, XFile>>?
  get attachmentFiles => $value.attachmentFiles != null
      ? ListCopyWith(
          $value.attachmentFiles!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(attachmentFiles: v),
        )
      : null;
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get metadata => $value.metadata != null
      ? MapCopyWith(
          $value.metadata!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(metadata: v),
        )
      : null;
  @override
  $R call({
    String? title,
    Object? description = $none,
    Object? lat = $none,
    Object? lng = $none,
    RescuePriority? priority,
    EmergencyType? emergencyType,
    Object? femaleCount = $none,
    Object? maleCount = $none,
    Object? contactPhone = $none,
    Object? importantInformation = $none,
    Object? scheduledFor = $none,
    Object? user = $none,
    String? email,
    Object? attachmentFiles = $none,
    Object? metadata = $none,
  }) => $apply(
    FieldCopyWithData({
      if (title != null) #title: title,
      if (description != $none) #description: description,
      if (lat != $none) #lat: lat,
      if (lng != $none) #lng: lng,
      if (priority != null) #priority: priority,
      if (emergencyType != null) #emergencyType: emergencyType,
      if (femaleCount != $none) #femaleCount: femaleCount,
      if (maleCount != $none) #maleCount: maleCount,
      if (contactPhone != $none) #contactPhone: contactPhone,
      if (importantInformation != $none)
        #importantInformation: importantInformation,
      if (scheduledFor != $none) #scheduledFor: scheduledFor,
      if (user != $none) #user: user,
      if (email != null) #email: email,
      if (attachmentFiles != $none) #attachmentFiles: attachmentFiles,
      if (metadata != $none) #metadata: metadata,
    }),
  );
  @override
  CreateRescueRequest $make(CopyWithData data) => CreateRescueRequest(
    title: data.get(#title, or: $value.title),
    description: data.get(#description, or: $value.description),
    lat: data.get(#lat, or: $value.lat),
    lng: data.get(#lng, or: $value.lng),
    priority: data.get(#priority, or: $value.priority),
    emergencyType: data.get(#emergencyType, or: $value.emergencyType),
    femaleCount: data.get(#femaleCount, or: $value.femaleCount),
    maleCount: data.get(#maleCount, or: $value.maleCount),
    contactPhone: data.get(#contactPhone, or: $value.contactPhone),
    importantInformation: data.get(
      #importantInformation,
      or: $value.importantInformation,
    ),
    scheduledFor: data.get(#scheduledFor, or: $value.scheduledFor),
    user: data.get(#user, or: $value.user),
    email: data.get(#email, or: $value.email),
    attachmentFiles: data.get(#attachmentFiles, or: $value.attachmentFiles),
    metadata: data.get(#metadata, or: $value.metadata),
  );

  @override
  CreateRescueRequestCopyWith<$R2, CreateRescueRequest, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CreateRescueRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

