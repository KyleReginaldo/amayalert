import 'package:amayalert/dependency.dart';
import 'package:amayalert/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_route.dart';
import 'core/services/notification_handler.dart';
import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  init();
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_SERVICE_ROLE'),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
      eventsPerSecond: 10,
    ),
    debug: true, // Enable debug mode for development
  );
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.initialize('1811210d-e4b7-4304-8cd5-3de7a1da8e26');
  debugPrint(
    'OneSignal SDK initialized: ${await OneSignal.User.getExternalId()}',
  );
  OneSignal.Notifications.requestPermission(false);
  NotificationHandler.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Amayalert',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,
      routerConfig: appRouter.config(),
      builder: EasyLoading.init(),
    );
  }
}

// void _handleOneSignalLogin() async {
//   final deviceToken = await getDeviceToken();
//   if (deviceToken != null) {
//     await OneSignal.login(deviceToken);
//   }
// }
