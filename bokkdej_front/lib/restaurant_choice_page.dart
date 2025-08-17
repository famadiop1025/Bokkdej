import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'menu_page.dart';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class RestaurantChoicePage extends StatefulWidget {
  @override
  _RestaurantChoicePageState createState() => _RestaurantChoicePageState();
}

class _RestaurantChoicePageState extends State<RestaurantChoicePage> {
  List<Map<String, dynamic>> restaurants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/restaurants/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          restaurants = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des restaurants')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choisir un Restaurant'),
        backgroundColor: Color(0xFFFFD700),
        foregroundColor: Color(0xFF2C2C2C),
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
            : restaurants.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucun restaurant disponible',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRestaurants,
                          child: Text('Actualiser'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restaurants disponibles:',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: restaurants.length,
                            itemBuilder: (context, index) {
                              final restaurant = restaurants[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 12),
                                elevation: 4,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Color(0xFFFFD700),
                                    child: Icon(Icons.restaurant, color: Color(0xFF2C2C2C)),
                                  ),
                                  title: Text(
                                    restaurant['nom'] ?? 'Restaurant ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (restaurant['adresse'] != null)
                                        Text(restaurant['adresse']),
                                      if (restaurant['description'] != null)
                                        Text(
                                          restaurant['description'],
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MenuPage(
                                          restaurantId: restaurant['id'],
                                          restaurantName: restaurant['nom'] ?? 'Restaurant',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
