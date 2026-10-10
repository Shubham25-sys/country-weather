import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/app_exception.dart';
import '../../core/utils/view_status.dart';
import '../../data/models/country_model.dart';
import '../../data/repositories/country_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  final CountryRepository _repository = Get.find();
  final AuthService _auth = Get.find();
  final StorageService storage = Get.find();

  static const String allRegions = 'All';

  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  final scrollController = ScrollController();

  final status = ViewStatus.loading.obs;
  final errorMessage = ''.obs;
  final countries = <Country>[].obs; // Full list from the API.
  final visibleCountries = <Country>[].obs; // After search & filters.
  final searchQuery = ''.obs;
  final selectedRegion = allRegions.obs;
  final showFavoritesOnly = false.obs;

  String get userEmail => _auth.currentUser?.email ?? '';

  bool get isSearching => searchQuery.value.trim().isNotEmpty;

  List<String> get regions {
    final set = countries.map((c) => c.region).where((r) => r != 'N/A').toSet().toList()..sort();
    return [allRegions, ...set];
  }

  List<Country> get recentCountries =>
      storage.recentSearches.map(_findByCode).whereType<Country>().toList();

  Country? get lastSelectedCountry {
    final code = storage.lastSelected.value;
    return code == null ? null : _findByCode(code);
  }

  @override
  void onInit() {
    super.onInit();
    // Wait until the user stops typing before filtering.
    debounce(
      searchQuery,
      (_) => _applyFiltersAndScrollToTop(),
      time: const Duration(milliseconds: 300),
    );
    ever(selectedRegion, (_) => _applyFiltersAndScrollToTop());
    ever(showFavoritesOnly, (_) => _applyFiltersAndScrollToTop());
    ever(storage.favorites, (_) => _applyFilters());
    fetchCountries();
  }

  /// [showLoader] is false for pull-to-refresh, which has its own spinner.
  Future<void> fetchCountries({bool showLoader = true}) async {
    if (showLoader) status.value = ViewStatus.loading;
    try {
      final result = await _repository.getCountries();
      countries.assignAll(result);
      status.value = result.isEmpty ? ViewStatus.empty : ViewStatus.success;
      _applyFilters();
    } on AppException catch (e) {
      _onFetchError(e.message);
    } catch (_) {
      _onFetchError('Unable to load countries. Please try again.');
    }
  }

  /// A failed pull-to-refresh keeps the list already on screen and shows a
  /// snackbar; only a failed first load replaces the list with the error view.
  void _onFetchError(String message) {
    if (countries.isNotEmpty) {
      status.value = ViewStatus.success;
      Get.closeAllSnackbars();
      Get.snackbar(
        'Could not refresh',
        message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    errorMessage.value = message;
    status.value = ViewStatus.error;
  }

  Future<void> refreshCountries() => fetchCountries(showLoader: false);

  void onSearchChanged(String value) => searchQuery.value = value;

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  /// Closes the keyboard without clearing the search text.
  void hideKeyboard() => searchFocusNode.unfocus();

  void selectRegion(String region) {
    hideKeyboard();
    selectedRegion.value = region;
  }

  void toggleFavoritesOnly() {
    hideKeyboard();
    showFavoritesOnly.toggle();
  }

  void toggleFavorite(Country country) => storage.toggleFavorite(country.code);

  bool isFavorite(Country country) => storage.favorites.contains(country.code);

  void openCountry(Country country) {
    // A country opened from search results counts as a "recent search".
    if (isSearching) storage.addRecentSearch(country.code);
    // Unfocus first, otherwise the keyboard reopens when coming back.
    hideKeyboard();
    Get.toNamed(AppRoutes.details, arguments: country);
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();

    final filtered = countries.where((country) {
      final matchesQuery =
          query.isEmpty ||
          country.name.toLowerCase().contains(query) ||
          country.officialName.toLowerCase().contains(query);
      final matchesRegion =
          selectedRegion.value == allRegions || country.region == selectedRegion.value;
      final matchesFavorite = !showFavoritesOnly.value || isFavorite(country);
      return matchesQuery && matchesRegion && matchesFavorite;
    });

    visibleCountries.assignAll(filtered);
  }

  /// New search/filter results should start from the top, not where the old
  /// list was scrolled. Not used for favorite toggles, so tapping a heart
  /// mid-list doesn't jump.
  void _applyFiltersAndScrollToTop() {
    _applyFilters();
    if (scrollController.hasClients) scrollController.jumpTo(0);
  }

  Country? _findByCode(String code) => countries.firstWhereOrNull((c) => c.code == code);

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
