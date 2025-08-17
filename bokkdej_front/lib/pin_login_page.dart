import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_page.dart';
import 'utils/auth_manager.dart';

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
    if (_phoneController.text.isEmpty || _pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      http.Response response;
      try {
        response = await http.post(
          Uri.parse('${getApiBaseUrl()}/api/auth/pin-login/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phone': _phoneController.text, 'pin': _pinController.text}),
        );
      } catch (_) {
        response = await http.post(
          Uri.parse('${getApiBaseUrl()}/api/token/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'username': _phoneController.text, 'password': _pinController.text}),
        );
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access'] ?? data['token'];
        if (token == null || token.toString().isEmpty) {
          throw Exception('Token manquant dans la réponse');
        }
        await AuthManager.redirectBasedOnRole(context, token);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Numéro ou PIN incorrect'),
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
        title: Text(widget.isStaff ? 'Connexion Restaurant' : 'Connexion Client'),
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
                      'Connexion',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Champ téléphone
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Champ PIN
                    TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      decoration: InputDecoration(
                        labelText: 'Code PIN (4 chiffres)',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        counterText: '',
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Bouton de connexion
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFD700),
                          foregroundColor: Color(0xFF2C2C2C),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    if (!widget.isStaff) ...[
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // TODO: Implémenter l'inscription
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Inscription'),
                              content: Text('Fonctionnalité d\'inscription à venir.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          'Pas encore de compte ? S\'inscrire',
                          style: TextStyle(color: Color(0xFF2C2C2C)),
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