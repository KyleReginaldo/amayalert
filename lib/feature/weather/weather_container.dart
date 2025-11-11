// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:amayalert/core/utils/helper.dart';
import 'package:amayalert/feature/weather/weather_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/text/custom_text.dart';

class WeatherContainer extends StatelessWidget {
  final String? errorMessage;
  final bool isLoading;
  final Weather? weather;
  const WeatherContainer({
    super.key,
    this.errorMessage,
    required this.isLoading,
    this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: isLoading
          ? Center(child: CircularProgressIndicator.adaptive())
          : errorMessage != null
          ? CustomText(text: errorMessage!)
          : weather != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: CustomText(
                    text: 'Weather forecast',
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: weather!.forecastDays.map((forecast) {
                        final date =
                            "${forecast.displayDate.month}/${forecast.displayDate.day}";
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          width: MediaQuery.sizeOf(context).width * 0.32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 8),
                                width: MediaQuery.sizeOf(context).width * 0.32,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                ),
                                child: CustomText(
                                  text: getWeekdayName(
                                    int.parse(date.split('/').last),
                                  ),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),

                              CustomText(
                                text:
                                    "${forecast.maxTemperature.degrees.toStringAsFixed(0)}°",
                                fontWeight: FontWeight.w500,
                                fontSize: 32,
                              ),
                              SizedBox(height: 8),
                              CachedNetworkImage(
                                imageUrl:
                                    '${forecast.daytimeForecast.weatherCondition.iconBaseUri}.png',
                                height: 24,
                                width: 24,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 8),
                              CustomText(
                                text: forecast
                                    .daytimeForecast
                                    .weatherCondition
                                    .description
                                    .text,
                                maxLines: 2,
                                fontSize: 12,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
