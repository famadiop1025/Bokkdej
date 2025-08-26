import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'panier_page.dart';
import 'composer_page.dart';
import 'order_tracking_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/device_id_service.dart';
import 'dart:async';


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
  Timer? _notifTimer;

  @override
  void initState() {
    super.initState();
    _loadMenuData();
    // Conserver l'id restaurant dans le panier pour la commande
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Provider.of<CartProvider>(context, listen: false).setRestaurantId(widget.restaurantId);
      } catch (_) {}
    });
    // Notifications supprimées
  }

  Future<void> _loadMenuData() async {
    try {
      // 1) Charger le menu du restaurant sélectionné
      List<Map<String, dynamic>> loadedMenu = [];
      final menuResp1 = await http.get(Uri.parse('${getApiBaseUrl()}/api/restaurants/${widget.restaurantId}/menu/'));
      if (menuResp1.statusCode == 200) {
        final decoded = json.decode(menuResp1.body);
        if (decoded is Map<String, dynamic> && decoded['menu'] is List) {
          loadedMenu = List<Map<String, dynamic>>.from(decoded['menu']);
        } else if (decoded is List) {
          loadedMenu = List<Map<String, dynamic>>.from(decoded);
        }
      }

      // 2) Fallback: endpoint générique avec filtre restaurant
      if (loadedMenu.isEmpty) {
        final menuResp2 = await http.get(
          Uri.parse('${getApiBaseUrl()}/api/menu/').replace(queryParameters: {'restaurant': '${widget.restaurantId}'}),
        );
        if (menuResp2.statusCode == 200) {
          final decoded2 = json.decode(menuResp2.body);
          if (decoded2 is List) {
            loadedMenu = List<Map<String, dynamic>>.from(decoded2);
          }
        }
      }

      // 3) Charger les ingrédients (ne bloque pas l'affichage du menu en cas d'erreur)
      try {
        final ingredientsResponse = await http.get(Uri.parse('${getApiBaseUrl()}/api/ingredients/'));
        if (ingredientsResponse.statusCode == 200) {
          ingredients = List<Map<String, dynamic>>.from(json.decode(ingredientsResponse.body));
        }
      } catch (_) {}

      setState(() {
        menuItems = loadedMenu;
        isLoading = false;
      });
      if (loadedMenu.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucun plat disponible pour ce restaurant.')),
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



  @override
  void dispose() {
    _notifTimer?.cancel();
    super.dispose();
  }

  void _addToCart(Map<String, dynamic> item, {int quantity = 1}) {
    Provider.of<CartProvider>(context, listen: false).addItem(item, quantity: quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['nom']} x$quantity ajouté(s) au panier'), duration: Duration(seconds: 1)),
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
          // Notifications supprimées
          IconButton(
            tooltip: 'Suivre une commande',
            icon: Icon(Icons.local_shipping),
            onPressed: () async {
              final controller = TextEditingController();
              final choice = await showDialog<String?>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Suivre une commande'),
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(hintText: 'Entrez votre numéro'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, null), child: Text('Annuler')),
                    TextButton(onPressed: () => Navigator.pop(ctx, 'PHONE'), child: Text('Continuer')),
                    TextButton(onPressed: () => Navigator.pop(ctx, 'DEVICE'), child: Text('Cet appareil')),
                  ],
                ),
              );
              if (choice == null) return;
              try {
                if (choice == 'DEVICE') {
                  final did = await DeviceIdService.getOrCreate();
                  // Chercher panier/commande par device (panier -> id)
                  final getResp = await http.get(
                    Uri.parse('${getApiBaseUrl()}/api/orders/panier/').replace(queryParameters: {'device_id': did}),
                  );
                  int? orderId;
                  if (getResp.statusCode == 200) {
                    final p = json.decode(getResp.body);
                    if (p is Map && p['panier'] is Map && (p['panier']['id'] is int)) {
                      orderId = p['panier']['id'] as int;
                    }
                  }
                  // Sinon tenter l'historique par téléphone s'il existe
                  if (orderId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aucune commande trouvée pour cet appareil')));
                    return;
                  }
                  final token = Provider.of<CartProvider>(context, listen: false).token;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingPage(orderId: orderId!, token: token)));
                  return;
                } else {
                  final phone = controller.text;
                  final normalized = phone.replaceAll(RegExp(r'[^0-9]'), '');
                  if (normalized.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Numéro invalide')));
                    return;
                  }
                  final uri = Uri.parse('${getApiBaseUrl()}/api/orders/historique').replace(queryParameters: {
                    'phone': normalized,
                  });
                  final resp = await http.get(uri);
                  if (resp.statusCode == 200) {
                    final data = json.decode(resp.body);
                    final List orders = (data is Map && data['orders'] is List) ? data['orders'] as List : const [];
                    if (orders.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aucune commande trouvée pour ce numéro')));
                      return;
                    }
                    final latest = orders.first as Map<String, dynamic>;
                    final int? orderId = latest['id'] is int ? latest['id'] as int : int.tryParse(latest['id']?.toString() ?? '');
                    if (orderId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Commande introuvable')));
                      return;
                    }
                    final token = Provider.of<CartProvider>(context, listen: false).token;
                    Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingPage(orderId: orderId!, token: token, phone: normalized)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${resp.statusCode}')));
                  }
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
              }
            },
          ),
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
                  
                  // Menu par catégories avec onglets
                  Expanded(
                    child: DefaultTabController(
                      length: 4,
                      child: Column(
                        children: [
                          TabBar(
                            indicatorColor: Color(0xFFFFD700),
                            labelColor: Color(0xFF2C2C2C),
                            tabs: const [
                              Tab(text: 'Tous'),
                              Tab(text: 'Petit-déj.'),
                              Tab(text: 'Déjeuner'),
                              Tab(text: 'Dîner'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildMenuListForType(null),
                                _buildMenuListForType('petit_dej'),
                                _buildMenuListForType('dej'),
                                _buildMenuListForType('diner'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMenuListForType(String? type) {
    final List<Map<String, dynamic>> source = type == null
        ? List<Map<String, dynamic>>.from(menuItems)
        : menuItems.where((e) => (e['type'] ?? '') == type).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
    if (source.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucun plat disponible', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadMenuData, child: Text('Actualiser')),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: source.length,
      itemBuilder: (context, index) {
        final item = source[index];
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
                      child: (item['image_url'] ?? item['image']) != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                (() {
                                  final src = (item['image_url'] ?? item['image']).toString();
                                  if (src.startsWith('http')) return src;
                                  return '${getApiBaseUrl()}$src';
                                })(),
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
                  _QuantityAndAddRow(item: item, onAdd: (q) => _addToCart(item, quantity: q)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuantityAndAddRow extends StatefulWidget {
  final Map<String, dynamic> item;
  final void Function(int quantity) onAdd;
  const _QuantityAndAddRow({Key? key, required this.item, required this.onAdd}) : super(key: key);
  @override
  State<_QuantityAndAddRow> createState() => _QuantityAndAddRowState();
}

class _QuantityAndAddRowState extends State<_QuantityAndAddRow> {
  int qty = 1;
  void _inc() => setState(() => qty++);
  void _dec() => setState(() { if (qty > 1) qty--; });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                IconButton(onPressed: _dec, icon: Icon(Icons.remove)),
                Text('$qty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(onPressed: _inc, icon: Icon(Icons.add)),
              ]),
            ),
          ],
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => widget.onAdd(qty),
          icon: Icon(Icons.add_shopping_cart),
          label: Text('Ajouter au panier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFD700),
            foregroundColor: Color(0xFF2C2C2C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}