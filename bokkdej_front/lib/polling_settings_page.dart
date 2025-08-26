import 'package:flutter/material.dart';
import 'services/polling_config.dart';
import 'services/polling_manager.dart';

class PollingSettingsPage extends StatefulWidget {
  @override
  _PollingSettingsPageState createState() => _PollingSettingsPageState();
}

class _PollingSettingsPageState extends State<PollingSettingsPage> {
  bool _pollingEnabled = true;
  int _dashboardInterval = 60;
  int _ordersInterval = 30;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      _pollingEnabled = await PollingConfig.isPollingEnabled();
      _dashboardInterval = await PollingConfig.getDashboardInterval();
      _ordersInterval = await PollingConfig.getOrdersInterval();

    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    try {
      await PollingConfig.setPollingEnabled(_pollingEnabled);
      await PollingConfig.setDashboardInterval(_dashboardInterval);
      await PollingConfig.setOrdersInterval(_ordersInterval);

      
      // Mettre à jour tous les timers actifs
      await PollingManager().updateAllTimers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Paramètres sauvegardés avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Retourner true pour indiquer que les paramètres ont changé
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de la sauvegarde: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Réinitialiser'),
        content: Text('Remettre tous les paramètres aux valeurs par défaut ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Réinitialiser', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PollingConfig.resetToDefaults();
        await _loadSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Paramètres réinitialisés aux valeurs par défaut'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la réinitialisation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Paramètres de mise à jour'),
          backgroundColor: Color(0xFFFFD700),
          foregroundColor: Color(0xFF2C2C2C),
        ),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres de mise à jour'),
        backgroundColor: Color(0xFFFFD700),
        foregroundColor: Color(0xFF2C2C2C),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadSettings,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section principale
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings, color: Color(0xFFFFD700)),
                        SizedBox(width: 8),
                        Text(
                          'Configuration des mises à jour automatiques',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Activer/désactiver le polling
                    SwitchListTile(
                      title: Text('Mises à jour automatiques'),
                      subtitle: Text('Activer la synchronisation en temps réel'),
                      value: _pollingEnabled,
                      onChanged: (value) => setState(() => _pollingEnabled = value),
                      secondary: Icon(Icons.sync, color: Color(0xFFFFD700)),
                    ),
                    
                    if (_pollingEnabled) ...[
                      Divider(),
                      SizedBox(height: 8),
                      
                      // Dashboard
                      _buildIntervalSlider(
                        'Dashboard Restaurant',
                        'Mise à jour des statistiques',
                        _dashboardInterval,
                        (value) => setState(() => _dashboardInterval = value),
                        min: 30,
                        max: 300,
                        divisions: 9,
                        label: '${_dashboardInterval}s',
                        icon: Icons.dashboard,
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Commandes
                      _buildIntervalSlider(
                        'Commandes',
                        'Mise à jour du statut des commandes',
                        _ordersInterval,
                        (value) => setState(() => _ordersInterval = value),
                        min: 15,
                        max: 120,
                        divisions: 7,
                        label: '${_ordersInterval}s',
                        icon: Icons.shopping_cart,
                      ),
                      
                      SizedBox(height: 16),
                      

                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Section d'information
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Informations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Les mises à jour automatiques permettent de garder les données synchronisées en temps réel\n'
                      '• Des intervalles plus courts = données plus fraîches mais consommation réseau plus élevée\n'
                      '• Des intervalles plus longs = économie de données mais données moins fraîches\n'
                      '• Les changements prennent effet immédiatement',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetToDefaults,
                    icon: Icon(Icons.restore),
                    label: Text('Valeurs par défaut'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: Icon(Icons.save),
                    label: Text('Sauvegarder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD700),
                      foregroundColor: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSlider(
    String title,
    String subtitle,
    int value,
    ValueChanged<int> onChanged, {
    required int min,
    required int max,
    required int divisions,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFFFFD700), size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFFFD700).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: divisions,
          onChanged: (newValue) => onChanged(newValue.round()),
          activeColor: Color(0xFFFFD700),
          inactiveColor: Colors.grey.shade300,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min}s', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            Text('${max}s', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }
}
