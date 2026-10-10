import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/country_model.dart';
import '../../widgets/flag_image.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_view.dart';
import 'country_details_controller.dart';
import 'widgets/info_tile.dart';
import 'widgets/map_section.dart';
import 'widgets/weather_section.dart';

class CountryDetailsView extends GetView<CountryDetailsController> {
  const CountryDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final country = controller.country;
    if (country == null) {
      return Scaffold(
        appBar: AppBar(),
        body: StatusView(
          icon: Icons.travel_explore_rounded,
          title: 'Country not found',
          message: 'Please go back and select a country again.',
          actionLabel: 'Go back',
          onAction: () => Get.back(),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(country),
          // Keeps the map card above the Android navigation bar (edge-to-edge).
          SliverSafeArea(
            top: false,
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 800;
                        final facts = _buildFacts(context, country);
                        final weatherAndMap = Column(
                          children: [
                            _buildWeather(),
                            const SizedBox(height: AppSpacing.md),
                            SectionCard(
                              title: 'Location',
                              icon: Icons.map_rounded,
                              child: MapSection(country: country),
                            ),
                          ],
                        );

                        // Tablets / wide screens: two columns. Phones: one column.
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: facts),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: weatherAndMap),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            facts,
                            const SizedBox(height: AppSpacing.md),
                            weatherAndMap,
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Country country) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 230,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      actions: [
        Obx(
          () => IconButton(
            tooltip: controller.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: controller.toggleFavorite,
            icon: Icon(
              controller.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: controller.isFavorite ? AppColors.favorite : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          country.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'flag-${country.code}',
              child: FlagImage(
                url: country.flagUrl,
                emoji: country.flagEmoji,
                width: double.infinity,
                height: double.infinity,
                radius: 0,
              ),
            ),
            // Dark gradient so the title stays readable on light flags.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black38, Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacts(BuildContext context, Country country) {
    final tiles = [
      InfoTile(icon: Icons.location_city_rounded, label: 'Capital', value: country.capital),
      InfoTile(icon: Icons.public_rounded, label: 'Region', value: country.region),
      InfoTile(
        icon: Icons.groups_rounded,
        label: 'Population',
        value: Formatters.groupedNumber(country.population),
        singleLine: true,
      ),
      InfoTile(icon: Icons.payments_rounded, label: 'Currency', value: country.currencyLabel),
      InfoTile(
        icon: Icons.north_rounded,
        label: 'Latitude',
        value: country.latitude == null ? 'N/A' : Formatters.latitude(country.latitude!),
        singleLine: true,
      ),
      InfoTile(
        icon: Icons.east_rounded,
        label: 'Longitude',
        value: country.longitude == null ? 'N/A' : Formatters.longitude(country.longitude!),
        singleLine: true,
      ),
    ];

    return SectionCard(
      title: 'Country facts',
      icon: Icons.info_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(country.officialName, style: Theme.of(context).textTheme.titleMedium),
          if (country.subregion.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(country.subregion, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              // Two tiles per row, or one on very narrow screens.
              final columns = constraints.maxWidth < 320 ? 1 : 2;
              final tileWidth = (constraints.maxWidth - (columns - 1) * AppSpacing.sm) / columns;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [for (final tile in tiles) SizedBox(width: tileWidth, child: tile)],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeather() {
    return SectionCard(
      title: 'Weather',
      icon: Icons.wb_sunny_outlined,
      child: Obx(
        () => WeatherSection(
          status: controller.weatherStatus.value,
          weather: controller.weather.value,
          errorMessage: controller.weatherError.value,
          onRetry: controller.fetchWeather,
        ),
      ),
    );
  }
}
