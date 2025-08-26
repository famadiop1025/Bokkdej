import 'dart:async';
import 'polling_config.dart';

class PollingManager {
  static final PollingManager _instance = PollingManager._internal();
  factory PollingManager() => _instance;
  PollingManager._internal();

  final Map<String, Timer> _timers = {};
  final Map<String, Function> _callbacks = {};

  // Enregistrer un timer avec un identifiant unique
  void registerTimer(String id, Function callback) {
    _callbacks[id] = callback;
    _startTimer(id);
  }

  // Démarrer un timer
  Future<void> _startTimer(String id) async {
    // Annuler le timer existant s'il y en a un
    _timers[id]?.cancel();

    // Vérifier si le polling est activé
    final isEnabled = await PollingConfig.isPollingEnabled();
    if (!isEnabled) return;

    // Obtenir l'intervalle approprié selon l'ID
    int interval;
    switch (id) {
      case 'dashboard':
        interval = await PollingConfig.getDashboardInterval();
        break;
      case 'orders':
        interval = await PollingConfig.getOrdersInterval();
        break;

      default:
        interval = 60; // Valeur par défaut
    }

    // Créer et démarrer le timer
    _timers[id] = Timer.periodic(Duration(seconds: interval), (_) {
      if (_callbacks[id] != null) {
        _callbacks[id]!();
      }
    });
  }

  // Mettre à jour un timer existant
  Future<void> updateTimer(String id) async {
    if (_callbacks.containsKey(id)) {
      await _startTimer(id);
    }
  }

  // Mettre à jour tous les timers
  Future<void> updateAllTimers() async {
    for (String id in _callbacks.keys) {
      await updateTimer(id);
    }
  }

  // Arrêter un timer spécifique
  void stopTimer(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  // Arrêter tous les timers
  void stopAllTimers() {
    for (Timer timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  // Vérifier si un timer est actif
  bool isTimerActive(String id) {
    return _timers.containsKey(id) && _timers[id]!.isActive;
  }

  // Obtenir l'intervalle actuel d'un timer
  Future<int> getCurrentInterval(String id) async {
    switch (id) {
      case 'dashboard':
        return await PollingConfig.getDashboardInterval();
      case 'orders':
        return await PollingConfig.getOrdersInterval();

      default:
        return 60;
    }
  }

  // Nettoyer les ressources
  void dispose() {
    stopAllTimers();
    _callbacks.clear();
  }
}

