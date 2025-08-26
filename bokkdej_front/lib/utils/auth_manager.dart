import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../admin_page.dart';
import '../navigation/app_navigation.dart';

class AuthManager {
  static const String apiBaseUrl = 'http://localhost:8000';
  
  static Future<Map<String, dynamic>?> validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/user/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Erreur validation token: $e');
      return null;
    }
  }
  
  static Future<void> redirectBasedOnRole(BuildContext context, String token) async {
    final userProfile = await validateToken(token);
    
    if (userProfile == null) {
      // Token invalide - retour à la connexion
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/login', 
        (route) => false
      );
      return;
    }
    
    final role = userProfile['role'] as String?;
    final restaurant = userProfile['restaurant'];
    
    switch (role) {
      case 'admin':
      case 'personnel':
      case 'chef':
        // Si le profil a un restaurant associé, on ouvre directement l'espace de CE restaurant
        if (restaurant != null) {
          Map<String, dynamic> restMap = {};
          try {
            if (restaurant is Map) {
              restMap = Map<String, dynamic>.from(restaurant as Map);
            } else {
              final int restId = int.tryParse(restaurant.toString()) ?? -1;
              if (restId > 0) {
                // Essai 1: endpoint admin
                var resp = await http.get(
                  Uri.parse('$apiBaseUrl/api/admin/restaurants/$restId/'),
                  headers: {'Authorization': 'Bearer $token'},
                );
                if (resp.statusCode == 200) {
                  restMap = Map<String, dynamic>.from(json.decode(resp.body));
                } else {
                  // Fallback public
                  resp = await http.get(Uri.parse('$apiBaseUrl/api/restaurants/$restId/'));
                  if (resp.statusCode == 200) {
                    restMap = Map<String, dynamic>.from(json.decode(resp.body));
                  }
                }
              }
            }
          } catch (_) {}

          if (restMap.isEmpty) {
            // À défaut, passer l'id pour que l'écran recharge, mais éviter null dans le titre
            restMap = {
              if (restaurant is int) 'id': restaurant,
              if (restaurant is String) 'id': int.tryParse(restaurant) ?? 0,
              'nom': 'Restaurant',
            };
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantDashboard(restaurant: restMap, token: token),
            ),
          );
        } else {
          // Sinon, page admin générale
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(token: token, userRole: role ?? 'staff'),
            ),
          );
        }
        break;
      case 'client':
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(token: token),
          ),
        );
        break;
    }
  }
  
  static Widget getHomeForRole(String token, Map<String, dynamic>? userProfile) {
    if (userProfile == null) {
      return MainNavigation(token: token);
    }
    
    final role = userProfile['role'] as String?;
    
    switch (role) {
      case 'admin':
      case 'personnel':
      case 'chef':
        return AdminPage(token: token, userRole: userProfile['role'] ?? 'staff');
      case 'client':
      default:
        return MainNavigation(token: token);
    }
  }
  
  static bool isAdmin(Map<String, dynamic>? userProfile) {
    if (userProfile == null) return false;
    final role = userProfile['role'] as String?;
    return ['admin', 'personnel', 'chef'].contains(role);
  }
  
  static bool canManageRestaurant(Map<String, dynamic>? userProfile) {
    if (userProfile == null) return false;
    final role = userProfile['role'] as String?;
    return role == 'admin';
  }
}
