import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/view_status.dart';
import '../../../data/models/weather_model.dart';

/// Current weather card with its own loading / error / empty states.
class WeatherSection extends StatelessWidget {
  final ViewStatus status;
  final Weather? weather;
  final String errorMessage;
  final VoidCallback onRetry;

  const WeatherSection({
    super.key,
    required this.status,
    required this.weather,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (status) {
        ViewStatus.loading => const _MessageCard(
            key: ValueKey('loading'),
            icon: Icons.cloud_sync_rounded,
            message: 'Fetching current weather...',
            showLoader: true,
          ),
        ViewStatus.error => _MessageCard(
            key: const ValueKey('error'),
            icon: Icons.cloud_off_rounded,
            message: errorMessage,
            color: AppColors.error,
            onRetry: onRetry,
          ),
        ViewStatus.empty => const _MessageCard(
            key: ValueKey('empty'),
            icon: Icons.location_off_rounded,
            message: 'Weather is not available because this country has no coordinates.',
          ),
        ViewStatus.success => weather == null
            ? const SizedBox.shrink()
            : _WeatherCard(key: const ValueKey('success'), weather: weather!),
      },
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final Weather weather;

  const _WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.weatherGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current weather',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${weather.temperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${weather.condition} · Feels like ${weather.feelsLike.round()}°C',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
              Icon(_iconFor(weather), size: 72, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _WeatherStat(
                  icon: Icons.water_drop_rounded,
                  label: 'Humidity',
                  value: '${weather.humidity}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WeatherStat(
                  icon: Icons.air_rounded,
                  label: 'Wind speed',
                  value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(Weather weather) {
    final code = weather.weatherCode;
    if (code == 0 || code == 1) {
      return weather.isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    }
    if (code == 2) return Icons.wb_cloudy_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 67) return Icons.grain_rounded;
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) return Icons.umbrella_rounded;
    if (code == 85 || code == 86) return Icons.ac_unit_rounded;
    if (code >= 95) return Icons.thunderstorm_rounded;
    return Icons.cloud_queue_rounded;
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  final bool showLoader;
  final VoidCallback? onRetry;

  const _MessageCard({
    super.key,
    required this.icon,
    required this.message,
    this.color = AppColors.accent,
    this.showLoader = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          showLoader
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
                )
              : Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
