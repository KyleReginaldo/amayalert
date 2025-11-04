import 'package:amayalert/core/services/auth_storage_service.dart';
import 'package:amayalert/feature/activity/activity_repository.dart';
import 'package:amayalert/feature/alerts/alert_provider.dart';
import 'package:amayalert/feature/alerts/alert_repository.dart';
import 'package:amayalert/feature/evacuation/evacuation_provider.dart';
import 'package:amayalert/feature/evacuation/evacuation_repository.dart';
import 'package:amayalert/feature/messages/enhanced_message_repository.dart';
import 'package:amayalert/feature/messages/message_repository.dart';
import 'package:amayalert/feature/posts/post_provider.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:amayalert/feature/profile/profile_provider.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:amayalert/feature/search/search_repository.dart';
import 'package:amayalert/feature/weather/weather_provider.dart';
import 'package:amayalert/feature/weather/weather_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feature/messages/message_provider.dart';

final sl = GetIt.instance;

Future init() async {
  sl.registerLazySingleton(() => WeatherRepository(provider: sl()));
  sl.registerLazySingleton(() => WeatherProvider());
  sl.registerLazySingleton(() => ProfileProvider());
  sl.registerLazySingleton(() => ProfileRepository(provider: sl()));
  sl.registerLazySingleton(() => PostProvider());
  sl.registerLazySingleton(() => PostRepository(provider: sl()));
  sl.registerLazySingleton(() => AlertProvider());
  sl.registerLazySingleton(() => AlertRepository(provider: sl()));
  sl.registerLazySingleton(() => MessageProvider());
  sl.registerLazySingleton(() => MessageRepository(provider: sl()));
  sl.registerLazySingleton(() => EnhancedMessageRepository());
  sl.registerLazySingleton(() => EvacuationRepository(provider: sl()));
  sl.registerLazySingleton(() => EvacuationProvider());
  sl.registerLazySingleton(() => ActivityRepository());
  sl.registerLazySingleton(
    () => SearchRepository(
      postRepository: sl(),
      alertRepository: sl(),
      evacuationRepository: sl(),
      activityRepository: sl(),
    ),
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => AuthStorageService(sl()));
}
