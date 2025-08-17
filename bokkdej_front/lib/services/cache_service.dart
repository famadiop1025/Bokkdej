import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _menuKey = 'cached_menu';
  static const String _ingredientsKey = 'cached_ingredients';
  static const String _lastUpdateKey = 'last_cache_update';
  static const Duration _cacheValidity = Duration(hours: 24);

  Future<void> cacheMenu(List<dynamic> menuItems) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_menuKey, json.encode(menuItems));
    await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  Future<void> cacheIngredients(List<dynamic> ingredients) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ingredientsKey, json.encode(ingredients));
  }

  Future<List<dynamic>?> getCachedMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final menuData = prefs.getString(_menuKey);
    if (menuData != null) {
      final lastUpdate = prefs.getString(_lastUpdateKey);
      if (lastUpdate != null) {
        final lastUpdateTime = DateTime.parse(lastUpdate);
        if (DateTime.now().difference(lastUpdateTime) < _cacheValidity) {
          return json.decode(menuData);
        }
      }
    }
    return null;
  }

  Future<List<dynamic>?> getCachedIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientsData = prefs.getString(_ingredientsKey);
    if (ingredientsData != null) {
      return json.decode(ingredientsData);
    }
    return null;
  }

  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString(_lastUpdateKey);
    if (lastUpdate != null) {
      final lastUpdateTime = DateTime.parse(lastUpdate);
      return DateTime.now().difference(lastUpdateTime) < _cacheValidity;
    }
    return false;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_menuKey);
    await prefs.remove(_ingredientsKey);
    await prefs.remove(_lastUpdateKey);
  }

  Future<DateTime?> getLastUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString(_lastUpdateKey);
    if (lastUpdate != null) {
      return DateTime.parse(lastUpdate);
    }
    return null;
  }
} 
