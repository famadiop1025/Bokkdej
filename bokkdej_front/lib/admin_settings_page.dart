import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;


String getApiBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:8000';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000';
  } else {
    return 'http://localhost:8000';
  }
}

class AdminSettingsPage extends StatefulWidget {
  final String token;
  
  const AdminSettingsPage({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  Map<String, dynamic>? _settings;
  bool _isLoading = true;
  String? _error;
  bool _isSaving = false;

  // Controllers pour les champs de saisie
  final TextEditingController _restaurantNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commandeMinController = TextEditingController();
  final TextEditingController _tempsPreparationController = TextEditingController();
  final TextEditingController _deviseController = TextEditingController();
  final TextEditingController _fraisLivraisonController = TextEditingController();
  final TextEditingController _zoneLivraisonController = TextEditingController();

  // Switches
  bool _accepterCommandesAnonymes = true;
  bool _notificationsActivees = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _livraisonActivee = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _commandeMinController.dispose();
    _tempsPreparationController.dispose();
    _deviseController.dispose();
    _fraisLivraisonController.dispose();
    _zoneLivraisonController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/admin/settings/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _settings = data;
          _isLoading = false;
        });
        _populateFields(data);
      } else {
        setState(() {
          _error = 'Erreur de chargement: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur réseau: $e';
        _isLoading = false;
      });
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    final restaurant = data['restaurant'] ?? {};
    final settings = data['settings'] ?? {};

    _restaurantNameController.text = restaurant['nom'] ?? '';
    _addressController.text = restaurant['adresse'] ?? '';
    _phoneController.text = restaurant['telephone'] ?? '';
    _emailController.text = restaurant['email'] ?? '';
    
    _commandeMinController.text = (settings['commande_min'] ?? 0).toString();
    _tempsPreparationController.text = (settings['temps_preparation_defaut'] ?? 30).toString();
    _deviseController.text = settings['devise'] ?? 'F CFA';
    _fraisLivraisonController.text = (settings['frais_livraison'] ?? 0).toString();
    _zoneLivraisonController.text = settings['zone_livraison'] ?? '';

    setState(() {
      _accepterCommandesAnonymes = settings['accepter_commandes_anonymes'] ?? true;
      _notificationsActivees = settings['notifications_activees'] ?? true;
      _emailNotifications = settings['email_notifications'] ?? true;
      _smsNotifications = settings['sms_notifications'] ?? false;
      _livraisonActivee = settings['livraison_activee'] ?? false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final data = {
        'restaurant': {
          'nom': _restaurantNameController.text,
          'adresse': _addressController.text,
          'telephone': _phoneController.text,
          'email': _emailController.text,
        },
        'settings': {
          'commande_min': double.tryParse(_commandeMinController.text) ?? 0,
          'temps_preparation_defaut': int.tryParse(_tempsPreparationController.text) ?? 30,
          'accepter_commandes_anonymes': _accepterCommandesAnonymes,
          'notifications_activees': _notificationsActivees,
          'email_notifications': _emailNotifications,
          'sms_notifications': _smsNotifications,
          'devise': _deviseController.text,
          'livraison_activee': _livraisonActivee,
          'frais_livraison': double.tryParse(_fraisLivraisonController.text) ?? 0,
          'zone_livraison': _zoneLivraisonController.text,
        },
      };

      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/admin/settings/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres sauvegardés avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadSettings();
      } else {
        throw Exception('Erreur de sauvegarde: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Paramètres Système',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[700],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSettings,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildSettingsContent(),
      floatingActionButton: _isSaving
          ? null
          : FloatingActionButton.extended(
              onPressed: _saveSettings,
              backgroundColor: Colors.green,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Sauvegarder',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSettings,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRestaurantInfoSection(),
          const SizedBox(height: 24),
          _buildOrderSettingsSection(),
          const SizedBox(height: 24),
          _buildNotificationSettingsSection(),
          const SizedBox(height: 24),
          _buildDeliverySettingsSection(),
          const SizedBox(height: 24),
          _buildDisplaySettingsSection(),
          const SizedBox(height: 80), // Espace pour le FAB
        ],
      ),
    );
  }

  Widget _buildRestaurantInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Informations du Restaurant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _restaurantNameController,
              decoration: const InputDecoration(
                labelText: 'Nom du restaurant',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Paramètres de Commande',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commandeMinController,
              decoration: const InputDecoration(
                labelText: 'Montant minimum de commande',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on),
                suffixText: 'F',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tempsPreparationController,
              decoration: const InputDecoration(
                labelText: 'Temps de préparation par défaut',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
                suffixText: 'minutes',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Accepter les commandes anonymes'),
              subtitle: const Text('Permettre aux clients de commander sans compte'),
              value: _accepterCommandesAnonymes,
              onChanged: (value) {
                setState(() {
                  _accepterCommandesAnonymes = value;
                });
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Paramètres de Notification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Notifications activées'),
              subtitle: const Text('Activer toutes les notifications'),
              value: _notificationsActivees,
              onChanged: (value) {
                setState(() {
                  _notificationsActivees = value;
                });
              },
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: const Text('Notifications par email'),
              subtitle: const Text('Recevoir les notifications par email'),
              value: _emailNotifications,
              onChanged: _notificationsActivees
                  ? (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    }
                  : null,
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: const Text('Notifications par SMS'),
              subtitle: const Text('Recevoir les notifications par SMS'),
              value: _smsNotifications,
              onChanged: _notificationsActivees
                  ? (value) {
                      setState(() {
                        _smsNotifications = value;
                      });
                    }
                  : null,
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.delivery_dining, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Paramètres de Livraison',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Livraison activée'),
              subtitle: const Text('Proposer un service de livraison'),
              value: _livraisonActivee,
              onChanged: (value) {
                setState(() {
                  _livraisonActivee = value;
                });
              },
              activeColor: Colors.green,
            ),
            if (_livraisonActivee) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _fraisLivraisonController,
                decoration: const InputDecoration(
                  labelText: 'Frais de livraison',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
                  suffixText: 'F',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _zoneLivraisonController,
                decoration: const InputDecoration(
                  labelText: 'Zone de livraison',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                  hintText: 'Ex: Dakar, Pikine, Guédiawaye...',
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.display_settings, color: Colors.indigo, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Paramètres d\'Affichage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deviseController,
              decoration: const InputDecoration(
                labelText: 'Devise',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'Ex: F CFA, EUR, USD...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}