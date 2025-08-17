import 'package:flutter/foundation.dart';
import 'dart:developer';

/// Gestionnaire global d'erreurs pour traquer les erreurs null
class GlobalErrorHandler {
  static int _errorCount = 0;
  static Set<String> _seenErrors = {};
  
  /// Initialiser le gestionnaire d'erreurs global
  static void initialize() {
    // Capturer les erreurs Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleError(details.exception, details.stack, 'Flutter Framework');
    };
    
    // Capturer les erreurs Dart non gérées
    PlatformDispatcher.instance.onError = (error, stack) {
      _handleError(error, stack, 'Dart Runtime');
      return true;
    };
  }
  
  /// Traiter une erreur capturée
  static void _handleError(dynamic error, StackTrace? stack, String source) {
    final errorString = error.toString();
    
    // Détecter spécifiquement les erreurs null
    if (errorString.contains('Unexpected null value') || 
        errorString.contains('null check operator') ||
        errorString.contains('Null check operator used on a null value')) {
      
      _errorCount++;
      
      // Éviter les doublons
      final errorKey = '${errorString}_${stack?.toString().split('\n').take(5).join('\n')}';
      if (_seenErrors.contains(errorKey)) {
        return;
      }
      _seenErrors.add(errorKey);
      
      print('🚨 [NULL ERROR #$_errorCount] Source: $source');
      print('🚨 Erreur: $errorString');
      
      if (stack != null) {
        final stackLines = stack.toString().split('\n');
        print('🚨 Stack trace (top 10):');
        for (int i = 0; i < stackLines.length && i < 10; i++) {
          final line = stackLines[i].trim();
          if (line.isNotEmpty) {
            // Mettre en évidence les lignes de notre code
            if (line.contains('panier_page.dart') || 
                line.contains('cart_provider.dart') ||
                line.contains('debug_safe_widget.dart')) {
              print('🎯 $line');
            } else {
              print('   $line');
            }
          }
        }
      }
      
      print('🚨 Total erreurs null détectées: $_errorCount');
      print('----------------------------------------');
    }
  }
  
  /// Réinitialiser les compteurs
  static void reset() {
    _errorCount = 0;
    _seenErrors.clear();
  }
  
  /// Obtenir le nombre d'erreurs
  static int get errorCount => _errorCount;
}
