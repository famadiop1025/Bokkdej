import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants/app_colors.dart';

class AdminRestaurantManagement extends StatefulWidget {
  final String token;
  
  const AdminRestaurantManagement({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminRestaurantManagement> createState() => _AdminRestaurantManagementState();
}

class _AdminRestaurantManagementState extends State<AdminRestaurantManagement> {
  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> filteredRestaurants = [];
  bool isLoading = true;
  String? error;
  String selectedFilter = 'tous';
  
  final Map<String, String> filterNames = {
    'tous': 'Tous',
    'en_attente': 'En attente',
    'valide': 'Validés',
    'suspendu': 'Suspendus',
    'rejete': 'Rejetés',
  };
  
  final Map<String, Color> statusColors = {
    'en_attente': Colors.orange,
    'valide': Colors.green,
    'suspendu': Colors.red,
    'rejete': Colors.grey,
  };

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
        Uri.parse('http://localhost:8000/api/admin/restaurants/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          restaurants = List<Map<String, dynamic>>.from(data);
          _applyFilter();
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

  void _applyFilter() {
    if (selectedFilter == 'tous') {
      filteredRestaurants = restaurants;
    } else {
      filteredRestaurants = restaurants
          .where((restaurant) => restaurant['statut'] == selectedFilter)
          .toList();
    }
  }

  Future<void> _changeRestaurantStatus(int restaurantId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/admin/restaurants/$restaurantId/$action/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadRestaurants();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showActionDialog(Map<String, dynamic> restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actions pour ${restaurant['nom']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              'Valider', 
              Colors.green, 
              restaurant['statut'] != 'valide',
              () => _changeRestaurantStatus(restaurant['id'], 'valider_restaurant')
            ),
            _buildActionButton(
              'Suspendre', 
              Colors.red, 
              restaurant['statut'] != 'suspendu',
              () => _changeRestaurantStatus(restaurant['id'], 'suspendre_restaurant')
            ),
            _buildActionButton(
              'Réactiver', 
              Colors.blue, 
              restaurant['statut'] == 'suspendu',
              () => _changeRestaurantStatus(restaurant['id'], 'reactiver_restaurant')
            ),
            _buildActionButton(
              'Rejeter', 
              Colors.grey, 
              restaurant['statut'] == 'en_attente',
              () => _changeRestaurantStatus(restaurant['id'], 'rejeter_restaurant')
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, bool enabled, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: enabled ? () {
          Navigator.pop(context);
          onPressed();
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? color : Colors.grey[300],
          foregroundColor: enabled ? Colors.white : Colors.grey,
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Gestion des Restaurants',
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
            onPressed: _loadRestaurants,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filterNames.length,
              itemBuilder: (context, index) {
                final filter = filterNames.keys.elementAt(index);
                final isSelected = selectedFilter == filter;
                
                return Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(
                      filterNames[filter]!,
                      style: TextStyle(
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                        _applyFilter();
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.3),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          
          // Liste des restaurants
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRestaurants,
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (filteredRestaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun restaurant dans cette catégorie',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = filteredRestaurants[index];
        return _buildRestaurantCard(restaurant);
      },
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    final status = restaurant['statut'] as String;
    final statusColor = statusColors[status] ?? Colors.grey;
    
    return Card(
      color: AppColors.surface,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    restaurant['nom'] ?? 'Restaurant sans nom',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Informations du restaurant
            if (restaurant['adresse'] != null && restaurant['adresse'].isNotEmpty)
              _buildInfoRow(Icons.location_on, restaurant['adresse']),
            
            if (restaurant['telephone'] != null && restaurant['telephone'].isNotEmpty)
              _buildInfoRow(Icons.phone, restaurant['telephone']),
            
            if (restaurant['email'] != null && restaurant['email'].isNotEmpty)
              _buildInfoRow(Icons.email, restaurant['email']),
            
            SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showActionDialog(restaurant),
                    icon: Icon(Icons.settings),
                    label: Text('Actions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showRestaurantDetails(restaurant),
                  icon: Icon(Icons.info),
                  label: Text('Détails'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'en_attente':
        return 'EN ATTENTE';
      case 'valide':
        return 'VALIDÉ';
      case 'suspendu':
        return 'SUSPENDU';
      case 'rejete':
        return 'REJETÉ';
      default:
        return status.toUpperCase();
    }
  }

  void _showRestaurantDetails(Map<String, dynamic> restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(restaurant['nom']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Statut', _getStatusLabel(restaurant['statut'])),
              _buildDetailRow('Adresse', restaurant['adresse'] ?? 'Non renseignée'),
              _buildDetailRow('Téléphone', restaurant['telephone'] ?? 'Non renseigné'),
              _buildDetailRow('Email', restaurant['email'] ?? 'Non renseigné'),
              _buildDetailRow('Actif', restaurant['actif'] == true ? 'Oui' : 'Non'),
              if (restaurant['date_validation'] != null)
                _buildDetailRow('Date validation', restaurant['date_validation']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
