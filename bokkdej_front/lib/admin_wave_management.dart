import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants/app_colors.dart';

class AdminWaveManagement extends StatefulWidget {
  final String token;
  
  const AdminWaveManagement({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminWaveManagement> createState() => _AdminWaveManagementState();
}

class _AdminWaveManagementState extends State<AdminWaveManagement> {
  List<Map<String, dynamic>> restaurants = [];
  bool isLoading = true;
  String? error;

  String getApiBaseUrl() {
    return 'http://localhost:8000';
  }

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
        Uri.parse('${getApiBaseUrl()}/api/admin/restaurants/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          restaurants = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Erreur lors du chargement des restaurants';
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

  Future<void> _updateWaveConfig(int restaurantId, Map<String, String> waveData) async {
    try {
      final response = await http.patch(
        Uri.parse('${getApiBaseUrl()}/api/admin/restaurants/$restaurantId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode(waveData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Configuration Wave mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRestaurants(); // Recharger la liste
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

  void _showWaveConfigDialog(Map<String, dynamic> restaurant) {
    final waveLinkController = TextEditingController(text: restaurant['wave_payment_link'] ?? '');
    final merchantIdController = TextEditingController(text: restaurant['wave_merchant_id'] ?? '');
    final apiKeyController = TextEditingController(text: restaurant['wave_api_key'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Configuration Wave - ${restaurant['nom']}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Configurez les paramètres de paiement Wave pour ce restaurant',
                        style: TextStyle(color: Colors.blue[800], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: waveLinkController,
                decoration: InputDecoration(
                  labelText: 'Lien de paiement Wave',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                  hintText: 'https://wave.com/pay/...',
                ),
              ),
              
              SizedBox(height: 16),
              
              TextFormField(
                controller: merchantIdController,
                decoration: InputDecoration(
                  labelText: 'ID Marchand Wave',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                  hintText: 'Ex: MERCHANT123',
                ),
              ),
              
              SizedBox(height: 16),
              
              TextFormField(
                controller: apiKeyController,
                decoration: InputDecoration(
                  labelText: 'Clé API Wave',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                  hintText: 'Clé secrète API',
                ),
                obscureText: true,
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
              await _updateWaveConfig(
                restaurant['id'],
                {
                  'wave_payment_link': waveLinkController.text,
                  'wave_merchant_id': merchantIdController.text,
                  'wave_api_key': apiKeyController.text,
                },
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveStatusChip(String? link, String? merchantId, String? apiKey) {
    bool hasConfig = (link?.isNotEmpty ?? false) || 
                     (merchantId?.isNotEmpty ?? false) || 
                     (apiKey?.isNotEmpty ?? false);
    
    return Chip(
      label: Text(
        hasConfig ? 'Wave configuré' : 'Wave non configuré',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: hasConfig ? Colors.green : Colors.orange,
      avatar: Icon(
        hasConfig ? Icons.check : Icons.warning,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion Wave'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
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
                )
              : Column(
                  children: [
                    // En-tête informatif
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        border: Border(
                          bottom: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.payment, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Configuration Wave',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Gérez les configurations de paiement Wave pour chaque restaurant',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    
                    // Liste des restaurants
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: restaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = restaurants[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  restaurant['nom'][0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                restaurant['nom'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(restaurant['adresse'] ?? 'Adresse non renseignée'),
                                  SizedBox(height: 4),
                                  _buildWaveStatusChip(
                                    restaurant['wave_payment_link'],
                                    restaurant['wave_merchant_id'],
                                    restaurant['wave_api_key'],
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.edit),
                              onTap: () => _showWaveConfigDialog(restaurant),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
