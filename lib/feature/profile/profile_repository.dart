import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/profile/profile_model.dart';
import 'package:flutter/material.dart';

import '../../core/dto/user.dto.dart';
import 'profile_provider.dart';

class ProfileRepository extends ChangeNotifier {
  final ProfileProvider provider;

  Profile? _profile;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Profile? get profile => _profile;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileRepository({required this.provider});

  Future<void> getUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await provider.getUserProfile(userId);
    if (result.isError) {
      _errorMessage = result.error;
      _isLoading = false;
      notifyListeners();
    } else {
      _profile = result.value;
      _isLoading = false;
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

  Future<Result<String>> requestPhoneChangeOtp({
    required String userId,
    required String newPhone,
  }) async {
    return await provider.requestPhoneChangeOtp(
      userId: userId,
      newPhone: newPhone,
    );
  }

  Future<Result<String>> verifyPhoneChangeOtp({
    required String userId,
    required String newPhone,
    required String code,
  }) async {
    return await provider.verifyPhoneChangeOtp(
      userId: userId,
      newPhone: newPhone,
      code: code,
    );
  }

  void clear() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }
}
