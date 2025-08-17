import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class MenuProvider with ChangeNotifier {
  List<Map<String, dynamic>> _menuItems = [];
  List<Map<String, dynamic>> _ingredients = [];
  bool _isLoading = false;
  String _token;

  MenuProvider(this._token);

  List<Map<String, dynamic>> get menuItems => _menuItems;
  List<Map<String, dynamic>> get ingredients => _ingredients;
  bool get isLoading => _isLoading;

  Future<void> loadMenuItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/menu/'),
      );

      if (response.statusCode == 200) {
        _menuItems = List<Map<String, dynamic>>.from(json.decode(response.body));
      }
    } catch (e) {
      print('Erreur lors du chargement du menu: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadIngredients() async {
    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/ingredients/'),
      );

      if (response.statusCode == 200) {
        _ingredients = List<Map<String, dynamic>>.from(json.decode(response.body));
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors du chargement des ingrédients: $e');
    }
  }
}