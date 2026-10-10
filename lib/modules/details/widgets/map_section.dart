import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/country_model.dart';
import '../../../widgets/country_map.dart';

/// Small map preview; tapping "Expand" opens a full-screen interactive map.
class MapSection extends StatelessWidget {
  final Country country;

  const MapSection({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    if (!country.hasLocation) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 36, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.sm),
            Text('Location not available', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 240,
        child: Stack(
          children: [
            CountryMap(
              latitude: country.latitude!,
              longitude: country.longitude!,
              interactive: false,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: FilledButton.tonalIcon(
                onPressed: () => Get.to(() => FullScreenMap(country: country)),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
                icon: const Icon(Icons.open_in_full_rounded, size: 18),
                label: const Text('Expand'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenMap extends StatelessWidget {
  final Country country;

  const FullScreenMap({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(country.name)),
      body: CountryMap(
        latitude: country.latitude!,
        longitude: country.longitude!,
        zoom: 5,
      ),
    );
  }
}
