// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';

part 'profile_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Profile with ProfileMappable {
  final String id;
  final String fullName;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? suffix;
  final String email;
  final DateTime? birthDate;
  final String? gender;
  final String? phoneNumber;
  final String role;
  final String? profilePicture;
  final String? idPicture;
  final String? deviceToken;
  final bool suspended;
  final String? address;
  @MappableField(key: 'status')
  final String? userStatus;

  Profile({
    required this.id,
    required this.fullName,
    this.firstName,
    this.middleName,
    this.lastName,
    this.suffix,
    required this.email,
    this.birthDate,
    this.gender,
    this.phoneNumber,
    required this.role,
    this.profilePicture,
    this.idPicture,
    this.deviceToken,
    required this.suspended,
    this.address,
    this.userStatus,
  });

  /// Display name: uses name parts when available, falls back to fullName
  String get displayName {
    if (firstName != null || lastName != null) {
      final parts = [
        firstName ?? '',
        if (middleName != null && middleName!.isNotEmpty) middleName!,
        lastName ?? '',
        if (suffix != null && suffix!.isNotEmpty) suffix!,
      ].where((p) => p.isNotEmpty);
      return parts.join(' ');
    }
    return fullName;
  }
}
