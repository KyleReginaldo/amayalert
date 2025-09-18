import 'dart:convert';

import 'package:amayalert/feature/weather/weather_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../core/result/result.dart';

class WeatherProvider {
  Future<Result<Weather>> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      'https://weather.googleapis.com/v1/forecast/days:lookup?key=${dotenv.get('WEATHER_API_KEY')}&location.latitude=$latitude&location.longitude=$longitude',
    );
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    debugPrint(data.toString());
    if (response.statusCode == 200) {
      return Result.success(WeatherMapper.fromMap(data));
    } else {
      return Result.error(
        'Can\'t get the current weather, please try again later.',
      );
    }
  }
}
