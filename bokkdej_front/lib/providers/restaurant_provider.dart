import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantProvider with ChangeNotifier {
  int? _selectedRestaurantId;
  String? _selectedRestaurantName;
  Map<String, dynamic>? _restaurantInfo;

  int? get selectedRestaurantId => _selectedRestaurantId;
  String? get selectedRestaurantName => _selectedRestaurantName;
  Map<String, dynamic>? get restaurantInfo => _restaurantInfo;

  // Informations des restaurants (démo). Peut être vide pour les IDs dynamiques
  static const Map<int, Map<String, dynamic>> _restaurants = {
    1: {
      'id': 1,
      'nom': 'Lambouroise',
      'description': 'Cuisine traditionnelle africaine authentique',
      'image': 'assets/images/restaurant1.jpg',
      'specialite': 'Plats traditionnels',
      'note': 4.8,
      'theme_color': 0xFFFFD700,
      'accent_color': 0xFFFFD700,
    },
    2: {
      'id': 2,
      'nom': 'DIMBAL JABOOT',
      'description': 'Cuisine moderne et créative',
      'image': 'assets/images/restaurant2.jpg',
      'specialite': 'Cuisine fusion',
      'note': 4.6,
      'theme_color': 0xFFFFD700,
      'accent_color': 0xFFFFD700,
    },
    3: {
      'id': 3,
      'nom': 'Mère Diane',
      'description': 'Cuisine familiale chaleureuse et accueillante',
      'image': 'assets/images/restaurant3.jpg',
      'specialite': 'Plats maison',
      'note': 4.9,
      'theme_color': 0xFFFFD700,
      'accent_color': 0xFFFFD700,
    },
  };

  Future<void> loadSelectedRestaurant() async {
    final prefs = await SharedPreferences.getInstance();
    final restaurantId = prefs.getInt('restaurant_id');
    final restaurantName = prefs.getString('restaurant_nom');
    
    if (restaurantId != null) {
      _selectedRestaurantId = restaurantId;
      // Si présent dans la map démo, on enrichit les infos, sinon on crée une info minimale
      _restaurantInfo = _restaurants[restaurantId] ?? {
        'id': restaurantId,
        'nom': restaurantName ?? 'Restaurant',
      };
      _selectedRestaurantName = restaurantName ?? _restaurantInfo!['nom'];
      notifyListeners();
    }
  }

  Future<void> selectRestaurant(int restaurantId, {String? name}) async {
    _selectedRestaurantId = restaurantId;
    // Utiliser nom fourni, sinon chercher dans la map démo
    _selectedRestaurantName = name ?? _restaurants[restaurantId]?['nom'] ?? 'Restaurant';
    _restaurantInfo = _restaurants[restaurantId] ?? {
      'id': restaurantId,
      'nom': _selectedRestaurantName,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('restaurant_id', restaurantId);
    await prefs.setString('restaurant_nom', _selectedRestaurantName!);

    notifyListeners();
  }

  void clearRestaurant() {
    _selectedRestaurantId = null;
    _selectedRestaurantName = null;
    _restaurantInfo = null;
    notifyListeners();
  }

  bool get hasSelectedRestaurant => _selectedRestaurantId != null;
} 