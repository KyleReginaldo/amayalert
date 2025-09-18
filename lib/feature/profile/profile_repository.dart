import 'package:amayalert/feature/profile/profile_model.dart';
import 'package:flutter/material.dart';

import '../../core/dto/user.dto.dart';
import 'profile_provider.dart';

class ProfileRepository extends ChangeNotifier {
  final ProfileProvider provider;

  Profile? _profile;
  Profile? get profile => _profile;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileRepository({required this.provider});

  Future<void> getUserProfile(String userId) async {
    final result = await provider.getUserProfile(userId);
    if (result.isError) {
      _errorMessage = result.error;
      notifyListeners();
    } else {
      _profile = result.value;
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile({
    required String userId,
    required UpdateUserDTO dto,
  }) async {
    final result = await provider.updateUserProfile(userId: userId, dto: dto);

    if (result.isError) {
      _errorMessage = result.error;
      notifyListeners();
      return false;
    } else {
      // Refresh the profile to get updated data
      await getUserProfile(userId);
      return true;
    }
  }

  void clear() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }
}
