import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'panier_page.dart';
import 'composer_page.dart';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class MenuPage extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;

  MenuPage({required this.restaurantId, required this.restaurantName});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> ingredients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenuData();
  }

  Future<void> _loadMenuData() async {
    try {
      // Charger les plats du menu
      final menuResponse = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/menu/'),
      );

      // Charger les ingrédients
      final ingredientsResponse = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/ingredients/'),
      );

      if (menuResponse.statusCode == 200 && ingredientsResponse.statusCode == 200) {
        setState(() {
          menuItems = List<Map<String, dynamic>>.from(json.decode(menuResponse.body));
          ingredients = List<Map<String, dynamic>>.from(json.decode(ingredientsResponse.body));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement du menu')),
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

  void _addToCart(Map<String, dynamic> item) {
    Provider.of<CartProvider>(context, listen: false).addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['nom']} ajouté au panier'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName),
        backgroundColor: Color(0xFFFFD700),
        foregroundColor: Color(0xFF2C2C2C),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PanierPage()),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD700).withOpacity(0.2), Colors.white],
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Bouton Composer
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ComposerPage()),
                          );
                        },
                        icon: Icon(Icons.create, size: 28),
                        label: Text(
                          'Composer mon plat',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Menu existant
                  Expanded(
                    child: menuItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Aucun plat disponible',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadMenuData,
                                  child: Text('Actualiser'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: menuItems.length,
                            itemBuilder: (context, index) {
                              final item = menuItems[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 16),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Image du plat
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.grey.shade200,
                                            ),
                                            child: item['image'] != null
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.network(
                                                      item['image'].startsWith('http')
                                                          ? item['image']
                                                          : '${getApiBaseUrl()}${item['image']}',
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(Icons.restaurant_menu, size: 40, color: Colors.grey);
                                                      },
                                                    ),
                                                  )
                                                : Icon(Icons.restaurant_menu, size: 40, color: Colors.grey),
                                          ),
                                          SizedBox(width: 16),
                                          
                                          // Informations du plat
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['nom'] ?? 'Plat sans nom',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  '${item['prix'] ?? 0} F',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2C2C2C),
                                                  ),
                                                ),
                                                if (item['description'] != null) ...[
                                                  SizedBox(height: 4),
                                                  Text(
                                                    item['description'],
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                                SizedBox(height: 8),
                                                if (item['disponible'] == true)
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      'Disponible',
                                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                                    ),
                                                  )
                                                else
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      'Indisponible',
                                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      if (item['disponible'] == true) ...[
                                        SizedBox(height: 16),
                                        Container(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _addToCart(item),
                                            icon: Icon(Icons.add_shopping_cart),
                                            label: Text('Ajouter au panier'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFFFFD700),
                                              foregroundColor: Color(0xFF2C2C2C),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}