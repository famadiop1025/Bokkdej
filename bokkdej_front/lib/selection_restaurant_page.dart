import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants/app_colors.dart';
import 'widgets/safe_image_widget.dart';

class SelectionRestaurantPage extends StatefulWidget {
  final String? token;
  final VoidCallback? onSelected;
  
  const SelectionRestaurantPage({Key? key, this.token, this.onSelected}) : super(key: key);

  @override
  State<SelectionRestaurantPage> createState() => _SelectionRestaurantPageState();
}

class _SelectionRestaurantPageState extends State<SelectionRestaurantPage> {
  List<Map<String, dynamic>> restaurants = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/restaurants/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          restaurants = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Erreur lors du chargement: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur de connexion: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadRestaurantMenu(Map<String, dynamic> restaurant) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Chargement du menu...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/restaurants/${restaurant['id']}/menu/'),
        headers: {'Content-Type': 'application/json'},
      );

      Navigator.pop(context); // Fermer le dialog de chargement

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Naviguer vers la page du menu avec les données du restaurant
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantMenuPage(
              restaurant: restaurant,
              menuData: data,
              token: widget.token,
            ),
          ),
        );
      } else {
        _showErrorSnackBar('Erreur lors du chargement du menu');
      }
    } catch (e) {
      Navigator.pop(context); // Fermer le dialog de chargement
      _showErrorSnackBar('Erreur de connexion: $e');
    }
  }

  Future<void> _loadPlatDuJour(Map<String, dynamic> restaurant) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/restaurants/${restaurant['id']}/plat_du_jour/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showPlatDuJourDialog(restaurant, data);
      } else {
        _showErrorSnackBar('Erreur lors du chargement du plat du jour');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur de connexion: $e');
    }
  }

  void _showPlatDuJourDialog(Map<String, dynamic> restaurant, Map<String, dynamic> data) {
    final platDuJour = data['plat_du_jour'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Plat du jour - ${restaurant['nom']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (platDuJour != null) ...[
                if (platDuJour['image'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      platDuJour['image'].toString().startsWith('http') 
                        ? platDuJour['image']
                        : 'http://localhost:8000${platDuJour['image']}',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Icon(Icons.restaurant, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 16),
                Text(
                  platDuJour['nom'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${platDuJour['prix']} F CFA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (platDuJour['description'] != null && platDuJour['description'].isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    platDuJour['description'],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text('${platDuJour['calories']} kcal'),
                    SizedBox(width: 16),
                    Icon(Icons.schedule, size: 16, color: Colors.blue),
                    SizedBox(width: 4),
                    Text('${platDuJour['temps_preparation']} min'),
                  ],
                ),
              ] else ...[
                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Aucun plat du jour défini pour ce restaurant',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          if (platDuJour != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadRestaurantMenu(restaurant);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Voir le menu'),
            ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Choisissez votre Restaurant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRestaurants,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Chargement des restaurants...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              SizedBox(height: 16),
              Text(
                error!,
                style: TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadRestaurants,
                icon: Icon(Icons.refresh),
                label: Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (restaurants.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Aucun restaurant disponible',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Revenez plus tard pour découvrir nos restaurants partenaires',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRestaurants,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return _buildRestaurantCard(restaurant);
        },
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _loadRestaurantMenu(restaurant),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo du restaurant (si disponible)
              if ((restaurant['logo_url'] ?? restaurant['logo']) != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SafeImageWidget(
                      imageUrl: (restaurant['logo_url'] ?? restaurant['logo'])?.toString(),
                      height: 80,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              
              if ((restaurant['logo_url'] ?? restaurant['logo']) != null) SizedBox(height: 16),
              
              // Nom du restaurant
              Text(
                restaurant['nom'] ?? 'Restaurant sans nom',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              
              SizedBox(height: 8),
              
              // Adresse
              if (restaurant['adresse'] != null && restaurant['adresse'].isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        restaurant['adresse'],
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              
              SizedBox(height: 16),
              
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _loadRestaurantMenu(restaurant),
                      icon: Icon(Icons.restaurant_menu),
                      label: Text('Voir le Menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _loadPlatDuJour(restaurant),
                    icon: Icon(Icons.star),
                    label: Text('Plat du Jour'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RestaurantMenuPage extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final Map<String, dynamic> menuData;
  final String? token;
  
  const RestaurantMenuPage({
    Key? key,
    required this.restaurant,
    required this.menuData,
    this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 28,
                height: 28,
                child: (((restaurant['logo_url'] ?? restaurant['logo']) ?? '') as String).toString().isNotEmpty
                  ? SafeImageWidget(imageUrl: (restaurant['logo_url'] ?? restaurant['logo'])?.toString(), width: 28, height: 28, fit: BoxFit.cover)
                  : Container(color: Colors.white.withOpacity(0.3), child: Icon(Icons.business, size: 18, color: Colors.white)),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                restaurant['nom'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du restaurant
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant['nom'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (restaurant['adresse'] != null) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            restaurant['adresse'],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Menu
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildMenuList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    final menu = menuData['menu'] as List? ?? [];
    
    if (menu.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Menu non disponible',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: menu.map((item) => _buildMenuItem(item)).toList(),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Image du plat
            if ((item['image_url'] ?? item['image']) != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  (() {
                    final src = (item['image_url'] ?? item['image']).toString();
                    if (src.startsWith('http')) return src;
                    return 'http://localhost:8000$src';
                  })(),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: Icon(Icons.restaurant, color: Colors.grey),
                    );
                  },
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restaurant, color: Colors.grey),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item['description'] != null && item['description'].isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      item['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 8),
                  Text(
                    '${item['prix']} F CFA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
