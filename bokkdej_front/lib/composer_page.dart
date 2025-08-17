import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class ComposerPage extends StatefulWidget {
  @override
  _ComposerPageState createState() => _ComposerPageState();
}

class _ComposerPageState extends State<ComposerPage> {
  List<Map<String, dynamic>> bases = [];
  List<Map<String, dynamic>> ingredients = [];
  Map<String, dynamic>? selectedBase;
  List<Map<String, dynamic>> selectedIngredients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Charger les bases
      final basesResponse = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/bases/'),
      );

      // Charger les ingrédients
      final ingredientsResponse = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/ingredients/'),
      );

      if (basesResponse.statusCode == 200 && ingredientsResponse.statusCode == 200) {
        setState(() {
          bases = List<Map<String, dynamic>>.from(json.decode(basesResponse.body));
          ingredients = List<Map<String, dynamic>>.from(json.decode(ingredientsResponse.body));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des données')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    }
  }

  double get totalPrice {
    double total = 0.0;
    if (selectedBase != null) {
      total += double.tryParse(selectedBase!['prix'].toString()) ?? 0.0;
    }
    for (var ingredient in selectedIngredients) {
      total += double.tryParse(ingredient['prix'].toString()) ?? 0.0;
    }
    return total;
  }

  void _addToCart() {
    if (selectedBase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez choisir une base')),
      );
      return;
    }

    final customDish = {
      'nom': 'Plat personnalisé - ${selectedBase!['nom']}',
      'prix': totalPrice,
      'base': selectedBase,
      'ingredients': selectedIngredients,
      'type': 'custom',
    };

    Provider.of<CartProvider>(context, listen: false).addItem(customDish);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plat personnalisé ajouté au panier !'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Composer mon plat'),
        backgroundColor: Color(0xFFFFD700),
        foregroundColor: Color(0xFF2C2C2C),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sélection de la base
                  Text(
                    'Choisissez votre base',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  ...bases.map((base) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: RadioListTile<Map<String, dynamic>>(
                        title: Text(base['nom'] ?? 'Base'),
                        subtitle: Text('${base['prix'] ?? 0} F'),
                        value: base,
                        groupValue: selectedBase,
                        onChanged: (value) {
                          setState(() {
                            selectedBase = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    );
                  }).toList(),
                  
                  SizedBox(height: 24),
                  
                  // Sélection des ingrédients
                  Text(
                    'Ajoutez des ingrédients',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  ...ingredients.map((ingredient) {
                    final isSelected = selectedIngredients.contains(ingredient);
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        title: Text(ingredient['nom'] ?? 'Ingrédient'),
                        subtitle: Text('${ingredient['prix'] ?? 0} F'),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedIngredients.add(ingredient);
                            } else {
                              selectedIngredients.remove(ingredient);
                            }
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    );
                  }).toList(),
                  
                  SizedBox(height: 24),
                  
                  // Résumé et total
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Résumé de votre plat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          
                          if (selectedBase != null)
                            Text('Base: ${selectedBase!['nom']} - ${selectedBase!['prix']} F'),
                          
                          if (selectedIngredients.isNotEmpty) ...[
                            SizedBox(height: 8),
                            Text('Ingrédients:'),
                            ...selectedIngredients.map((ingredient) {
                              return Text('  • ${ingredient['nom']} - ${ingredient['prix']} F');
                            }).toList(),
                          ],
                          
                          SizedBox(height: 12),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${totalPrice.toStringAsFixed(0)} F',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Bouton d'ajout au panier
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedBase != null ? _addToCart : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD700),
                        foregroundColor: Color(0xFF2C2C2C),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Ajouter au panier',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}