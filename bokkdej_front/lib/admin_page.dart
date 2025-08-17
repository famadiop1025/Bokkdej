import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'main.dart';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class AdminPage extends StatefulWidget {
  final String token;
  final String userRole;
  
  AdminPage({required this.token, required this.userRole});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  String? userRole;

  late final List<Widget> _pages;

  final List<String> _titles = [
    'Tableau de Bord',
    'Gestion Restaurants',
    'Gestion Menu',
    'Gestion Commandes',
    'Gestion Utilisateurs',
    'Statistiques',
  ];

  @override
  void initState() {
    super.initState();
    userRole = widget.userRole;
    _pages = [
      AdminDashboard(),
      AdminRestaurantManagement(token: widget.token),
      AdminMenuManagement(),
      AdminOrdersManagement(),
      AdminUsersManagement(token: widget.token),
      AdminStatsPage(),
    ];
  }

  Future<void> _logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Color(0xFFFFD700),
        foregroundColor: Color(0xFF2C2C2C),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
    setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Color(0xFFFFD700),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}

// Dashboard Admin
class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic> dashboardData = {
    'total_commandes': 25,
    'commandes_en_attente': 3,
    'revenus_jour': 1500.0,
    'plats_populaires': 12,
  };

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD700).withOpacity(0.1), Colors.white],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue dans votre espace administration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Commandes Total',
                    '${dashboardData['total_commandes']}',
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'En Attente',
                    '${dashboardData['commandes_en_attente']}',
                    Icons.hourglass_empty,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Revenus du Jour',
                    '${dashboardData['revenus_jour']} F',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Plats Populaires',
                    '${dashboardData['plats_populaires']}',
                    Icons.star,
                    Color(0xFFFFD700),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions Rapides',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickAction(
                          'Nouveau Plat',
                          Icons.add_circle,
                          Color(0xFFFFD700),
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Fonctionnalité à venir')),
                            );
                          },
                        ),
                        _buildQuickAction(
                          'Voir Commandes',
                          Icons.list,
                          Colors.blue,
                          () {
                            // Navigation vers commandes
                          },
                        ),
                        _buildQuickAction(
                          'Statistiques',
                          Icons.bar_chart,
                          Colors.purple,
                          () {
                            // Navigation vers stats
                          },
                        ),
                      ],
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

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Gestion Menu
class AdminMenuManagement extends StatefulWidget {
  @override
  _AdminMenuManagementState createState() => _AdminMenuManagementState();
}

class _AdminMenuManagementState extends State<AdminMenuManagement> {
  List<Map<String, dynamic>> menuItems = [
    {
      'id': 1,
      'nom': 'Omelette au fromage',
      'prix': 500,
      'description': 'Délicieuse omelette avec fromage',
      'disponible': true,
      'populaire': true,
    },
    {
      'id': 2,
      'nom': 'Riz au poisson',
      'prix': 800,
      'description': 'Plat traditionnel sénégalais',
      'disponible': true,
      'populaire': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD700).withOpacity(0.1), Colors.white],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestion du Menu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddDishDialog();
                  },
                  icon: Icon(Icons.add),
                  label: Text('Ajouter Plat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD700),
                    foregroundColor: Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFD700).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.restaurant_menu, 
                            color: Color(0xFF2C2C2C), size: 30),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nom'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${item['prix']} F',
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
                                ),
                              ],
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item['disponible'] ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item['disponible'] ? 'Disponible' : 'Indisponible',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  if (item['populaire']) ...[
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFD700),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Populaire',
                                        style: TextStyle(color: Color(0xFF2C2C2C), fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () => _editDish(item),
                              icon: Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () => _deleteDish(item),
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDishDialog() {
    final _nameController = TextEditingController();
    final _priceController = TextEditingController();
    final _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un Plat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nom du plat'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Prix (F)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
                setState(() {
                  menuItems.add({
                    'id': menuItems.length + 1,
                    'nom': _nameController.text,
                    'prix': int.tryParse(_priceController.text) ?? 0,
                    'description': _descriptionController.text,
                    'disponible': true,
                    'populaire': false,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Plat ajouté avec succès !')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700)),
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _editDish(Map<String, dynamic> dish) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Édition de ${dish['nom']} - Fonctionnalité à venir')),
    );
  }

  void _deleteDish(Map<String, dynamic> dish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le plat'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${dish['nom']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                menuItems.remove(dish);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Plat supprimé')),
              );
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Gestion Commandes
class AdminOrdersManagement extends StatefulWidget {
  @override
  _AdminOrdersManagementState createState() => _AdminOrdersManagementState();
}

class _AdminOrdersManagementState extends State<AdminOrdersManagement> {
  List<Map<String, dynamic>> orders = [
    {
      'id': 1,
      'client': 'Client A',
      'total': 1500,
      'statut': 'en_attente',
      'items': ['Omelette au fromage', 'Riz au poisson'],
      'date': '10/08/2025 - 14:30',
    },
    {
      'id': 2,
      'client': 'Client B',
      'total': 800,
      'statut': 'en_preparation',
      'items': ['Riz au poisson'],
      'date': '10/08/2025 - 14:15',
    },
  ];

  String _getStatusText(String status) {
    switch (status) {
      case 'en_attente': return 'En attente';
      case 'en_preparation': return 'En préparation';
      case 'pret': return 'Prêt';
      case 'livre': return 'Livré';
      default: return 'Inconnu';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'en_attente': return Colors.orange;
      case 'en_preparation': return Colors.blue;
      case 'pret': return Colors.green;
      case 'livre': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD700).withOpacity(0.1), Colors.white],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Gestion des Commandes',
          style: TextStyle(
                fontSize: 24,
            fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Commande #${order['id']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
                                color: _getStatusColor(order['statut']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(order['statut']),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Client: ${order['client']}'),
                        Text('Date: ${order['date']}'),
                        Text('Total: ${order['total']} F'),
                        SizedBox(height: 8),
                        Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...((order['items'] as List).map((item) => Text('• $item'))),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (order['statut'] == 'en_attente')
                              ElevatedButton(
                                onPressed: () => _updateOrderStatus(index, 'en_preparation'),
                                child: Text('Accepter'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                            if (order['statut'] == 'en_preparation')
                              ElevatedButton(
                                onPressed: () => _updateOrderStatus(index, 'pret'),
                                child: Text('Marquer Prêt'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              ),
                            if (order['statut'] == 'pret')
                              ElevatedButton(
                                onPressed: () => _updateOrderStatus(index, 'livre'),
                                child: Text('Marquer Livré'),
                                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700)),
                              ),
                            ElevatedButton(
            onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Détails de la commande #${order['id']}')),
                                );
            },
                              child: Text('Détails'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          ),
        ],
      ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(int index, String newStatus) {
    setState(() {
      orders[index]['statut'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Statut mis à jour: ${_getStatusText(newStatus)}')),
    );
  }
}

// Gestion Restaurants
class AdminRestaurantManagement extends StatefulWidget {
  final String token;

  AdminRestaurantManagement({required this.token});

  @override
  _AdminRestaurantManagementState createState() => _AdminRestaurantManagementState();
}

class _AdminRestaurantManagementState extends State<AdminRestaurantManagement> {
  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> _filteredRestaurants = [];
  bool isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();
  String? _statusFilter; // null = tous
  String _sortBy = 'nom'; // 'nom' | 'date'
  bool _sortAsc = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurantsFromApi();
  }

  Future<void> _loadRestaurantsFromApi() async {
    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/admin/restaurants/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          restaurants = data.map((restaurant) {
            return {
              'id': restaurant['id'],
              'nom': restaurant['nom'],
              'adresse': restaurant['adresse'] ?? '',
              'telephone': restaurant['telephone'] ?? '',
              'email': restaurant['email'] ?? '',
              'actif': restaurant['actif'] ?? true,
              'statut': restaurant['statut'] ?? 'en_attente',
              'logo_url': restaurant['logo_url'] ?? '',
              'date_creation': _formatDate(restaurant['created_at'] ?? ''),
              'created_at': restaurant['created_at'] ?? '',
            };
          }).toList();
          isLoading = false;
          _applyRestaurantFilterAndSort();
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        restaurants = [
          {
            'id': 1,
            'nom': 'Restaurant Test',
            'adresse': 'Dakar, Sénégal',
            'telephone': '221771234567',
            'email': 'test@restaurant.com',
            'actif': true,
            'statut': 'valide',
            'date_creation': '15/08/2025',
          },
        ];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Impossible de charger les restaurants: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Date inconnue';
    }
  }

  void _applyRestaurantFilterAndSort() {
    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(restaurants);
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((r) => (r['nom'] ?? '').toString().toLowerCase().contains(q)).toList();
    }
    if (_statusFilter != null && _statusFilter!.isNotEmpty) {
      list = list.where((r) => (r['statut'] ?? '') == _statusFilter).toList();
    }
    int cmp(Map<String, dynamic> a, Map<String, dynamic> b) {
      if (_sortBy == 'date') {
        final DateTime da = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime db = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return da.compareTo(db);
      }
      return (a['nom'] ?? '').toString().toLowerCase().compareTo((b['nom'] ?? '').toString().toLowerCase());
    }
    list.sort(cmp);
    if (!_sortAsc) {
      list = list.reversed.toList();
    }
    setState(() {
      _filteredRestaurants = list;
    });
  }

  String _getStatutText(String statut) {
    switch (statut) {
      case 'en_attente': return 'En attente';
      case 'valide': return 'Validé';
      case 'suspendu': return 'Suspendu';
      case 'rejete': return 'Rejeté';
      default: return 'Inconnu';
    }
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'en_attente': return Colors.orange;
      case 'valide': return Colors.green;
      case 'suspendu': return Colors.red;
      case 'rejete': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD700).withOpacity(0.1), Colors.white],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gestion des Restaurants',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAddRestaurantDialog();
                      },
                      icon: Icon(Icons.add_business),
                      label: Text('Ajouter Restaurant'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD700),
                        foregroundColor: Color(0xFF2C2C2C),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(labelText: 'Rechercher par nom'),
                        onChanged: (_) => setState(_applyRestaurantFilterAndSort),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String?>(
                        value: _statusFilter,
                        decoration: InputDecoration(labelText: 'Statut'),
                        items: const [
                          DropdownMenuItem<String?>(value: null, child: Text('Tous')),
                          DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
                          DropdownMenuItem(value: 'valide', child: Text('Validé')),
                          DropdownMenuItem(value: 'suspendu', child: Text('Suspendu')),
                          DropdownMenuItem(value: 'rejete', child: Text('Rejeté')),
                        ],
                        onChanged: (v) => setState(() { _statusFilter = v; _applyRestaurantFilterAndSort(); }),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: InputDecoration(labelText: 'Trier par'),
                        items: const [
                          DropdownMenuItem(value: 'nom', child: Text('Nom')),
                          DropdownMenuItem(value: 'date', child: Text('Date création')),
                        ],
                        onChanged: (v) => setState(() { _sortBy = v ?? 'nom'; _applyRestaurantFilterAndSort(); }),
                      ),
                    ),
                    IconButton(
                      tooltip: _sortAsc ? 'Tri croissant' : 'Tri décroissant',
                      onPressed: () => setState(() { _sortAsc = !_sortAsc; _applyRestaurantFilterAndSort(); }),
                      icon: Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _searchCtrl.clear();
                        _statusFilter = null;
                        _sortBy = 'nom';
                        _sortAsc = true;
                        _applyRestaurantFilterAndSort();
                      }),
                      child: Text('Réinitialiser'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFFFD700)),
                      SizedBox(height: 16),
                      Text('Chargement des restaurants...'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _filteredRestaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = _filteredRestaurants[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: (restaurant['logo_url'] ?? '').toString().isNotEmpty
                                  ? Image.network(restaurant['logo_url'], fit: BoxFit.cover)
                                  : Container(
                                      color: Color(0xFFFFD700).withOpacity(0.3),
                                      child: Icon(Icons.business, color: Color(0xFF2C2C2C), size: 30),
                                    ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurant['nom'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '📍 ${restaurant['adresse']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '📞 ${restaurant['telephone']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (restaurant['email'].isNotEmpty) Text(
                                    '✉️ ${restaurant['email']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatutColor(restaurant['statut']),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getStatutText(restaurant['statut']),
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: restaurant['actif'] ? Colors.green : Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          restaurant['actif'] ? 'Actif' : 'Inactif',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Créé le: ${restaurant['date_creation']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () => _openRestaurantDashboard(restaurant),
                                  icon: Icon(Icons.dashboard, color: Color(0xFFFFD700)),
                                  tooltip: 'Gérer Restaurant',
                                ),
                                IconButton(
                                  onPressed: () => _editRestaurant(restaurant),
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'Modifier',
                                ),
                                if (restaurant['statut'] != 'valide')
                                  IconButton(
                                    onPressed: () => _validateRestaurant(restaurant),
                                    icon: Icon(Icons.verified, color: Colors.green),
                                    tooltip: 'Valider',
                                  ),
                                IconButton(
                                  onPressed: () => _toggleRestaurantStatus(restaurant),
                                  icon: Icon(
                                    restaurant['actif'] ? Icons.block : Icons.check_circle,
                                    color: restaurant['actif'] ? Colors.red : Colors.green,
                                  ),
                                  tooltip: restaurant['actif'] ? 'Désactiver' : 'Activer',
                                ),
                                IconButton(
                                  onPressed: () => _deleteRestaurant(restaurant),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Supprimer',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  void _showAddRestaurantDialog() {
    final _nomController = TextEditingController();
    final _adresseController = TextEditingController();
    final _telephoneController = TextEditingController();
    final _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un Restaurant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom du restaurant *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _adresseController,
                decoration: InputDecoration(
                  labelText: 'Adresse *',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Dakar, Sénégal',
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _telephoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone *',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 221771234567',
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  hintText: 'restaurant@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info, color: Color(0xFF2C2C2C)),
                    SizedBox(height: 8),
                    Text(
                      'Le restaurant sera créé avec son propre espace de gestion (menu, commandes, personnel).',
                      style: TextStyle(fontSize: 12, color: Color(0xFF2C2C2C)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nomController.text.isNotEmpty && 
                  _adresseController.text.isNotEmpty && 
                  _telephoneController.text.isNotEmpty) {
                
                await _createRestaurantInBackend(
                  _nomController.text,
                  _adresseController.text,
                  _telephoneController.text,
                  _emailController.text,
                );
                
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Veuillez remplir tous les champs obligatoires'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700)),
            child: Text('Créer Restaurant', style: TextStyle(color: Color(0xFF2C2C2C))),
          ),
        ],
      ),
    );
  }

  Future<void> _createRestaurantInBackend(String nom, String adresse, String telephone, String email) async {
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/admin/restaurants/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode({
          'nom': nom,
          'adresse': adresse,
          'telephone': telephone,
          'email': email,
          'actif': true,
          'statut': 'valide',
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        setState(() {
          restaurants.add({
            'id': responseData['id'],
            'nom': nom,
            'adresse': adresse,
            'telephone': telephone,
            'email': email,
            'actif': true,
            'statut': 'valide',
            'date_creation': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Restaurant créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        // Proposer d'uploader un logo
        _promptUploadRestaurantLogo(responseData['id']);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de la création: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _promptUploadRestaurantLogo(int restaurantId) async {
    final pick = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Logo du restaurant'),
        content: Text('Voulez-vous ajouter un logo maintenant ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Plus tard')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Ajouter')),
        ],
      ),
    );
    if (pick == true) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
        if (file == null) return;
        final uri = Uri.parse('${getApiBaseUrl()}/api/upload-image/');
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer ${widget.token}'
          ..fields['model_type'] = 'restaurant'
          ..fields['item_id'] = restaurantId.toString()
          ..files.add(await http.MultipartFile.fromPath('image', file.path));
        final resp = await request.send();
        if (resp.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logo uploadé'), backgroundColor: Colors.green));
        } else {
          throw Exception('Erreur API: ${resp.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur upload logo: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _openRestaurantDashboard(Map<String, dynamic> restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDashboard(
          restaurant: restaurant,
          token: widget.token,
        ),
      ),
    );
  }

  void _editRestaurant(Map<String, dynamic> restaurant) {
    final nameCtrl = TextEditingController(text: restaurant['nom']?.toString() ?? '');
    final addrCtrl = TextEditingController(text: restaurant['adresse']?.toString() ?? '');
    final phoneCtrl = TextEditingController(text: restaurant['telephone']?.toString() ?? '');
    final emailCtrl = TextEditingController(text: restaurant['email']?.toString() ?? '');
    String statut = (restaurant['statut']?.toString() ?? 'en_attente');
    bool actif = (restaurant['actif'] ?? true) == true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier le restaurant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nom *')),
              SizedBox(height: 8),
              TextField(controller: addrCtrl, decoration: InputDecoration(labelText: 'Adresse *')),
              SizedBox(height: 8),
              TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'Téléphone *'), keyboardType: TextInputType.phone),
              SizedBox(height: 8),
              TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: statut,
                decoration: InputDecoration(labelText: 'Statut'),
                items: const [
                  DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
                  DropdownMenuItem(value: 'valide', child: Text('Validé')),
                  DropdownMenuItem(value: 'suspendu', child: Text('Suspendu')),
                  DropdownMenuItem(value: 'rejete', child: Text('Rejeté')),
                ],
                onChanged: (v) => statut = v ?? statut,
              ),
              SizedBox(height: 8),
              Row(children: [Switch(value: actif, onChanged: (v) => actif = v), Text('Actif')]),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await _uploadRestaurantLogo(restaurant['id']);
                    await _loadRestaurantsFromApi();
                  },
                  icon: Icon(Icons.image),
                  label: Text('Changer le logo'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              try {
                final resp = await http.put(
                  Uri.parse('${getApiBaseUrl()}/api/admin/restaurants/${restaurant['id']}/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode({
                    'nom': nameCtrl.text,
                    'adresse': addrCtrl.text,
                    'telephone': phoneCtrl.text,
                    'email': emailCtrl.text,
                    'statut': statut,
                    'actif': actif,
                  }),
                );
                if (resp.statusCode == 200) {
                  Navigator.pop(context);
                  await _loadRestaurantsFromApi();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restaurant mis à jour'), backgroundColor: Colors.green));
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _validateRestaurant(Map<String, dynamic> restaurant) async {
    try {
      final resp = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/admin/restaurants/${restaurant['id']}/valider_restaurant/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200) {
        await _loadRestaurantsFromApi();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restaurant validé'), backgroundColor: Colors.green));
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _uploadRestaurantLogo(int restaurantId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return;
      final uri = Uri.parse('${getApiBaseUrl()}/api/upload-image/');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${widget.token}'
        ..fields['model_type'] = 'restaurant'
        ..fields['item_id'] = restaurantId.toString()
        ..files.add(await http.MultipartFile.fromPath('image', file.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logo mis à jour'), backgroundColor: Colors.green));
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur upload logo: $e'), backgroundColor: Colors.red));
    }
  }

  void _toggleRestaurantStatus(Map<String, dynamic> restaurant) {
    final bool isActive = restaurant['actif'] == true;
    final String action = isActive ? 'suspendre_restaurant' : 'reactiver_restaurant';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isActive ? 'Suspendre le restaurant' : 'Réactiver le restaurant'),
        content: Text(isActive ? 'Suspendre "${restaurant['nom']}" ?' : 'Réactiver "${restaurant['nom']}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final resp = await http.post(
                  Uri.parse('${getApiBaseUrl()}/api/admin/restaurants/${restaurant['id']}/$action/'),
                  headers: {'Authorization': 'Bearer ${widget.token}'},
                );
                if (resp.statusCode == 200) {
                  await _loadRestaurantsFromApi();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isActive ? 'Restaurant suspendu' : 'Restaurant réactivé'), backgroundColor: Colors.green));
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            child: Text(isActive ? 'Suspendre' : 'Réactiver'),
          ),
        ],
      ),
    );
  }

  void _deleteRestaurant(Map<String, dynamic> restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le restaurant'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${restaurant['nom']}" ?\n\nToutes les données associées (menu, commandes, personnel) seront supprimées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final resp = await http.delete(
                  Uri.parse('${getApiBaseUrl()}/api/admin/restaurants/${restaurant['id']}/'),
                  headers: {'Authorization': 'Bearer ${widget.token}'},
                );
                if (resp.statusCode == 204) {
                  setState(() {
                    restaurants.removeWhere((r) => r['id'] == restaurant['id']);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restaurant supprimé'), backgroundColor: Colors.green));
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Dashboard spécifique pour chaque restaurant
class RestaurantDashboard extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String token;

  RestaurantDashboard({required this.restaurant, required this.token});

  @override
  _RestaurantDashboardState createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;
  final List<String> _titles = [
    'Dashboard',
    'Menu',
    'Commandes',
    'Personnel',
    'Statistiques',
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      RestaurantSpecificDashboard(restaurant: widget.restaurant, token: widget.token),
      RestaurantSpecificMenu(restaurant: widget.restaurant, token: widget.token),
      RestaurantSpecificOrders(restaurant: widget.restaurant, token: widget.token),
      RestaurantSpecificStaff(restaurant: widget.restaurant, token: widget.token),
      RestaurantSpecificStats(restaurant: widget.restaurant, token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.restaurant['nom']} - ${_titles[_selectedIndex]}'),
        backgroundColor: Color(0xFFFFD700),
        foregroundColor: Color(0xFF2C2C2C),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Color(0xFFFFD700),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Personnel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}

// Composants spécifiques pour chaque restaurant
class RestaurantSpecificDashboard extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String token;

  RestaurantSpecificDashboard({required this.restaurant, required this.token});

  @override
  State<RestaurantSpecificDashboard> createState() => _RestaurantSpecificDashboardState();
}

class _RestaurantSpecificDashboardState extends State<RestaurantSpecificDashboard> {
  bool _loading = true;
  String? _error;
  int _menuCount = 0;
  int _ordersToday = 0;
  int _staffCount = 0;
  double _revenueToday = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final restaurantId = widget.restaurant['id'];
      // 1) Menu count (public)
      final menuResp = await http.get(Uri.parse('${getApiBaseUrl()}/api/restaurants/$restaurantId/menu/'));
      if (menuResp.statusCode == 200) {
        final data = json.decode(menuResp.body);
        final List<dynamic> menu = data['menu'] ?? [];
        _menuCount = menu.length;
      }

      // 2) Staff count (admin, filtré par restaurant)
      final staffResp = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/?restaurant=$restaurantId'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (staffResp.statusCode == 200) {
        final List<dynamic> staff = json.decode(staffResp.body);
        _staffCount = staff.length;
      }

      // 3) Statistiques globales (au moins pour aujourd'hui)
      final statsResp = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/admin/statistics/?restaurant=$restaurantId'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (statsResp.statusCode == 200) {
        final stats = json.decode(statsResp.body);
        _ordersToday = (stats['orders']?['today'] ?? 0) as int;
        _revenueToday = (stats['revenue']?['today'] ?? 0).toDouble();
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(height: 8),
            Text('Erreur: $_error'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
            )
          ],
        ),
      );
    }

    final restaurant = widget.restaurant;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD700).withOpacity(0.1), Colors.white],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard - ${restaurant['nom']}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard('Éléments du menu', '$_menuCount', Icons.restaurant_menu, Colors.blue),
                  _buildStatCard('Commandes aujourd\'hui', '$_ordersToday', Icons.shopping_cart, Colors.green),
                  _buildStatCard('Personnel', '$_staffCount', Icons.people, Colors.purple),
                  _buildStatCard('Revenus du jour', '${_revenueToday.toStringAsFixed(0)} F', Icons.attach_money, Color(0xFFFFD700)),
                ],
              ),
            ),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations du Restaurant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('📍 Adresse: ${restaurant['adresse']}'),
                    Text('📞 Téléphone: ${restaurant['telephone']}'),
                    if (restaurant['email'].toString().isNotEmpty) 
                      Text('✉️ Email: ${restaurant['email']}'),
                    if (restaurant['date_creation'] != null)
                      Text('📅 Créé le: ${restaurant['date_creation']}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantSpecificMenu extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String token;

  RestaurantSpecificMenu({required this.restaurant, required this.token});

  @override
  State<RestaurantSpecificMenu> createState() => _RestaurantSpecificMenuState();
}

class _RestaurantSpecificMenuState extends State<RestaurantSpecificMenu> {
  bool _loading = true;
  String? _error;
  List<dynamic> _menu = [];
  // Filtres
  String? _typeFilter; // 'petit_dej' | 'dej' | 'diner'
  bool _disponibleOnly = false;
  int? _categoryId;
  List<dynamic> _categories = [];
  final TextEditingController _minPriceCtrl = TextEditingController();
  final TextEditingController _maxPriceCtrl = TextEditingController();
  
  // ========= CATÉGORIES (CRUD) =========
  Future<void> _openCategoriesManager() async {
    await _fetchCategories();
    List<dynamic> categories = List<dynamic>.from(_categories);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> refreshLocal() async {
            await _fetchCategories();
            setModalState(() => categories = List<dynamic>.from(_categories));
          }
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Catégories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: () => _createCategoryDialog(onDone: refreshLocal),
                          icon: Icon(Icons.add),
                          label: Text('Ajouter'),
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final c = categories[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            title: Text(c['nom'] ?? 'Catégorie'),
                            subtitle: Text((c['description'] ?? '').toString()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (c['actif'] ?? true) ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text((c['actif'] ?? true) ? 'Actif' : 'Inactif', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                                IconButton(
                                  tooltip: 'Activer/Désactiver',
                                  onPressed: () async {
                                    try {
                                      final resp = await http.post(
                                        Uri.parse('${getApiBaseUrl()}/api/admin/categories/${c['id']}/toggle_active/'),
                                        headers: {'Authorization': 'Bearer ${widget.token}'},
                                      );
                                      if (resp.statusCode == 200) {
                                        await refreshLocal();
                                      }
                                    } catch (_) {}
                                  },
                                  icon: Icon(Icons.power_settings_new, color: (c['actif'] ?? true) ? Colors.green : Colors.red),
                                ),
                                IconButton(
                                  tooltip: 'Modifier',
                                  onPressed: () => _editCategoryDialog(c, onDone: refreshLocal),
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                ),
                                IconButton(
                                  tooltip: 'Supprimer',
                                  onPressed: () => _deleteCategory(c, onDone: refreshLocal),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
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
        },
      ),
    );
  }
  
  Future<void> _createCategoryDialog({required Future<void> Function() onDone}) async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final ordreCtrl = TextEditingController(text: '0');
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ajouter une catégorie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nom *')),
              SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Description')),
              SizedBox(height: 8),
              TextField(controller: ordreCtrl, decoration: InputDecoration(labelText: 'Ordre'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              try {
                final resp = await http.post(
                  Uri.parse('${getApiBaseUrl()}/api/admin/categories/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode({
                    'nom': nameCtrl.text,
                    'description': descCtrl.text,
                    'ordre': int.tryParse(ordreCtrl.text) ?? 0,
                    'actif': true,
                  }),
                );
                if (resp.statusCode == 201) {
                  Navigator.pop(context);
                  await onDone();
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _editCategoryDialog(Map<String, dynamic> c, {required Future<void> Function() onDone}) async {
    final nameCtrl = TextEditingController(text: c['nom']?.toString() ?? '');
    final descCtrl = TextEditingController(text: c['description']?.toString() ?? '');
    final ordreCtrl = TextEditingController(text: (c['ordre']?.toString() ?? '0'));
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier la catégorie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nom *')),
              SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Description')),
              SizedBox(height: 8),
              TextField(controller: ordreCtrl, decoration: InputDecoration(labelText: 'Ordre'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              try {
                final resp = await http.put(
                  Uri.parse('${getApiBaseUrl()}/api/admin/categories/${c['id']}/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode({
                    'nom': nameCtrl.text,
                    'description': descCtrl.text,
                    'ordre': int.tryParse(ordreCtrl.text) ?? 0,
                    'actif': c['actif'] ?? true,
                  }),
                );
                if (resp.statusCode == 200) {
                  Navigator.pop(context);
                  await onDone();
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteCategory(Map<String, dynamic> c, {required Future<void> Function() onDone}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Supprimer'),
        content: Text('Supprimer "${c['nom']}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final resp = await http.delete(
        Uri.parse('${getApiBaseUrl()}/api/admin/categories/${c['id']}/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 204) {
        await onDone();
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }
  
  // ========= INGRÉDIENTS (CRUD + STOCK + IMAGE) =========
  Future<void> _openIngredientsManager() async {
    final restaurantId = widget.restaurant['id'];
    List<dynamic> ingredients = [];
    Future<void> load() async {
      final resp = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/admin/ingredients/?restaurant=$restaurantId'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200) {
        ingredients = json.decode(resp.body) as List<dynamic>;
      }
    }
    await load();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> refreshLocal() async {
            await load();
            setModalState(() {});
          }
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ingrédients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: () => _createIngredientDialog(onDone: refreshLocal),
                          icon: Icon(Icons.add),
                          label: Text('Ajouter'),
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) {
                        final ing = ingredients[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: (ing['image_url'] ?? '').toString().isNotEmpty ? Image.network(ing['image_url'], fit: BoxFit.cover) : Container(color: Colors.grey.shade200, child: Icon(Icons.image, color: Colors.grey)),
                              ),
                            ),
                            title: Text(ing['nom'] ?? 'Ingrédient'),
                            subtitle: Text('Type: ${ing['type'] ?? '-'}  •  Prix: ${ing['prix'] ?? 0}  •  Stock: ${ing['stock_actuel'] ?? 0}'),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: (ing['disponible'] ?? true) ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(12)),
                                  child: Text((ing['disponible'] ?? true) ? 'Disponible' : 'Indisponible', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                                IconButton(
                                  tooltip: 'Stock',
                                  onPressed: () => _updateIngredientStockDialog(ing, onDone: refreshLocal),
                                  icon: Icon(Icons.inventory, color: Colors.blue),
                                ),
                                IconButton(
                                  tooltip: 'Image',
                                  onPressed: () => _uploadIngredientImage(ing['id']),
                                  icon: Icon(Icons.image, color: Colors.purple),
                                ),
                                IconButton(
                                  tooltip: 'Modifier',
                                  onPressed: () => _editIngredientDialog(ing, onDone: refreshLocal),
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                ),
                                IconButton(
                                  tooltip: 'Supprimer',
                                  onPressed: () => _deleteIngredient(ing, onDone: refreshLocal),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
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
        },
      ),
    );
  }
  
  Future<void> _createIngredientDialog({required Future<void> Function() onDone}) async {
    String typeValue = 'legume';
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ajouter un ingrédient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nom *')),
              SizedBox(height: 8),
              TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Prix *'), keyboardType: TextInputType.number),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: typeValue,
                decoration: InputDecoration(labelText: 'Type *'),
                items: const [
                  DropdownMenuItem(value: 'legume', child: Text('Légume')),
                  DropdownMenuItem(value: 'viande', child: Text('Viande')),
                  DropdownMenuItem(value: 'poisson', child: Text('Poisson')),
                  DropdownMenuItem(value: 'fromage', child: Text('Fromage')),
                  DropdownMenuItem(value: 'sauce', child: Text('Sauce')),
                  DropdownMenuItem(value: 'epice', child: Text('Épice')),
                  DropdownMenuItem(value: 'protéine', child: Text('Protéine')),
                  DropdownMenuItem(value: 'autre', child: Text('Autre')),
                ],
                onChanged: (v) => typeValue = v ?? 'legume',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              try {
                final resp = await http.post(
                  Uri.parse('${getApiBaseUrl()}/api/admin/ingredients/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode({
                    'nom': nameCtrl.text,
                    'prix': double.tryParse(priceCtrl.text) ?? 0,
                    'type': typeValue,
                    'restaurant': widget.restaurant['id'],
                    'disponible': true,
                  }),
                );
                if (resp.statusCode == 201) {
                  Navigator.pop(context);
                  await onDone();
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _editIngredientDialog(Map<String, dynamic> ing, {required Future<void> Function() onDone}) async {
    String typeValue = (ing['type']?.toString() ?? 'legume');
    final nameCtrl = TextEditingController(text: ing['nom']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: (ing['prix']?.toString() ?? ''));
    bool disponible = ing['disponible'] ?? true;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier l\'ingrédient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nom *')),
              SizedBox(height: 8),
              TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Prix *'), keyboardType: TextInputType.number),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: typeValue,
                decoration: InputDecoration(labelText: 'Type *'),
                items: const [
                  DropdownMenuItem(value: 'legume', child: Text('Légume')),
                  DropdownMenuItem(value: 'viande', child: Text('Viande')),
                  DropdownMenuItem(value: 'poisson', child: Text('Poisson')),
                  DropdownMenuItem(value: 'fromage', child: Text('Fromage')),
                  DropdownMenuItem(value: 'sauce', child: Text('Sauce')),
                  DropdownMenuItem(value: 'epice', child: Text('Épice')),
                  DropdownMenuItem(value: 'protéine', child: Text('Protéine')),
                  DropdownMenuItem(value: 'autre', child: Text('Autre')),
                ],
                onChanged: (v) => typeValue = v ?? typeValue,
              ),
              SizedBox(height: 8),
              Row(children: [Switch(value: disponible, onChanged: (v) => disponible = v), Text('Disponible')]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              try {
                final resp = await http.put(
                  Uri.parse('${getApiBaseUrl()}/api/admin/ingredients/${ing['id']}/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode({
                    'nom': nameCtrl.text,
                    'prix': double.tryParse(priceCtrl.text) ?? 0,
                    'type': typeValue,
                    'disponible': disponible,
                    'restaurant': widget.restaurant['id'],
                  }),
                );
                if (resp.statusCode == 200) {
                  Navigator.pop(context);
                  await onDone();
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteIngredient(Map<String, dynamic> ing, {required Future<void> Function() onDone}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Supprimer'),
        content: Text('Supprimer "${ing['nom']}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final resp = await http.delete(
        Uri.parse('${getApiBaseUrl()}/api/admin/ingredients/${ing['id']}/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 204) {
        await onDone();
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }
  
  Future<void> _updateIngredientStockDialog(Map<String, dynamic> ing, {required Future<void> Function() onDone}) async {
    final stockCtrl = TextEditingController(text: (ing['stock_actuel']?.toString() ?? '0'));
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Mettre à jour le stock'),
        content: TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Stock actuel')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              try {
                final resp = await http.post(
                  Uri.parse('${getApiBaseUrl()}/api/admin/ingredients/${ing['id']}/update_stock/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode({'stock': int.tryParse(stockCtrl.text) ?? 0}),
                );
                if (resp.statusCode == 200) {
                  Navigator.pop(context);
                  await onDone();
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _uploadIngredientImage(int itemId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return;
      final uri = Uri.parse('${getApiBaseUrl()}/api/upload-image/');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${widget.token}'
        ..fields['model_type'] = 'ingredient'
        ..fields['item_id'] = itemId.toString()
        ..files.add(await http.MultipartFile.fromPath('image', file.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image uploadée'), backgroundColor: Colors.green));
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur upload: $e'), backgroundColor: Colors.red));
    }
  }

  // ========= BASES (CRUD + IMAGE) =========
  Future<void> _openBasesManager() async {
    final restaurantId = widget.restaurant['id'];
    List<dynamic> bases = [];
    Future<void> load() async {
      final resp = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/bases/?restaurant=$restaurantId'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200) {
        bases = json.decode(resp.body) as List<dynamic>;
      }
    }
    await load();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> refreshLocal() async { await load(); setModalState(() {}); }
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bases', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: () => _createBaseDialog(onDone: refreshLocal),
                          icon: Icon(Icons.add),
                          label: Text('Ajouter'),
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: bases.length,
                      itemBuilder: (context, index) {
                        final base = bases[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: (base['image_url'] ?? '').toString().isNotEmpty
                                  ? Image.network(base['image_url'], fit: BoxFit.cover)
                                  : Container(color: Colors.grey.shade200, child: Icon(Icons.bakery_dining, color: Colors.grey)),
                              ),
                            ),
                            title: Text(base['nom'] ?? 'Base'),
                            subtitle: Text('Prix: ${base['prix'] ?? 0}  •  ${base['disponible'] == true ? "Disponible" : "Indisponible"}'),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  tooltip: 'Image',
                                  onPressed: () => _uploadBaseImage(base['id']),
                                  icon: Icon(Icons.image, color: Colors.purple),
                                ),
                                IconButton(
                                  tooltip: (base['disponible'] == true) ? 'Rendre indisponible' : 'Rendre disponible',
                                  onPressed: () => _toggleBaseDisponible(base, onDone: refreshLocal),
                                  icon: Icon(Icons.power_settings_new, color: (base['disponible'] == true) ? Colors.green : Colors.red),
                                ),
                                IconButton(
                                  tooltip: 'Modifier',
                                  onPressed: () => _editBaseDialog(base, onDone: refreshLocal),
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                ),
                                IconButton(
                                  tooltip: 'Supprimer',
                                  onPressed: () => _deleteBase(base, onDone: refreshLocal),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
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
        },
      ),
    );
  }

  Future<void> _createBaseDialog({required Future<void> Function() onDone}) async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool disponible = true;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ajouter une base'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nom *')),
              SizedBox(height: 8),
              TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Prix *'), keyboardType: TextInputType.number),
              SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Description')),
              SizedBox(height: 8),
              Row(children: [Switch(value: disponible, onChanged: (v) => disponible = v), Text('Disponible')]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              try {
                final resp = await http.post(
                  Uri.parse('${getApiBaseUrl()}/api/bases/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode({
                    'nom': nameCtrl.text,
                    'prix': double.tryParse(priceCtrl.text) ?? 0,
                    'description': descCtrl.text,
                    'disponible': disponible,
                    'restaurant': widget.restaurant['id'],
                  }),
                );
                if (resp.statusCode == 201) { Navigator.pop(context); await onDone(); } else { throw Exception('Erreur API: ${resp.statusCode}'); }
              } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red)); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _editBaseDialog(Map<String, dynamic> base, {required Future<void> Function() onDone}) async {
    final nameCtrl = TextEditingController(text: base['nom']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: (base['prix']?.toString() ?? ''));
    final descCtrl = TextEditingController(text: base['description']?.toString() ?? '');
    bool disponible = base['disponible'] ?? true;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier la base'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nom *')),
              SizedBox(height: 8),
              TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Prix *'), keyboardType: TextInputType.number),
              SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Description')),
              SizedBox(height: 8),
              Row(children: [Switch(value: disponible, onChanged: (v) => disponible = v), Text('Disponible')]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              try {
                final resp = await http.put(
                  Uri.parse('${getApiBaseUrl()}/api/bases/${base['id']}/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode({
                    'nom': nameCtrl.text,
                    'prix': double.tryParse(priceCtrl.text) ?? 0,
                    'description': descCtrl.text,
                    'disponible': disponible,
                    'restaurant': widget.restaurant['id'],
                  }),
                );
                if (resp.statusCode == 200) { Navigator.pop(context); await onDone(); } else { throw Exception('Erreur API: ${resp.statusCode}'); }
              } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red)); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBase(Map<String, dynamic> base, {required Future<void> Function() onDone}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Supprimer'),
        content: Text('Supprimer "${base['nom']}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final resp = await http.delete(
        Uri.parse('${getApiBaseUrl()}/api/bases/${base['id']}/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 204) { await onDone(); } else { throw Exception('Erreur API: ${resp.statusCode}'); }
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red)); }
  }

  Future<void> _uploadBaseImage(int itemId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return;
      final uri = Uri.parse('${getApiBaseUrl()}/api/upload-image/');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${widget.token}'
        ..fields['model_type'] = 'base'
        ..fields['item_id'] = itemId.toString()
        ..files.add(await http.MultipartFile.fromPath('image', file.path));
      final response = await request.send();
      if (response.statusCode == 200) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image uploadée'), backgroundColor: Colors.green)); }
      else { throw Exception('Erreur API: ${response.statusCode}'); }
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur upload: $e'), backgroundColor: Colors.red)); }
  }

  Future<void> _toggleBaseDisponible(Map<String, dynamic> base, {required Future<void> Function() onDone}) async {
    try {
      final resp = await http.put(
        Uri.parse('${getApiBaseUrl()}/api/bases/${base['id']}/'),
        headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
        body: json.encode({
          'nom': base['nom'],
          'prix': base['prix'],
          'description': base['description'],
          'disponible': !(base['disponible'] == true),
          'restaurant': widget.restaurant['id'],
        }),
      );
      if (resp.statusCode == 200) {
        await onDone();
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final id = widget.restaurant['id'];
      final query = <String, String>{'restaurant': '$id'};
      if (_typeFilter != null && _typeFilter!.isNotEmpty) query['type'] = _typeFilter!;
      if (_disponibleOnly) query['disponible'] = 'true';
      if (_categoryId != null) query['category'] = _categoryId.toString();
      final uri = Uri.parse('${getApiBaseUrl()}/api/admin/menu/').replace(queryParameters: query);
      final resp = await http.get(uri, headers: {'Authorization': 'Bearer ${widget.token}'});
      if (resp.statusCode == 200) {
        List<dynamic> data = json.decode(resp.body) as List<dynamic>;
        final double? minP = double.tryParse(_minPriceCtrl.text);
        final double? maxP = double.tryParse(_maxPriceCtrl.text);
        if (minP != null) {
          data = data.where((e) {
            final double? p = (e['prix'] is num)
              ? (e['prix'] as num).toDouble()
              : double.tryParse(e['prix']?.toString() ?? '');
            return p != null && p >= minP;
          }).toList();
        }
        if (maxP != null) {
          data = data.where((e) {
            final double? p = (e['prix'] is num)
              ? (e['prix'] as num).toDouble()
              : double.tryParse(e['prix']?.toString() ?? '');
            return p != null && p <= maxP;
          }).toList();
        }
        setState(() {
          _menu = data;
          _loading = false;
        });
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final resp = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/admin/categories/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200) {
        setState(() {
          _categories = json.decode(resp.body) as List<dynamic>;
        });
      }
    } catch (_) {}
  }

  // ========= PLATS (CRUD) =========
  Future<void> _createDish() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String typeValue = 'dej';
    final descCtrl = TextEditingController();
    int? categoryValue = _categoryId;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ajouter un plat'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nom *')),
              SizedBox(height: 8),
              TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Prix *'), keyboardType: TextInputType.number),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: typeValue,
                decoration: InputDecoration(labelText: 'Type *'),
                items: const [
                  DropdownMenuItem(value: 'petit_dej', child: Text('Petit-déjeuner')),
                  DropdownMenuItem(value: 'dej', child: Text('Déjeuner')),
                  DropdownMenuItem(value: 'diner', child: Text('Dîner')),
                ],
                onChanged: (v) => typeValue = v ?? 'dej',
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                value: categoryValue,
                decoration: InputDecoration(labelText: 'Catégorie'),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Aucune')),
                  ..._categories.map((c) => DropdownMenuItem<int?>(value: c['id'] as int, child: Text(c['nom']))),
                ],
                onChanged: (v) => categoryValue = v,
              ),
              SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Description'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
              try {
                final resp = await http.post(
                  Uri.parse('${getApiBaseUrl()}/api/admin/menu/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode({
                    'nom': nameCtrl.text,
                    'prix': double.tryParse(priceCtrl.text) ?? 0,
                    'type': typeValue,
                    'description': descCtrl.text,
                    'restaurant': widget.restaurant['id'],
                    if (categoryValue != null) 'category': categoryValue,
                    'disponible': true,
                    'populaire': false,
                  }),
                );
                if (resp.statusCode == 201) {
                  Navigator.pop(context);
                  await _fetchMenu();
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _editDish(Map<String, dynamic> item) async {
    final nameCtrl = TextEditingController(text: item['nom']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: (item['prix']?.toString() ?? ''));
    String typeValue = (item['type']?.toString() ?? 'dej');
    final descCtrl = TextEditingController(text: item['description']?.toString() ?? '');
    int? categoryValue = (item['category'] is Map) ? item['category']['id'] : item['category'] as int?;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier le plat'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nom *')),
              SizedBox(height: 8),
              TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Prix *'), keyboardType: TextInputType.number),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: typeValue,
                decoration: InputDecoration(labelText: 'Type *'),
                items: const [
                  DropdownMenuItem(value: 'petit_dej', child: Text('Petit-déjeuner')),
                  DropdownMenuItem(value: 'dej', child: Text('Déjeuner')),
                  DropdownMenuItem(value: 'diner', child: Text('Dîner')),
                ],
                onChanged: (v) => typeValue = v ?? 'dej',
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                value: categoryValue,
                decoration: InputDecoration(labelText: 'Catégorie'),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Aucune')),
                  ..._categories.map((c) => DropdownMenuItem<int?>(value: c['id'] as int, child: Text(c['nom']))),
                ],
                onChanged: (v) => categoryValue = v,
              ),
              SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Description'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                final resp = await http.put(
                  Uri.parse('${getApiBaseUrl()}/api/admin/menu/${item['id']}/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode({
                    'nom': nameCtrl.text,
                    'prix': double.tryParse(priceCtrl.text) ?? 0,
                    'type': typeValue,
                    'description': descCtrl.text,
                    'restaurant': widget.restaurant['id'],
                    'category': categoryValue,
                    'disponible': item['disponible'] ?? true,
                    'populaire': item['populaire'] ?? false,
                  }),
                );
                if (resp.statusCode == 200) {
                  Navigator.pop(context);
                  await _fetchMenu();
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDish(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Supprimer'),
        content: Text('Supprimer ce plat ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final resp = await http.delete(
        Uri.parse('${getApiBaseUrl()}/api/admin/menu/$id/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 204) {
        await _fetchMenu();
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _toggleDisponible(int itemId) async {
    try {
      final resp = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/admin/menu/$itemId/toggle_disponible/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (resp.statusCode == 200) {
        await _fetchMenu();
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _togglePopulaire(int itemId) async {
    try {
      final resp = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/admin/menu/$itemId/toggle_populaire/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (resp.statusCode == 200) {
        await _fetchMenu();
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _uploadImage(int itemId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return;

      final uri = Uri.parse('${getApiBaseUrl()}/api/upload-image/');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${widget.token}'
        ..fields['model_type'] = 'menu'
        ..fields['item_id'] = itemId.toString()
        ..files.add(await http.MultipartFile.fromPath('image', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image uploadée'), backgroundColor: Colors.green));
        await _fetchMenu();
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur upload: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _exportMenuCsv() async {
    try {
      final csv = _toCsvFromList(_menu);
      await Clipboard.setData(ClipboardData(text: csv));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV copié dans le presse-papiers'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur export: $e'), backgroundColor: Colors.red));
    }
  }

  String _toCsvFromList(List<dynamic> list) {
    if (list.isEmpty) return '';
    final Set<String> headers = {};
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        headers.addAll(item.keys.map((k) => k.toString()));
      }
    }
    final List<String> ordered = headers.isEmpty ? ['value'] : headers.toList();
    final String headerLine = ordered.map(_escapeCsv).join(',');
    final List<String> rows = [];
    for (final item in list) {
      if (item is Map) {
        rows.add(ordered.map((h) => _escapeCsv(item[h])).join(','));
      } else {
        rows.add(_escapeCsv(item));
      }
    }
    return ([headerLine]..addAll(rows)).join('\n');
  }

  String _escapeCsv(dynamic value) {
    final String s = (value ?? '').toString();
    final bool needQuotes = s.contains(',') || s.contains('"') || s.contains('\n');
    final String escaped = s.replaceAll('"', '""');
    return needQuotes ? '"$escaped"' : escaped;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(height: 8),
            Text('Erreur: $_error'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchMenu,
              child: Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMenu,
      child: ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _menu.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Menu du restaurant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(children: [
                ElevatedButton.icon(
                  onPressed: _openCategoriesManager,
                  icon: Icon(Icons.category),
                  label: Text('Catégories'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _openIngredientsManager,
                  icon: Icon(Icons.kitchen),
                  label: Text('Ingrédients'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _openBasesManager,
                  icon: Icon(Icons.category_outlined),
                  label: Text('Bases'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _exportMenuCsv,
                  icon: Icon(Icons.download),
                  label: Text('Exporter'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _createDish,
                  icon: Icon(Icons.add),
                  label: Text('Ajouter'),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
                ),
              ]),
            ],
          );
        } else if (index == 1) {
          return Padding(
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        value: _typeFilter,
                        decoration: InputDecoration(labelText: 'Type'),
                        items: const [
                          DropdownMenuItem(value: 'petit_dej', child: Text('Petit-déjeuner')),
                          DropdownMenuItem(value: 'dej', child: Text('Déjeuner')),
                          DropdownMenuItem(value: 'diner', child: Text('Dîner')),
                        ],
                        onChanged: (v) => setState(() => _typeFilter = v),
                      ),
                    ),
                    Row(children: [
                      Switch(value: _disponibleOnly, onChanged: (v) => setState(() => _disponibleOnly = v)),
                      Text('Disponible'),
                    ]),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _minPriceCtrl,
                        decoration: InputDecoration(labelText: 'Prix min'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _maxPriceCtrl,
                        decoration: InputDecoration(labelText: 'Prix max'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: FutureBuilder(
                        future: _categories.isEmpty ? _fetchCategories() : Future.value(),
                        builder: (context, snapshot) {
                          return DropdownButtonFormField<int?>(
                            value: _categoryId,
                            decoration: InputDecoration(labelText: 'Catégorie'),
                            items: [
                              const DropdownMenuItem<int?>(value: null, child: Text('Toutes')),
                              ..._categories.map((c) => DropdownMenuItem<int?>(value: c['id'] as int, child: Text(c['nom']))),
                            ],
                            onChanged: (int? v) => setState(() => _categoryId = v),
                          );
                        },
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _fetchMenu,
                      icon: Icon(Icons.filter_alt),
                      label: Text('Filtrer'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        final item = _menu[index - 2];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFD700).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.restaurant_menu, color: Color(0xFF2C2C2C), size: 30),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nom'] ?? 'Plat',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          if ((item['image_url'] ?? '').toString().isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(item['image_url'], width: 56, height: 56, fit: BoxFit.cover),
                            ),
                            SizedBox(width: 8),
                          ],
                          Text('${item['prix'] ?? 0} F', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
                        ],
                      ),
                      if ((item['description'] ?? '').toString().isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(item['description'], style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                      ],
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (item['disponible'] ?? true) ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text((item['disponible'] ?? true) ? 'Disponible' : 'Indisponible', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                          if (item['populaire'] == true) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Color(0xFFFFD700), borderRadius: BorderRadius.circular(12)),
                              child: Text('Populaire', style: TextStyle(color: Color(0xFF2C2C2C), fontSize: 12)),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _toggleDisponible(item['id']),
                            icon: Icon(Icons.power_settings_new, size: 18),
                            label: Text('Basculer dispo'),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _togglePopulaire(item['id']),
                            icon: Icon(Icons.star, size: 18),
                            label: Text('Basculer populaire'),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _uploadImage(item['id']),
                            icon: Icon(Icons.image, size: 18),
                            label: Text('Image'),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                final resp = await http.post(
                                  Uri.parse('${getApiBaseUrl()}/api/admin/menu/${item['id']}/set_plat_du_jour/'),
                                  headers: {'Authorization': 'Bearer ${widget.token}'},
                                );
                                if (resp.statusCode == 200) {
                                  await _fetchMenu();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Plat du jour défini'), backgroundColor: Colors.green));
                                } else {
                                  throw Exception('Erreur API: ${resp.statusCode}');
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
                              }
                            },
                            icon: Icon(Icons.local_fire_department, size: 18, color: Colors.orange),
                            label: Text('Plat du jour'),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _editDish(Map<String, dynamic>.from(item)),
                            icon: Icon(Icons.edit, size: 18),
                            label: Text('Modifier'),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Supprimer'),
                                  content: Text('Supprimer "${item['nom']}" ?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuler')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Supprimer', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await _deleteDish(item['id']);
                              }
                            },
                            icon: Icon(Icons.delete, size: 18, color: Colors.red),
                            label: Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ));
  }
}

class RestaurantSpecificOrders extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String token;

  RestaurantSpecificOrders({required this.restaurant, required this.token});

  @override
  State<RestaurantSpecificOrders> createState() => _RestaurantSpecificOrdersState();
}

class _RestaurantSpecificOrdersState extends State<RestaurantSpecificOrders> {
  bool _loading = true;
  String? _error;
  List<dynamic> _orders = [];
  String? _statusFilter; // en_attente | en_preparation | pret | termine | livre

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final restaurantId = widget.restaurant['id'];
      final uri = Uri.parse('${getApiBaseUrl()}/api/orders/').replace(
        queryParameters: {
          'restaurant': '$restaurantId',
          if (_statusFilter != null && _statusFilter!.isNotEmpty) 'status': _statusFilter!,
        },
      );
      final resp = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        setState(() {
          _orders = data;
          _loading = false;
        });
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    try {
      final resp = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/orders/$orderId/update-status/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': newStatus}),
      );
      if (resp.statusCode == 200) {
        await _fetchOrders();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour: $newStatus'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(height: 8),
            Text('Erreur: $_error'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchOrders,
              child: Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
            )
          ],
        ),
      );
    }

    final restaurantId = widget.restaurant['id'];
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _orders.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Commandes du restaurant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: _statusFilter,
                    decoration: InputDecoration(labelText: 'Statut'),
                    items: const [
                      DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
                      DropdownMenuItem(value: 'en_preparation', child: Text('En préparation')),
                      DropdownMenuItem(value: 'pret', child: Text('Prêt')),
                      DropdownMenuItem(value: 'termine', child: Text('Terminé')),
                      DropdownMenuItem(value: 'livre', child: Text('Livré')),
                    ],
                    onChanged: (v) => setState(() { _statusFilter = v; _fetchOrders(); }),
                  ),
                ),
              ],
            ),
          );
        }
        final order = _orders[index - 1];
        final status = order['status'] ?? order['statut'] ?? 'en_attente';
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Commande #${order['id']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: _statusColor(status), borderRadius: BorderRadius.circular(12)),
                      child: Text(_statusText(status), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if ((order['user'] ?? '').toString().isNotEmpty) Text('Client: ${order['user']}'),
                if ((order['phone'] ?? '').toString().isNotEmpty) Text('Téléphone: ${order['phone']}'),
                if (order['prix_total'] != null) Text('Total: ${order['prix_total']} F'),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (status == 'en_attente')
                      ElevatedButton(onPressed: () => _updateStatus(order['id'], 'en_preparation'), child: Text('Accepter'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
                    if (status == 'en_preparation')
                      ElevatedButton(onPressed: () => _updateStatus(order['id'], 'pret'), child: Text('Marquer Prêt'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue)),
                    if (status == 'pret')
                      ElevatedButton(onPressed: () => _updateStatus(order['id'], 'termine'), child: Text('Terminer'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C))),
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          final resp = await http.get(Uri.parse('${getApiBaseUrl()}/api/orders/${order['id']}/suivi/'), headers: {'Authorization': 'Bearer ${widget.token}'});
                          if (resp.statusCode == 200) {
                            final data = json.decode(resp.body);
                            showDialog(context: context, builder: (_) => AlertDialog(title: Text('Suivi commande #${order['id']}'), content: SingleChildScrollView(child: Text(data.toString())), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Fermer'))]));
                          } else {
                            throw Exception('Erreur API: ${resp.statusCode}');
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
                        }
                      },
                      child: Text('Détails'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ));
  }

  String _statusText(String status) {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'en_preparation':
        return 'En préparation';
      case 'pret':
        return 'Prêt';
      case 'termine':
        return 'Terminé';
      case 'livre':
        return 'Livré';
      default:
        return 'Inconnu';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'en_attente':
        return Colors.orange;
      case 'en_preparation':
        return Colors.blue;
      case 'pret':
        return Colors.green;
      case 'termine':
        return Colors.green;
      case 'livre':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class RestaurantSpecificStaff extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String token;

  RestaurantSpecificStaff({required this.restaurant, required this.token});

  @override
  State<RestaurantSpecificStaff> createState() => _RestaurantSpecificStaffState();
}

class _RestaurantSpecificStaffState extends State<RestaurantSpecificStaff> {
  bool _loading = true;
  String? _error;
  List<dynamic> _staff = [];
  String? _roleFilter; // admin | personnel | chef

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final id = widget.restaurant['id'];
      final uri = Uri.parse('${getApiBaseUrl()}/api/admin/personnel/').replace(
        queryParameters: {
          'restaurant': '$id',
          if (_roleFilter != null && _roleFilter!.isNotEmpty) 'role': _roleFilter!,
        },
      );
      final resp = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200) {
        setState(() {
          _staff = json.decode(resp.body);
          _loading = false;
        });
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(height: 8),
            Text('Erreur: $_error'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchStaff,
              child: Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchStaff,
      child: ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _staff.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Personnel du restaurant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(children: [
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: _roleFilter,
                    decoration: InputDecoration(labelText: 'Rôle'),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'personnel', child: Text('Personnel')),
                      DropdownMenuItem(value: 'chef', child: Text('Chef')),
                    ],
                    onChanged: (v) => setState(() { _roleFilter = v; _fetchStaff(); }),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _createStaffDialog(),
                  icon: Icon(Icons.person_add),
                  label: Text('Ajouter'),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
                ),
              ]),
            ],
          );
        }
        final u = _staff[index - 1];
        final profile = u['profile'] ?? {};
        final fullName = '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFFFD700).withOpacity(0.3),
                  child: Icon(Icons.person, color: Color(0xFF2C2C2C)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName.isEmpty ? (u['username'] ?? 'Utilisateur') : fullName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Tél: ${profile['phone'] ?? u['username'] ?? ''}', style: TextStyle(color: Colors.grey.shade700)),
                      Text('Email: ${u['email'] ?? ''}', style: TextStyle(color: Colors.grey.shade700)),
                      SizedBox(height: 6),
                      Row(children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                          child: Text((profile['role'] ?? 'client').toString(), style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: (u['is_active'] ?? true) ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(12)),
                          child: Text((u['is_active'] ?? true) ? 'Actif' : 'Inactif', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ]),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              final resp = await http.post(
                                Uri.parse('${getApiBaseUrl()}/api/admin/personnel/${u['id']}/toggle_active/'),
                                headers: {'Authorization': 'Bearer ${widget.token}'},
                              );
                              if (resp.statusCode == 200) {
                                _fetchStaff();
                              } else {
                                throw Exception('Erreur API: ${resp.statusCode}');
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                              );
                            }
                          },
                          icon: Icon(Icons.power_settings_new, size: 18, color: (u['is_active'] ?? true) ? Colors.green : Colors.red),
                          label: Text('Activer/Désactiver'),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(children: [
                      IconButton(
                        tooltip: 'Modifier',
                        onPressed: () => _editStaffDialog(u),
                        icon: Icon(Icons.edit, color: Colors.blue),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Changer rôle',
                        icon: Icon(Icons.admin_panel_settings, color: Colors.purple),
                        onSelected: (role) => _changeUserRole(u, role),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'admin', child: Text('Rendre Admin')),
                          PopupMenuItem(value: 'personnel', child: Text('Rendre Personnel')),
                          PopupMenuItem(value: 'chef', child: Text('Rendre Chef')),
                        ],
                      ),
                    ]),
                    IconButton(
                      tooltip: 'Supprimer',
                      onPressed: () => _deleteStaff(u),
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    ));
  }

  Future<void> _createStaffDialog() async {
    final phoneCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String roleValue = 'personnel';
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ajouter un membre du personnel'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'Téléphone (obligatoire)')),
              SizedBox(height: 8),
              TextField(controller: usernameCtrl, decoration: InputDecoration(labelText: 'Nom d\'utilisateur (optionnel)')),
              SizedBox(height: 8),
              TextField(controller: firstNameCtrl, decoration: InputDecoration(labelText: 'Prénom')),
              SizedBox(height: 8),
              TextField(controller: lastNameCtrl, decoration: InputDecoration(labelText: 'Nom')),
              SizedBox(height: 8),
              TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email')),
              SizedBox(height: 8),
              TextField(controller: passwordCtrl, decoration: InputDecoration(labelText: 'Mot de passe / PIN'), obscureText: true),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: roleValue,
                decoration: InputDecoration(labelText: 'Rôle'),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'personnel', child: Text('Personnel')),
                  DropdownMenuItem(value: 'chef', child: Text('Chef')),
                ],
                onChanged: (v) => roleValue = v ?? 'personnel',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (phoneCtrl.text.isEmpty && usernameCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Téléphone ou nom d\'utilisateur requis'), backgroundColor: Colors.red));
                return;
              }
              try {
                final body = {
                  'username': (usernameCtrl.text.isNotEmpty ? usernameCtrl.text : phoneCtrl.text),
                  'phone': phoneCtrl.text.isNotEmpty ? phoneCtrl.text : usernameCtrl.text,
                  'first_name': firstNameCtrl.text,
                  'last_name': lastNameCtrl.text,
                  'email': emailCtrl.text,
                  'role': roleValue,
                  'restaurant': widget.restaurant['id'],
                  'is_active': true,
                  'password': passwordCtrl.text,
                };
                final resp = await http.post(
                  Uri.parse('${getApiBaseUrl()}/api/admin/personnel/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode(body),
                );
                if (resp.statusCode == 201) {
                  Navigator.pop(context);
                  await _fetchStaff();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Membre créé'), backgroundColor: Colors.green));
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _editStaffDialog(Map<String, dynamic> u) async {
    final profile = u['profile'] ?? {};
    final phoneCtrl = TextEditingController(text: (profile['phone'] ?? u['username'] ?? '').toString());
    final usernameCtrl = TextEditingController(text: (u['username'] ?? '').toString());
    final firstNameCtrl = TextEditingController(text: (u['first_name'] ?? '').toString());
    final lastNameCtrl = TextEditingController(text: (u['last_name'] ?? '').toString());
    final emailCtrl = TextEditingController(text: (u['email'] ?? '').toString());
    final passwordCtrl = TextEditingController();
    String roleValue = (profile['role'] ?? 'personnel').toString();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier le membre du personnel'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'Téléphone')),
              SizedBox(height: 8),
              TextField(controller: usernameCtrl, decoration: InputDecoration(labelText: 'Nom d\'utilisateur')),
              SizedBox(height: 8),
              TextField(controller: firstNameCtrl, decoration: InputDecoration(labelText: 'Prénom')),
              SizedBox(height: 8),
              TextField(controller: lastNameCtrl, decoration: InputDecoration(labelText: 'Nom')),
              SizedBox(height: 8),
              TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email')),
              SizedBox(height: 8),
              TextField(controller: passwordCtrl, decoration: InputDecoration(labelText: 'Nouveau mot de passe (optionnel)'), obscureText: true),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: roleValue,
                decoration: InputDecoration(labelText: 'Rôle'),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'personnel', child: Text('Personnel')),
                  DropdownMenuItem(value: 'chef', child: Text('Chef')),
                ],
                onChanged: (v) => roleValue = v ?? roleValue,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              try {
                final body = {
                  'username': usernameCtrl.text.isNotEmpty ? usernameCtrl.text : phoneCtrl.text,
                  'phone': phoneCtrl.text.isNotEmpty ? phoneCtrl.text : usernameCtrl.text,
                  'first_name': firstNameCtrl.text,
                  'last_name': lastNameCtrl.text,
                  'email': emailCtrl.text,
                  'role': roleValue,
                  'restaurant': widget.restaurant['id'],
                  if (passwordCtrl.text.isNotEmpty) 'password': passwordCtrl.text,
                };
                final resp = await http.put(
                  Uri.parse('${getApiBaseUrl()}/api/admin/personnel/${u['id']}/'),
                  headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
                  body: json.encode(body),
                );
                if (resp.statusCode == 200) {
                  Navigator.pop(context);
                  await _fetchStaff();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Membre mis à jour'), backgroundColor: Colors.green));
                } else {
                  throw Exception('Erreur API: ${resp.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStaff(Map<String, dynamic> u) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Supprimer'),
        content: Text('Supprimer "${(u['first_name'] ?? '')} ${(u['last_name'] ?? '')}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final resp = await http.delete(
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/${u['id']}/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 204) {
        await _fetchStaff();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Membre supprimé'), backgroundColor: Colors.green));
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _changeUserRole(Map<String, dynamic> u, String role) async {
    try {
      final resp = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/${u['id']}/change_role/'),
        headers: {'Authorization': 'Bearer ${widget.token}', 'Content-Type': 'application/json'},
        body: json.encode({'role': role}),
      );
      if (resp.statusCode == 200) {
        await _fetchStaff();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rôle changé vers $role'), backgroundColor: Colors.green));
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }
}

class RestaurantSpecificStats extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String token;

  RestaurantSpecificStats({required this.restaurant, required this.token});

  @override
  State<RestaurantSpecificStats> createState() => _RestaurantSpecificStatsState();
}

class _RestaurantSpecificStatsState extends State<RestaurantSpecificStats> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _stats = {};
  DateTime? _startDate;
  DateTime? _endDate;
  String _reportType = 'ventes'; // ventes | inventaire | personnel

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/admin/statistics/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200) {
        setState(() {
          _stats = json.decode(resp.body);
          _loading = false;
        });
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(height: 8),
            Text('Erreur: $_error'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchStats,
              child: Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700), foregroundColor: Color(0xFF2C2C2C)),
            )
          ],
        ),
      );
    }

    final orders = _stats['orders'] ?? {};
    final revenue = _stats['revenue'] ?? {};
    final menu = _stats['menu'] ?? {};
    final ingredients = _stats['ingredients'] ?? {};

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD700).withOpacity(0.1), Colors.white],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistiques', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
            SizedBox(height: 24),
            Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        value: _reportType,
                        decoration: InputDecoration(labelText: 'Type de rapport'),
                        items: const [
                          DropdownMenuItem(value: 'ventes', child: Text('Ventes')),
                          DropdownMenuItem(value: 'inventaire', child: Text('Inventaire')),
                          DropdownMenuItem(value: 'personnel', child: Text('Personnel')),
                        ],
                        onChanged: (v) => setState(() => _reportType = v ?? 'ventes'),
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: Icon(Icons.date_range),
                      label: Text(_startDate == null ? 'Début' : _startDate!.toString().split(' ').first),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(context: context, firstDate: DateTime(now.year - 2), lastDate: DateTime(now.year + 2), initialDate: _startDate ?? now);
                        if (picked != null) setState(() => _startDate = picked);
                      },
                    ),
                    OutlinedButton.icon(
                      icon: Icon(Icons.event),
                      label: Text(_endDate == null ? 'Fin' : _endDate!.toString().split(' ').first),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(context: context, firstDate: DateTime(now.year - 2), lastDate: DateTime(now.year + 2), initialDate: _endDate ?? now);
                        if (picked != null) setState(() => _endDate = picked);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.insert_drive_file),
                      label: Text('Générer rapport'),
                      onPressed: _generateReport,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard('Ventes du jour', '${(revenue['today'] ?? 0).toStringAsFixed(0)} F', Icons.today, Colors.green),
                  _buildStatCard('Commandes du jour', '${orders['today'] ?? 0}', Icons.shopping_cart, Colors.blue),
                  _buildStatCard('Éléments du menu', '${menu['total_items'] ?? 0}', Icons.restaurant, Color(0xFFFFD700)),
                  _buildStatCard('Ingrédients', '${ingredients['total'] ?? 0}', Icons.kitchen, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
    try {
      final params = <String, String>{
        'type': _reportType,
        if (_startDate != null) 'start_date': _startDate!.toIso8601String().split('T').first,
        if (_endDate != null) 'end_date': _endDate!.toIso8601String().split('T').first,
        'restaurant': widget.restaurant['id'].toString(),
      };
      final uri = Uri.parse('${getApiBaseUrl()}/api/admin/reports/').replace(queryParameters: params);
      final resp = await http.get(uri, headers: {'Authorization': 'Bearer ${widget.token}'});
      if (resp.statusCode == 200) {
        // Affichage simple JSON; on pourrait ajouter un export fichier plus tard
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Rapport: ${_reportType.toUpperCase()}'),
            content: SingleChildScrollView(child: Text(const JsonEncoder.withIndent('  ').convert(json.decode(resp.body)))),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Fermer')),
            ],
          ),
        );
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }
}

// Gestion Utilisateurs
class AdminUsersManagement extends StatefulWidget {
  final String token;

  AdminUsersManagement({required this.token});

  @override
  _AdminUsersManagementState createState() => _AdminUsersManagementState();
}

class _AdminUsersManagementState extends State<AdminUsersManagement> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsersFromApi();
  }

  Future<void> _loadUsersFromApi() async {
    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          users = data.map((user) {
            return {
              'id': user['id'],
              'nom': '${user['first_name']} ${user['last_name']}'.trim(),
              'telephone': user['profile']?['phone'] ?? user['username'],
              'email': user['email'] ?? '',
              'pin': '****', // PIN masqué pour la sécurité
              'role': user['profile']?['role'] ?? 'client',
              'actif': user['is_active'] ?? true,
              'date_creation': _formatDate(user['date_joined']),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        // Fallback vers des données par défaut
        users = [
          {
            'id': 1,
            'nom': 'Utilisateur Test',
            'telephone': '221771234567',
            'email': 'test@email.com',
            'pin': '5678',
            'role': 'client',
            'actif': true,
            'date_creation': '12/08/2025',
          },
        ];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Impossible de charger les utilisateurs: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Date inconnue';
    }
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'admin': return 'Administrateur';
      case 'personnel': return 'Personnel';
      case 'chef': return 'Chef';
      case 'client': return 'Client';
      default: return 'Inconnu';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.red;
      case 'personnel': return Colors.blue;
      case 'chef': return Colors.orange;
      case 'client': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD700).withOpacity(0.1), Colors.white],
        ),
      ),
              child: Column(
                children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestion des Utilisateurs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddUserDialog();
                  },
                  icon: Icon(Icons.person_add),
                  label: Text('Ajouter Utilisateur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD700),
                    foregroundColor: Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFFFD700)),
                      SizedBox(height: 16),
                      Text('Chargement des utilisateurs...'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFFFD700).withOpacity(0.3),
                          child: Icon(
                            Icons.person,
                            color: Color(0xFF2C2C2C),
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                                user['nom'],
                            style: TextStyle(
                                  fontSize: 18,
                              fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tél: ${user['telephone']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                'Email: ${user['email']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getRoleColor(user['role']),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getRoleText(user['role']),
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: user['actif'] ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user['actif'] ? 'Actif' : 'Inactif',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                          Text(
                                'Créé le: ${user['date_creation']}',
                            style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () => _showUserDetails(user),
                              icon: Icon(Icons.visibility, color: Color(0xFFFFD700)),
                              tooltip: 'Voir détails',
                            ),
                            IconButton(
                              onPressed: () => _editUser(user),
                              icon: Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Modifier',
                            ),
                            IconButton(
                              onPressed: () => _toggleUserStatus(user),
                              icon: Icon(
                                user['actif'] ? Icons.block : Icons.check_circle,
                                color: user['actif'] ? Colors.red : Colors.green,
                              ),
                              tooltip: user['actif'] ? 'Désactiver' : 'Activer',
                            ),
                            IconButton(
                              onPressed: () => _deleteUser(user),
                              icon: Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Supprimer',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
                  },
                ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final _nomController = TextEditingController();
    final _telephoneController = TextEditingController();
    final _emailController = TextEditingController();
    final _pinController = TextEditingController();
    String _selectedRole = 'client';

    // Générer un PIN automatique
    String _generatePin() {
      return (1000 + DateTime.now().millisecond % 9000).toString();
    }

    _pinController.text = _generatePin();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un Utilisateur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom complet *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _telephoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone *',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 221771234567',
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                  hintText: 'exemple@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pinController,
                      decoration: InputDecoration(
                        labelText: 'Code PIN *',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            _pinController.text = _generatePin();
                          },
                          tooltip: 'Générer nouveau PIN',
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Rôle *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'client', child: Text('Client')),
                  DropdownMenuItem(value: 'personnel', child: Text('Personnel')),
                  DropdownMenuItem(value: 'chef', child: Text('Chef')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                ],
                onChanged: (value) {
                  _selectedRole = value!;
                },
              ),
                  SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                    children: [
                    Icon(Icons.info, color: Color(0xFF2C2C2C)),
                    SizedBox(height: 8),
                    Text(
                      'L\'utilisateur pourra se connecter avec son téléphone et ce code PIN.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF2C2C2C)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nomController.text.isNotEmpty && 
                  _telephoneController.text.isNotEmpty && 
                  _emailController.text.isNotEmpty &&
                  _pinController.text.isNotEmpty) {
                
                // Créer l'utilisateur via l'API
                await _createUserInBackend(
                  _nomController.text,
                  _telephoneController.text,
                  _emailController.text,
                  _pinController.text,
                  _selectedRole,
                );
                
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Veuillez remplir tous les champs obligatoires'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700)),
            child: Text('Créer Utilisateur', style: TextStyle(color: Color(0xFF2C2C2C))),
          ),
        ],
      ),
    );
  }

  // Méthodes API pour la gestion des utilisateurs
  Future<void> _createUserInBackend(String nom, String telephone, String email, String pin, String role) async {
    try {
      // Séparer le nom en prénom et nom de famille
      List<String> nameParts = nom.split(' ');
      String firstName = nameParts[0];
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode({
          'username': telephone,
          'phone': telephone,
          'pin': pin,
          'password': pin,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
          'is_active': true,
        }),
      );

      if (response.statusCode == 201) {
        // Récupérer l'ID de l'utilisateur créé
        final responseData = json.decode(response.body);
        int userId = responseData['id'];
        
        // Ajouter à la liste locale après succès de l'API
        setState(() {
          users.add({
            'id': userId,
            'nom': nom,
            'telephone': telephone,
            'email': email,
            'pin': pin,
            'role': role,
            'actif': true,
            'date_creation': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Utilisateur créé avec succès !\n📱 Téléphone: $telephone\n🔑 PIN: $pin'),
            duration: Duration(seconds: 4),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMsg = 'Erreur API: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMsg = errorData.toString();
        } catch (e) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de la création: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _updateUserInBackend(Map<String, dynamic> user, String nom, String telephone, String email, String pin, String role) async {
    try {
      // Séparer le nom en prénom et nom de famille
      List<String> nameParts = nom.split(' ');
      String firstName = nameParts[0];
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final response = await http.put(
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/${user['id']}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode({
          'username': telephone,
          'phone': telephone,
          'pin': pin,
          'password': pin,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        // Mettre à jour la liste locale après succès de l'API
        setState(() {
          user['nom'] = nom;
          user['telephone'] = telephone;
          user['email'] = email;
          user['pin'] = pin;
          user['role'] = role;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Utilisateur modifié avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMsg = 'Erreur API: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMsg = errorData.toString();
        } catch (e) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de la modification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUserInBackend(Map<String, dynamic> user) async {
    try {
      final response = await http.delete(
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/${user['id']}/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 204) {
        // Supprimer de la liste locale après succès de l'API
        setState(() {
          users.remove(user);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Utilisateur supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMsg = 'Erreur API: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMsg = errorData.toString();
        } catch (e) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editUser(Map<String, dynamic> user) {
    final _nomController = TextEditingController(text: user['nom']);
    final _telephoneController = TextEditingController(text: user['telephone']);
    final _emailController = TextEditingController(text: user['email']);
    final _pinController = TextEditingController(text: user['pin'] ?? '1234');
    String _selectedRole = user['role'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier Utilisateur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom complet *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _telephoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: 'Code PIN *',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      _pinController.text = (1000 + DateTime.now().millisecond % 9000).toString();
                    },
                    tooltip: 'Générer nouveau PIN',
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Rôle *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'client', child: Text('Client')),
                  DropdownMenuItem(value: 'personnel', child: Text('Personnel')),
                  DropdownMenuItem(value: 'chef', child: Text('Chef')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                ],
                onChanged: (value) {
                  _selectedRole = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nomController.text.isNotEmpty && 
                  _telephoneController.text.isNotEmpty && 
                  _emailController.text.isNotEmpty &&
                  _pinController.text.isNotEmpty) {
                
                await _updateUserInBackend(
                  user,
                  _nomController.text,
                  _telephoneController.text,
                  _emailController.text,
                  _pinController.text,
                  _selectedRole,
                );
                
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Modifier', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Color(0xFFFFD700)),
            SizedBox(width: 8),
            Text('Détails Utilisateur'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nom', user['nom']),
              _buildDetailRow('Téléphone', user['telephone']),
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('Code PIN', user['pin'] ?? '****', isSecret: true),
              _buildDetailRow('Rôle', _getRoleText(user['role'])),
              _buildDetailRow('Statut', user['actif'] ? 'Actif' : 'Inactif'),
              _buildDetailRow('Date création', user['date_creation']),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.lock, color: Color(0xFF2C2C2C)),
                    SizedBox(height: 8),
                  Text(
                      'Informations de connexion:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)),
                    ),
                    Text(
                      'Téléphone: ${user['telephone']}',
                      style: TextStyle(color: Color(0xFF2C2C2C)),
                    ),
                    Text(
                      'PIN: ${user['pin'] ?? '****'}',
                      style: TextStyle(color: Color(0xFF2C2C2C)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _editUser(user);
            },
            icon: Icon(Icons.edit),
            label: Text('Modifier'),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isSecret = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              value,
                    style: TextStyle(
                color: Colors.black87,
                fontWeight: isSecret ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    setState(() {
      user['actif'] = !user['actif'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user['nom']} ${user['actif'] ? 'activé' : 'désactivé'}'),
        backgroundColor: user['actif'] ? Colors.green : Colors.orange,
      ),
    );
  }

  void _deleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer l\'utilisateur'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${user['nom']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Fermer le dialog de confirmation
              await _deleteUserInBackend(user);
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Statistiques
class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({Key? key}) : super(key: key);

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  String reportType = 'sales';
  DateTimeRange? _range;
  Map<String, dynamic>? _report;
  bool _loading = false;
  String? _error;

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final res = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range ?? DateTimeRange(start: now.subtract(Duration(days: 7)), end: now),
    );
    if (res != null) setState(() => _range = res);
  }

  Future<void> _loadReport() async {
    setState(() { _loading = true; _error = null; });
    try {
      Uri uri;
      if (reportType == 'sales') {
        final start = (_range?.start ?? DateTime.now().subtract(Duration(days: 7))).toIso8601String().split('T').first;
        final end = (_range?.end ?? DateTime.now()).toIso8601String().split('T').first;
        uri = Uri.parse('${getApiBaseUrl()}/api/admin/reports/?type=sales&start_date=$start&end_date=$end');
      } else {
        uri = Uri.parse('${getApiBaseUrl()}/api/admin/reports/?type=$reportType');
      }
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        setState(() { _report = json.decode(resp.body); _loading = false; });
      } else {
        throw Exception('Erreur API: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD700).withOpacity(0.1), Colors.white],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rapports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
                Row(children: [
                  DropdownButton<String>(
                    value: reportType,
                    items: const [
                      DropdownMenuItem(value: 'sales', child: Text('Ventes')),
                      DropdownMenuItem(value: 'inventory', child: Text('Inventaire')),
                      DropdownMenuItem(value: 'staff', child: Text('Personnel')),
                    ],
                    onChanged: (v) => setState(() => reportType = v ?? 'sales'),
                  ),
                  SizedBox(width: 8),
                  if (reportType == 'sales')
                    ElevatedButton.icon(onPressed: _pickRange, icon: Icon(Icons.date_range), label: Text('Période')),
                  SizedBox(width: 8),
                  ElevatedButton.icon(onPressed: _loadReport, icon: Icon(Icons.refresh), label: Text('Charger')),
                ])
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _loading
                ? Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                : _error != null
                  ? Center(child: Text('Erreur: $_error'))
                  : _report == null
                    ? Center(child: Text('Choisissez un type et chargez un rapport'))
                    : SingleChildScrollView(
                        child: SelectableText(const JsonEncoder.withIndent('  ').convert(_report), style: TextStyle(fontFamily: 'monospace')),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}