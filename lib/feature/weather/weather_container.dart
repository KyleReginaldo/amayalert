import 'package:amayalert/core/utils/helper.dart';
import 'package:amayalert/feature/weather/weather_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WeatherContainer extends StatelessWidget {
  final String? errorMessage;
  final bool isLoading;
  final Weather? weather;
  final VoidCallback? onViewForecast;

  const WeatherContainer({
    super.key,
    this.errorMessage,
    required this.isLoading,
    this.weather,
    this.onViewForecast,
  });

  static const _gradientStart = Color(0xFF1A6BF3);
  static const _gradientEnd = Color(0xFF4DA6FF);
  static const _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_gradientStart, _gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _gradientStart.withValues(alpha: 0.35),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _buildBody(onViewForecast),
      ),
    );
  }

  Widget _buildBody(VoidCallback? onViewForecast) {
    if (isLoading) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(color: _white),
        ),
      );
    }

    if (weather == null || weather!.forecastDays.isEmpty) {
      return const SizedBox.shrink();
    }

    final today = weather!.forecastDays.first;
    final next = weather!.forecastDays.skip(1).take(3).toList();

    final tempStr = '${today.maxTemperature.degrees.toStringAsFixed(0)}°C';
    final condition = today.daytimeForecast.weatherCondition.description.text;
    final iconUrl = '${today.daytimeForecast.weatherCondition.iconBaseUri}.png';

    final precip = today.daytimeForecast.precipitation.probability.percent;
    final riskLabel = precip >= 70
        ? 'High Risk'
        : precip >= 40
            ? 'Moderate Risk'
            : 'Low Risk';
    final riskColor = precip >= 70
        ? const Color(0xFFFF6B6B)
        : precip >= 40
            ? const Color(0xFFFFD166)
            : const Color(0xFF6EE7B7);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Main content ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Today block
              Expanded(
                flex: 11,
                child: _TodayBlock(
                  iconUrl: iconUrl,
                  tempStr: tempStr,
                  condition: condition,
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _white.withValues(alpha: 0.0),
                      _white.withValues(alpha: 0.4),
                      _white.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // 3-day forecast
              Expanded(
                flex: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: next
                      .map((f) => _ForecastChip(forecastDay: f))
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        // ── Bottom alert row ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: _white.withValues(alpha: 0.15),
            border: Border(
              top: BorderSide(
                color: _white.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.droplets, size: 15, color: _white),
              const SizedBox(width: 6),
              Text(
                'High Tide Alert: ',
                style: TextStyle(
                  fontSize: 12.5,
                  color: _white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                riskLabel,
                style: TextStyle(
                  fontSize: 12.5,
                  color: riskColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onViewForecast,
                child: Row(
                  children: [
                    Text(
                      'View forecast',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        decoration: onViewForecast != null
                            ? TextDecoration.underline
                            : null,
                        decorationColor: _white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 15,
                      color: _white.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Today block ───────────────────────────────────────────────────────────────

class _TodayBlock extends StatelessWidget {
  final String iconUrl;
  final String tempStr;
  final String condition;

  const _TodayBlock({
    required this.iconUrl,
    required this.tempStr,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Weather icon — drop shadow to make it pop on the gradient
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CachedNetworkImage(
            imageUrl: iconUrl,
            width: 76,
            height: 76,
            fit: BoxFit.contain,
            errorWidget: (_, _, _) => const Icon(
              Icons.wb_sunny_rounded,
              size: 68,
              color: Color(0xFFFFC107),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Temp + condition
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tempStr,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.wb_sunny_rounded,
                    size: 13,
                    color: Color(0xFFFFD166),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      condition,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Forecast chip ─────────────────────────────────────────────────────────────

class _ForecastChip extends StatelessWidget {
  final ForecastDay forecastDay;
  const _ForecastChip({required this.forecastDay});

  @override
  Widget build(BuildContext context) {
    final dayName = getWeekdayName(
      forecastDay.displayDate.day,
      month: forecastDay.displayDate.month,
    ).substring(0, 3);
    final temp =
        '${forecastDay.maxTemperature.degrees.toStringAsFixed(0)}°C';
    final iconUrl =
        '${forecastDay.daytimeForecast.weatherCondition.iconBaseUri}.png';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayName,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        CachedNetworkImage(
          imageUrl: iconUrl,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          errorWidget: (_, _, _) => const Icon(
            Icons.wb_sunny_rounded,
            size: 28,
            color: Color(0xFFFFC107),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          temp,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
