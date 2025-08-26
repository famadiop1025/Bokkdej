import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/device_id_service.dart';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  String _token;
  String? _phone;
  int? _restaurantId;
  int? _selectedRestaurantId;
  String? _selectedRestaurantName;

  CartProvider(this._token);
  String get token => _token;
  
  List<Map<String, dynamic>> get items => _items;
  String? get phone => _phone;
  int? get restaurantId => _restaurantId;
  int? get selectedRestaurantId => _selectedRestaurantId;
  String? get selectedRestaurantName => _selectedRestaurantName;

  void setPhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  void setRestaurant(int restaurantId, String restaurantName) {
    _selectedRestaurantId = restaurantId;
    _selectedRestaurantName = restaurantName;
    notifyListeners();
  }

  void addItem(Map<String, dynamic> item, {int quantity = 1}) {
    final itemWithQuantity = Map<String, dynamic>.from(item);
    itemWithQuantity['quantity'] = quantity;
    _items.add(itemWithQuantity);
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get totalAmount => _items.fold(0.0, (sum, item) {
    final prix = item['prix'];
    final quantity = item['quantity'] as int? ?? 1;
    
    // Convertir le prix en double, peu importe s'il est string ou num
    double prixValue = 0.0;
    if (prix is num) {
      prixValue = prix.toDouble();
    } else if (prix is String) {
      prixValue = double.tryParse(prix) ?? 0.0;
    }
    
    return sum + (prixValue * quantity);
  });
  
  int get itemCount => _items.length;

  // Getters pour ultra_safe_panier_wrapper
  List<Map<String, dynamic>> get panier => _items;
  bool get isLoading => false; // TODO: Implémenter la logique de chargement
  String? get error => null; // TODO: Implémenter la gestion d'erreur
  double get total => totalAmount;
  
  // Méthode pour charger le panier
  Future<void> loadPanier() async {
    // TODO: Implémenter le chargement du panier depuis l'API
    notifyListeners();
  }

  Future<Map<String, dynamic>> submitOrder() async {
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/orders/valider-panier/'),
        headers: {
          'Content-Type': 'application/json',
          if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'items': _items,
          'phone': _phone,
          'restaurant_id': _selectedRestaurantId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'ok': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {'ok': false, 'message': errorData.get('error', 'Erreur lors de la commande')};
      }
    } catch (e) {
      return {'ok': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  void setRestaurantId(int id) {
    _restaurantId = id;
    notifyListeners();
  }
}