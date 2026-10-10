import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';

/// Persists favorites, recent searches and the last selected country
/// using SharedPreferences. Values are country codes (e.g. "IND").
///
/// The lists are reactive so every screen updates automatically.
class StorageService extends GetxService {
  static const _favoritesKey = 'favorite_countries';
  static const _recentKey = 'recent_searches';
  static const _lastSelectedKey = 'last_selected_country';

  late final SharedPreferences _prefs;

  final favorites = <String>[].obs;
  final recentSearches = <String>[].obs;
  final lastSelected = RxnString();

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    favorites.assignAll(_prefs.getStringList(_favoritesKey) ?? []);
    recentSearches.assignAll(_prefs.getStringList(_recentKey) ?? []);
    lastSelected.value = _prefs.getString(_lastSelectedKey);
    return this;
  }

  // Favorites

  bool isFavorite(String code) => favorites.contains(code);

  Future<void> toggleFavorite(String code) async {
    isFavorite(code) ? favorites.remove(code) : favorites.insert(0, code);
    await _prefs.setStringList(_favoritesKey, favorites);
  }

  // Recent searches (most recent first, max 5)

  Future<void> addRecentSearch(String code) async {
    recentSearches
      ..remove(code)
      ..insert(0, code);
    if (recentSearches.length > AppConfig.maxRecentSearches) {
      recentSearches.removeRange(AppConfig.maxRecentSearches, recentSearches.length);
    }
    await _prefs.setStringList(_recentKey, recentSearches);
  }

  Future<void> clearRecentSearches() async {
    recentSearches.clear();
    await _prefs.remove(_recentKey);
  }

  // Last selected country

  Future<void> saveLastSelected(String code) async {
    lastSelected.value = code;
    await _prefs.setString(_lastSelectedKey, code);
  }
}
