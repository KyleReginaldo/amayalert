import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/widgets/input/search_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/alerts/alert_banner_widget.dart';
import 'package:amayalert/feature/alerts/alert_repository.dart';
import 'package:amayalert/feature/evacuation/evacuation_repository.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:amayalert/feature/posts/posts_list_widget.dart';
import 'package:amayalert/feature/search/search_repository.dart';
import 'package:amayalert/feature/search/search_results_widget.dart';
import 'package:amayalert/feature/weather/weather_container.dart';
import 'package:amayalert/feature/weather/weather_model.dart';
import 'package:amayalert/feature/weather/weather_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constant/constant.dart';
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
        ChangeNotifierProvider.value(value: sl<EvacuationRepository>()),
        ChangeNotifierProvider.value(value: sl<SearchRepository>()),
      ],
      child: this,
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  LatLng? _latlng;
  RealtimeChannel postChannel = supabase.channel('public:posts');
  bool _showSearchResults = false;

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

    // Setup search listener
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        setState(() {
          _showSearchResults = false;
        });
        context.read<SearchRepository>().clearSearch();
      } else {
        setState(() {
          _showSearchResults = true;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      postChannel = supabase
          .channel('public:posts')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'posts',
            callback: (payload) {
              context.read<PostRepository>().loadPosts();
            },
          )
          .subscribe();

      // Load initial data for search
      context.read<PostRepository>().loadPosts();
      context.read<AlertRepository>().loadAlerts();
      context.read<EvacuationRepository>().getEvacuationCenters();
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchRepository>().search(query.trim());
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showSearchResults = false;
    });
    context.read<SearchRepository>().clearSearch();
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getGradientTopColor(),
              AppColors.gray50.withValues(alpha: 0.3),
              Colors.white,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            getCurrentLocation();
            await context.read<PostRepository>().loadPosts();
            await context.read<AlertRepository>().loadAlerts();
            context.read<EvacuationRepository>().getEvacuationCenters();
          },
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                expandedHeight: 120,
                floating: true,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Good ${_getGreeting()}',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryDark,
                        ),
                        CustomText(
                          text: 'Stay informed, stay safe',
                          fontSize: 16,
                          color: AppColors.textPrimaryDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Emergency Alert Section (always shown)
                    _buildAlertSection(),
                    const SizedBox(height: 24),

                    // Search Section (always shown)
                    _buildSearchSection(),

                    // Regular content (hidden when showing search results)
                    if (!_showSearchResults) ...[
                      const SizedBox(height: 24),

                      // Weather Section
                      _buildWeatherSection(weather, isLoading, errorMessage),
                      const SizedBox(height: 32),

                      // Emergency Actions Section
                      _buildEmergencyActionsSection(context),
                      const SizedBox(height: 32),

                      // Quick Actions Section
                      _buildQuickActionsSection(context),
                      const SizedBox(height: 32),

                      // Posts Section
                      _buildPostsSection(),
                    ],

                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Color _getGradientTopColor() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      // Morning - soft blue/purple gradient
      return const Color(0xFF64B5F6);
    } else if (hour < 17) {
      // Afternoon - warm golden/orange gradient
      return const Color(0xFFFFB74D);
    } else {
      // Evening - deep purple/pink gradient
      return const Color(0xFF7986CB);
    }
  }

  Widget _buildAlertSection() {
    return ChangeNotifierProvider.value(
      value: sl<AlertRepository>(),
      child: const AlertBannerWidget(),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SearchTextField(
            controller: _searchController,
            hint: 'Search emergency info, weather, posts...',
            onChanged: _onSearchChanged,
          ),
        ),

        // Search Results
        if (_showSearchResults) ...[
          const SizedBox(height: 16),
          Consumer<SearchRepository>(
            builder: (context, searchRepo, child) {
              if (searchRepo.isSearching) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              return SearchResultsWidget(
                results: searchRepo.searchResults,
                query: searchRepo.currentQuery,
                onClear: _clearSearch,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildWeatherSection(
    Weather? weather,
    bool isLoading,
    String? errorMessage,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: WeatherContainer(
          isLoading: isLoading,
          errorMessage: errorMessage,
          weather: weather,
        ),
      ),
    );
  }

  Widget _buildEmergencyActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Emergency Services',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Report Emergency Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.router.push(const CreateRescueRoute()),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.shield,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const CustomText(
                            text: 'Report\nEmergency',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // View Rescues Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.router.push(const RescueListRoute()),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.list,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const CustomText(
                            text: 'View\nRequests',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Share Your Thoughts',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Avatar placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.user,
                  color: AppColors.gray500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Post input
              Expanded(
                child: GestureDetector(
                  onTap: () => context.router.push(const CreatePostsRoute()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: CustomText(
                      text: 'What\'s happening in your area?',
                      color: AppColors.textSecondaryLight,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Camera button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.router.push(const CreatePostsRoute()),
                    borderRadius: BorderRadius.circular(22),
                    child: const Icon(
                      LucideIcons.camera,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Community Updates',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const PostsListWidget(),
        ),
      ],
    );
  }
}
