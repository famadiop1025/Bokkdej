import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/wave_icon.dart';
import '../widgets/simple_wave_icon.dart';
import '../widgets/penguin_wave_icon.dart';
import '../widgets/wave_banner_icon.dart';
import '../widgets/wave_official_icon.dart';
import '../widgets/wave_simple_text_icon.dart';
import '../widgets/simple_red_box.dart';
import '../widgets/ultra_visible_test.dart';
import '../widgets/test_button_replacement.dart';
import '../widgets/wave_image_test.dart';
import '../widgets/wave_network_test.dart';
import 'payment_page.dart';

class CartPageWithWave extends StatelessWidget {
  const CartPageWithWave({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        backgroundColor: const Color(0xFF00D4AA),
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Votre panier est vide',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Liste des articles
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return _buildCartItem(context, cartProvider, item, index);
                  },
                ),
              ),
              
              // Résumé et boutons
              _buildCartSummary(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartProvider cartProvider, Map<String, dynamic> item, int index) {
    final quantity = item['quantity'] ?? 1;
    final price = (item['prix'] ?? 0.0).toDouble();
    final total = price * quantity;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image ou icône
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF00D4AA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Color(0xFF00D4AA),
                size: 30,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Informations de l'article
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nom'] ?? 'Article',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item['ingredients'] != null && item['ingredients'].isNotEmpty)
                    Text(
                      item['ingredients'].join(', '),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${price.toStringAsFixed(0)} F CFA',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Total: ${total.toStringAsFixed(0)} F CFA',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D4AA),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bouton supprimer
            IconButton(
              onPressed: () => cartProvider.removeItem(index),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Résumé des prix
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sous-total:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                '${cartProvider.totalAmount.toStringAsFixed(0)} F CFA',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Frais de service:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Text(
                '0 F CFA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${cartProvider.totalAmount.toStringAsFixed(0)} F CFA',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D4AA),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Boutons d'action
          Row(
            children: [
              // Bouton Commander (sans paiement)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleOrderWithoutPayment(context, cartProvider),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00D4AA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Commander',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00D4AA),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Bouton Payer avec Wave
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handlePaymentWithWave(context, cartProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WaveImageTest(width: 100, height: 32),
                      const SizedBox(width: 8),
                      const Text(
                        'Payer avec Wave',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Widget de test ultra visible
          const TestButtonReplacement(),
          
          // Test de l'image Wave depuis le web
          Padding(
            padding: const EdgeInsets.all(16),
            child: WaveNetworkTest(width: 150, height: 50),
          ),
        ],
      ),
    );
  }

  Future<void> _handleOrderWithoutPayment(BuildContext context, CartProvider cartProvider) async {
    // Afficher un dialogue de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la commande'),
        content: const Text(
          'Voulez-vous confirmer votre commande ? Vous pourrez payer plus tard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _submitOrder(context, cartProvider);
    }
  }

  Future<void> _handlePaymentWithWave(BuildContext context, CartProvider cartProvider) async {
    // Vérifier que le restaurant est sélectionné
    if (cartProvider.selectedRestaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un restaurant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier que le téléphone est renseigné
    if (cartProvider.phone == null || cartProvider.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner votre numéro de téléphone'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Afficher un dialogue de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paiement avec Wave'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Voulez-vous procéder au paiement avec Wave ?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Montant:'),
                Text(
                  '${cartProvider.totalAmount.toStringAsFixed(0)} F CFA',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Restaurant:'),
                Expanded(
                  child: Text(
                    cartProvider.selectedRestaurantName ?? 'Non sélectionné',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA),
              foregroundColor: Colors.white,
            ),
            child: const Text('Payer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _createOrderAndNavigateToPayment(context, cartProvider);
    }
  }

  Future<void> _submitOrder(BuildContext context, CartProvider cartProvider) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await cartProvider.submitOrder();
      
      // Fermer le dialogue de chargement
      Navigator.of(context).pop();
      
      if (result['ok']) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande confirmée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Vider le panier
        cartProvider.clear();
        
        // Retourner à la page précédente
        Navigator.of(context).pop();
      } else {
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de la commande'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement
      Navigator.of(context).pop();
      
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createOrderAndNavigateToPayment(BuildContext context, CartProvider cartProvider) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await cartProvider.createOrderForPayment();
      
      // Fermer le dialogue de chargement
      Navigator.of(context).pop();
      
      if (result['ok']) {
        // Naviguer vers la page de paiement
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              orderId: result['orderId'],
              amount: result['amount'],
              restaurantName: result['restaurantName'],
              items: result['items'],
            ),
          ),
        );
      } else {
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de la création de la commande'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement
      Navigator.of(context).pop();
      
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
