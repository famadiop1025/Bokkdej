import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum UserRole {
  restaurantStaff,
  admin,
}

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  
  static String? _token;
  static UserRole? _userRole;
  static int? _userId;
  static String? _userName;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Getters
  static String? get token => _token;
  static UserRole? get userRole => _userRole;
  static int? get userId => _userId;
  static String? get userName => _userName;
  static bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  static bool get isAdmin => _userRole == UserRole.admin;
  static bool get isRestaurantStaff => _userRole == UserRole.restaurantStaff;


  // Initialiser le service depuis le stockage local
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _userRole = _parseUserRole(prefs.getString(_userRoleKey));
    _userId = prefs.getInt(_userIdKey);
    _userName = prefs.getString(_userNameKey);
  }

  // Connexion avec PIN
  static Future<bool> loginWithPin(String pin) async {
    try {
      final response = await http.post(
        Uri.parse('${_getApiBaseUrl()}/api/auth/pin-login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'pin': pin}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Réponse API: $data'); // Debug
        
        // L'API retourne 'access' au lieu de 'token'
        final token = data['access'] ?? data['token'];
        final userData = data['user'] ?? {};
        
        await _saveAuthData(
          token: token,
          role: _parseUserRole(userData['role'] ?? 'client'),
          userId: userData['id'] ?? 0,
          userName: userData['name'] ?? userData['username'] ?? 'Utilisateur',
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur de connexion: $e');
      return false;
    }
  }

  // Connexion avec identifiants
  static Future<bool> loginWithCredentials(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${_getApiBaseUrl()}/api/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveAuthData(
          token: data['token'],
          role: _parseUserRole(data['user']['role']),
          userId: data['user']['id'],
          userName: data['user']['name'] ?? data['user']['username'],
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur de connexion: $e');
      return false;
    }
  }

  // Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    
    _token = null;
    _userRole = null;
    _userId = null;
    _userName = null;
  }

  // Vérifier si l'utilisateur a les permissions pour une fonctionnalité
  static bool hasPermission(String feature) {
    if (!isAuthenticated) return false;

    switch (feature) {
      case 'admin_panel':
        return isAdmin;
      case 'menu_management':
        return isAdmin || isRestaurantStaff;
      case 'ingredients_management':
        return isAdmin || isRestaurantStaff;
      case 'bases_management':
        return isAdmin || isRestaurantStaff;
      case 'orders_management':
        return isAdmin || isRestaurantStaff;
      case 'personnel_management':
        return isAdmin;
      case 'stats_view':
        return isAdmin || isRestaurantStaff;
      case 'order_placement':
        return true; // Tout le monde peut passer des commandes
      default:
        return false;
    }
  }

  // Obtenir les fonctionnalités disponibles selon le rôle
  static List<String> getAvailableFeatures() {
    if (!isAuthenticated) return [];

    List<String> features = [];

    if (isAdmin) {
      features.addAll([
        'admin_panel',
        'menu_management',
        'ingredients_management',
        'bases_management',
        'orders_management',
        'personnel_management',
        'stats_view',
        'order_placement',
      ]);
    } else if (isRestaurantStaff) {
      features.addAll([
        'menu_management',
        'ingredients_management',
        'bases_management',
        'orders_management',
        'stats_view',
        'order_placement',
      ]);
    }

    return features;
  }

  // Sauvegarder les données d'authentification
  static Future<void> _saveAuthData({
    required String? token,
    required UserRole? role,
    required int? userId,
    required String? userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Gérer les valeurs null de manière sécurisée
    if (token != null && token.isNotEmpty) {
      await prefs.setString(_tokenKey, token);
      _token = token;
    }
    
    if (role != null) {
      await prefs.setString(_userRoleKey, role.toString().split('.').last);
      _userRole = role;
    }
    
    if (userId != null) {
      await prefs.setInt(_userIdKey, userId);
      _userId = userId;
    }
    
    if (userName != null && userName.isNotEmpty) {
      await prefs.setString(_userNameKey, userName);
      _userName = userName;
    }
  }

  // Parser le rôle utilisateur
  static UserRole _parseUserRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'restaurant_staff':
      case 'staff':
        return UserRole.restaurantStaff;
      default:
        return UserRole.restaurantStaff;
    }
  }

  // Obtenir l'URL de l'API
  static String _getApiBaseUrl() {
    return 'http://localhost:8000';
  }

  // Rafraîchir le token (si nécessaire)
  static Future<bool> refreshToken() async {
    if (!isAuthenticated) return false;

    try {
      final response = await http.post(
        Uri.parse('${_getApiBaseUrl()}/api/auth/refresh/'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveAuthData(
          token: data['token'],
          role: _userRole!,
          userId: _userId!,
          userName: _userName!,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur de rafraîchissement du token: $e');
      return false;
    }
  }

  // Vérifier si le token est valide
  static Future<bool> validateToken() async {
    if (!isAuthenticated) return false;

    try {
      final response = await http.get(
        Uri.parse('${_getApiBaseUrl()}/api/auth/validate/'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur de validation du token: $e');
      return false;
    }
  }
} 