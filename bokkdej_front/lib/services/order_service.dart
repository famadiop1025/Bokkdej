import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderService {
  static String _getApiBaseUrl() {
    return 'http://localhost:8000';
  }

  // Créer une commande avec numéro de téléphone
  static Future<Map<String, dynamic>?> createOrder({
    required String phoneNumber,
    required String customerName,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
    String? deliveryAddress,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_getApiBaseUrl()}/api/orders/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': phoneNumber,
          'customer_name': customerName,
          'items': items,
          'special_instructions': specialInstructions,
          'delivery_address': deliveryAddress,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Erreur création commande: $e');
      return null;
    }
  }

  // Obtenir les commandes par numéro de téléphone
  static Future<List<Map<String, dynamic>>> getOrdersByPhone(String phoneNumber) async {
    try {
      final response = await http.get(
        Uri.parse('${_getApiBaseUrl()}/api/orders/by-phone/$phoneNumber/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur récupération commandes: $e');
      return [];
    }
  }

  // Obtenir le statut d'une commande
  static Future<Map<String, dynamic>?> getOrderStatus(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${_getApiBaseUrl()}/api/orders/$orderId/status/'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Erreur statut commande: $e');
      return null;
    }
  }

  // Annuler une commande
  static Future<bool> cancelOrder(int orderId, String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${_getApiBaseUrl()}/api/orders/$orderId/cancel/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur annulation commande: $e');
      return false;
    }
  }

  // Calculer le total d'une commande
  static double calculateOrderTotal(List<Map<String, dynamic>> items) {
    double total = 0;
    for (var item in items) {
      final price = (item['prix'] as num).toDouble();
      final quantity = (item['quantite'] as num).toInt();
      total += price * quantity;
    }
    return total;
  }

  // Valider un numéro de téléphone sénégalais
  static bool isValidSenegalesePhone(String phone) {
    // Format: +221 7X XXX XX XX ou 7X XXX XX XX
    final phoneRegex = RegExp(r'^(\+221\s?)?(7[0-9]{8})$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'\s+'), ''));
  }

  // Formater un numéro de téléphone
  static String formatPhoneNumber(String phone) {
    // Supprimer tous les espaces et caractères spéciaux
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Si le numéro commence par +221, le garder tel quel
    if (cleaned.startsWith('+221')) {
      return cleaned;
    }
    
    // Si le numéro commence par 221, ajouter le +
    if (cleaned.startsWith('221')) {
      return '+$cleaned';
    }
    
    // Si le numéro commence par 7 (format sénégalais), ajouter +221
    if (cleaned.startsWith('7') && cleaned.length == 9) {
      return '+221$cleaned';
    }
    
    // Sinon, retourner le numéro tel quel
    return cleaned;
  }
} 