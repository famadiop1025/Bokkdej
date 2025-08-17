import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  String _token;

  CartProvider(this._token);

  List<Map<String, dynamic>> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += double.tryParse(item['prix'].toString()) ?? 0.0;
    }
    return total;
  }

  void addItem(Map<String, dynamic> item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> submitOrder() async {
    if (_items.isEmpty) return false;

    try {
      final orderData = {
        'items': _items,
        'total': totalAmount,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/orders/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la soumission de la commande: $e');
      return false;
    }
  }
}