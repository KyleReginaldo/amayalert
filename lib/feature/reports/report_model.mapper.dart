// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'report_model.dart';

class ReportMapper extends ClassMapperBase<Report> {
  ReportMapper._();

  static ReportMapper? _instance;
  static ReportMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ReportMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Report';

  static int _$id(Report v) => v.id;
  static const Field<Report, int> _f$id = Field('id', _$id);
  static String _$createdAt(Report v) => v.createdAt;
  static const Field<Report, String> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static int _$post(Report v) => v.post;
  static const Field<Report, int> _f$post = Field('post', _$post);
  static String _$reason(Report v) => v.reason;
  static const Field<Report, String> _f$reason = Field('reason', _$reason);
  static String _$reportedBy(Report v) => v.reportedBy;
  static const Field<Report, String> _f$reportedBy = Field(
    'reportedBy',
    _$reportedBy,
    key: r'reported_by',
  );

  @override
  final MappableFields<Report> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #post: _f$post,
    #reason: _f$reason,
    #reportedBy: _f$reportedBy,
  };

  static Report _instantiate(DecodingData data) {
    return Report(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      post: data.dec(_f$post),
      reason: data.dec(_f$reason),
      reportedBy: data.dec(_f$reportedBy),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Report fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Report>(map);
  }

  static Report fromJson(String json) {
    return ensureInitialized().decodeJson<Report>(json);
  }
}

mixin ReportMappable {
  String toJson() {
    return ReportMapper.ensureInitialized().encodeJson<Report>(this as Report);
  }

  Map<String, dynamic> toMap() {
    return ReportMapper.ensureInitialized().encodeMap<Report>(this as Report);
  }

  ReportCopyWith<Report, Report, Report> get copyWith =>
      _ReportCopyWithImpl<Report, Report>(this as Report, $identity, $identity);
  @override
  String toString() {
    return ReportMapper.ensureInitialized().stringifyValue(this as Report);
  }

  @override
  bool operator ==(Object other) {
    return ReportMapper.ensureInitialized().equalsValue(this as Report, other);
  }

  @override
  int get hashCode {
    return ReportMapper.ensureInitialized().hashValue(this as Report);
  }
}

extension ReportValueCopy<$R, $Out> on ObjectCopyWith<$R, Report, $Out> {
  ReportCopyWith<$R, Report, $Out> get $asReport =>
      $base.as((v, t, t2) => _ReportCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ReportCopyWith<$R, $In extends Report, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    String? createdAt,
    int? post,
    String? reason,
    String? reportedBy,
  });
  ReportCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ReportCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Report, $Out>
    implements ReportCopyWith<$R, Report, $Out> {
  _ReportCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Report> $mapper = ReportMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    String? createdAt,
    int? post,
    String? reason,
    String? reportedBy,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (post != null) #post: post,
      if (reason != null) #reason: reason,
      if (reportedBy != null) #reportedBy: reportedBy,
    }),
  );
  @override
  Report $make(CopyWithData data) => Report(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    post: data.get(#post, or: $value.post),
    reason: data.get(#reason, or: $value.reason),
    reportedBy: data.get(#reportedBy, or: $value.reportedBy),
  );

  @override
  ReportCopyWith<$R2, Report, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ReportCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CreateReportRequestMapper extends ClassMapperBase<CreateReportRequest> {
  CreateReportRequestMapper._();

  static CreateReportRequestMapper? _instance;
  static CreateReportRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CreateReportRequestMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CreateReportRequest';

  static int _$post(CreateReportRequest v) => v.post;
  static const Field<CreateReportRequest, int> _f$post = Field('post', _$post);
  static String _$reason(CreateReportRequest v) => v.reason;
  static const Field<CreateReportRequest, String> _f$reason = Field(
    'reason',
    _$reason,
  );
  static String _$reportedBy(CreateReportRequest v) => v.reportedBy;
  static const Field<CreateReportRequest, String> _f$reportedBy = Field(
    'reportedBy',
    _$reportedBy,
    key: r'reported_by',
  );

  @override
  final MappableFields<CreateReportRequest> fields = const {
    #post: _f$post,
    #reason: _f$reason,
    #reportedBy: _f$reportedBy,
  };

  static CreateReportRequest _instantiate(DecodingData data) {
    return CreateReportRequest(
      post: data.dec(_f$post),
      reason: data.dec(_f$reason),
      reportedBy: data.dec(_f$reportedBy),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CreateReportRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CreateReportRequest>(map);
  }

  static CreateReportRequest fromJson(String json) {
    return ensureInitialized().decodeJson<CreateReportRequest>(json);
  }
}

mixin CreateReportRequestMappable {
  String toJson() {
    return CreateReportRequestMapper.ensureInitialized()
        .encodeJson<CreateReportRequest>(this as CreateReportRequest);
  }

  Map<String, dynamic> toMap() {
    return CreateReportRequestMapper.ensureInitialized()
        .encodeMap<CreateReportRequest>(this as CreateReportRequest);
  }

  CreateReportRequestCopyWith<
    CreateReportRequest,
    CreateReportRequest,
    CreateReportRequest
  >
  get copyWith =>
      _CreateReportRequestCopyWithImpl<
        CreateReportRequest,
        CreateReportRequest
      >(this as CreateReportRequest, $identity, $identity);
  @override
  String toString() {
    return CreateReportRequestMapper.ensureInitialized().stringifyValue(
      this as CreateReportRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return CreateReportRequestMapper.ensureInitialized().equalsValue(
      this as CreateReportRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return CreateReportRequestMapper.ensureInitialized().hashValue(
      this as CreateReportRequest,
    );
  }
}

extension CreateReportRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CreateReportRequest, $Out> {
  CreateReportRequestCopyWith<$R, CreateReportRequest, $Out>
  get $asCreateReportRequest => $base.as(
    (v, t, t2) => _CreateReportRequestCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CreateReportRequestCopyWith<
  $R,
  $In extends CreateReportRequest,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? post, String? reason, String? reportedBy});
  CreateReportRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CreateReportRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CreateReportRequest, $Out>
    implements CreateReportRequestCopyWith<$R, CreateReportRequest, $Out> {
  _CreateReportRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CreateReportRequest> $mapper =
      CreateReportRequestMapper.ensureInitialized();
  @override
  $R call({int? post, String? reason, String? reportedBy}) => $apply(
    FieldCopyWithData({
      if (post != null) #post: post,
      if (reason != null) #reason: reason,
      if (reportedBy != null) #reportedBy: reportedBy,
    }),
  );
  @override
  CreateReportRequest $make(CopyWithData data) => CreateReportRequest(
    post: data.get(#post, or: $value.post),
    reason: data.get(#reason, or: $value.reason),
    reportedBy: data.get(#reportedBy, or: $value.reportedBy),
  );

  @override
  CreateReportRequestCopyWith<$R2, CreateReportRequest, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CreateReportRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

