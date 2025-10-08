// ignore_for_file: public_member_api_docs, sort_constructors_first
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: isLoading
          ? Center(child: CircularProgressIndicator.adaptive())
          : errorMessage != null
          ? CustomText(text: errorMessage!)
          : weather != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Weather forecast'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: weather!.forecastDays.map((forecast) {
                      final date =
                          "${forecast.displayDate.month}/${forecast.displayDate.day}";
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        width: MediaQuery.sizeOf(context).width * 0.32,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
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
                            CustomText(
                              text: date,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            SizedBox(height: 8),
                            CachedNetworkImage(
                              imageUrl:
                                  '${forecast.daytimeForecast.weatherCondition.iconBaseUri}.png',
                              height: 40,
                              width: 40,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  text:
                                      "${forecast.maxTemperature.degrees.toStringAsFixed(0)}°",
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(width: 4),
                                CustomText(
                                  text:
                                      "${forecast.minTemperature.degrees.toStringAsFixed(0)}°",
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
