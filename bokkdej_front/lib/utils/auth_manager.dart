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
    
    switch (role) {
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPage(token: token, userRole: 'admin'),
          ),
        );
        break;
      case 'personnel':
      case 'chef':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPage(token: token, userRole: 'staff'),
          ),
        );
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
