import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants/app_colors.dart';

String getApiBaseUrl() {
  return 'http://localhost:8000';
}

class RestaurantRegistrationPage extends StatefulWidget {
  @override
  _RestaurantRegistrationPageState createState() => _RestaurantRegistrationPageState();
}

class _RestaurantRegistrationPageState extends State<RestaurantRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomGerantController = TextEditingController();
  final _telephoneGerantController = TextEditingController();
  final _typeCuisineController = TextEditingController();
  final _capaciteController = TextEditingController();
  final _horairesController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Contrôleurs pour Wave
  final _wavePaymentLinkController = TextEditingController();
  final _waveMerchantIdController = TextEditingController();
  final _waveApiKeyController = TextEditingController();
  
  bool _documentsLegaux = false;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _nomGerantController.dispose();
    _telephoneGerantController.dispose();
    _typeCuisineController.dispose();
    _capaciteController.dispose();
    _horairesController.dispose();
    _descriptionController.dispose();
    _wavePaymentLinkController.dispose();
    _waveMerchantIdController.dispose();
    _waveApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/restaurants/register/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nom': _nomController.text,
          'adresse': _adresseController.text,
          'telephone': _telephoneController.text,
          'email': _emailController.text,
          'nom_gerant': _nomGerantController.text,
          'telephone_gerant': _telephoneGerantController.text,
          'type_cuisine': _typeCuisineController.text,
          'capacite': int.tryParse(_capaciteController.text) ?? 0,
          'horaires': _horairesController.text,
          'description': _descriptionController.text,
          'documents_legaux': _documentsLegaux,
          // Configuration Wave
          'wave_payment_link': _wavePaymentLinkController.text,
          'wave_merchant_id': _waveMerchantIdController.text,
          'wave_api_key': _waveApiKeyController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        setState(() {
          _successMessage = responseData['message'];
        });
        
        // Vider le formulaire après succès
        _clearForm();
        
        // Afficher un dialogue de confirmation
        _showSuccessDialog(responseData['message']);
      } else {
        setState(() {
          _error = responseData['error'] ?? 'Erreur lors de la soumission';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _nomController.clear();
    _adresseController.clear();
    _telephoneController.clear();
    _emailController.clear();
    _nomGerantController.clear();
    _telephoneGerantController.clear();
    _typeCuisineController.clear();
    _capaciteController.clear();
    _horairesController.clear();
    _descriptionController.clear();
    _wavePaymentLinkController.clear();
    _waveMerchantIdController.clear();
    _waveApiKeyController.clear();
    _documentsLegaux = false;
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Demande soumise !'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prochaines étapes :',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
                    ),
                    SizedBox(height: 8),
                    Text('• Notre équipe examinera votre dossier'),
                    Text('• Vous recevrez une réponse par email'),
                    Text('• Si approuvé, vous obtiendrez vos identifiants'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Compris'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription Restaurant'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête informatif
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.restaurant, color: AppColors.primary, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Rejoignez BOKDEJ',
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
                      'Proposez votre cuisine à nos clients et gérez vos commandes facilement.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Messages d'erreur et de succès
              if (_error != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),

              if (_successMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(child: Text(_successMessage!, style: TextStyle(color: Colors.green))),
                    ],
                  ),
                ),

              SizedBox(height: 16),

              // Section Informations Restaurant
              _buildSectionHeader('Informations du Restaurant'),
              SizedBox(height: 16),

              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom du restaurant *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom du restaurant est requis';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: _adresseController,
                decoration: InputDecoration(
                  labelText: 'Adresse complète *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'adresse est requise';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _telephoneController,
                      decoration: InputDecoration(
                        labelText: 'Téléphone *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le téléphone est requis';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'email est requis';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Format d\'email invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: _typeCuisineController,
                decoration: InputDecoration(
                  labelText: 'Type de cuisine',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant_menu),
                  hintText: 'Ex: Sénégalaise, Française, Italienne...',
                ),
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _capaciteController,
                      decoration: InputDecoration(
                        labelText: 'Capacité d\'accueil',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _horairesController,
                      decoration: InputDecoration(
                        labelText: 'Horaires d\'ouverture',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                        hintText: 'Ex: 8h-22h',
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description du restaurant',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),

              SizedBox(height: 24),

              // Section Gérant
              _buildSectionHeader('Informations du Gérant'),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nomGerantController,
                      decoration: InputDecoration(
                        labelText: 'Nom du gérant *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom du gérant est requis';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _telephoneGerantController,
                      decoration: InputDecoration(
                        labelText: 'Téléphone gérant *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le téléphone du gérant est requis';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Section Configuration Wave
              _buildSectionHeader('Configuration Paiement Wave'),
              SizedBox(height: 16),
              
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Configuration Wave',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ces informations permettront à vos clients de vous payer directement via Wave. Vous pouvez les configurer plus tard dans votre espace admin.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),

              TextFormField(
                controller: _wavePaymentLinkController,
                decoration: InputDecoration(
                  labelText: 'Lien de paiement Wave (optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                  hintText: 'https://wave.com/pay/...',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.isAbsolute) {
                      return 'Veuillez entrer une URL valide';
                    }
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _waveMerchantIdController,
                      decoration: InputDecoration(
                        labelText: 'ID Marchand Wave (optionnel)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                        hintText: 'Ex: MERCHANT123',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _waveApiKeyController,
                      decoration: InputDecoration(
                        labelText: 'Clé API Wave (optionnel)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                        hintText: 'Clé secrète API',
                      ),
                      obscureText: true,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Section Documents
              _buildSectionHeader('Documents'),
              SizedBox(height: 16),

              CheckboxListTile(
                title: Text('J\'ai tous les documents légaux requis'),
                subtitle: Text('Licence, registre de commerce, etc.'),
                value: _documentsLegaux,
                onChanged: (value) {
                  setState(() {
                    _documentsLegaux = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              SizedBox(height: 32),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Soumission en cours...'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send),
                            SizedBox(width: 8),
                            Text('Soumettre ma demande'),
                          ],
                        ),
                ),
              ),

              SizedBox(height: 16),

              // Informations sur le processus
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Processus d\'inscription',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Soumettez votre demande avec tous les documents'),
                    Text('2. Notre équipe examine votre dossier (24-48h)'),
                    Text('3. Si approuvé, vous recevez vos identifiants'),
                    Text('4. Configurez votre menu et commencez à recevoir des commandes'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }
}
