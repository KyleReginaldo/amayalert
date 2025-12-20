import 'dart:convert';

import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/widgets/input/search_field.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/alerts/alert_banner_widget.dart';
import 'package:amayalert/feature/alerts/alert_repository.dart';
import 'package:amayalert/feature/evacuation/evacuation_repository.dart';
import 'package:amayalert/feature/home/widgets/hotline_container.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:amayalert/feature/posts/posts_list_widget.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:amayalert/feature/reports/report_repository.dart';
import 'package:amayalert/feature/search/search_repository.dart';
import 'package:amayalert/feature/search/search_results_widget.dart';
import 'package:amayalert/feature/weather/weather_container.dart';
import 'package:amayalert/feature/weather/weather_model.dart';
import 'package:amayalert/feature/weather/weather_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
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
        ChangeNotifierProvider.value(value: sl<ReportRepository>()),
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
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

      context.read<PostRepository>().loadPosts();
      context.read<AlertRepository>().loadAlerts();
      context.read<EvacuationRepository>().getEvacuationCenters();
      context.read<ProfileRepository>().getUserProfile(userID ?? '');
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

  void sendFeedBack(String to, String text, String from) async {
    final response = await http.post(
      Uri.parse('https://amayalert.site/api/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'to': to,
        'subject': 'Feedback',
        'html':
            """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Feedback</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f5f5f5;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f5f5f5; padding: 20px;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center;">
                            <h1 style="margin: 0; color: #ffffff; font-size: 24px; font-weight: 600;">New Feedback Received</h1>
                        </td>
                    </tr>
                    
                    <!-- Content -->
                    <tr>
                        <td style="padding: 30px;">
                            <p style="margin: 0 0 20px 0; color: #666666; font-size: 14px;">You have received new feedback from a user:</p>
                            
                            <!-- Feedback Box -->
                            <div style="background-color: #f8f9fa; border-left: 4px solid #667eea; padding: 20px; margin: 20px 0; border-radius: 4px;">
                                <p style="margin: 0; color: #333333; font-size: 15px; line-height: 1.6; white-space: pre-wrap;">$text</p>
                            </div>
                            
                            <!-- User Info -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin-top: 30px; border-top: 1px solid #e0e0e0; padding-top: 20px;">
                                <tr>
                                    <td style="padding: 8px 0;">
                                        <span style="color: #999999; font-size: 13px; font-weight: 500;">From:</span>
                                        <span style="color: #333333; font-size: 14px; margin-left: 8px;">$from</span>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 8px 0;">
                                        <span style="color: #999999; font-size: 13px; font-weight: 500;">Date:</span>
                                        <span style="color: #333333; font-size: 14px; margin-left: 8px;">${DateTime.now().toString().split('.')[0]}</span>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #f8f9fa; padding: 20px; text-align: center; border-top: 1px solid #e0e0e0;">
                            <p style="margin: 0; color: #999999; font-size: 12px;">
                                This is an automated message from Amayalert<br>
                                © ${DateTime.now().year} Amayalert. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
""",
        'type': 'single-email',
      }),
    );
    debugPrint('Feedback response body: ${response.body}');
    if (response.statusCode == 200) {
      EasyLoading.showSuccess('Feedback sent successfully!');
      // Feedback sent successfully
    } else {
      // Handle error
      EasyLoading.showError('Failed to send feedback. Please try again.');
    }
  }

  void _showFeedbackDialog(String from) {
    showDialog(
      context: context,
      builder: (dialogContext) => _FeedbackDialog(
        onSend: (feedback) {
          sendFeedBack('amayalert.site@gmail.com', feedback, from);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Feedback sent successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.select((WeatherRepository bloc) => bloc.weather);
    final profile = context.select((ProfileRepository bloc) => bloc.profile);
    final isLoading = context.select(
      (WeatherRepository bloc) => bloc.isLoading,
    );
    final errorMessage = context.select(
      (WeatherRepository bloc) => bloc.errorMessage,
    );

    return SafeArea(
      top: false,
      child: Scaffold(
        floatingActionButton: profile != null
            ? FloatingActionButton(
                onPressed: () {
                  _showFeedbackDialog(profile.email);
                },
                child: Icon(LucideIcons.messageCirclePlus, color: Colors.white),
              )
            : null,
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
              key: const PageStorageKey('home_scroll_view'),
              slivers: [
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

                SliverPadding(
                  padding: EdgeInsets.zero,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildAlertSection(),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSearchSection(),
                      ),

                      if (!_showSearchResults) ...[
                        const SizedBox(height: 16),
                        HotlineContainer(),
                        const SizedBox(height: 16),

                        _buildWeatherSection(weather, isLoading, errorMessage),
                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildEmergencyActionsSection(context),
                        ),
                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildQuickActionsSection(context),
                        ),
                        const SizedBox(height: 16),

                        _buildPostsSection(),
                      ],

                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
              ],
            ),
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
      return const Color(0xFF64B5F6);
    } else if (hour < 17) {
      return const Color(0xFFFFB74D);
    } else {
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
    return WeatherContainer(
      isLoading: isLoading,
      errorMessage: errorMessage,
      weather: weather,
    );
  }

  Widget _buildEmergencyActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Emergency Hotline Services',
          fontSize: 15,
          color: Colors.black87,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
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
                          Image.asset(
                            'assets/images/emergency_report.png',
                            height: 64,
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
                          Image.asset(
                            'assets/images/emergency_list.png',
                            height: 64,
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
          fontSize: 15,
          color: Colors.black87,
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
      spacing: 8,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CustomText(
            text: 'Community Updates',
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const PostsListWidget(),
      ],
    );
  }
}

class _FeedbackDialog extends StatefulWidget {
  final Function(String feedback) onSend;

  const _FeedbackDialog({required this.onSend});

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(LucideIcons.messageCirclePlus, color: AppColors.primary),
          const SizedBox(width: 12),
          const CustomText(
            text: 'Send Feedback',
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'Message',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tell us what you think...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const CustomText(text: 'Cancel', color: AppColors.gray600),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final feedback = _feedbackController.text.trim();

            if (feedback.isNotEmpty) {
              widget.onSend(feedback);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all fields'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          icon: const Icon(LucideIcons.send, size: 18),
          label: const CustomText(text: 'Send', color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
