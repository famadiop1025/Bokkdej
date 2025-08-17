import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class HistoriquePage extends StatefulWidget {
  @override
  _HistoriquePageState createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/orders/historique/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          orders = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement de l\'historique')),
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

  String _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'en_attente':
        return 'orange';
      case 'en_preparation':
        return 'blue';
      case 'pret':
        return 'green';
      case 'livre':
        return 'green';
      case 'annule':
        return 'red';
      default:
        return 'grey';
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'en_attente':
        return 'En attente';
      case 'en_preparation':
        return 'En préparation';
      case 'pret':
        return 'Prêt';
      case 'livre':
        return 'Livré';
      case 'annule':
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Commandes'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade100, Colors.white],
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucune commande dans l\'historique',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadOrderHistory,
                          child: Text('Actualiser'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadOrderHistory,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final plats = order['plats'] as List<dynamic>? ?? [];
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order['statut']) == 'orange'
                                            ? Colors.orange
                                            : _getStatusColor(order['statut']) == 'blue'
                                                ? Colors.blue
                                                : _getStatusColor(order['statut']) == 'green'
                                                    ? Colors.green
                                                    : _getStatusColor(order['statut']) == 'red'
                                                        ? Colors.red
                                                        : Colors.grey,
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
                                Text(
                                  'Date: ${order['date_creation'] ?? 'Non spécifiée'}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (order['restaurant_nom'] != null) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    'Restaurant: ${order['restaurant_nom']}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 12),
                                Text(
                                  'Plats commandés:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ...plats.map((plat) {
                                  return Padding(
                                    padding: EdgeInsets.only(left: 16, bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.restaurant_menu, size: 16),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${plat['base_nom'] ?? plat['base'] ?? 'Plat'} - ${plat['prix'] ?? 0}€',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total: ${order['prix_total'] ?? 0}€',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                    if (order['statut'] != 'livre' && order['statut'] != 'annule')
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/suivi',
                                            arguments: order['id'],
                                          );
                                        },
                                        child: Text('Suivre'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
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
      ),
    );
  }
}
