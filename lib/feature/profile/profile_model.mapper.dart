// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'profile_model.dart';

class ProfileMapper extends ClassMapperBase<Profile> {
  ProfileMapper._();

  static ProfileMapper? _instance;
  static ProfileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProfileMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Profile';

  static String _$id(Profile v) => v.id;
  static const Field<Profile, String> _f$id = Field('id', _$id);
  static String _$fullName(Profile v) => v.fullName;
  static const Field<Profile, String> _f$fullName = Field(
    'fullName',
    _$fullName,
    key: r'full_name',
  );
  static String _$email(Profile v) => v.email;
  static const Field<Profile, String> _f$email = Field('email', _$email);
  static DateTime _$birthDate(Profile v) => v.birthDate;
  static const Field<Profile, DateTime> _f$birthDate = Field(
    'birthDate',
    _$birthDate,
    key: r'birth_date',
  );
  static String _$gender(Profile v) => v.gender;
  static const Field<Profile, String> _f$gender = Field('gender', _$gender);
  static String _$phoneNumber(Profile v) => v.phoneNumber;
  static const Field<Profile, String> _f$phoneNumber = Field(
    'phoneNumber',
    _$phoneNumber,
    key: r'phone_number',
  );
  static String _$role(Profile v) => v.role;
  static const Field<Profile, String> _f$role = Field('role', _$role);
  static String? _$profilePicture(Profile v) => v.profilePicture;
  static const Field<Profile, String> _f$profilePicture = Field(
    'profilePicture',
    _$profilePicture,
    key: r'profile_picture',
  );
  static String? _$idPicture(Profile v) => v.idPicture;
  static const Field<Profile, String> _f$idPicture = Field(
    'idPicture',
    _$idPicture,
    key: r'id_picture',
  );
  static String? _$deviceToken(Profile v) => v.deviceToken;
  static const Field<Profile, String> _f$deviceToken = Field(
    'deviceToken',
    _$deviceToken,
    key: r'device_token',
    opt: true,
  );

  @override
  final MappableFields<Profile> fields = const {
    #id: _f$id,
    #fullName: _f$fullName,
    #email: _f$email,
    #birthDate: _f$birthDate,
    #gender: _f$gender,
    #phoneNumber: _f$phoneNumber,
    #role: _f$role,
    #profilePicture: _f$profilePicture,
    #idPicture: _f$idPicture,
    #deviceToken: _f$deviceToken,
  };

  static Profile _instantiate(DecodingData data) {
    return Profile(
      id: data.dec(_f$id),
      fullName: data.dec(_f$fullName),
      email: data.dec(_f$email),
      birthDate: data.dec(_f$birthDate),
      gender: data.dec(_f$gender),
      phoneNumber: data.dec(_f$phoneNumber),
      role: data.dec(_f$role),
      profilePicture: data.dec(_f$profilePicture),
      idPicture: data.dec(_f$idPicture),
      deviceToken: data.dec(_f$deviceToken),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Profile fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Profile>(map);
  }

  static Profile fromJson(String json) {
    return ensureInitialized().decodeJson<Profile>(json);
  }
}

mixin ProfileMappable {
  String toJson() {
    return ProfileMapper.ensureInitialized().encodeJson<Profile>(
      this as Profile,
    );
  }

  Map<String, dynamic> toMap() {
    return ProfileMapper.ensureInitialized().encodeMap<Profile>(
      this as Profile,
    );
  }

  ProfileCopyWith<Profile, Profile, Profile> get copyWith =>
      _ProfileCopyWithImpl<Profile, Profile>(
        this as Profile,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProfileMapper.ensureInitialized().stringifyValue(this as Profile);
  }

  @override
  bool operator ==(Object other) {
    return ProfileMapper.ensureInitialized().equalsValue(
      this as Profile,
      other,
    );
  }

  @override
  int get hashCode {
    return ProfileMapper.ensureInitialized().hashValue(this as Profile);
  }
}

extension ProfileValueCopy<$R, $Out> on ObjectCopyWith<$R, Profile, $Out> {
  ProfileCopyWith<$R, Profile, $Out> get $asProfile =>
      $base.as((v, t, t2) => _ProfileCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProfileCopyWith<$R, $In extends Profile, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? fullName,
    String? email,
    DateTime? birthDate,
    String? gender,
    String? phoneNumber,
    String? role,
    String? profilePicture,
    String? idPicture,
    String? deviceToken,
  });
  ProfileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProfileCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Profile, $Out>
    implements ProfileCopyWith<$R, Profile, $Out> {
  _ProfileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Profile> $mapper =
      ProfileMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? fullName,
    String? email,
    DateTime? birthDate,
    String? gender,
    String? phoneNumber,
    String? role,
    Object? profilePicture = $none,
    Object? idPicture = $none,
    Object? deviceToken = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (fullName != null) #fullName: fullName,
      if (email != null) #email: email,
      if (birthDate != null) #birthDate: birthDate,
      if (gender != null) #gender: gender,
      if (phoneNumber != null) #phoneNumber: phoneNumber,
      if (role != null) #role: role,
      if (profilePicture != $none) #profilePicture: profilePicture,
      if (idPicture != $none) #idPicture: idPicture,
      if (deviceToken != $none) #deviceToken: deviceToken,
    }),
  );
  @override
  Profile $make(CopyWithData data) => Profile(
    id: data.get(#id, or: $value.id),
    fullName: data.get(#fullName, or: $value.fullName),
    email: data.get(#email, or: $value.email),
    birthDate: data.get(#birthDate, or: $value.birthDate),
    gender: data.get(#gender, or: $value.gender),
    phoneNumber: data.get(#phoneNumber, or: $value.phoneNumber),
    role: data.get(#role, or: $value.role),
    profilePicture: data.get(#profilePicture, or: $value.profilePicture),
    idPicture: data.get(#idPicture, or: $value.idPicture),
    deviceToken: data.get(#deviceToken, or: $value.deviceToken),
  );

  @override
  ProfileCopyWith<$R2, Profile, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ProfileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

