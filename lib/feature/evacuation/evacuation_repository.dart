// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:amayalert/feature/evacuation/evacuation_center_model.dart';
import 'package:amayalert/feature/evacuation/evacuation_provider.dart';
import 'package:flutter/material.dart';

class EvacuationRepository extends ChangeNotifier {
  List<EvacuationCenter> _centers = [];
  List<EvacuationCenter> get centers => _centers;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  EvacuationProvider provider;
  EvacuationRepository({required this.provider});
  void getEvacuationCenters() async {
    _isLoading = true;
    notifyListeners();
    final provider = EvacuationProvider();
    final result = await provider.getEvacuationCenters();
    if (result.isError) {
      _isLoading = false;
      _centers = [];
      notifyListeners();
    } else {
      _centers = result.value;
      _isLoading = false;
      notifyListeners();
    }
  }
}
