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

class AdminIngredientsManagement extends StatefulWidget {
  final String token;
  
  const AdminIngredientsManagement({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminIngredientsManagement> createState() => _AdminIngredientsManagementState();
}

class _AdminIngredientsManagementState extends State<AdminIngredientsManagement> {
  List<dynamic> _ingredients = [];
  Map<String, dynamic>? _statistics;
  List<dynamic> _lowStockAlerts = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  final List<Map<String, String>> _ingredientTypes = [
    {'value': 'all', 'label': 'Tous'},
    {'value': 'legume', 'label': 'Légumes'},
    {'value': 'viande', 'label': 'Viandes'},
    {'value': 'poisson', 'label': 'Poissons'},
    {'value': 'fromage', 'label': 'Fromages'},
    {'value': 'sauce', 'label': 'Sauces'},
    {'value': 'epice', 'label': 'Épices'},
    {'value': 'autre', 'label': 'Autres'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadIngredients(),
      _loadStatistics(),
      _loadLowStockAlerts(),
    ]);
  }

  Future<void> _loadIngredients() async {
    setState(() => _isLoading = true);

    try {
      String url = '${getApiBaseUrl()}/api/admin/ingredients/';
      if (_selectedFilter != 'all') {
        url += '?type=$_selectedFilter';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _ingredients = json.decode(response.body);
          _error = null;
        });
      } else {
        setState(() {
          _error = 'Erreur de chargement: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur réseau: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/admin/ingredients/statistics/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _statistics = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Erreur chargement statistiques: $e');
    }
  }

  Future<void> _loadLowStockAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/admin/ingredients/low_stock_alert/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _lowStockAlerts = data['items'] ?? [];
        });
      }
    } catch (e) {
      print('Erreur chargement alertes: $e');
    }
  }

  Future<void> _updateStock(int ingredientId, int newStock) async {
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/admin/ingredients/$ingredientId/update_stock/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'stock': newStock}),
      );

      if (response.statusCode == 200) {
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock mis à jour')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _deleteIngredient(int ingredientId) async {
    try {
      final response = await http.delete(
        Uri.parse('${getApiBaseUrl()}/api/admin/ingredients/$ingredientId/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingrédient supprimé avec succès')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  List<dynamic> get _filteredIngredients {
    return _ingredients.where((item) {
      final matchesSearch = item['nom']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      
      final matchesFilter = _selectedFilter == 'all' || 
          item['type'] == _selectedFilter;
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Gestion des Ingrédients',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Ajouter un ingrédient',
          ),
          IconButton(
            icon: const Icon(Icons.warning, color: Colors.white),
            onPressed: () => _showLowStockDialog(),
            tooltip: 'Alertes stock faible',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget()
                    : _buildIngredientsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (_statistics == null) return Container();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              '${_statistics!['total'] ?? 0}',
              Icons.inventory,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Disponibles',
              '${_statistics!['disponibles'] ?? 0}',
              Icons.check_circle,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Stock Faible',
              '${_statistics!['low_stock_count'] ?? 0}',
              Icons.warning,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un ingrédient...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _ingredientTypes.map((type) {
                return _buildFilterChip(type['label']!, type['value']!);
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
          _loadIngredients();
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.green.withOpacity(0.2),
        checkmarkColor: Colors.green,
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
            onPressed: _loadData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    final filteredItems = _filteredIngredients;

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun ingrédient trouvé',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildIngredientCard(item);
      },
    );
  }

  Widget _buildIngredientCard(Map<String, dynamic> item) {
    final stockActuel = item['stock_actuel'] ?? 0;
    final stockMin = item['stock_min'] ?? 0;
    final isLowStock = stockActuel <= stockMin;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['nom'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isLowStock)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'STOCK FAIBLE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item['prix']} F / ${item['unite'] ?? 'unité'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${_getTypeLabel(item['type'])}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (item['fournisseur'] != null)
                        Text(
                          'Fournisseur: ${item['fournisseur']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stock: $stockActuel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLowStock ? Colors.red : Colors.green,
                      ),
                    ),
                    Text(
                      'Min: $stockMin',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showStockUpdateDialog(item),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Stock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 30),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: stockMin > 0 ? (stockActuel / (stockMin * 2)).clamp(0.0, 1.0) : 1.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isLowStock ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _showAddEditDialog(item: item),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Modifier'),
                ),
                TextButton.icon(
                  onPressed: () => _showStockUpdateDialog(item),
                  icon: const Icon(Icons.inventory, size: 16),
                  label: const Text('Gérer Stock'),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(item),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(String? type) {
    return _ingredientTypes
        .firstWhere((t) => t['value'] == type, orElse: () => {'label': type ?? 'Inconnu'})['label']!;
  }

  void _showStockUpdateDialog(Map<String, dynamic> item) {
    final TextEditingController stockController = TextEditingController();
    stockController.text = (item['stock_actuel'] ?? 0).toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mettre à jour le stock - ${item['nom']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stock actuel: ${item['stock_actuel']} ${item['unite'] ?? 'unité'}'),
            Text('Stock minimum: ${item['stock_min']} ${item['unite'] ?? 'unité'}'),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nouveau stock',
                border: OutlineInputBorder(),
                suffixText: item['unite'] ?? 'unité',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null) {
                Navigator.pop(context);
                _updateStock(item['id'], newStock);
              }
            },
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  void _showLowStockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Alertes Stock Faible'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: _lowStockAlerts.isEmpty
              ? const Text('Aucune alerte de stock faible')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _lowStockAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = _lowStockAlerts[index];
                    return ListTile(
                      leading: Icon(Icons.warning, color: Colors.red),
                      title: Text(alert['nom']),
                      subtitle: Text('Stock: ${alert['stock_actuel']} / Min: ${alert['stock_min']}'),
                      trailing: Text(alert['unite'] ?? ''),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({Map<String, dynamic>? item}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Ajouter un ingrédient' : 'Modifier l\'ingrédient'),
        content: Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${item['nom']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteIngredient(item['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}