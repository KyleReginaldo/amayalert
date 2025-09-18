import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/divider/custom_divider.dart';
import 'package:amayalert/core/widgets/input/custom_text_field.dart';
import 'package:amayalert/core/widgets/input/search_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/weather/weather_container.dart';
import 'package:amayalert/feature/weather/weather_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../dependency.dart';

@RoutePage()
class HomeScreen extends StatefulWidget implements AutoRouteWrapper {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<WeatherRepository>(),
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
              SearchTextField(
                controller: _searchController,
                hint: 'Search here...',
              ),
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
              Center(
                child: CustomText(
                  text: 'No posts available.',
                  color: AppColors.textSecondaryLight,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
