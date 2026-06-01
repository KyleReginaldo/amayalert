import 'package:image_picker/image_picker.dart';

class CreateUserDTO {
  final String firstName;
  final String middleName;
  final String lastName;
  final String? suffix;
  final String email;
  final String password;
  final String gender;
  final DateTime birthDate;
  final String phoneNumber;
  final String address;

  CreateUserDTO({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    this.suffix,
    required this.email,
    required this.password,
    required this.gender,
    required this.birthDate,
    required this.phoneNumber,
    required this.address,
  });

  /// Composed full name: "Juan Dela Cruz Jr."
  String get fullName {
    final parts = [
      firstName.trim(),
      if (middleName.trim().isNotEmpty) middleName.trim(),
      lastName.trim(),
      if (suffix != null && suffix!.trim().isNotEmpty) suffix!.trim(),
    ];
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'first_name': firstName.trim(),
      if (middleName.trim().isNotEmpty) 'middle_name': middleName.trim(),
      'last_name': lastName.trim(),
      if (suffix != null && suffix!.trim().isNotEmpty) 'suffix': suffix!.trim(),
      'email': email,
      'gender': gender,
      'birth_date': birthDate.toIso8601String(),
      'phone_number': phoneNumber,
      'address': address,
      'role': 'user',
    };
  }
}

class UpdateUserDTO {
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? suffix;
  final String? gender;
  final DateTime? birthDate;
  final XFile? imageFile;
  final String? address;

  UpdateUserDTO({
    this.firstName,
    this.middleName,
    this.lastName,
    this.suffix,
    this.gender,
    this.birthDate,
    this.imageFile,
    this.address,
  });

  String? get fullName {
    if (firstName == null && lastName == null) return null;
    final parts = [
      if (firstName != null) firstName!.trim(),
      if (middleName != null && middleName!.trim().isNotEmpty)
        middleName!.trim(),
      if (lastName != null) lastName!.trim(),
      if (suffix != null && suffix!.trim().isNotEmpty) suffix!.trim(),
    ].where((p) => p.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'full_name': fullName,
      if (firstName != null) 'first_name': firstName!.trim(),
      if (middleName != null) 'middle_name': middleName!.trim(),
      if (lastName != null) 'last_name': lastName!.trim(),
      if (suffix != null) 'suffix': suffix!.trim(),
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String(),
      if (address != null) 'address': address,
    };
  }
}
