// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'weather_model.dart';

class WeatherMapper extends ClassMapperBase<Weather> {
  WeatherMapper._();

  static WeatherMapper? _instance;
  static WeatherMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WeatherMapper._());
      ForecastDayMapper.ensureInitialized();
      TimeZoneMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Weather';

  static List<ForecastDay> _$forecastDays(Weather v) => v.forecastDays;
  static const Field<Weather, List<ForecastDay>> _f$forecastDays = Field(
    'forecastDays',
    _$forecastDays,
  );
  static TimeZone _$timeZone(Weather v) => v.timeZone;
  static const Field<Weather, TimeZone> _f$timeZone = Field(
    'timeZone',
    _$timeZone,
  );
  static String? _$nextPageToken(Weather v) => v.nextPageToken;
  static const Field<Weather, String> _f$nextPageToken = Field(
    'nextPageToken',
    _$nextPageToken,
    opt: true,
  );

  @override
  final MappableFields<Weather> fields = const {
    #forecastDays: _f$forecastDays,
    #timeZone: _f$timeZone,
    #nextPageToken: _f$nextPageToken,
  };

  static Weather _instantiate(DecodingData data) {
    return Weather(
      forecastDays: data.dec(_f$forecastDays),
      timeZone: data.dec(_f$timeZone),
      nextPageToken: data.dec(_f$nextPageToken),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Weather fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Weather>(map);
  }

  static Weather fromJson(String json) {
    return ensureInitialized().decodeJson<Weather>(json);
  }
}

mixin WeatherMappable {
  String toJson() {
    return WeatherMapper.ensureInitialized().encodeJson<Weather>(
      this as Weather,
    );
  }

  Map<String, dynamic> toMap() {
    return WeatherMapper.ensureInitialized().encodeMap<Weather>(
      this as Weather,
    );
  }

  WeatherCopyWith<Weather, Weather, Weather> get copyWith =>
      _WeatherCopyWithImpl<Weather, Weather>(
        this as Weather,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return WeatherMapper.ensureInitialized().stringifyValue(this as Weather);
  }

  @override
  bool operator ==(Object other) {
    return WeatherMapper.ensureInitialized().equalsValue(
      this as Weather,
      other,
    );
  }

  @override
  int get hashCode {
    return WeatherMapper.ensureInitialized().hashValue(this as Weather);
  }
}

extension WeatherValueCopy<$R, $Out> on ObjectCopyWith<$R, Weather, $Out> {
  WeatherCopyWith<$R, Weather, $Out> get $asWeather =>
      $base.as((v, t, t2) => _WeatherCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WeatherCopyWith<$R, $In extends Weather, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    ForecastDay,
    ForecastDayCopyWith<$R, ForecastDay, ForecastDay>
  >
  get forecastDays;
  TimeZoneCopyWith<$R, TimeZone, TimeZone> get timeZone;
  $R call({
    List<ForecastDay>? forecastDays,
    TimeZone? timeZone,
    String? nextPageToken,
  });
  WeatherCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WeatherCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Weather, $Out>
    implements WeatherCopyWith<$R, Weather, $Out> {
  _WeatherCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Weather> $mapper =
      WeatherMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    ForecastDay,
    ForecastDayCopyWith<$R, ForecastDay, ForecastDay>
  >
  get forecastDays => ListCopyWith(
    $value.forecastDays,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(forecastDays: v),
  );
  @override
  TimeZoneCopyWith<$R, TimeZone, TimeZone> get timeZone =>
      $value.timeZone.copyWith.$chain((v) => call(timeZone: v));
  @override
  $R call({
    List<ForecastDay>? forecastDays,
    TimeZone? timeZone,
    Object? nextPageToken = $none,
  }) => $apply(
    FieldCopyWithData({
      if (forecastDays != null) #forecastDays: forecastDays,
      if (timeZone != null) #timeZone: timeZone,
      if (nextPageToken != $none) #nextPageToken: nextPageToken,
    }),
  );
  @override
  Weather $make(CopyWithData data) => Weather(
    forecastDays: data.get(#forecastDays, or: $value.forecastDays),
    timeZone: data.get(#timeZone, or: $value.timeZone),
    nextPageToken: data.get(#nextPageToken, or: $value.nextPageToken),
  );

  @override
  WeatherCopyWith<$R2, Weather, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _WeatherCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ForecastDayMapper extends ClassMapperBase<ForecastDay> {
  ForecastDayMapper._();

  static ForecastDayMapper? _instance;
  static ForecastDayMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ForecastDayMapper._());
      IntervalMapper.ensureInitialized();
      DisplayDateMapper.ensureInitialized();
      ForecastMapper.ensureInitialized();
      TemperatureMapper.ensureInitialized();
      SunEventsMapper.ensureInitialized();
      MoonEventsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ForecastDay';

  static Interval _$interval(ForecastDay v) => v.interval;
  static const Field<ForecastDay, Interval> _f$interval = Field(
    'interval',
    _$interval,
  );
  static DisplayDate _$displayDate(ForecastDay v) => v.displayDate;
  static const Field<ForecastDay, DisplayDate> _f$displayDate = Field(
    'displayDate',
    _$displayDate,
  );
  static Forecast _$daytimeForecast(ForecastDay v) => v.daytimeForecast;
  static const Field<ForecastDay, Forecast> _f$daytimeForecast = Field(
    'daytimeForecast',
    _$daytimeForecast,
  );
  static Forecast _$nighttimeForecast(ForecastDay v) => v.nighttimeForecast;
  static const Field<ForecastDay, Forecast> _f$nighttimeForecast = Field(
    'nighttimeForecast',
    _$nighttimeForecast,
  );
  static Temperature _$maxTemperature(ForecastDay v) => v.maxTemperature;
  static const Field<ForecastDay, Temperature> _f$maxTemperature = Field(
    'maxTemperature',
    _$maxTemperature,
  );
  static Temperature _$minTemperature(ForecastDay v) => v.minTemperature;
  static const Field<ForecastDay, Temperature> _f$minTemperature = Field(
    'minTemperature',
    _$minTemperature,
  );
  static Temperature _$feelsLikeMaxTemperature(ForecastDay v) =>
      v.feelsLikeMaxTemperature;
  static const Field<ForecastDay, Temperature> _f$feelsLikeMaxTemperature =
      Field('feelsLikeMaxTemperature', _$feelsLikeMaxTemperature);
  static Temperature _$feelsLikeMinTemperature(ForecastDay v) =>
      v.feelsLikeMinTemperature;
  static const Field<ForecastDay, Temperature> _f$feelsLikeMinTemperature =
      Field('feelsLikeMinTemperature', _$feelsLikeMinTemperature);
  static SunEvents _$sunEvents(ForecastDay v) => v.sunEvents;
  static const Field<ForecastDay, SunEvents> _f$sunEvents = Field(
    'sunEvents',
    _$sunEvents,
  );
  static MoonEvents _$moonEvents(ForecastDay v) => v.moonEvents;
  static const Field<ForecastDay, MoonEvents> _f$moonEvents = Field(
    'moonEvents',
    _$moonEvents,
  );
  static Temperature _$maxHeatIndex(ForecastDay v) => v.maxHeatIndex;
  static const Field<ForecastDay, Temperature> _f$maxHeatIndex = Field(
    'maxHeatIndex',
    _$maxHeatIndex,
  );

  @override
  final MappableFields<ForecastDay> fields = const {
    #interval: _f$interval,
    #displayDate: _f$displayDate,
    #daytimeForecast: _f$daytimeForecast,
    #nighttimeForecast: _f$nighttimeForecast,
    #maxTemperature: _f$maxTemperature,
    #minTemperature: _f$minTemperature,
    #feelsLikeMaxTemperature: _f$feelsLikeMaxTemperature,
    #feelsLikeMinTemperature: _f$feelsLikeMinTemperature,
    #sunEvents: _f$sunEvents,
    #moonEvents: _f$moonEvents,
    #maxHeatIndex: _f$maxHeatIndex,
  };

  static ForecastDay _instantiate(DecodingData data) {
    return ForecastDay(
      interval: data.dec(_f$interval),
      displayDate: data.dec(_f$displayDate),
      daytimeForecast: data.dec(_f$daytimeForecast),
      nighttimeForecast: data.dec(_f$nighttimeForecast),
      maxTemperature: data.dec(_f$maxTemperature),
      minTemperature: data.dec(_f$minTemperature),
      feelsLikeMaxTemperature: data.dec(_f$feelsLikeMaxTemperature),
      feelsLikeMinTemperature: data.dec(_f$feelsLikeMinTemperature),
      sunEvents: data.dec(_f$sunEvents),
      moonEvents: data.dec(_f$moonEvents),
      maxHeatIndex: data.dec(_f$maxHeatIndex),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ForecastDay fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ForecastDay>(map);
  }

  static ForecastDay fromJson(String json) {
    return ensureInitialized().decodeJson<ForecastDay>(json);
  }
}

mixin ForecastDayMappable {
  String toJson() {
    return ForecastDayMapper.ensureInitialized().encodeJson<ForecastDay>(
      this as ForecastDay,
    );
  }

  Map<String, dynamic> toMap() {
    return ForecastDayMapper.ensureInitialized().encodeMap<ForecastDay>(
      this as ForecastDay,
    );
  }

  ForecastDayCopyWith<ForecastDay, ForecastDay, ForecastDay> get copyWith =>
      _ForecastDayCopyWithImpl<ForecastDay, ForecastDay>(
        this as ForecastDay,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ForecastDayMapper.ensureInitialized().stringifyValue(
      this as ForecastDay,
    );
  }

  @override
  bool operator ==(Object other) {
    return ForecastDayMapper.ensureInitialized().equalsValue(
      this as ForecastDay,
      other,
    );
  }

  @override
  int get hashCode {
    return ForecastDayMapper.ensureInitialized().hashValue(this as ForecastDay);
  }
}

extension ForecastDayValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ForecastDay, $Out> {
  ForecastDayCopyWith<$R, ForecastDay, $Out> get $asForecastDay =>
      $base.as((v, t, t2) => _ForecastDayCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ForecastDayCopyWith<$R, $In extends ForecastDay, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  IntervalCopyWith<$R, Interval, Interval> get interval;
  DisplayDateCopyWith<$R, DisplayDate, DisplayDate> get displayDate;
  ForecastCopyWith<$R, Forecast, Forecast> get daytimeForecast;
  ForecastCopyWith<$R, Forecast, Forecast> get nighttimeForecast;
  TemperatureCopyWith<$R, Temperature, Temperature> get maxTemperature;
  TemperatureCopyWith<$R, Temperature, Temperature> get minTemperature;
  TemperatureCopyWith<$R, Temperature, Temperature> get feelsLikeMaxTemperature;
  TemperatureCopyWith<$R, Temperature, Temperature> get feelsLikeMinTemperature;
  SunEventsCopyWith<$R, SunEvents, SunEvents> get sunEvents;
  MoonEventsCopyWith<$R, MoonEvents, MoonEvents> get moonEvents;
  TemperatureCopyWith<$R, Temperature, Temperature> get maxHeatIndex;
  $R call({
    Interval? interval,
    DisplayDate? displayDate,
    Forecast? daytimeForecast,
    Forecast? nighttimeForecast,
    Temperature? maxTemperature,
    Temperature? minTemperature,
    Temperature? feelsLikeMaxTemperature,
    Temperature? feelsLikeMinTemperature,
    SunEvents? sunEvents,
    MoonEvents? moonEvents,
    Temperature? maxHeatIndex,
  });
  ForecastDayCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ForecastDayCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ForecastDay, $Out>
    implements ForecastDayCopyWith<$R, ForecastDay, $Out> {
  _ForecastDayCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ForecastDay> $mapper =
      ForecastDayMapper.ensureInitialized();
  @override
  IntervalCopyWith<$R, Interval, Interval> get interval =>
      $value.interval.copyWith.$chain((v) => call(interval: v));
  @override
  DisplayDateCopyWith<$R, DisplayDate, DisplayDate> get displayDate =>
      $value.displayDate.copyWith.$chain((v) => call(displayDate: v));
  @override
  ForecastCopyWith<$R, Forecast, Forecast> get daytimeForecast =>
      $value.daytimeForecast.copyWith.$chain((v) => call(daytimeForecast: v));
  @override
  ForecastCopyWith<$R, Forecast, Forecast> get nighttimeForecast => $value
      .nighttimeForecast
      .copyWith
      .$chain((v) => call(nighttimeForecast: v));
  @override
  TemperatureCopyWith<$R, Temperature, Temperature> get maxTemperature =>
      $value.maxTemperature.copyWith.$chain((v) => call(maxTemperature: v));
  @override
  TemperatureCopyWith<$R, Temperature, Temperature> get minTemperature =>
      $value.minTemperature.copyWith.$chain((v) => call(minTemperature: v));
  @override
  TemperatureCopyWith<$R, Temperature, Temperature>
  get feelsLikeMaxTemperature => $value.feelsLikeMaxTemperature.copyWith.$chain(
    (v) => call(feelsLikeMaxTemperature: v),
  );
  @override
  TemperatureCopyWith<$R, Temperature, Temperature>
  get feelsLikeMinTemperature => $value.feelsLikeMinTemperature.copyWith.$chain(
    (v) => call(feelsLikeMinTemperature: v),
  );
  @override
  SunEventsCopyWith<$R, SunEvents, SunEvents> get sunEvents =>
      $value.sunEvents.copyWith.$chain((v) => call(sunEvents: v));
  @override
  MoonEventsCopyWith<$R, MoonEvents, MoonEvents> get moonEvents =>
      $value.moonEvents.copyWith.$chain((v) => call(moonEvents: v));
  @override
  TemperatureCopyWith<$R, Temperature, Temperature> get maxHeatIndex =>
      $value.maxHeatIndex.copyWith.$chain((v) => call(maxHeatIndex: v));
  @override
  $R call({
    Interval? interval,
    DisplayDate? displayDate,
    Forecast? daytimeForecast,
    Forecast? nighttimeForecast,
    Temperature? maxTemperature,
    Temperature? minTemperature,
    Temperature? feelsLikeMaxTemperature,
    Temperature? feelsLikeMinTemperature,
    SunEvents? sunEvents,
    MoonEvents? moonEvents,
    Temperature? maxHeatIndex,
  }) => $apply(
    FieldCopyWithData({
      if (interval != null) #interval: interval,
      if (displayDate != null) #displayDate: displayDate,
      if (daytimeForecast != null) #daytimeForecast: daytimeForecast,
      if (nighttimeForecast != null) #nighttimeForecast: nighttimeForecast,
      if (maxTemperature != null) #maxTemperature: maxTemperature,
      if (minTemperature != null) #minTemperature: minTemperature,
      if (feelsLikeMaxTemperature != null)
        #feelsLikeMaxTemperature: feelsLikeMaxTemperature,
      if (feelsLikeMinTemperature != null)
        #feelsLikeMinTemperature: feelsLikeMinTemperature,
      if (sunEvents != null) #sunEvents: sunEvents,
      if (moonEvents != null) #moonEvents: moonEvents,
      if (maxHeatIndex != null) #maxHeatIndex: maxHeatIndex,
    }),
  );
  @override
  ForecastDay $make(CopyWithData data) => ForecastDay(
    interval: data.get(#interval, or: $value.interval),
    displayDate: data.get(#displayDate, or: $value.displayDate),
    daytimeForecast: data.get(#daytimeForecast, or: $value.daytimeForecast),
    nighttimeForecast: data.get(
      #nighttimeForecast,
      or: $value.nighttimeForecast,
    ),
    maxTemperature: data.get(#maxTemperature, or: $value.maxTemperature),
    minTemperature: data.get(#minTemperature, or: $value.minTemperature),
    feelsLikeMaxTemperature: data.get(
      #feelsLikeMaxTemperature,
      or: $value.feelsLikeMaxTemperature,
    ),
    feelsLikeMinTemperature: data.get(
      #feelsLikeMinTemperature,
      or: $value.feelsLikeMinTemperature,
    ),
    sunEvents: data.get(#sunEvents, or: $value.sunEvents),
    moonEvents: data.get(#moonEvents, or: $value.moonEvents),
    maxHeatIndex: data.get(#maxHeatIndex, or: $value.maxHeatIndex),
  );

  @override
  ForecastDayCopyWith<$R2, ForecastDay, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ForecastDayCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class IntervalMapper extends ClassMapperBase<Interval> {
  IntervalMapper._();

  static IntervalMapper? _instance;
  static IntervalMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IntervalMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Interval';

  static DateTime _$startTime(Interval v) => v.startTime;
  static const Field<Interval, DateTime> _f$startTime = Field(
    'startTime',
    _$startTime,
  );
  static DateTime _$endTime(Interval v) => v.endTime;
  static const Field<Interval, DateTime> _f$endTime = Field(
    'endTime',
    _$endTime,
  );

  @override
  final MappableFields<Interval> fields = const {
    #startTime: _f$startTime,
    #endTime: _f$endTime,
  };

  static Interval _instantiate(DecodingData data) {
    return Interval(
      startTime: data.dec(_f$startTime),
      endTime: data.dec(_f$endTime),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Interval fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Interval>(map);
  }

  static Interval fromJson(String json) {
    return ensureInitialized().decodeJson<Interval>(json);
  }
}

mixin IntervalMappable {
  String toJson() {
    return IntervalMapper.ensureInitialized().encodeJson<Interval>(
      this as Interval,
    );
  }

  Map<String, dynamic> toMap() {
    return IntervalMapper.ensureInitialized().encodeMap<Interval>(
      this as Interval,
    );
  }

  IntervalCopyWith<Interval, Interval, Interval> get copyWith =>
      _IntervalCopyWithImpl<Interval, Interval>(
        this as Interval,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return IntervalMapper.ensureInitialized().stringifyValue(this as Interval);
  }

  @override
  bool operator ==(Object other) {
    return IntervalMapper.ensureInitialized().equalsValue(
      this as Interval,
      other,
    );
  }

  @override
  int get hashCode {
    return IntervalMapper.ensureInitialized().hashValue(this as Interval);
  }
}

extension IntervalValueCopy<$R, $Out> on ObjectCopyWith<$R, Interval, $Out> {
  IntervalCopyWith<$R, Interval, $Out> get $asInterval =>
      $base.as((v, t, t2) => _IntervalCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class IntervalCopyWith<$R, $In extends Interval, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({DateTime? startTime, DateTime? endTime});
  IntervalCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _IntervalCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Interval, $Out>
    implements IntervalCopyWith<$R, Interval, $Out> {
  _IntervalCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Interval> $mapper =
      IntervalMapper.ensureInitialized();
  @override
  $R call({DateTime? startTime, DateTime? endTime}) => $apply(
    FieldCopyWithData({
      if (startTime != null) #startTime: startTime,
      if (endTime != null) #endTime: endTime,
    }),
  );
  @override
  Interval $make(CopyWithData data) => Interval(
    startTime: data.get(#startTime, or: $value.startTime),
    endTime: data.get(#endTime, or: $value.endTime),
  );

  @override
  IntervalCopyWith<$R2, Interval, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _IntervalCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DisplayDateMapper extends ClassMapperBase<DisplayDate> {
  DisplayDateMapper._();

  static DisplayDateMapper? _instance;
  static DisplayDateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DisplayDateMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DisplayDate';

  static int _$year(DisplayDate v) => v.year;
  static const Field<DisplayDate, int> _f$year = Field('year', _$year);
  static int _$month(DisplayDate v) => v.month;
  static const Field<DisplayDate, int> _f$month = Field('month', _$month);
  static int _$day(DisplayDate v) => v.day;
  static const Field<DisplayDate, int> _f$day = Field('day', _$day);

  @override
  final MappableFields<DisplayDate> fields = const {
    #year: _f$year,
    #month: _f$month,
    #day: _f$day,
  };

  static DisplayDate _instantiate(DecodingData data) {
    return DisplayDate(
      year: data.dec(_f$year),
      month: data.dec(_f$month),
      day: data.dec(_f$day),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DisplayDate fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DisplayDate>(map);
  }

  static DisplayDate fromJson(String json) {
    return ensureInitialized().decodeJson<DisplayDate>(json);
  }
}

mixin DisplayDateMappable {
  String toJson() {
    return DisplayDateMapper.ensureInitialized().encodeJson<DisplayDate>(
      this as DisplayDate,
    );
  }

  Map<String, dynamic> toMap() {
    return DisplayDateMapper.ensureInitialized().encodeMap<DisplayDate>(
      this as DisplayDate,
    );
  }

  DisplayDateCopyWith<DisplayDate, DisplayDate, DisplayDate> get copyWith =>
      _DisplayDateCopyWithImpl<DisplayDate, DisplayDate>(
        this as DisplayDate,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DisplayDateMapper.ensureInitialized().stringifyValue(
      this as DisplayDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return DisplayDateMapper.ensureInitialized().equalsValue(
      this as DisplayDate,
      other,
    );
  }

  @override
  int get hashCode {
    return DisplayDateMapper.ensureInitialized().hashValue(this as DisplayDate);
  }
}

extension DisplayDateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DisplayDate, $Out> {
  DisplayDateCopyWith<$R, DisplayDate, $Out> get $asDisplayDate =>
      $base.as((v, t, t2) => _DisplayDateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DisplayDateCopyWith<$R, $In extends DisplayDate, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? year, int? month, int? day});
  DisplayDateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DisplayDateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DisplayDate, $Out>
    implements DisplayDateCopyWith<$R, DisplayDate, $Out> {
  _DisplayDateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DisplayDate> $mapper =
      DisplayDateMapper.ensureInitialized();
  @override
  $R call({int? year, int? month, int? day}) => $apply(
    FieldCopyWithData({
      if (year != null) #year: year,
      if (month != null) #month: month,
      if (day != null) #day: day,
    }),
  );
  @override
  DisplayDate $make(CopyWithData data) => DisplayDate(
    year: data.get(#year, or: $value.year),
    month: data.get(#month, or: $value.month),
    day: data.get(#day, or: $value.day),
  );

  @override
  DisplayDateCopyWith<$R2, DisplayDate, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DisplayDateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ForecastMapper extends ClassMapperBase<Forecast> {
  ForecastMapper._();

  static ForecastMapper? _instance;
  static ForecastMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ForecastMapper._());
      IntervalMapper.ensureInitialized();
      WeatherConditionMapper.ensureInitialized();
      PrecipitationMapper.ensureInitialized();
      WindMapper.ensureInitialized();
      IceThicknessMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Forecast';

  static Interval _$interval(Forecast v) => v.interval;
  static const Field<Forecast, Interval> _f$interval = Field(
    'interval',
    _$interval,
  );
  static WeatherCondition _$weatherCondition(Forecast v) => v.weatherCondition;
  static const Field<Forecast, WeatherCondition> _f$weatherCondition = Field(
    'weatherCondition',
    _$weatherCondition,
  );
  static int _$relativeHumidity(Forecast v) => v.relativeHumidity;
  static const Field<Forecast, int> _f$relativeHumidity = Field(
    'relativeHumidity',
    _$relativeHumidity,
  );
  static int _$uvIndex(Forecast v) => v.uvIndex;
  static const Field<Forecast, int> _f$uvIndex = Field('uvIndex', _$uvIndex);
  static Precipitation _$precipitation(Forecast v) => v.precipitation;
  static const Field<Forecast, Precipitation> _f$precipitation = Field(
    'precipitation',
    _$precipitation,
  );
  static int _$thunderstormProbability(Forecast v) => v.thunderstormProbability;
  static const Field<Forecast, int> _f$thunderstormProbability = Field(
    'thunderstormProbability',
    _$thunderstormProbability,
  );
  static Wind _$wind(Forecast v) => v.wind;
  static const Field<Forecast, Wind> _f$wind = Field('wind', _$wind);
  static int _$cloudCover(Forecast v) => v.cloudCover;
  static const Field<Forecast, int> _f$cloudCover = Field(
    'cloudCover',
    _$cloudCover,
  );
  static IceThickness _$iceThickness(Forecast v) => v.iceThickness;
  static const Field<Forecast, IceThickness> _f$iceThickness = Field(
    'iceThickness',
    _$iceThickness,
  );

  @override
  final MappableFields<Forecast> fields = const {
    #interval: _f$interval,
    #weatherCondition: _f$weatherCondition,
    #relativeHumidity: _f$relativeHumidity,
    #uvIndex: _f$uvIndex,
    #precipitation: _f$precipitation,
    #thunderstormProbability: _f$thunderstormProbability,
    #wind: _f$wind,
    #cloudCover: _f$cloudCover,
    #iceThickness: _f$iceThickness,
  };

  static Forecast _instantiate(DecodingData data) {
    return Forecast(
      interval: data.dec(_f$interval),
      weatherCondition: data.dec(_f$weatherCondition),
      relativeHumidity: data.dec(_f$relativeHumidity),
      uvIndex: data.dec(_f$uvIndex),
      precipitation: data.dec(_f$precipitation),
      thunderstormProbability: data.dec(_f$thunderstormProbability),
      wind: data.dec(_f$wind),
      cloudCover: data.dec(_f$cloudCover),
      iceThickness: data.dec(_f$iceThickness),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Forecast fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Forecast>(map);
  }

  static Forecast fromJson(String json) {
    return ensureInitialized().decodeJson<Forecast>(json);
  }
}

mixin ForecastMappable {
  String toJson() {
    return ForecastMapper.ensureInitialized().encodeJson<Forecast>(
      this as Forecast,
    );
  }

  Map<String, dynamic> toMap() {
    return ForecastMapper.ensureInitialized().encodeMap<Forecast>(
      this as Forecast,
    );
  }

  ForecastCopyWith<Forecast, Forecast, Forecast> get copyWith =>
      _ForecastCopyWithImpl<Forecast, Forecast>(
        this as Forecast,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ForecastMapper.ensureInitialized().stringifyValue(this as Forecast);
  }

  @override
  bool operator ==(Object other) {
    return ForecastMapper.ensureInitialized().equalsValue(
      this as Forecast,
      other,
    );
  }

  @override
  int get hashCode {
    return ForecastMapper.ensureInitialized().hashValue(this as Forecast);
  }
}

extension ForecastValueCopy<$R, $Out> on ObjectCopyWith<$R, Forecast, $Out> {
  ForecastCopyWith<$R, Forecast, $Out> get $asForecast =>
      $base.as((v, t, t2) => _ForecastCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ForecastCopyWith<$R, $In extends Forecast, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  IntervalCopyWith<$R, Interval, Interval> get interval;
  WeatherConditionCopyWith<$R, WeatherCondition, WeatherCondition>
  get weatherCondition;
  PrecipitationCopyWith<$R, Precipitation, Precipitation> get precipitation;
  WindCopyWith<$R, Wind, Wind> get wind;
  IceThicknessCopyWith<$R, IceThickness, IceThickness> get iceThickness;
  $R call({
    Interval? interval,
    WeatherCondition? weatherCondition,
    int? relativeHumidity,
    int? uvIndex,
    Precipitation? precipitation,
    int? thunderstormProbability,
    Wind? wind,
    int? cloudCover,
    IceThickness? iceThickness,
  });
  ForecastCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ForecastCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Forecast, $Out>
    implements ForecastCopyWith<$R, Forecast, $Out> {
  _ForecastCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Forecast> $mapper =
      ForecastMapper.ensureInitialized();
  @override
  IntervalCopyWith<$R, Interval, Interval> get interval =>
      $value.interval.copyWith.$chain((v) => call(interval: v));
  @override
  WeatherConditionCopyWith<$R, WeatherCondition, WeatherCondition>
  get weatherCondition =>
      $value.weatherCondition.copyWith.$chain((v) => call(weatherCondition: v));
  @override
  PrecipitationCopyWith<$R, Precipitation, Precipitation> get precipitation =>
      $value.precipitation.copyWith.$chain((v) => call(precipitation: v));
  @override
  WindCopyWith<$R, Wind, Wind> get wind =>
      $value.wind.copyWith.$chain((v) => call(wind: v));
  @override
  IceThicknessCopyWith<$R, IceThickness, IceThickness> get iceThickness =>
      $value.iceThickness.copyWith.$chain((v) => call(iceThickness: v));
  @override
  $R call({
    Interval? interval,
    WeatherCondition? weatherCondition,
    int? relativeHumidity,
    int? uvIndex,
    Precipitation? precipitation,
    int? thunderstormProbability,
    Wind? wind,
    int? cloudCover,
    IceThickness? iceThickness,
  }) => $apply(
    FieldCopyWithData({
      if (interval != null) #interval: interval,
      if (weatherCondition != null) #weatherCondition: weatherCondition,
      if (relativeHumidity != null) #relativeHumidity: relativeHumidity,
      if (uvIndex != null) #uvIndex: uvIndex,
      if (precipitation != null) #precipitation: precipitation,
      if (thunderstormProbability != null)
        #thunderstormProbability: thunderstormProbability,
      if (wind != null) #wind: wind,
      if (cloudCover != null) #cloudCover: cloudCover,
      if (iceThickness != null) #iceThickness: iceThickness,
    }),
  );
  @override
  Forecast $make(CopyWithData data) => Forecast(
    interval: data.get(#interval, or: $value.interval),
    weatherCondition: data.get(#weatherCondition, or: $value.weatherCondition),
    relativeHumidity: data.get(#relativeHumidity, or: $value.relativeHumidity),
    uvIndex: data.get(#uvIndex, or: $value.uvIndex),
    precipitation: data.get(#precipitation, or: $value.precipitation),
    thunderstormProbability: data.get(
      #thunderstormProbability,
      or: $value.thunderstormProbability,
    ),
    wind: data.get(#wind, or: $value.wind),
    cloudCover: data.get(#cloudCover, or: $value.cloudCover),
    iceThickness: data.get(#iceThickness, or: $value.iceThickness),
  );

  @override
  ForecastCopyWith<$R2, Forecast, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ForecastCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class WeatherConditionMapper extends ClassMapperBase<WeatherCondition> {
  WeatherConditionMapper._();

  static WeatherConditionMapper? _instance;
  static WeatherConditionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WeatherConditionMapper._());
      DescriptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'WeatherCondition';

  static String _$iconBaseUri(WeatherCondition v) => v.iconBaseUri;
  static const Field<WeatherCondition, String> _f$iconBaseUri = Field(
    'iconBaseUri',
    _$iconBaseUri,
  );
  static Description _$description(WeatherCondition v) => v.description;
  static const Field<WeatherCondition, Description> _f$description = Field(
    'description',
    _$description,
  );
  static String _$type(WeatherCondition v) => v.type;
  static const Field<WeatherCondition, String> _f$type = Field('type', _$type);

  @override
  final MappableFields<WeatherCondition> fields = const {
    #iconBaseUri: _f$iconBaseUri,
    #description: _f$description,
    #type: _f$type,
  };

  static WeatherCondition _instantiate(DecodingData data) {
    return WeatherCondition(
      iconBaseUri: data.dec(_f$iconBaseUri),
      description: data.dec(_f$description),
      type: data.dec(_f$type),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static WeatherCondition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WeatherCondition>(map);
  }

  static WeatherCondition fromJson(String json) {
    return ensureInitialized().decodeJson<WeatherCondition>(json);
  }
}

mixin WeatherConditionMappable {
  String toJson() {
    return WeatherConditionMapper.ensureInitialized()
        .encodeJson<WeatherCondition>(this as WeatherCondition);
  }

  Map<String, dynamic> toMap() {
    return WeatherConditionMapper.ensureInitialized()
        .encodeMap<WeatherCondition>(this as WeatherCondition);
  }

  WeatherConditionCopyWith<WeatherCondition, WeatherCondition, WeatherCondition>
  get copyWith =>
      _WeatherConditionCopyWithImpl<WeatherCondition, WeatherCondition>(
        this as WeatherCondition,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return WeatherConditionMapper.ensureInitialized().stringifyValue(
      this as WeatherCondition,
    );
  }

  @override
  bool operator ==(Object other) {
    return WeatherConditionMapper.ensureInitialized().equalsValue(
      this as WeatherCondition,
      other,
    );
  }

  @override
  int get hashCode {
    return WeatherConditionMapper.ensureInitialized().hashValue(
      this as WeatherCondition,
    );
  }
}

extension WeatherConditionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, WeatherCondition, $Out> {
  WeatherConditionCopyWith<$R, WeatherCondition, $Out>
  get $asWeatherCondition =>
      $base.as((v, t, t2) => _WeatherConditionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WeatherConditionCopyWith<$R, $In extends WeatherCondition, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  DescriptionCopyWith<$R, Description, Description> get description;
  $R call({String? iconBaseUri, Description? description, String? type});
  WeatherConditionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _WeatherConditionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WeatherCondition, $Out>
    implements WeatherConditionCopyWith<$R, WeatherCondition, $Out> {
  _WeatherConditionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WeatherCondition> $mapper =
      WeatherConditionMapper.ensureInitialized();
  @override
  DescriptionCopyWith<$R, Description, Description> get description =>
      $value.description.copyWith.$chain((v) => call(description: v));
  @override
  $R call({String? iconBaseUri, Description? description, String? type}) =>
      $apply(
        FieldCopyWithData({
          if (iconBaseUri != null) #iconBaseUri: iconBaseUri,
          if (description != null) #description: description,
          if (type != null) #type: type,
        }),
      );
  @override
  WeatherCondition $make(CopyWithData data) => WeatherCondition(
    iconBaseUri: data.get(#iconBaseUri, or: $value.iconBaseUri),
    description: data.get(#description, or: $value.description),
    type: data.get(#type, or: $value.type),
  );

  @override
  WeatherConditionCopyWith<$R2, WeatherCondition, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _WeatherConditionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DescriptionMapper extends ClassMapperBase<Description> {
  DescriptionMapper._();

  static DescriptionMapper? _instance;
  static DescriptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DescriptionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Description';

  static String _$text(Description v) => v.text;
  static const Field<Description, String> _f$text = Field('text', _$text);
  static String _$languageCode(Description v) => v.languageCode;
  static const Field<Description, String> _f$languageCode = Field(
    'languageCode',
    _$languageCode,
  );

  @override
  final MappableFields<Description> fields = const {
    #text: _f$text,
    #languageCode: _f$languageCode,
  };

  static Description _instantiate(DecodingData data) {
    return Description(
      text: data.dec(_f$text),
      languageCode: data.dec(_f$languageCode),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Description fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Description>(map);
  }

  static Description fromJson(String json) {
    return ensureInitialized().decodeJson<Description>(json);
  }
}

mixin DescriptionMappable {
  String toJson() {
    return DescriptionMapper.ensureInitialized().encodeJson<Description>(
      this as Description,
    );
  }

  Map<String, dynamic> toMap() {
    return DescriptionMapper.ensureInitialized().encodeMap<Description>(
      this as Description,
    );
  }

  DescriptionCopyWith<Description, Description, Description> get copyWith =>
      _DescriptionCopyWithImpl<Description, Description>(
        this as Description,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DescriptionMapper.ensureInitialized().stringifyValue(
      this as Description,
    );
  }

  @override
  bool operator ==(Object other) {
    return DescriptionMapper.ensureInitialized().equalsValue(
      this as Description,
      other,
    );
  }

  @override
  int get hashCode {
    return DescriptionMapper.ensureInitialized().hashValue(this as Description);
  }
}

extension DescriptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Description, $Out> {
  DescriptionCopyWith<$R, Description, $Out> get $asDescription =>
      $base.as((v, t, t2) => _DescriptionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DescriptionCopyWith<$R, $In extends Description, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? text, String? languageCode});
  DescriptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DescriptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Description, $Out>
    implements DescriptionCopyWith<$R, Description, $Out> {
  _DescriptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Description> $mapper =
      DescriptionMapper.ensureInitialized();
  @override
  $R call({String? text, String? languageCode}) => $apply(
    FieldCopyWithData({
      if (text != null) #text: text,
      if (languageCode != null) #languageCode: languageCode,
    }),
  );
  @override
  Description $make(CopyWithData data) => Description(
    text: data.get(#text, or: $value.text),
    languageCode: data.get(#languageCode, or: $value.languageCode),
  );

  @override
  DescriptionCopyWith<$R2, Description, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DescriptionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PrecipitationMapper extends ClassMapperBase<Precipitation> {
  PrecipitationMapper._();

  static PrecipitationMapper? _instance;
  static PrecipitationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PrecipitationMapper._());
      ProbabilityMapper.ensureInitialized();
      QuantityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Precipitation';

  static Probability _$probability(Precipitation v) => v.probability;
  static const Field<Precipitation, Probability> _f$probability = Field(
    'probability',
    _$probability,
  );
  static Quantity _$snowQpf(Precipitation v) => v.snowQpf;
  static const Field<Precipitation, Quantity> _f$snowQpf = Field(
    'snowQpf',
    _$snowQpf,
  );
  static Quantity _$qpf(Precipitation v) => v.qpf;
  static const Field<Precipitation, Quantity> _f$qpf = Field('qpf', _$qpf);

  @override
  final MappableFields<Precipitation> fields = const {
    #probability: _f$probability,
    #snowQpf: _f$snowQpf,
    #qpf: _f$qpf,
  };

  static Precipitation _instantiate(DecodingData data) {
    return Precipitation(
      probability: data.dec(_f$probability),
      snowQpf: data.dec(_f$snowQpf),
      qpf: data.dec(_f$qpf),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Precipitation fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Precipitation>(map);
  }

  static Precipitation fromJson(String json) {
    return ensureInitialized().decodeJson<Precipitation>(json);
  }
}

mixin PrecipitationMappable {
  String toJson() {
    return PrecipitationMapper.ensureInitialized().encodeJson<Precipitation>(
      this as Precipitation,
    );
  }

  Map<String, dynamic> toMap() {
    return PrecipitationMapper.ensureInitialized().encodeMap<Precipitation>(
      this as Precipitation,
    );
  }

  PrecipitationCopyWith<Precipitation, Precipitation, Precipitation>
  get copyWith => _PrecipitationCopyWithImpl<Precipitation, Precipitation>(
    this as Precipitation,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return PrecipitationMapper.ensureInitialized().stringifyValue(
      this as Precipitation,
    );
  }

  @override
  bool operator ==(Object other) {
    return PrecipitationMapper.ensureInitialized().equalsValue(
      this as Precipitation,
      other,
    );
  }

  @override
  int get hashCode {
    return PrecipitationMapper.ensureInitialized().hashValue(
      this as Precipitation,
    );
  }
}

extension PrecipitationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Precipitation, $Out> {
  PrecipitationCopyWith<$R, Precipitation, $Out> get $asPrecipitation =>
      $base.as((v, t, t2) => _PrecipitationCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PrecipitationCopyWith<$R, $In extends Precipitation, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ProbabilityCopyWith<$R, Probability, Probability> get probability;
  QuantityCopyWith<$R, Quantity, Quantity> get snowQpf;
  QuantityCopyWith<$R, Quantity, Quantity> get qpf;
  $R call({Probability? probability, Quantity? snowQpf, Quantity? qpf});
  PrecipitationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PrecipitationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Precipitation, $Out>
    implements PrecipitationCopyWith<$R, Precipitation, $Out> {
  _PrecipitationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Precipitation> $mapper =
      PrecipitationMapper.ensureInitialized();
  @override
  ProbabilityCopyWith<$R, Probability, Probability> get probability =>
      $value.probability.copyWith.$chain((v) => call(probability: v));
  @override
  QuantityCopyWith<$R, Quantity, Quantity> get snowQpf =>
      $value.snowQpf.copyWith.$chain((v) => call(snowQpf: v));
  @override
  QuantityCopyWith<$R, Quantity, Quantity> get qpf =>
      $value.qpf.copyWith.$chain((v) => call(qpf: v));
  @override
  $R call({Probability? probability, Quantity? snowQpf, Quantity? qpf}) =>
      $apply(
        FieldCopyWithData({
          if (probability != null) #probability: probability,
          if (snowQpf != null) #snowQpf: snowQpf,
          if (qpf != null) #qpf: qpf,
        }),
      );
  @override
  Precipitation $make(CopyWithData data) => Precipitation(
    probability: data.get(#probability, or: $value.probability),
    snowQpf: data.get(#snowQpf, or: $value.snowQpf),
    qpf: data.get(#qpf, or: $value.qpf),
  );

  @override
  PrecipitationCopyWith<$R2, Precipitation, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PrecipitationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ProbabilityMapper extends ClassMapperBase<Probability> {
  ProbabilityMapper._();

  static ProbabilityMapper? _instance;
  static ProbabilityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProbabilityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Probability';

  static int _$percent(Probability v) => v.percent;
  static const Field<Probability, int> _f$percent = Field('percent', _$percent);
  static String _$type(Probability v) => v.type;
  static const Field<Probability, String> _f$type = Field('type', _$type);

  @override
  final MappableFields<Probability> fields = const {
    #percent: _f$percent,
    #type: _f$type,
  };

  static Probability _instantiate(DecodingData data) {
    return Probability(percent: data.dec(_f$percent), type: data.dec(_f$type));
  }

  @override
  final Function instantiate = _instantiate;

  static Probability fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Probability>(map);
  }

  static Probability fromJson(String json) {
    return ensureInitialized().decodeJson<Probability>(json);
  }
}

mixin ProbabilityMappable {
  String toJson() {
    return ProbabilityMapper.ensureInitialized().encodeJson<Probability>(
      this as Probability,
    );
  }

  Map<String, dynamic> toMap() {
    return ProbabilityMapper.ensureInitialized().encodeMap<Probability>(
      this as Probability,
    );
  }

  ProbabilityCopyWith<Probability, Probability, Probability> get copyWith =>
      _ProbabilityCopyWithImpl<Probability, Probability>(
        this as Probability,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProbabilityMapper.ensureInitialized().stringifyValue(
      this as Probability,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProbabilityMapper.ensureInitialized().equalsValue(
      this as Probability,
      other,
    );
  }

  @override
  int get hashCode {
    return ProbabilityMapper.ensureInitialized().hashValue(this as Probability);
  }
}

extension ProbabilityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Probability, $Out> {
  ProbabilityCopyWith<$R, Probability, $Out> get $asProbability =>
      $base.as((v, t, t2) => _ProbabilityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProbabilityCopyWith<$R, $In extends Probability, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? percent, String? type});
  ProbabilityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProbabilityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Probability, $Out>
    implements ProbabilityCopyWith<$R, Probability, $Out> {
  _ProbabilityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Probability> $mapper =
      ProbabilityMapper.ensureInitialized();
  @override
  $R call({int? percent, String? type}) => $apply(
    FieldCopyWithData({
      if (percent != null) #percent: percent,
      if (type != null) #type: type,
    }),
  );
  @override
  Probability $make(CopyWithData data) => Probability(
    percent: data.get(#percent, or: $value.percent),
    type: data.get(#type, or: $value.type),
  );

  @override
  ProbabilityCopyWith<$R2, Probability, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProbabilityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class QuantityMapper extends ClassMapperBase<Quantity> {
  QuantityMapper._();

  static QuantityMapper? _instance;
  static QuantityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = QuantityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Quantity';

  static double _$quantity(Quantity v) => v.quantity;
  static const Field<Quantity, double> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static String _$unit(Quantity v) => v.unit;
  static const Field<Quantity, String> _f$unit = Field('unit', _$unit);

  @override
  final MappableFields<Quantity> fields = const {
    #quantity: _f$quantity,
    #unit: _f$unit,
  };

  static Quantity _instantiate(DecodingData data) {
    return Quantity(quantity: data.dec(_f$quantity), unit: data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static Quantity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Quantity>(map);
  }

  static Quantity fromJson(String json) {
    return ensureInitialized().decodeJson<Quantity>(json);
  }
}

mixin QuantityMappable {
  String toJson() {
    return QuantityMapper.ensureInitialized().encodeJson<Quantity>(
      this as Quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return QuantityMapper.ensureInitialized().encodeMap<Quantity>(
      this as Quantity,
    );
  }

  QuantityCopyWith<Quantity, Quantity, Quantity> get copyWith =>
      _QuantityCopyWithImpl<Quantity, Quantity>(
        this as Quantity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return QuantityMapper.ensureInitialized().stringifyValue(this as Quantity);
  }

  @override
  bool operator ==(Object other) {
    return QuantityMapper.ensureInitialized().equalsValue(
      this as Quantity,
      other,
    );
  }

  @override
  int get hashCode {
    return QuantityMapper.ensureInitialized().hashValue(this as Quantity);
  }
}

extension QuantityValueCopy<$R, $Out> on ObjectCopyWith<$R, Quantity, $Out> {
  QuantityCopyWith<$R, Quantity, $Out> get $asQuantity =>
      $base.as((v, t, t2) => _QuantityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class QuantityCopyWith<$R, $In extends Quantity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? quantity, String? unit});
  QuantityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _QuantityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Quantity, $Out>
    implements QuantityCopyWith<$R, Quantity, $Out> {
  _QuantityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Quantity> $mapper =
      QuantityMapper.ensureInitialized();
  @override
  $R call({double? quantity, String? unit}) => $apply(
    FieldCopyWithData({
      if (quantity != null) #quantity: quantity,
      if (unit != null) #unit: unit,
    }),
  );
  @override
  Quantity $make(CopyWithData data) => Quantity(
    quantity: data.get(#quantity, or: $value.quantity),
    unit: data.get(#unit, or: $value.unit),
  );

  @override
  QuantityCopyWith<$R2, Quantity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _QuantityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class WindMapper extends ClassMapperBase<Wind> {
  WindMapper._();

  static WindMapper? _instance;
  static WindMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WindMapper._());
      WindDirectionMapper.ensureInitialized();
      WindSpeedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Wind';

  static WindDirection _$direction(Wind v) => v.direction;
  static const Field<Wind, WindDirection> _f$direction = Field(
    'direction',
    _$direction,
  );
  static WindSpeed _$speed(Wind v) => v.speed;
  static const Field<Wind, WindSpeed> _f$speed = Field('speed', _$speed);
  static WindSpeed _$gust(Wind v) => v.gust;
  static const Field<Wind, WindSpeed> _f$gust = Field('gust', _$gust);

  @override
  final MappableFields<Wind> fields = const {
    #direction: _f$direction,
    #speed: _f$speed,
    #gust: _f$gust,
  };

  static Wind _instantiate(DecodingData data) {
    return Wind(
      direction: data.dec(_f$direction),
      speed: data.dec(_f$speed),
      gust: data.dec(_f$gust),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Wind fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Wind>(map);
  }

  static Wind fromJson(String json) {
    return ensureInitialized().decodeJson<Wind>(json);
  }
}

mixin WindMappable {
  String toJson() {
    return WindMapper.ensureInitialized().encodeJson<Wind>(this as Wind);
  }

  Map<String, dynamic> toMap() {
    return WindMapper.ensureInitialized().encodeMap<Wind>(this as Wind);
  }

  WindCopyWith<Wind, Wind, Wind> get copyWith =>
      _WindCopyWithImpl<Wind, Wind>(this as Wind, $identity, $identity);
  @override
  String toString() {
    return WindMapper.ensureInitialized().stringifyValue(this as Wind);
  }

  @override
  bool operator ==(Object other) {
    return WindMapper.ensureInitialized().equalsValue(this as Wind, other);
  }

  @override
  int get hashCode {
    return WindMapper.ensureInitialized().hashValue(this as Wind);
  }
}

extension WindValueCopy<$R, $Out> on ObjectCopyWith<$R, Wind, $Out> {
  WindCopyWith<$R, Wind, $Out> get $asWind =>
      $base.as((v, t, t2) => _WindCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WindCopyWith<$R, $In extends Wind, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  WindDirectionCopyWith<$R, WindDirection, WindDirection> get direction;
  WindSpeedCopyWith<$R, WindSpeed, WindSpeed> get speed;
  WindSpeedCopyWith<$R, WindSpeed, WindSpeed> get gust;
  $R call({WindDirection? direction, WindSpeed? speed, WindSpeed? gust});
  WindCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WindCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Wind, $Out>
    implements WindCopyWith<$R, Wind, $Out> {
  _WindCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Wind> $mapper = WindMapper.ensureInitialized();
  @override
  WindDirectionCopyWith<$R, WindDirection, WindDirection> get direction =>
      $value.direction.copyWith.$chain((v) => call(direction: v));
  @override
  WindSpeedCopyWith<$R, WindSpeed, WindSpeed> get speed =>
      $value.speed.copyWith.$chain((v) => call(speed: v));
  @override
  WindSpeedCopyWith<$R, WindSpeed, WindSpeed> get gust =>
      $value.gust.copyWith.$chain((v) => call(gust: v));
  @override
  $R call({WindDirection? direction, WindSpeed? speed, WindSpeed? gust}) =>
      $apply(
        FieldCopyWithData({
          if (direction != null) #direction: direction,
          if (speed != null) #speed: speed,
          if (gust != null) #gust: gust,
        }),
      );
  @override
  Wind $make(CopyWithData data) => Wind(
    direction: data.get(#direction, or: $value.direction),
    speed: data.get(#speed, or: $value.speed),
    gust: data.get(#gust, or: $value.gust),
  );

  @override
  WindCopyWith<$R2, Wind, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _WindCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class WindDirectionMapper extends ClassMapperBase<WindDirection> {
  WindDirectionMapper._();

  static WindDirectionMapper? _instance;
  static WindDirectionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WindDirectionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'WindDirection';

  static int _$degrees(WindDirection v) => v.degrees;
  static const Field<WindDirection, int> _f$degrees = Field(
    'degrees',
    _$degrees,
  );
  static String _$cardinal(WindDirection v) => v.cardinal;
  static const Field<WindDirection, String> _f$cardinal = Field(
    'cardinal',
    _$cardinal,
  );

  @override
  final MappableFields<WindDirection> fields = const {
    #degrees: _f$degrees,
    #cardinal: _f$cardinal,
  };

  static WindDirection _instantiate(DecodingData data) {
    return WindDirection(
      degrees: data.dec(_f$degrees),
      cardinal: data.dec(_f$cardinal),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static WindDirection fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WindDirection>(map);
  }

  static WindDirection fromJson(String json) {
    return ensureInitialized().decodeJson<WindDirection>(json);
  }
}

mixin WindDirectionMappable {
  String toJson() {
    return WindDirectionMapper.ensureInitialized().encodeJson<WindDirection>(
      this as WindDirection,
    );
  }

  Map<String, dynamic> toMap() {
    return WindDirectionMapper.ensureInitialized().encodeMap<WindDirection>(
      this as WindDirection,
    );
  }

  WindDirectionCopyWith<WindDirection, WindDirection, WindDirection>
  get copyWith => _WindDirectionCopyWithImpl<WindDirection, WindDirection>(
    this as WindDirection,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return WindDirectionMapper.ensureInitialized().stringifyValue(
      this as WindDirection,
    );
  }

  @override
  bool operator ==(Object other) {
    return WindDirectionMapper.ensureInitialized().equalsValue(
      this as WindDirection,
      other,
    );
  }

  @override
  int get hashCode {
    return WindDirectionMapper.ensureInitialized().hashValue(
      this as WindDirection,
    );
  }
}

extension WindDirectionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, WindDirection, $Out> {
  WindDirectionCopyWith<$R, WindDirection, $Out> get $asWindDirection =>
      $base.as((v, t, t2) => _WindDirectionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WindDirectionCopyWith<$R, $In extends WindDirection, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? degrees, String? cardinal});
  WindDirectionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WindDirectionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WindDirection, $Out>
    implements WindDirectionCopyWith<$R, WindDirection, $Out> {
  _WindDirectionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WindDirection> $mapper =
      WindDirectionMapper.ensureInitialized();
  @override
  $R call({int? degrees, String? cardinal}) => $apply(
    FieldCopyWithData({
      if (degrees != null) #degrees: degrees,
      if (cardinal != null) #cardinal: cardinal,
    }),
  );
  @override
  WindDirection $make(CopyWithData data) => WindDirection(
    degrees: data.get(#degrees, or: $value.degrees),
    cardinal: data.get(#cardinal, or: $value.cardinal),
  );

  @override
  WindDirectionCopyWith<$R2, WindDirection, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _WindDirectionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class WindSpeedMapper extends ClassMapperBase<WindSpeed> {
  WindSpeedMapper._();

  static WindSpeedMapper? _instance;
  static WindSpeedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WindSpeedMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'WindSpeed';

  static double _$value(WindSpeed v) => v.value;
  static const Field<WindSpeed, double> _f$value = Field('value', _$value);
  static String _$unit(WindSpeed v) => v.unit;
  static const Field<WindSpeed, String> _f$unit = Field('unit', _$unit);

  @override
  final MappableFields<WindSpeed> fields = const {
    #value: _f$value,
    #unit: _f$unit,
  };

  static WindSpeed _instantiate(DecodingData data) {
    return WindSpeed(value: data.dec(_f$value), unit: data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static WindSpeed fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WindSpeed>(map);
  }

  static WindSpeed fromJson(String json) {
    return ensureInitialized().decodeJson<WindSpeed>(json);
  }
}

mixin WindSpeedMappable {
  String toJson() {
    return WindSpeedMapper.ensureInitialized().encodeJson<WindSpeed>(
      this as WindSpeed,
    );
  }

  Map<String, dynamic> toMap() {
    return WindSpeedMapper.ensureInitialized().encodeMap<WindSpeed>(
      this as WindSpeed,
    );
  }

  WindSpeedCopyWith<WindSpeed, WindSpeed, WindSpeed> get copyWith =>
      _WindSpeedCopyWithImpl<WindSpeed, WindSpeed>(
        this as WindSpeed,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return WindSpeedMapper.ensureInitialized().stringifyValue(
      this as WindSpeed,
    );
  }

  @override
  bool operator ==(Object other) {
    return WindSpeedMapper.ensureInitialized().equalsValue(
      this as WindSpeed,
      other,
    );
  }

  @override
  int get hashCode {
    return WindSpeedMapper.ensureInitialized().hashValue(this as WindSpeed);
  }
}

extension WindSpeedValueCopy<$R, $Out> on ObjectCopyWith<$R, WindSpeed, $Out> {
  WindSpeedCopyWith<$R, WindSpeed, $Out> get $asWindSpeed =>
      $base.as((v, t, t2) => _WindSpeedCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WindSpeedCopyWith<$R, $In extends WindSpeed, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? value, String? unit});
  WindSpeedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WindSpeedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WindSpeed, $Out>
    implements WindSpeedCopyWith<$R, WindSpeed, $Out> {
  _WindSpeedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WindSpeed> $mapper =
      WindSpeedMapper.ensureInitialized();
  @override
  $R call({double? value, String? unit}) => $apply(
    FieldCopyWithData({
      if (value != null) #value: value,
      if (unit != null) #unit: unit,
    }),
  );
  @override
  WindSpeed $make(CopyWithData data) => WindSpeed(
    value: data.get(#value, or: $value.value),
    unit: data.get(#unit, or: $value.unit),
  );

  @override
  WindSpeedCopyWith<$R2, WindSpeed, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _WindSpeedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class IceThicknessMapper extends ClassMapperBase<IceThickness> {
  IceThicknessMapper._();

  static IceThicknessMapper? _instance;
  static IceThicknessMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IceThicknessMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'IceThickness';

  static double _$thickness(IceThickness v) => v.thickness;
  static const Field<IceThickness, double> _f$thickness = Field(
    'thickness',
    _$thickness,
  );
  static String _$unit(IceThickness v) => v.unit;
  static const Field<IceThickness, String> _f$unit = Field('unit', _$unit);

  @override
  final MappableFields<IceThickness> fields = const {
    #thickness: _f$thickness,
    #unit: _f$unit,
  };

  static IceThickness _instantiate(DecodingData data) {
    return IceThickness(
      thickness: data.dec(_f$thickness),
      unit: data.dec(_f$unit),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static IceThickness fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<IceThickness>(map);
  }

  static IceThickness fromJson(String json) {
    return ensureInitialized().decodeJson<IceThickness>(json);
  }
}

mixin IceThicknessMappable {
  String toJson() {
    return IceThicknessMapper.ensureInitialized().encodeJson<IceThickness>(
      this as IceThickness,
    );
  }

  Map<String, dynamic> toMap() {
    return IceThicknessMapper.ensureInitialized().encodeMap<IceThickness>(
      this as IceThickness,
    );
  }

  IceThicknessCopyWith<IceThickness, IceThickness, IceThickness> get copyWith =>
      _IceThicknessCopyWithImpl<IceThickness, IceThickness>(
        this as IceThickness,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return IceThicknessMapper.ensureInitialized().stringifyValue(
      this as IceThickness,
    );
  }

  @override
  bool operator ==(Object other) {
    return IceThicknessMapper.ensureInitialized().equalsValue(
      this as IceThickness,
      other,
    );
  }

  @override
  int get hashCode {
    return IceThicknessMapper.ensureInitialized().hashValue(
      this as IceThickness,
    );
  }
}

extension IceThicknessValueCopy<$R, $Out>
    on ObjectCopyWith<$R, IceThickness, $Out> {
  IceThicknessCopyWith<$R, IceThickness, $Out> get $asIceThickness =>
      $base.as((v, t, t2) => _IceThicknessCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class IceThicknessCopyWith<$R, $In extends IceThickness, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? thickness, String? unit});
  IceThicknessCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _IceThicknessCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, IceThickness, $Out>
    implements IceThicknessCopyWith<$R, IceThickness, $Out> {
  _IceThicknessCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<IceThickness> $mapper =
      IceThicknessMapper.ensureInitialized();
  @override
  $R call({double? thickness, String? unit}) => $apply(
    FieldCopyWithData({
      if (thickness != null) #thickness: thickness,
      if (unit != null) #unit: unit,
    }),
  );
  @override
  IceThickness $make(CopyWithData data) => IceThickness(
    thickness: data.get(#thickness, or: $value.thickness),
    unit: data.get(#unit, or: $value.unit),
  );

  @override
  IceThicknessCopyWith<$R2, IceThickness, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _IceThicknessCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TemperatureMapper extends ClassMapperBase<Temperature> {
  TemperatureMapper._();

  static TemperatureMapper? _instance;
  static TemperatureMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TemperatureMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Temperature';

  static double _$degrees(Temperature v) => v.degrees;
  static const Field<Temperature, double> _f$degrees = Field(
    'degrees',
    _$degrees,
  );
  static String _$unit(Temperature v) => v.unit;
  static const Field<Temperature, String> _f$unit = Field('unit', _$unit);

  @override
  final MappableFields<Temperature> fields = const {
    #degrees: _f$degrees,
    #unit: _f$unit,
  };

  static Temperature _instantiate(DecodingData data) {
    return Temperature(degrees: data.dec(_f$degrees), unit: data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static Temperature fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Temperature>(map);
  }

  static Temperature fromJson(String json) {
    return ensureInitialized().decodeJson<Temperature>(json);
  }
}

mixin TemperatureMappable {
  String toJson() {
    return TemperatureMapper.ensureInitialized().encodeJson<Temperature>(
      this as Temperature,
    );
  }

  Map<String, dynamic> toMap() {
    return TemperatureMapper.ensureInitialized().encodeMap<Temperature>(
      this as Temperature,
    );
  }

  TemperatureCopyWith<Temperature, Temperature, Temperature> get copyWith =>
      _TemperatureCopyWithImpl<Temperature, Temperature>(
        this as Temperature,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TemperatureMapper.ensureInitialized().stringifyValue(
      this as Temperature,
    );
  }

  @override
  bool operator ==(Object other) {
    return TemperatureMapper.ensureInitialized().equalsValue(
      this as Temperature,
      other,
    );
  }

  @override
  int get hashCode {
    return TemperatureMapper.ensureInitialized().hashValue(this as Temperature);
  }
}

extension TemperatureValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Temperature, $Out> {
  TemperatureCopyWith<$R, Temperature, $Out> get $asTemperature =>
      $base.as((v, t, t2) => _TemperatureCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TemperatureCopyWith<$R, $In extends Temperature, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? degrees, String? unit});
  TemperatureCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TemperatureCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Temperature, $Out>
    implements TemperatureCopyWith<$R, Temperature, $Out> {
  _TemperatureCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Temperature> $mapper =
      TemperatureMapper.ensureInitialized();
  @override
  $R call({double? degrees, String? unit}) => $apply(
    FieldCopyWithData({
      if (degrees != null) #degrees: degrees,
      if (unit != null) #unit: unit,
    }),
  );
  @override
  Temperature $make(CopyWithData data) => Temperature(
    degrees: data.get(#degrees, or: $value.degrees),
    unit: data.get(#unit, or: $value.unit),
  );

  @override
  TemperatureCopyWith<$R2, Temperature, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TemperatureCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class SunEventsMapper extends ClassMapperBase<SunEvents> {
  SunEventsMapper._();

  static SunEventsMapper? _instance;
  static SunEventsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SunEventsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SunEvents';

  static DateTime _$sunriseTime(SunEvents v) => v.sunriseTime;
  static const Field<SunEvents, DateTime> _f$sunriseTime = Field(
    'sunriseTime',
    _$sunriseTime,
  );
  static DateTime _$sunsetTime(SunEvents v) => v.sunsetTime;
  static const Field<SunEvents, DateTime> _f$sunsetTime = Field(
    'sunsetTime',
    _$sunsetTime,
  );

  @override
  final MappableFields<SunEvents> fields = const {
    #sunriseTime: _f$sunriseTime,
    #sunsetTime: _f$sunsetTime,
  };

  static SunEvents _instantiate(DecodingData data) {
    return SunEvents(
      sunriseTime: data.dec(_f$sunriseTime),
      sunsetTime: data.dec(_f$sunsetTime),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SunEvents fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SunEvents>(map);
  }

  static SunEvents fromJson(String json) {
    return ensureInitialized().decodeJson<SunEvents>(json);
  }
}

mixin SunEventsMappable {
  String toJson() {
    return SunEventsMapper.ensureInitialized().encodeJson<SunEvents>(
      this as SunEvents,
    );
  }

  Map<String, dynamic> toMap() {
    return SunEventsMapper.ensureInitialized().encodeMap<SunEvents>(
      this as SunEvents,
    );
  }

  SunEventsCopyWith<SunEvents, SunEvents, SunEvents> get copyWith =>
      _SunEventsCopyWithImpl<SunEvents, SunEvents>(
        this as SunEvents,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SunEventsMapper.ensureInitialized().stringifyValue(
      this as SunEvents,
    );
  }

  @override
  bool operator ==(Object other) {
    return SunEventsMapper.ensureInitialized().equalsValue(
      this as SunEvents,
      other,
    );
  }

  @override
  int get hashCode {
    return SunEventsMapper.ensureInitialized().hashValue(this as SunEvents);
  }
}

extension SunEventsValueCopy<$R, $Out> on ObjectCopyWith<$R, SunEvents, $Out> {
  SunEventsCopyWith<$R, SunEvents, $Out> get $asSunEvents =>
      $base.as((v, t, t2) => _SunEventsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SunEventsCopyWith<$R, $In extends SunEvents, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({DateTime? sunriseTime, DateTime? sunsetTime});
  SunEventsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SunEventsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SunEvents, $Out>
    implements SunEventsCopyWith<$R, SunEvents, $Out> {
  _SunEventsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SunEvents> $mapper =
      SunEventsMapper.ensureInitialized();
  @override
  $R call({DateTime? sunriseTime, DateTime? sunsetTime}) => $apply(
    FieldCopyWithData({
      if (sunriseTime != null) #sunriseTime: sunriseTime,
      if (sunsetTime != null) #sunsetTime: sunsetTime,
    }),
  );
  @override
  SunEvents $make(CopyWithData data) => SunEvents(
    sunriseTime: data.get(#sunriseTime, or: $value.sunriseTime),
    sunsetTime: data.get(#sunsetTime, or: $value.sunsetTime),
  );

  @override
  SunEventsCopyWith<$R2, SunEvents, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SunEventsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MoonEventsMapper extends ClassMapperBase<MoonEvents> {
  MoonEventsMapper._();

  static MoonEventsMapper? _instance;
  static MoonEventsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MoonEventsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MoonEvents';

  static String _$moonPhase(MoonEvents v) => v.moonPhase;
  static const Field<MoonEvents, String> _f$moonPhase = Field(
    'moonPhase',
    _$moonPhase,
  );
  static List<DateTime> _$moonriseTimes(MoonEvents v) => v.moonriseTimes;
  static const Field<MoonEvents, List<DateTime>> _f$moonriseTimes = Field(
    'moonriseTimes',
    _$moonriseTimes,
  );
  static List<DateTime> _$moonsetTimes(MoonEvents v) => v.moonsetTimes;
  static const Field<MoonEvents, List<DateTime>> _f$moonsetTimes = Field(
    'moonsetTimes',
    _$moonsetTimes,
  );

  @override
  final MappableFields<MoonEvents> fields = const {
    #moonPhase: _f$moonPhase,
    #moonriseTimes: _f$moonriseTimes,
    #moonsetTimes: _f$moonsetTimes,
  };

  static MoonEvents _instantiate(DecodingData data) {
    return MoonEvents(
      moonPhase: data.dec(_f$moonPhase),
      moonriseTimes: data.dec(_f$moonriseTimes),
      moonsetTimes: data.dec(_f$moonsetTimes),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MoonEvents fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MoonEvents>(map);
  }

  static MoonEvents fromJson(String json) {
    return ensureInitialized().decodeJson<MoonEvents>(json);
  }
}

mixin MoonEventsMappable {
  String toJson() {
    return MoonEventsMapper.ensureInitialized().encodeJson<MoonEvents>(
      this as MoonEvents,
    );
  }

  Map<String, dynamic> toMap() {
    return MoonEventsMapper.ensureInitialized().encodeMap<MoonEvents>(
      this as MoonEvents,
    );
  }

  MoonEventsCopyWith<MoonEvents, MoonEvents, MoonEvents> get copyWith =>
      _MoonEventsCopyWithImpl<MoonEvents, MoonEvents>(
        this as MoonEvents,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MoonEventsMapper.ensureInitialized().stringifyValue(
      this as MoonEvents,
    );
  }

  @override
  bool operator ==(Object other) {
    return MoonEventsMapper.ensureInitialized().equalsValue(
      this as MoonEvents,
      other,
    );
  }

  @override
  int get hashCode {
    return MoonEventsMapper.ensureInitialized().hashValue(this as MoonEvents);
  }
}

extension MoonEventsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MoonEvents, $Out> {
  MoonEventsCopyWith<$R, MoonEvents, $Out> get $asMoonEvents =>
      $base.as((v, t, t2) => _MoonEventsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MoonEventsCopyWith<$R, $In extends MoonEvents, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, DateTime, ObjectCopyWith<$R, DateTime, DateTime>>
  get moonriseTimes;
  ListCopyWith<$R, DateTime, ObjectCopyWith<$R, DateTime, DateTime>>
  get moonsetTimes;
  $R call({
    String? moonPhase,
    List<DateTime>? moonriseTimes,
    List<DateTime>? moonsetTimes,
  });
  MoonEventsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MoonEventsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MoonEvents, $Out>
    implements MoonEventsCopyWith<$R, MoonEvents, $Out> {
  _MoonEventsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MoonEvents> $mapper =
      MoonEventsMapper.ensureInitialized();
  @override
  ListCopyWith<$R, DateTime, ObjectCopyWith<$R, DateTime, DateTime>>
  get moonriseTimes => ListCopyWith(
    $value.moonriseTimes,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(moonriseTimes: v),
  );
  @override
  ListCopyWith<$R, DateTime, ObjectCopyWith<$R, DateTime, DateTime>>
  get moonsetTimes => ListCopyWith(
    $value.moonsetTimes,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(moonsetTimes: v),
  );
  @override
  $R call({
    String? moonPhase,
    List<DateTime>? moonriseTimes,
    List<DateTime>? moonsetTimes,
  }) => $apply(
    FieldCopyWithData({
      if (moonPhase != null) #moonPhase: moonPhase,
      if (moonriseTimes != null) #moonriseTimes: moonriseTimes,
      if (moonsetTimes != null) #moonsetTimes: moonsetTimes,
    }),
  );
  @override
  MoonEvents $make(CopyWithData data) => MoonEvents(
    moonPhase: data.get(#moonPhase, or: $value.moonPhase),
    moonriseTimes: data.get(#moonriseTimes, or: $value.moonriseTimes),
    moonsetTimes: data.get(#moonsetTimes, or: $value.moonsetTimes),
  );

  @override
  MoonEventsCopyWith<$R2, MoonEvents, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MoonEventsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TimeZoneMapper extends ClassMapperBase<TimeZone> {
  TimeZoneMapper._();

  static TimeZoneMapper? _instance;
  static TimeZoneMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TimeZoneMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TimeZone';

  static String _$id(TimeZone v) => v.id;
  static const Field<TimeZone, String> _f$id = Field('id', _$id);

  @override
  final MappableFields<TimeZone> fields = const {#id: _f$id};

  static TimeZone _instantiate(DecodingData data) {
    return TimeZone(id: data.dec(_f$id));
  }

  @override
  final Function instantiate = _instantiate;

  static TimeZone fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TimeZone>(map);
  }

  static TimeZone fromJson(String json) {
    return ensureInitialized().decodeJson<TimeZone>(json);
  }
}

mixin TimeZoneMappable {
  String toJson() {
    return TimeZoneMapper.ensureInitialized().encodeJson<TimeZone>(
      this as TimeZone,
    );
  }

  Map<String, dynamic> toMap() {
    return TimeZoneMapper.ensureInitialized().encodeMap<TimeZone>(
      this as TimeZone,
    );
  }

  TimeZoneCopyWith<TimeZone, TimeZone, TimeZone> get copyWith =>
      _TimeZoneCopyWithImpl<TimeZone, TimeZone>(
        this as TimeZone,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TimeZoneMapper.ensureInitialized().stringifyValue(this as TimeZone);
  }

  @override
  bool operator ==(Object other) {
    return TimeZoneMapper.ensureInitialized().equalsValue(
      this as TimeZone,
      other,
    );
  }

  @override
  int get hashCode {
    return TimeZoneMapper.ensureInitialized().hashValue(this as TimeZone);
  }
}

extension TimeZoneValueCopy<$R, $Out> on ObjectCopyWith<$R, TimeZone, $Out> {
  TimeZoneCopyWith<$R, TimeZone, $Out> get $asTimeZone =>
      $base.as((v, t, t2) => _TimeZoneCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TimeZoneCopyWith<$R, $In extends TimeZone, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id});
  TimeZoneCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TimeZoneCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TimeZone, $Out>
    implements TimeZoneCopyWith<$R, TimeZone, $Out> {
  _TimeZoneCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TimeZone> $mapper =
      TimeZoneMapper.ensureInitialized();
  @override
  $R call({String? id}) => $apply(FieldCopyWithData({if (id != null) #id: id}));
  @override
  TimeZone $make(CopyWithData data) =>
      TimeZone(id: data.get(#id, or: $value.id));

  @override
  TimeZoneCopyWith<$R2, TimeZone, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TimeZoneCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

