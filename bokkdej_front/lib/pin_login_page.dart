import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_page.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class PinLoginPage extends StatefulWidget {
  final bool isStaff;
  
  PinLoginPage({this.isStaff = false});

  @override
  _PinLoginPageState createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() { _isLoading = true; });
    
    try {
      final String raw = _phoneController.text.trim();
      final String phone = raw.replaceAll(RegExp(r'[^0-9]'), '');
      final String pin = _pinController.text.trim();
      
      http.Response response;
      
      // Si c'est un client (pas staff), créer un compte automatiquement
      if (!widget.isStaff) {
        try {
          response = await http.post(
            Uri.parse('${getApiBaseUrl()}/api/auth/create-client/'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'phone': phone,
              'name': 'Client $phone',
            }),
          );
          
          if (response.statusCode == 201 || response.statusCode == 200) {
            final data = json.decode(response.body);
            final token = data['access'] ?? data['token'];
            
            if (token != null && token.toString().isNotEmpty) {
              // Rediriger directement vers la page de choix de restaurant
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage(token: token)),
              );
              return;
            }
          }
        } catch (_) {
          // Si la création client échoue, continuer avec la connexion normale
        }
      }
      
      // Connexion PIN pour staff (admin, personnel, chef)
      response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/auth/pin-login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'pin': pin,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access'] ?? data['token'];
        if (token == null || token.toString().isEmpty) {
          throw Exception('Token manquant dans la réponse');
        }
        // Essayer d'envoyer un fcm_token stocké localement s'il existe
        try {
          final prefs = await SharedPreferences.getInstance();
          final fcm = prefs.getString('fcm_token');
          if (fcm != null && fcm.isNotEmpty) {
            await http.post(
              Uri.parse('${getApiBaseUrl()}/api/user/update-fcm/'),
              headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
              body: json.encode({'fcm_token': fcm}),
            );
          }
        } catch (_) {}
        
        // Debug: afficher les données reçues
        print('🔍 DEBUG - Données de connexion: $data');
        print('🔍 DEBUG - Type de data: ${data.runtimeType}');
        print('🔍 DEBUG - Clés disponibles: ${data.keys.toList()}');
        print('🔍 DEBUG - Rôle: ${data['role']}');
        print('🔍 DEBUG - User object: ${data['user']}');
        print('🔍 DEBUG - Token: ${token.substring(0, 20)}...');
        
        // Essayer d'accéder au rôle de différentes manières
        String? userRole = data['role'];
        if (userRole == null && data['user'] != null) {
          userRole = data['user']['role'];
          print('🔍 DEBUG - Rôle depuis user object: $userRole');
        }
        
        // Rediriger vers la page appropriée
                       if (userRole == 'admin' || userRole == 'personnel' || userRole == 'chef') {
          print('🚀 DEBUG - Redirection vers AdminPage');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminPage(token: token, userRole: userRole)),
          );
        } else {
          print('🚀 DEBUG - Redirection vers HomePage (rôle: $userRole)');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(token: token)),
          );
        }
      } else {
        String details = '';
        try { details = json.decode(response.body).toString(); } catch (_) { details = response.body; }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Numéro ou PIN incorrect (${response.statusCode})${details.isNotEmpty ? '\n$details' : ''}'),
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
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isStaff ? 'Connexion Restaurant' : 'Accès Client'),
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
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isStaff ? Icons.business : Icons.person,
                      size: 64,
                      color: Color(0xFF2C2C2C),
                    ),
                    SizedBox(height: 24),
                    
                    Text(
                      widget.isStaff ? 'Connexion' : 'Accès Rapide',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    Text(
                      widget.isStaff 
                        ? 'Entrez vos identifiants restaurant'
                        : 'Entrez votre numéro de téléphone pour commander',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Champ téléphone
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        hintText: 'Ex: 221771234567',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    
                    // Champ PIN seulement pour le staff
                    if (widget.isStaff) ...[
                      SizedBox(height: 16),
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'PIN',
                          hintText: 'Entrez votre PIN',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                    
                    SizedBox(height: 32),
                    
                    // Bouton de connexion
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFD700),
                          foregroundColor: Color(0xFF2C2C2C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Color(0xFF2C2C2C))
                            : Text(
                                widget.isStaff ? 'Se connecter' : 'Continuer',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    if (!widget.isStaff) ...[
                      SizedBox(height: 16),
                      Text(
                        'Aucun compte requis !',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}