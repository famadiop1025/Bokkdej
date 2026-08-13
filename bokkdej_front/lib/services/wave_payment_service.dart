import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class WavePaymentService {
  static const String baseUrl = 'http://localhost:8000/api';
  
  /// Créer un paiement Wave pour une commande
  static Future<Map<String, dynamic>> createWavePayment(int orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wave/create-payment/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'order_id': orderId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Erreur lors de la création du paiement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Vérifier le statut de paiement d'une commande
  static Future<Map<String, dynamic>> checkPaymentStatus(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wave/payment-status/$orderId/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Erreur lors de la vérification du statut',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Ouvrir l'URL de paiement Wave dans le navigateur
  static Future<bool> openWavePayment(String paymentUrl) async {
    try {
      final uri = Uri.parse(paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        if (kDebugMode) {
          print('Impossible d\'ouvrir l\'URL: $paymentUrl');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'ouverture de l\'URL: $e');
      }
      return false;
    }
  }

  /// Polling pour vérifier le statut de paiement
  static Stream<Map<String, dynamic>> pollPaymentStatus(int orderId, {int maxAttempts = 30}) async* {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      final result = await checkPaymentStatus(orderId);
      
      if (result['success']) {
        final data = result['data'];
        final status = data['payment_status'];
        
        yield {
          'success': true,
          'status': status,
          'data': data,
        };
        
        // Arrêter le polling si le paiement est terminé
        if (status == 'paid' || status == 'failed' || status == 'cancelled') {
          break;
        }
      } else {
        yield {
          'success': false,
          'error': result['error'],
        };
        break;
      }
      
      attempts++;
      await Future.delayed(const Duration(seconds: 2)); // Attendre 2 secondes
    }
    
    // Timeout
    if (attempts >= maxAttempts) {
      yield {
        'success': false,
        'error': 'Timeout: Le paiement prend trop de temps',
      };
    }
  }

  /// Formater le montant pour l'affichage
  static String formatAmount(double amount) {
    return '${amount.toStringAsFixed(0)} F CFA';
  }

  /// Obtenir le message de statut
  static String getStatusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'En attente de paiement';
      case 'paid':
        return 'Paiement confirmé';
      case 'failed':
        return 'Paiement échoué';
      case 'cancelled':
        return 'Paiement annulé';
      case 'refunded':
        return 'Paiement remboursé';
      default:
        return 'Statut inconnu';
    }
  }

  /// Obtenir l'icône de statut
  static String getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return '⏳';
      case 'paid':
        return '✅';
      case 'failed':
        return '❌';
      case 'cancelled':
        return '🚫';
      case 'refunded':
        return '💰';
      default:
        return '❓';
    }
  }
}
