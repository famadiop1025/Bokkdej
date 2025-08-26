import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class AdminStatsPage extends StatefulWidget {
  final String token;
  final int? restaurantId;

  AdminStatsPage({required this.token, this.restaurantId});

  @override
  _AdminStatsPageState createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  Map<String, dynamic> stats = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final uri = Uri.parse('${getApiBaseUrl()}/api/admin/statistics/').replace(
        queryParameters: {
          if (widget.restaurantId != null) 'restaurant': widget.restaurantId.toString(),
        },
      );
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stats = data;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          isLoading = false;
          error = 'Erreur ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des statistiques')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    }
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
          colors: [Colors.orange.shade100, Colors.white],
        ),
      ),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistiques',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
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
                          'Commandes du jour',
                          '${(stats['orders'] ?? {})['today'] ?? 0}',
                          Icons.shopping_cart,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Revenus du mois',
                          '${((stats['revenue'] ?? {})['month'] ?? 0).toStringAsFixed(0)} F',
                          Icons.attach_money,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Commandes (30j)',
                          '${(stats['orders'] ?? {})['month'] ?? 0}',
                          Icons.timeline,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Panier moyen',
                          '${(stats['avg_order_value'] ?? 0).toStringAsFixed(0)} F',
                          Icons.receipt_long,
                          Colors.purple,
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
                            'Plats les plus vendus',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ...(_extractPopular(stats).take(5).map((plat) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(plat['label'] ?? 'Plat'),
                                  Text('${plat['quantity'] ?? 0} ventes'),
                                ],
                              ),
                            );
                          }).toList()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<Map<String, dynamic>> _extractPopular(Map<String, dynamic> s) {
    // Adapter aux retours de admin_statistics (popular_dishes) ou fallback
    final List<Map<String, dynamic>> out = [];
    final popular = s['popular_dishes'];
    if (popular is List) {
      for (final item in popular) {
        if (item is Map<String, dynamic>) {
          out.add({
            'label': item['label'] ?? item['custom_dish__base']?.toString() ?? 'Plat',
            'quantity': item['total_quantity'] ?? item['count'] ?? 0,
          });
        }
      }
    }
    return out;
  }
}
