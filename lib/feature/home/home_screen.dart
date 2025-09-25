import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/widgets/divider/custom_divider.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/input/search_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/alerts/alert_banner_widget.dart';
import 'package:amayalert/feature/alerts/alert_repository.dart';
import 'package:amayalert/feature/messages/test_users_widget.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:amayalert/feature/posts/posts_list_widget.dart';
import 'package:amayalert/feature/weather/weather_container.dart';
import 'package:amayalert/feature/weather/weather_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../dependency.dart';

@RoutePage()
class HomeScreen extends StatefulWidget implements AutoRouteWrapper {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<WeatherRepository>()),
        ChangeNotifierProvider.value(value: sl<PostRepository>()),
        ChangeNotifierProvider.value(value: sl<AlertRepository>()),
      ],
      child: this,
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  LatLng? _latlng;

  void getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    bool approved =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    if (!approved) {
      permission = await Geolocator.requestPermission();
      approved =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    }
    if (approved) {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latlng = LatLng(position.latitude, position.longitude);
      });
      getWeatherData();
    }
  }

  void getWeatherData() async {
    if (_latlng != null) {
      context.read<WeatherRepository>().getWeather(
        latitude: _latlng!.latitude,
        longitude: _latlng!.longitude,
      );
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.select((WeatherRepository bloc) => bloc.weather);
    final isLoading = context.select(
      (WeatherRepository bloc) => bloc.isLoading,
    );
    final errorMessage = context.select(
      (WeatherRepository bloc) => bloc.errorMessage,
    );
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alert banner for emergency alerts
              ChangeNotifierProvider.value(
                value: sl<AlertRepository>(),
                child: const AlertBannerWidget(),
              ),

              SearchTextField(
                controller: _searchController,
                hint: 'Search here...',
              ),
              const AlertBannerWidget(),
              WeatherContainer(
                isLoading: isLoading,
                errorMessage: errorMessage,
                weather: weather,
              ),
              CustomDivider(
                endIndent: 0,
                indent: 0,
                thickness: 4,
                color: Colors.grey.shade300,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _postController,
                      hint: 'What\'s on your mind?',
                      onTap: () {
                        context.router.push(const CreatePostsRoute());
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.router.push(const CreatePostsRoute());
                    },
                    icon: Icon(LucideIcons.camera),
                    style: ButtonStyle().copyWith(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      backgroundColor: WidgetStatePropertyAll(Colors.black),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                  ),
                ],
              ),
              CustomDivider(
                endIndent: 0,
                indent: 0,
                thickness: 4,
                color: Colors.grey.shade300,
              ),
              CustomText(text: 'New Posts', color: AppColors.textPrimaryLight),
              const SizedBox(height: 8),

              // Test widget for development
              const TestUsersWidget(),
              const SizedBox(height: 16),

              const PostsListWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
