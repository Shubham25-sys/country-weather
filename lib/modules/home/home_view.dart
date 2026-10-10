import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/view_status.dart';
import '../../data/models/country_model.dart';
import '../../widgets/status_view.dart';
import 'home_controller.dart';
import 'widgets/country_card.dart';
import 'widgets/country_list_skeleton.dart';
import 'widgets/last_viewed_card.dart';
import 'widgets/recent_searches.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.hideKeyboard,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Explore countries'),
              Text(controller.userEmail, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
        body: Column(
          children: [
            _buildSearchField(),
            _buildFilters(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: Obx(_buildBody)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 12),
      child: Obx(
        () => TextField(
          controller: controller.searchController,
          focusNode: controller.searchFocusNode,
          onChanged: controller.onSearchChanged,
          onSubmitted: (_) => controller.hideKeyboard(),
          onTapOutside: (_) => controller.hideKeyboard(),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search countries by name',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: controller.searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: controller.clearSearch,
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: Obx(() {
        final regions = controller.regions;
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            FilterChip(
              avatar: Icon(
                Icons.favorite_rounded,
                size: 18,
                color: controller.showFavoritesOnly.value ? Colors.white : AppColors.favorite,
              ),
              label: Text('Favorites (${controller.storage.favorites.length})'),
              selected: controller.showFavoritesOnly.value,
              selectedColor: AppColors.favorite,
              labelStyle: TextStyle(
                color: controller.showFavoritesOnly.value ? Colors.white : AppColors.textPrimary,
              ),
              onSelected: (_) => controller.toggleFavoritesOnly(),
            ),
            const SizedBox(width: AppSpacing.sm),
            for (final region in regions) ...[
              ChoiceChip(
                label: Text(region),
                selected: controller.selectedRegion.value == region,
                labelStyle: TextStyle(
                  color: controller.selectedRegion.value == region
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
                onSelected: (_) => controller.selectRegion(region),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildBody() {
    switch (controller.status.value) {
      case ViewStatus.loading:
        return const CountryListSkeleton();
      case ViewStatus.error:
        return StatusView.error(
          title: 'Could not load countries',
          message: controller.errorMessage.value,
          onAction: controller.fetchCountries,
        );
      case ViewStatus.empty:
        return StatusView(
          icon: Icons.public_off_rounded,
          title: 'No countries found',
          message: 'The server returned no countries. Please try again.',
          actionLabel: 'Reload',
          onAction: controller.fetchCountries,
        );
      case ViewStatus.success:
        return _buildCountryList();
    }
  }

  Widget _buildCountryList() {
    final countries = controller.visibleCountries;
    final showExtras = !controller.isSearching && !controller.showFavoritesOnly.value;
    final lastViewed = showExtras ? controller.lastSelectedCountry : null;
    final recents = showExtras ? controller.recentCountries : const <Country>[];
    final favorites = controller.storage.favorites.toSet();

    return RefreshIndicator(
      onRefresh: controller.refreshCountries,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          if (lastViewed != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: LastViewedCard(
                  country: lastViewed,
                  onTap: () => controller.openCountry(lastViewed),
                ),
              ),
            ),
          if (recents.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: RecentSearches(
                  countries: recents,
                  onTap: controller.openCountry,
                  onClear: controller.storage.clearRecentSearches,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 12),
              child: Text(
                '${countries.length} ${countries.length == 1 ? 'country' : 'countries'}',
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (countries.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _buildNoResults())
          else
            // Keeps the last card above the Android navigation bar (edge-to-edge).
            SliverSafeArea(
              top: false,
              sliver: SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
                // Max extent makes the grid show 1 column on phones, 2+ on tablets.
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 520,
                    mainAxisExtent: 84,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: countries.length,
                  itemBuilder: (_, index) {
                    final country = countries[index];
                    return CountryCard(
                      country: country,
                      isFavorite: favorites.contains(country.code),
                      onTap: () => controller.openCountry(country),
                      onFavoriteTap: () => controller.toggleFavorite(country),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    if (controller.isSearching) {
      return StatusView(
        icon: Icons.search_off_rounded,
        title: 'No results',
        message:
            'No country matches "${controller.searchQuery.value.trim()}". '
            'Try a different name.',
        actionLabel: 'Clear search',
        onAction: controller.clearSearch,
      );
    }
    if (controller.showFavoritesOnly.value) {
      return const StatusView(
        icon: Icons.favorite_border_rounded,
        title: 'No favorites yet',
        message: 'Tap the heart on any country to save it here.',
        color: AppColors.favorite,
      );
    }
    return StatusView(
      icon: Icons.filter_alt_off_rounded,
      title: 'Nothing here',
      message: 'No countries found for this region.',
      actionLabel: 'Show all',
      onAction: () => controller.selectRegion(HomeController.allRegions),
    );
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to explore countries.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
