import 'package:shared_preferences/shared_preferences.dart';

class PollingConfig {
  static const String _dashboardIntervalKey = 'dashboard_polling_interval';
  static const String _ordersIntervalKey = 'orders_polling_interval';
  // Intervalles par défaut (en secondes)
  static const int defaultDashboardInterval = 60; // 1 minute
  static const int defaultOrdersInterval = 30;    // 30 secondes
  
  // Intervalles minimaux pour éviter la surcharge
  static const int minDashboardInterval = 30;     // 30 secondes minimum
  static const int minOrdersInterval = 15;        // 15 secondes minimum
  
  // Obtenir l'intervalle du dashboard
  static Future<int> getDashboardInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dashboardIntervalKey) ?? defaultDashboardInterval;
  }
  
  // Obtenir l'intervalle des commandes
  static Future<int> getOrdersInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_ordersIntervalKey) ?? defaultOrdersInterval;
  }
  

  
  // Définir l'intervalle du dashboard
  static Future<void> setDashboardInterval(int seconds) async {
    if (seconds < minDashboardInterval) seconds = minDashboardInterval;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dashboardIntervalKey, seconds);
  }
  
  // Définir l'intervalle des commandes
  static Future<void> setOrdersInterval(int seconds) async {
    if (seconds < minOrdersInterval) seconds = minOrdersInterval;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ordersIntervalKey, seconds);
  }
  

  
  // Réinitialiser aux valeurs par défaut
  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dashboardIntervalKey);
    await prefs.remove(_ordersIntervalKey);

  }
  
  // Obtenir tous les intervalles actuels
  static Future<Map<String, int>> getAllIntervals() async {
    return {
      'dashboard': await getDashboardInterval(),
      'orders': await getOrdersInterval(),

    };
  }
  
  // Vérifier si le polling est activé (pour désactiver si nécessaire)
  static Future<bool> isPollingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('polling_enabled') ?? true;
  }
  
  // Activer/désactiver le polling
  static Future<void> setPollingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('polling_enabled', enabled);
  }
}

