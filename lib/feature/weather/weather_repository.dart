import 'package:amayalert/feature/weather/weather_model.dart';
import 'package:amayalert/feature/weather/weather_provider.dart';
import 'package:flutter/material.dart';

class WeatherRepository extends ChangeNotifier {
  Weather? _weather;
  String? _errorMessage;
  bool _isLoading = false;
  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  final WeatherProvider provider;

  WeatherRepository({required this.provider});

  void getWeather({required double latitude, required double longitude}) async {
    _isLoading = true;
    notifyListeners();
    final result = await provider.getWeather(
      latitude: latitude,
      longitude: longitude,
    );
    if (result.isError) {
      _isLoading = false;
      _errorMessage = result.error;
      notifyListeners();
    } else {
      _isLoading = false;
      _weather = result.value;
      notifyListeners();
    }
  }
}
