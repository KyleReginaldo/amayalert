import 'package:dart_mappable/dart_mappable.dart';

part 'weather_model.mapper.dart';

@MappableClass(caseStyle: CaseStyle.camelCase)
class Weather with WeatherMappable {
  final List<ForecastDay> forecastDays;
  final TimeZone timeZone;
  final String? nextPageToken;

  const Weather({
    required this.forecastDays,
    required this.timeZone,
    this.nextPageToken,
  });
}

@MappableClass()
class ForecastDay with ForecastDayMappable {
  final Interval interval;
  final DisplayDate displayDate;
  final Forecast daytimeForecast;
  final Forecast nighttimeForecast;
  final Temperature maxTemperature;
  final Temperature minTemperature;
  final Temperature feelsLikeMaxTemperature;
  final Temperature feelsLikeMinTemperature;
  final SunEvents sunEvents;
  final MoonEvents moonEvents;
  final Temperature maxHeatIndex;

  const ForecastDay({
    required this.interval,
    required this.displayDate,
    required this.daytimeForecast,
    required this.nighttimeForecast,
    required this.maxTemperature,
    required this.minTemperature,
    required this.feelsLikeMaxTemperature,
    required this.feelsLikeMinTemperature,
    required this.sunEvents,
    required this.moonEvents,
    required this.maxHeatIndex,
  });
}

@MappableClass()
class Forecast with ForecastMappable {
  final Interval interval;
  final WeatherCondition weatherCondition;
  final int relativeHumidity;
  final int uvIndex;
  final Precipitation precipitation;
  final int thunderstormProbability;
  final Wind wind;
  final int cloudCover;
  final IceThickness iceThickness;

  const Forecast({
    required this.interval,
    required this.weatherCondition,
    required this.relativeHumidity,
    required this.uvIndex,
    required this.precipitation,
    required this.thunderstormProbability,
    required this.wind,
    required this.cloudCover,
    required this.iceThickness,
  });
}

@MappableClass()
class Interval with IntervalMappable {
  final DateTime startTime;
  final DateTime endTime;

  const Interval({required this.startTime, required this.endTime});
}

@MappableClass()
class DisplayDate with DisplayDateMappable {
  final int year;
  final int month;
  final int day;

  const DisplayDate({
    required this.year,
    required this.month,
    required this.day,
  });
}

@MappableClass()
class WeatherCondition with WeatherConditionMappable {
  final String iconBaseUri;
  final Description description;
  final String type;

  const WeatherCondition({
    required this.iconBaseUri,
    required this.description,
    required this.type,
  });
}

@MappableClass()
class Description with DescriptionMappable {
  final String text;
  final String languageCode;

  const Description({required this.text, required this.languageCode});
}

@MappableClass()
class Precipitation with PrecipitationMappable {
  final Probability probability;
  final Quantity snowQpf;
  final Quantity qpf;

  const Precipitation({
    required this.probability,
    required this.snowQpf,
    required this.qpf,
  });
}

@MappableClass()
class Probability with ProbabilityMappable {
  final int percent;
  final String type;

  const Probability({required this.percent, required this.type});
}

@MappableClass()
class Quantity with QuantityMappable {
  final double quantity;
  final String unit;

  const Quantity({required this.quantity, required this.unit});
}

@MappableClass()
class Wind with WindMappable {
  final WindDirection direction;
  final WindSpeed speed;
  final WindSpeed gust;

  const Wind({
    required this.direction,
    required this.speed,
    required this.gust,
  });
}

@MappableClass()
class WindDirection with WindDirectionMappable {
  final int degrees;
  final String cardinal;

  const WindDirection({required this.degrees, required this.cardinal});
}

@MappableClass()
class WindSpeed with WindSpeedMappable {
  final double value;
  final String unit;

  const WindSpeed({required this.value, required this.unit});
}

@MappableClass()
class IceThickness with IceThicknessMappable {
  final double thickness;
  final String unit;

  const IceThickness({required this.thickness, required this.unit});
}

@MappableClass()
class Temperature with TemperatureMappable {
  final double degrees;
  final String unit;

  const Temperature({required this.degrees, required this.unit});
}

@MappableClass()
class SunEvents with SunEventsMappable {
  final DateTime sunriseTime;
  final DateTime sunsetTime;

  const SunEvents({required this.sunriseTime, required this.sunsetTime});
}

@MappableClass()
class MoonEvents with MoonEventsMappable {
  final String moonPhase;
  final List<DateTime> moonriseTimes;
  final List<DateTime> moonsetTimes;

  const MoonEvents({
    required this.moonPhase,
    required this.moonriseTimes,
    required this.moonsetTimes,
  });
}

@MappableClass()
class TimeZone with TimeZoneMappable {
  final String id;

  const TimeZone({required this.id});
}
