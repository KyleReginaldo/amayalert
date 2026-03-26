import 'package:image_picker/image_picker.dart';

class CreateUserDTO {
  final String fullName;
  final String email;
  final String password;
  final String gender;
  final DateTime birthDate;
  final String phoneNumber;
  final String address;

  CreateUserDTO({
    required this.fullName,
    required this.email,
    required this.password,
    required this.gender,
    required this.birthDate,
    required this.phoneNumber,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
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
  final String? fullName;
  final String? gender;
  final DateTime? birthDate;
  final XFile? imageFile;
  final String? address;

  UpdateUserDTO({
    required this.fullName,
    required this.gender,
    required this.birthDate,
    required this.imageFile,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'full_name': fullName,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String(),
      if (address != null) 'address': address,
    };
  }
}
