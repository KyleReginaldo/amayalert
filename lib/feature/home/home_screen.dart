import 'dart:convert';

import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/services/badge_service.dart';
import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/notification_badge.dart';
import 'package:amayalert/feature/alerts/alert_model.dart';
import 'package:amayalert/feature/alerts/alert_repository.dart';
import 'package:amayalert/feature/evacuation/evacuation_repository.dart';
import 'package:amayalert/feature/home/widgets/hotline_container.dart';
import 'package:amayalert/feature/posts/post_repository.dart';
import 'package:amayalert/feature/posts/posts_list_widget.dart';
import 'package:amayalert/feature/profile/profile_model.dart';
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
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constant/constant.dart';
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
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      supabase
          .channel('public:posts')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'posts',
            callback: (_) => context.read<PostRepository>().loadPosts(),
          )
          .subscribe();

      context.read<PostRepository>().loadPosts();
      context.read<AlertRepository>().loadAlerts();
      context.read<EvacuationRepository>().getEvacuationCenters();
      context.read<ProfileRepository>().getUserProfile(userID ?? '');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _getCurrentLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse) {
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        context.read<WeatherRepository>().getWeather(
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
      }
    }
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      setState(() => _showSearchResults = false);
      context.read<SearchRepository>().clearSearch();
    } else {
      setState(() => _showSearchResults = true);
      context.read<SearchRepository>().search(q);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _showSearchResults = false);
    context.read<SearchRepository>().clearSearch();
  }

  bool get _isGuest =>
      Supabase.instance.client.auth.currentUser?.isAnonymous ?? false;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final weather = context.select((WeatherRepository r) => r.weather);
    final weatherLoading = context.select((WeatherRepository r) => r.isLoading);
    final weatherError = context.select(
      (WeatherRepository r) => r.errorMessage,
    );
    final profile = context.select((ProfileRepository r) => r.profile);

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          final postRepo = context.read<PostRepository>();
          final alertRepo = context.read<AlertRepository>();
          final evacRepo = context.read<EvacuationRepository>();
          _getCurrentLocation();
          await postRepo.loadPosts();
          await alertRepo.loadAlerts();
          evacRepo.getEvacuationCenters();
        },
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 1,
              toolbarHeight: 72,
              automaticallyImplyLeading: false,
              title: _buildAppBarTitle(profile),
              actions: [
                // _buildNotificationBell(context),
                _buildMenuButton(context, profile),
                const SizedBox(width: 4),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Search
                  _buildSearch(context),
                  const SizedBox(height: 12),

                  if (_showSearchResults) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Consumer<SearchRepository>(
                        builder: (_, repo, __) => repo.isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : SearchResultsWidget(
                                results: repo.searchResults,
                                query: repo.currentQuery,
                                onClear: _clearSearch,
                              ),
                      ),
                    ),
                  ] else ...[
                    // Weather card
                    WeatherContainer(
                      isLoading: weatherLoading,
                      errorMessage: weatherError,
                      weather: weather,
                      onViewForecast: weather != null
                          ? () => _showWeatherSheet(context, weather)
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Emergency Services
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildEmergencySection(context),
                    ),
                    const SizedBox(height: 16),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildQuickActions(context),
                    ),
                    const SizedBox(height: 16),
                    // Post composer (non-guests)
                    if (!_isGuest)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildPostComposer(context, profile),
                      ),
                    // Community posts
                    _buildPostsSection(context),
                  ],

                  const SizedBox(height: 100), // nav bar clearance
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBarTitle(Profile? profile) {
    final firstName = profile?.fullName.split(' ').firstOrNull ?? 'there';
    return Row(
      children: [
        GestureDetector(
          onTap: () => AutoTabsRouter.of(context).setActiveIndex(3),
          child: _buildAvatar(profile),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_greeting()}, $firstName! 👋',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'Stay informed. Stay safe.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(Profile? profile) {
    final initials = profile?.fullName.isNotEmpty == true
        ? profile!.fullName.trim()[0].toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundImage: profile?.profilePicture != null
          ? NetworkImage(profile!.profilePicture!)
          : null,
      child: profile?.profilePicture == null
          ? Text(
              initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            )
          : null,
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    final count = BadgeService().unreadActivityCount;
    return IconButton(
      onPressed: () => context.router.push(const MapRoute()),
      icon: NotificationBadge(
        count: count,
        child: const Icon(
          LucideIcons.bell,
          color: AppColors.textPrimaryLight,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, Profile? profile) {
    return IconButton(
      onPressed: profile != null
          ? () => _showFeedbackDialog(profile.email)
          : null,
      icon: const Icon(
        LucideIcons.messageCirclePlus,
        color: AppColors.textPrimaryLight,
        size: 22,
      ),
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Icon(
                LucideIcons.search,
                color: AppColors.gray400,
                size: 18,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search alerts, posts, evacuation centers...',
                  hintStyle: TextStyle(color: AppColors.gray400, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 13,
                  ),
                  isDense: true,
                  fillColor: Colors.transparent,
                  filled: true,
                ),
              ),
            ),
            if (_showSearchResults)
              IconButton(
                onPressed: _clearSearch,
                icon: const Icon(
                  LucideIcons.x,
                  color: AppColors.gray400,
                  size: 18,
                ),
                padding: const EdgeInsets.only(right: 8),
              ),
          ],
        ),
      ),
    );
  }

  // ── Emergency Section ─────────────────────────────────────────────────────

  Widget _buildEmergencySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Emergency Services',
          'See all',
          onMore: () {
            context.router.push(const RescueListRoute());
          },
        ),
        const SizedBox(height: 12),

        // Main SOS card
        _EmergencyCard(
          onTap: () => context.router.push(const CreateRescueRoute()),
        ),
        const SizedBox(height: 10),

        // Three mini action cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Expanded(
              child: _MiniActionCard(
                icon: LucideIcons.phone,
                label: 'Hotline',
                sublabel: 'Emergency hotlines',
                color: AppColors.danger,
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) =>
                      const SizedBox(height: 520, child: HotlineContainer()),
                ),
              ),
            ),
            Expanded(
              child: _MiniActionCard(
                icon: LucideIcons.mapPin,
                label: 'Evacuation',
                sublabel: 'Find safe locations',
                color: AppColors.primary,
                onTap: () => context.router.push(const MapRoute()),
              ),
            ),
            Expanded(
              child: _MiniActionCard(
                icon: LucideIcons.clipboardList,
                label: 'Requests',
                sublabel: 'Track your requests',
                color: const Color(0xFF2E7D32),
                onTap: () => context.router.push(const RescueListRoute()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(LucideIcons.waves, 'Weather', const Color(0xFF1D6BF3)),
      _QuickAction(LucideIcons.map, 'Hazard Map', const Color(0xFF2E7D32)),
      _QuickAction(LucideIcons.siren, 'Alerts', const Color(0xFF7C3AED)),
      _QuickAction(LucideIcons.shield, 'Safety Tips', const Color(0xFFF59E0B)),
      _QuickAction(LucideIcons.phone, 'Contacts', const Color(0xFF0891B2)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Quick Actions', null),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((a) {
            return _QuickActionButton(
              action: a,
              onTap: () => _onQuickAction(context, a.label),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _onQuickAction(BuildContext context, String label) {
    switch (label) {
      case 'Weather':
        final weather = context.read<WeatherRepository>().weather;
        if (weather != null) _showWeatherSheet(context, weather);
      case 'Hazard Map':
        context.router.push(const MapRoute());
      case 'Alerts':
        _showAlertsSheet(context);
      case 'Safety Tips':
        _showSafetyTipsSheet(context);
      case 'Contacts':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) =>
              const SizedBox(height: 520, child: HotlineContainer()),
        );
    }
  }

  void _showWeatherSheet(BuildContext context, Weather weather) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _WeatherForecastSheet(weather: weather),
    );
  }

  void _showAlertsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: sl<AlertRepository>(),
        child: const _AlertsSheet(),
      ),
    );
  }

  void _showSafetyTipsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _SafetyTipsSheet(),
    );
  }

  // ── Posts section ─────────────────────────────────────────────────────────

  Widget _buildPostComposer(BuildContext context, Profile? profile) {
    return GestureDetector(
      onTap: () => _onCreatePost(context, profile),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _buildAvatar(profile),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "What's happening in your area?",
                style: TextStyle(fontSize: 14, color: AppColors.gray400),
              ),
            ),
            GestureDetector(
              onTap: () => _onCreatePost(context, profile),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Post',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCreatePost(BuildContext context, Profile? profile) {
    if (profile?.suspended == true) {
      EasyLoading.showError(
        'Your account has been suspended.\nPlease contact support.',
        duration: const Duration(seconds: 5),
      );
      return;
    }
    context.router.push(const CreatePostsRoute());
  }

  Widget _buildPostsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _sectionHeader("What's happening in Amaya V?", null),
        ),
        const SizedBox(height: 8),
        const PostsListWidget(),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionHeader(
    String title,
    String? moreLabel, {
    VoidCallback? onMore,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ),
        if (moreLabel != null)
          GestureDetector(
            onTap: onMore,
            child: Row(
              children: [
                Text(
                  moreLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Feedback dialog ───────────────────────────────────────────────────────

  void _showFeedbackDialog(String from) {
    showDialog(
      context: context,
      builder: (_) =>
          _FeedbackDialog(onSend: (text) => _sendFeedback(from, text)),
    );
  }

  void _sendFeedback(String from, String text) async {
    final response = await http.post(
      Uri.parse('https://amayalert.site/api/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'to': 'amayalert1@gmail.com',
        'subject': 'Feedback',
        'html': '<p>From: $from</p><p>$text</p>',
        'type': 'single-email',
      }),
    );
    if (response.statusCode == 200) {
      EasyLoading.showSuccess('Feedback sent!');
    } else {
      EasyLoading.showError('Failed to send feedback.');
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _EmergencyCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EmergencyCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.danger,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/emergency_report.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REPORT EMERGENCY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Get immediate assistance',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.arrowRight,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _MiniActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: AppColors.gray400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction(this.icon, this.label, this.color);
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  final VoidCallback onTap;
  const _QuickActionButton({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(action.icon, color: action.color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weather Forecast Sheet ────────────────────────────────────────────────────

class _WeatherForecastSheet extends StatelessWidget {
  final Weather weather;
  const _WeatherForecastSheet({required this.weather});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.waves,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Weather Forecast',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              padding: const EdgeInsets.all(16),
              itemCount: weather.forecastDays.length,
              itemBuilder: (_, i) =>
                  _ForecastDayTile(day: weather.forecastDays[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastDayTile extends StatelessWidget {
  final ForecastDay day;
  const _ForecastDayTile({required this.day});

  @override
  Widget build(BuildContext context) {
    final dayName = _dayName(day.displayDate);
    final date = '${day.displayDate.month}/${day.displayDate.day}';
    final iconUrl = '${day.daytimeForecast.weatherCondition.iconBaseUri}.png';
    final condition = day.daytimeForecast.weatherCondition.description.text;
    final max = day.maxTemperature.degrees.toStringAsFixed(0);
    final min = day.minTemperature.degrees.toStringAsFixed(0);
    final feelsLike = day.feelsLikeMaxTemperature.degrees.toStringAsFixed(0);
    final humidity = day.daytimeForecast.relativeHumidity;
    final uv = day.daytimeForecast.uvIndex;
    final rain = day.daytimeForecast.precipitation.probability.percent;
    final wind = day.daytimeForecast.wind.speed.value.toStringAsFixed(0);
    final windDir = day.daytimeForecast.wind.direction.cardinal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                CachedNetworkImageWrapper(iconUrl: iconUrl),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '$max° / $min°',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Details grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DetailChip(
                  LucideIcons.thermometer,
                  'Feels like $feelsLike°',
                  AppColors.danger,
                ),
                _DetailChip(
                  LucideIcons.droplets,
                  'Humidity $humidity%',
                  AppColors.info,
                ),
                _DetailChip(LucideIcons.zap, 'UV Index $uv', AppColors.warning),
                _DetailChip(
                  LucideIcons.cloud,
                  'Rain $rain%',
                  AppColors.primary,
                ),
                _DetailChip(
                  LucideIcons.wind,
                  'Wind $wind km/h $windDir',
                  AppColors.success,
                ),
                _DetailChip(LucideIcons.sun, condition, AppColors.gray500),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dayName(DisplayDate d) {
    final dt = DateTime(d.year, d.month, d.day);
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[dt.weekday - 1];
  }
}

class CachedNetworkImageWrapper extends StatelessWidget {
  final String iconUrl;
  const CachedNetworkImageWrapper({super.key, required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      iconUrl,
      width: 36,
      height: 36,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          const Icon(LucideIcons.cloud, size: 28, color: AppColors.primary),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _DetailChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Alerts Sheet ──────────────────────────────────────────────────────────────

class _AlertsSheet extends StatefulWidget {
  const _AlertsSheet();

  @override
  State<_AlertsSheet> createState() => _AlertsSheetState();
}

class _AlertsSheetState extends State<_AlertsSheet> {
  late final AlertRepository _repo = sl<AlertRepository>();

  @override
  void initState() {
    super.initState();
    _repo.loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (_, _) {
        final alerts = _repo.alerts;
        final isLoading = _repo.isLoading;
        final error = _repo.errorMessage;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          expand: false,
          builder: (_, ctrl) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.siren,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Active Alerts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (alerts.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${alerts.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Error: $error',
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : alerts.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.checkCheck,
                              size: 40,
                              color: AppColors.success,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No active alerts',
                              style: TextStyle(color: AppColors.gray500),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: ctrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: alerts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _AlertTile(alert: alerts[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AlertTile extends StatelessWidget {
  final Alert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _color(alert.level);
    final label = _label(alert.level);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(width: 4, color: color),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Level badge + time row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_icon(alert.level),
                                    size: 11, color: color),
                                const SizedBox(width: 4),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (alert.createdAt != null)
                            Text(
                              timeago.format(alert.createdAt!),
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.gray400),
                            ),
                        ],
                      ),

                      // Title
                      if (alert.title?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Text(
                          alert.title!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                            height: 1.3,
                          ),
                        ),
                      ],

                      // Description
                      if (alert.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          alert.description!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                            height: 1.45,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Location
                      if (alert.location?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin,
                                size: 11, color: AppColors.gray400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                alert.location!,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.gray400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _color(AlertLevel? l) => switch (l) {
        AlertLevel.low => AppColors.info,
        AlertLevel.medium => AppColors.warning,
        AlertLevel.high => AppColors.danger,
        AlertLevel.critical => const Color(0xFF7C3AED),
        _ => AppColors.gray500,
      };

  IconData _icon(AlertLevel? l) => switch (l) {
        AlertLevel.low => LucideIcons.info,
        AlertLevel.medium => LucideIcons.triangle,
        AlertLevel.high => LucideIcons.siren,
        AlertLevel.critical => LucideIcons.zap,
        _ => LucideIcons.bell,
      };

  String _label(AlertLevel? l) => switch (l) {
        AlertLevel.low => 'LOW',
        AlertLevel.medium => 'MODERATE',
        AlertLevel.high => 'HIGH',
        AlertLevel.critical => 'CRITICAL',
        _ => 'ALERT',
      };
}

// ── Safety Tips Sheet ─────────────────────────────────────────────────────────

class _SafetyTipsSheet extends StatelessWidget {
  const _SafetyTipsSheet();

  static const _tips = [
    _Tip(LucideIcons.waves, 'Flood', AppColors.info, [
      'Move to higher ground immediately when water rises.',
      'Do not walk or drive through floodwater.',
      'Turn off electricity at the main switch.',
      'Keep emergency numbers ready: NDRRMC 911.',
    ]),
    _Tip(LucideIcons.zap, 'Typhoon', Color(0xFF7C3AED), [
      'Secure loose objects outside your home.',
      'Stay indoors away from windows.',
      'Keep a 72-hour emergency kit ready.',
      'Monitor PAGASA updates regularly.',
    ]),
    _Tip(LucideIcons.flame, 'Fire', AppColors.danger, [
      'Evacuate immediately — do not use the elevator.',
      'Stay low to avoid smoke inhalation.',
      'Close doors to slow fire spread.',
      'Call BFP: 160 or 911 immediately.',
    ]),
    _Tip(LucideIcons.activity, 'Earthquake', AppColors.warning, [
      'Drop, Cover, and Hold On.',
      'Stay away from windows and heavy objects.',
      'After shaking stops, evacuate carefully.',
      'Expect aftershocks — stay alert.',
    ]),
    _Tip(LucideIcons.heartPulse, 'Medical Emergency', AppColors.success, [
      'Call 911 or the nearest hospital immediately.',
      'Do not move someone with a suspected spinal injury.',
      'Apply pressure to stop bleeding with clean cloth.',
      'Keep the person calm and still until help arrives.',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: const [
                Icon(LucideIcons.shield, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Safety Tips',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              controller: ctrl,
              padding: const EdgeInsets.all(16),
              itemCount: _tips.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _TipCard(tip: _tips[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> items;
  const _Tip(this.icon, this.title, this.color, this.items);
}

class _TipCard extends StatelessWidget {
  final _Tip tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: tip.color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(tip.icon, size: 16, color: tip.color),
                const SizedBox(width: 8),
                Text(
                  tip.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: tip.color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: tip.items
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: tip.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FeedbackDialog extends StatefulWidget {
  final Function(String) onSend;
  const _FeedbackDialog({required this.onSend});

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(LucideIcons.messageCirclePlus, color: AppColors.primary),
          SizedBox(width: 10),
          Text(
            'Send Feedback',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: TextField(
        controller: _ctrl,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Tell us what you think...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final text = _ctrl.text.trim();
            if (text.isNotEmpty) {
              widget.onSend(text);
              Navigator.pop(context);
            }
          },
          icon: const Icon(LucideIcons.send, size: 16),
          label: const Text('Send'),
        ),
      ],
    );
  }
}
