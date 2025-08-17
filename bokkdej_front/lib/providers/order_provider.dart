import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/notification_service.dart';
import '../pin_login_page.dart'; // Pour getApiBaseUrl
import 'dart:async';

class OrderItem {
  final int id;
  final List<Map<String, dynamic>> plats;
  final double prixTotal;
  final String status;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.plats,
    required this.prixTotal,
    required this.status,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      plats: json['plats'] != null 
          ? List<Map<String, dynamic>>.from(json['plats'])
          : <Map<String, dynamic>>[],
      prixTotal: double.tryParse(json['prix_total']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'en_attente',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  String get statusText {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'en_preparation':
        return 'En préparation';
      case 'pret':
        return 'Prêt';
      case 'termine':
        return 'Terminé';
      default:
        return 'Inconnu';
    }
  }

  String get statusIcon {
    switch (status) {
      case 'en_attente':
        return '⏳';
      case 'en_preparation':
        return '👨‍🍳';
      case 'pret':
        return '✅';
      case 'termine':
        return '🎉';
      default:
        return '❓';
    }
  }
}

class OrderProvider with ChangeNotifier {
  List<OrderItem> _orders = [];
  bool _isLoading = false;
  String? _error;
  final String _token;
  final NotificationService _notificationService = NotificationService();
  Map<int, String> _previousStatuses = {};
  Timer? _pollingTimer;

  OrderProvider(this._token);

  List<OrderItem> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/orders/'),
        headers: _token.isNotEmpty ? {'Authorization': 'Bearer $_token'} : {},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final newOrders = data.map((order) => OrderItem.fromJson(Map<String, dynamic>.from(order))).toList();
        // Vérifier les changements de statut et notifier
        _checkStatusChanges(newOrders);
        _orders = newOrders;
        _setError(null);
      } else {
        _setError('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Erreur réseau: $e');
    }
    _setLoading(false);
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 10), (_) => loadOrders());
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  void _checkStatusChanges(List<OrderItem> newOrders) {
    for (final order in newOrders) {
      final previousStatus = _previousStatuses[order.id];
      if (previousStatus != null && previousStatus != order.status) {
        _notifyStatusChange(order);
      }
      _previousStatuses[order.id] = order.status;
    }
  }

  void _notifyStatusChange(OrderItem order) {
    switch (order.status) {
      case 'en_preparation':
        _notificationService.showPreparationNotification(order.id);
        break;
      case 'pret':
        _notificationService.showReadyNotification(order.id);
        break;
      case 'termine':
        _notificationService.showCompletedNotification(order.id);
        break;
    }
  }

  // Méthode pour forcer une notification (pour les tests)
  void testNotification(int orderId, String status) {
    switch (status) {
      case 'en_preparation':
        _notificationService.showPreparationNotification(orderId);
        break;
      case 'pret':
        _notificationService.showReadyNotification(orderId);
        break;
      case 'termine':
        _notificationService.showCompletedNotification(orderId);
        break;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
} 
