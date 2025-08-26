import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/restaurant_provider.dart';
import 'order_tracking_page.dart';
import 'restaurant_choice_page.dart';

class PanierPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Mon Panier'),
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Votre panier est vide',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Retour au menu'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Mon Panier'),
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
          ),
          body: Column(
            children: [
              // Indicateur du restaurant sélectionné
              Consumer<RestaurantProvider>(
                builder: (context, restaurantProvider, child) {
                  if (!restaurantProvider.hasSelectedRestaurant) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      color: Colors.orange[100],
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange[800]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Aucun restaurant sélectionné',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RestaurantChoicePage(),
                                ),
                              );
                            },
                            child: Text('Choisir'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    color: Colors.green[100],
                    child: Row(
                      children: [
                        Icon(Icons.restaurant, color: Colors.green[800]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Restaurant: ${restaurantProvider.selectedRestaurantName}',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  // Debug: afficher le nombre d'items
                  print('DEBUG: Panier contient ${cart.items.length} items');
                  print('DEBUG: Items: ${cart.items}');
                  
                  return Column(
                    children: [
                      // Debug: afficher le nombre d'items en haut
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        color: Colors.blue[100],
                        child: Text(
                          'DEBUG: ${cart.items.length} items dans le panier',
                          style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: cart.items.length,
                          itemBuilder: (context, index) {
                            final item = cart.items[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color(0xFFFFD700),
                                      child: Icon(Icons.restaurant_menu, color: Color(0xFF2C2C2C)),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item['nom'] ?? 'Plat', style: TextStyle(fontWeight: FontWeight.bold)),
                                          SizedBox(height: 4),
                                          Text('${_formatPrice(item['prix'])} F'),
                                        ],
                                      ),
                                    ),
                                    _QtyControl(
                                      quantity: (item['quantity'] as int? ?? 1),
                                      onChanged: (q) {
                                        final int qv = q < 0 ? 0 : q;
                                        if (qv == 0) {
                                          cart.removeItem(index);
                                        } else {
                                          cart.items[index]['quantity'] = qv;
                                          cart.notifyListeners();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => cart.removeItem(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Coordonnées + Total et commande
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Téléphone pour la commande', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(hintText: 'Ex: 221771234567'),
                              onChanged: (v) => cart.setPhone(v),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${cart.totalAmount.toStringAsFixed(0)} F',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C2C2C),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              child: Consumer<RestaurantProvider>(
                                builder: (context, restaurantProvider, child) {
                                  final hasRestaurant = restaurantProvider.hasSelectedRestaurant;
                                  
                                  return ElevatedButton(
                                    onPressed: hasRestaurant ? () async {
                                      final result = await cart.submitOrder();
                                      if (result['ok'] == true) {
                                        final orderId = result['data']?['commande']?['id'];
                                        try {
                                          // Commande réussie, afficher un message et vider le panier
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Commande passée avec succès !'),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                          cart.clear();
                                          Navigator.pop(context);
                                        } catch (e) {
                                          print('Erreur après commande: $e');
                                        }
                                      } else {
                                        final msg = (result['message'] ?? 'Erreur lors de la commande').toString();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(msg.length > 200 ? msg.substring(0,200) : msg),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasRestaurant ? Colors.green : Colors.grey,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      hasRestaurant ? 'Passer la commande' : 'Sélectionnez un restaurant d\'abord',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _formatPrice(dynamic prix) {
    if (prix == null) return '0';
    
    if (prix is num) {
      return prix.toStringAsFixed(0);
    } else if (prix is String) {
      final doubleValue = double.tryParse(prix);
      return doubleValue?.toStringAsFixed(0) ?? '0';
    }
    
    return '0';
  }
}

String cartToken(BuildContext context) {
  try {
    // Si vous stockez le token ailleurs, adaptez cette fonction
    return Provider.of<CartProvider>(context, listen: false).token;
  } catch (_) {
    return '';
  }
}

class _QtyControl extends StatelessWidget {
  final int quantity;
  final void Function(int newQuantity) onChanged;
  const _QtyControl({Key? key, required this.quantity, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () => onChanged(quantity - 1), icon: Icon(Icons.remove_circle_outline)),
        Text('$quantity', style: TextStyle(fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => onChanged(quantity + 1), icon: Icon(Icons.add_circle_outline)),
      ],
    );
  }
}