// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_mappable/dart_mappable.dart';

part 'profile_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Profile with ProfileMappable {
  final String id;
  final String fullName;
  final String email;
  final DateTime birthDate;
  final String gender;
  final String phoneNumber;
  final String role;
  final String? profilePicture;
  final String? idPicture;
  final String? deviceToken;

  Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.phoneNumber,
    required this.role,
    required this.profilePicture,
    required this.idPicture,
    this.deviceToken,
  });
}
