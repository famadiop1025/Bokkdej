import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants/app_colors.dart';
import 'widgets/image_upload_widget.dart';
import 'widgets/network_image_widget.dart';

class AdminImageManagement extends StatefulWidget {
  final String token;
  
  const AdminImageManagement({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminImageManagement> createState() => _AdminImageManagementState();
}

class _AdminImageManagementState extends State<AdminImageManagement> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _menuItems = [];
  List<Map<String, dynamic>> _ingredients = [];
  List<Map<String, dynamic>> _bases = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Charger les plats du menu
      final menuResponse = await http.get(
        Uri.parse('http://localhost:8000/api/menu/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (menuResponse.statusCode == 200) {
        _menuItems = List<Map<String, dynamic>>.from(json.decode(menuResponse.body));
      }

      // Charger les ingrédients
      final ingredientsResponse = await http.get(
        Uri.parse('http://localhost:8000/api/ingredients/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (ingredientsResponse.statusCode == 200) {
        _ingredients = List<Map<String, dynamic>>.from(json.decode(ingredientsResponse.body));
      }

      // Charger les bases
      final basesResponse = await http.get(
        Uri.parse('http://localhost:8000/api/bases/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (basesResponse.statusCode == 200) {
        _bases = List<Map<String, dynamic>>.from(json.decode(basesResponse.body));
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des données: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildItemCard(Map<String, dynamic> item, String modelType) {
    final hasImage = item['image'] != null && item['image'].toString().isNotEmpty;
    
    return Card(
      color: AppColors.surface,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de l'élément
            Text(
              item['nom'] ?? 'Sans nom',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(height: 8),
            
            // Prix si disponible
            if (item['prix'] != null)
              Text(
                '${item['prix']} FCFA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            
            SizedBox(height: 12),
            
            // Image actuelle
            if (hasImage)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Image actuelle:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  NetworkImageWidget(
                    imageUrl: 'http://localhost:8000${item['image']}',
                    width: 150,
                    height: 150,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            
            SizedBox(height: 16),
            
            // Widget d'upload
            ImageUploadWidget(
              modelType: modelType,
              itemId: item['id'],
              token: widget.token,
              onImageUploaded: (imageUrl) {
                // Rafraîchir les données après upload
                _loadData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    List<Map<String, dynamic>> items = [];
    String modelType = '';

    switch (_tabController.index) {
      case 0:
        items = _menuItems;
        modelType = 'menu';
        break;
      case 1:
        items = _ingredients;
        modelType = 'ingredients';
        break;
      case 2:
        items = _bases;
        modelType = 'bases';
        break;
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun élément trouvé',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(items[index], modelType);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Gestion des Images',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.textPrimary,
          tabs: [
            Tab(
              icon: Icon(Icons.restaurant),
              text: 'Plats (${_menuItems.length})',
            ),
            Tab(
              icon: Icon(Icons.category),
              text: 'Ingrédients (${_ingredients.length})',
            ),
            Tab(
              icon: Icon(Icons.layers),
              text: 'Bases (${_bases.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(), // Plats
          _buildTabContent(), // Ingrédients
          _buildTabContent(), // Bases
        ],
      ),
    );
  }
}