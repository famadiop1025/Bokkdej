import 'package:flutter/material.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String token;
  final VoidCallback? onHomePressed;
  final List<Map<String, dynamic>> orderItems;
  final double totalPrice;

  const OrderConfirmationPage({
    Key? key,
    required this.token,
    this.onHomePressed,
    required this.orderItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color blanc = Colors.white;
    final Color noir = const Color(0xFF222222);
    final Color orJaune = const Color(0xFFFFD700); // Jaune doré
    final Color vert = const Color(0xFF4CAF50);
    final Color grisClair = const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: grisClair,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Icône de succès
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: vert.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: vert,
                ),
              ),
              const SizedBox(height: 32),
              
              // Titre
              Text(
                'Commande validée !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: noir,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Message
              Text(
                'Merci pour votre commande. Voici le récapitulatif :',
                style: TextStyle(
                  fontSize: 16,
                  color: noir.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Séparateur
              Container(
                height: 2,
                color: orJaune.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 40),
              ),
              const SizedBox(height: 24),
              
              // Récapitulatif de la commande
              Expanded(
                child: orderItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: noir.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Commande enregistrée',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: noir.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Votre commande a été enregistrée\navec succès !',
                              style: TextStyle(
                                fontSize: 14,
                                color: noir.withOpacity(0.4),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tête du récapitulatif
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: grisClair,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.receipt_long, color: orJaune, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Récapitulatif de commande',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: noir,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Liste des plats
                            ...orderItems.map((item) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: orJaune.withOpacity(0.2),
                                  child: Icon(Icons.restaurant, color: orJaune, size: 20),
                                ),
                                title: Text(
                                  item['base'] ?? 'Plat personnalisé',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: noir,
                                  ),
                                ),
                                subtitle: item['ingredients'] != null && (item['ingredients'] as List).isNotEmpty
                                    ? Text(
                                        '${(item['ingredients'] as List).length} ingrédient(s)',
                                        style: TextStyle(
                                          color: noir.withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                      )
                                    : null,
                                trailing: Text(
                                  '${double.tryParse(item['prix']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'} F',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: noir,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )).toList(),
                            
                            const SizedBox(height: 16),
                            
                            // Total
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: orJaune.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: orJaune.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: noir,
                                    ),
                                  ),
                                  Text(
                                    '${totalPrice.toStringAsFixed(0)} F',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: orJaune,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Informations supplémentaires
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: grisClair,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, color: orJaune, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Heure de commande',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: noir,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateTime.now().toString().substring(11, 16),
                                    style: TextStyle(
                                      color: noir.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline, color: orJaune, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Statut',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: noir,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'En attente de préparation',
                                    style: TextStyle(
                                      color: vert,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              
              const SizedBox(height: 24),
              
              // Bouton de retour à l'accueil
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orJaune,
                    foregroundColor: noir,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                  ),
                  onPressed: () {
                    // Retour à la navigation principale
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.home, size: 20),
                  label: Text(
                    'Retour à l\'accueil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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