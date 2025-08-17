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

class AdminPersonnelManagement extends StatefulWidget {
  final String token;
  
  const AdminPersonnelManagement({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminPersonnelManagement> createState() => _AdminPersonnelManagementState();
}

class _AdminPersonnelManagementState extends State<AdminPersonnelManagement> {
  List<dynamic> _personnel = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  final List<Map<String, String>> _roles = [
    {'value': 'all', 'label': 'Tous'},
    {'value': 'admin', 'label': 'Administrateurs'},
    {'value': 'personnel', 'label': 'Personnel'},
    {'value': 'chef', 'label': 'Chefs'},
  ];

  final Map<String, Color> _roleColors = {
    'admin': Colors.red,
    'personnel': Colors.blue,
    'chef': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadPersonnel(),
      _loadStatistics(),
    ]);
  }

  Future<void> _loadPersonnel() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _personnel = json.decode(response.body);
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
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/statistics/'),
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

  Future<void> _toggleActive(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/$userId/toggle_active/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statut mis à jour')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _changeRole(int userId, String newRole) async {
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/$userId/change_role/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'role': newRole}),
      );

      if (response.statusCode == 200) {
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rôle mis à jour')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _deletePersonnel(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${getApiBaseUrl()}/api/admin/personnel/$userId/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membre du personnel supprimé')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  List<dynamic> get _filteredPersonnel {
    return _personnel.where((person) {
      final matchesSearch = person['username']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          (person['first_name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          (person['last_name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      
      final role = person['profile']?['role'] ?? '';
      final matchesFilter = _selectedFilter == 'all' || role == _selectedFilter;
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Gestion du Personnel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () => _showAddPersonnelDialog(),
            tooltip: 'Ajouter du personnel',
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
                    : _buildPersonnelList(),
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
              'Total Personnel',
              '${_statistics!['total_staff'] ?? 0}',
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Actifs',
              '${_statistics!['active_staff'] ?? 0}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Inactifs',
              '${(_statistics!['total_staff'] ?? 0) - (_statistics!['active_staff'] ?? 0)}',
              Icons.cancel,
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
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
              hintText: 'Rechercher un membre du personnel...',
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
              children: _roles.map((role) {
                return _buildFilterChip(role['label']!, role['value']!);
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
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.withOpacity(0.2),
        checkmarkColor: Colors.blue,
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

  Widget _buildPersonnelList() {
    final filteredPersonnel = _filteredPersonnel;

    if (filteredPersonnel.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun membre du personnel trouvé',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPersonnel.length,
      itemBuilder: (context, index) {
        final person = filteredPersonnel[index];
        return _buildPersonnelCard(person);
      },
    );
  }

  Widget _buildPersonnelCard(Map<String, dynamic> person) {
    final profile = person['profile'] ?? {};
    final role = profile['role'] ?? 'client';
    final isActive = person['is_active'] ?? false;
    final fullName = '${person['first_name'] ?? ''} ${person['last_name'] ?? ''}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : person['username'];

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
                CircleAvatar(
                  backgroundColor: _roleColors[role] ?? Colors.grey,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _roleColors[role] ?? Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getRoleLabel(role),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Username: ${person['username']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (person['email'] != null && person['email'].toString().isNotEmpty)
                        Text(
                          'Email: ${person['email']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      if (profile['phone'] != null)
                        Text(
                          'Téléphone: ${profile['phone']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      if (profile['date_embauche'] != null)
                        Text(
                          'Embauché le: ${profile['date_embauche']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: isActive,
                      onChanged: (value) => _toggleActive(person['id']),
                      activeColor: Colors.green,
                    ),
                    Text(
                      isActive ? 'Actif' : 'Inactif',
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditPersonnelDialog(person),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Modifier'),
                ),
                TextButton.icon(
                  onPressed: () => _showChangeRoleDialog(person),
                  icon: const Icon(Icons.admin_panel_settings, size: 16),
                  label: const Text('Rôle'),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(person),
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

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'ADMIN';
      case 'personnel':
        return 'PERSONNEL';
      case 'chef':
        return 'CHEF';
      default:
        return role.toUpperCase();
    }
  }

  void _showChangeRoleDialog(Map<String, dynamic> person) {
    final currentRole = person['profile']?['role'] ?? 'personnel';
    String selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Changer le rôle - ${person['username']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rôle actuel: ${_getRoleLabel(currentRole)}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Nouveau rôle',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                  DropdownMenuItem(value: 'personnel', child: Text('Personnel')),
                  DropdownMenuItem(value: 'chef', child: Text('Chef')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedRole != currentRole
                  ? () {
                      Navigator.pop(context);
                      _changeRole(person['id'], selectedRole);
                    }
                  : null,
              child: const Text('Changer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPersonnelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter du personnel'),
        content: const Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showEditPersonnelDialog(Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier - ${person['username']}'),
        content: const Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${person['username']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePersonnel(person['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}