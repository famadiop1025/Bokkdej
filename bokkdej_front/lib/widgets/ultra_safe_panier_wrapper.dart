import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

/// Wrapper ultra-sécurisé pour le panier qui capture TOUTES les erreurs
class UltraSafePanierWrapper extends StatelessWidget {
  final Widget Function(BuildContext, CartProvider) builder;

  const UltraSafePanierWrapper({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        try {
          // Vérification ultra-sécurisée du cart
          if (cart == null) {
            print('[ULTRA SAFE] CartProvider est null !');
            return _buildErrorState('CartProvider non disponible');
          }

          // Vérification des propriétés critiques
          try {
            final _ = cart.panier; // Test d'accès
            final __ = cart.isLoading; // Test d'accès
            final ___ = cart.error; // Test d'accès
            final ____ = cart.total; // Test d'accès
          } catch (e) {
            print('[ULTRA SAFE] Erreur d\'accès aux propriétés du cart: $e');
            return _buildErrorState('Données du panier corrompues');
          }

          // Construction sécurisée
          try {
            return builder(context, cart);
          } catch (e, stackTrace) {
            print('[ULTRA SAFE] Erreur dans la construction du panier: $e');
            print('[ULTRA SAFE] Stack trace: $stackTrace');
            return _buildErrorState('Erreur d\'affichage du panier');
          }

        } catch (e, stackTrace) {
          print('[ULTRA SAFE] Erreur générale dans UltraSafePanierWrapper: $e');
          print('[ULTRA SAFE] Stack trace: $stackTrace');
          return _buildErrorState('Erreur système');
        }
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(24),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                'Panier temporairement indisponible',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Builder(
                builder: (context) => ElevatedButton.icon(
                  onPressed: () {
                    // Tenter de recharger le panier
                    try {
                      Provider.of<CartProvider>(context, listen: false).loadPanier();
                    } catch (e) {
                      print('[ULTRA SAFE] Erreur lors du rechargement: $e');
                    }
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension pour wrapper facilement le panier
extension UltraSafeExtension on Widget {
  Widget ultraSafePanier() {
    if (this is Builder) {
      final builder = this as Builder;
      return UltraSafePanierWrapper(
        builder: (context, cart) => builder.builder(context),
      );
    }
    return UltraSafePanierWrapper(
      builder: (context, cart) => this,
    );
  }
}
