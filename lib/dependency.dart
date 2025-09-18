import 'package:amayalert/feature/profile/profile_provider.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:amayalert/feature/weather/weather_provider.dart';
import 'package:amayalert/feature/weather/weather_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future init() async {
  sl.registerLazySingleton(() => WeatherRepository(provider: sl()));
  sl.registerLazySingleton(() => WeatherProvider());
  sl.registerLazySingleton(() => ProfileProvider());
  sl.registerLazySingleton(() => ProfileRepository(provider: sl()));
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
