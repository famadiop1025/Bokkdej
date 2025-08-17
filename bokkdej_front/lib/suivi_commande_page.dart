import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants/app_colors.dart';

class SuiviCommandePage extends StatefulWidget {
  final int commandeId;
  final String? token;
  final String? phone;
  
  const SuiviCommandePage({
    Key? key,
    required this.commandeId,
    this.token,
    this.phone,
  }) : super(key: key);

  @override
  State<SuiviCommandePage> createState() => _SuiviCommandePageState();
}

class _SuiviCommandePageState extends State<SuiviCommandePage> {
  Map<String, dynamic>? commande;
  List<Map<String, dynamic>> statusHistory = [];
  int? estimatedTime;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSuivi();
  }

  Future<void> _loadSuivi() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String url = 'http://localhost:8000/api/orders/${widget.commandeId}/suivi/';
      
      if (widget.token != null) {
        headers['Authorization'] = 'Bearer ${widget.token}';
      } else if (widget.phone != null) {
        url += '?phone=${widget.phone}';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          commande = data['order'];
          statusHistory = List<Map<String, dynamic>>.from(data['status_history'] ?? []);
          estimatedTime = data['estimated_time'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Erreur lors du chargement: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur de connexion: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Suivi Commande #${widget.commandeId}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSuivi,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Chargement du suivi...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              SizedBox(height: 16),
              Text(
                error!,
                style: TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadSuivi,
                icon: Icon(Icons.refresh),
                label: Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (commande == null) {
      return Center(
        child: Text(
          'Commande introuvable',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSuivi,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(),
            SizedBox(height: 24),
            _buildEstimatedTime(),
            SizedBox(height: 24),
            _buildStatusTimeline(),
            SizedBox(height: 24),
            _buildOrderDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final status = commande!['status'] as String? ?? 'en_attente';
    final statusInfo = _getStatusInfo(status);
    final prixTotal = commande!['prix_total'] is String 
        ? double.tryParse(commande!['prix_total']) ?? 0.0
        : (commande!['prix_total'] as num?)?.toDouble() ?? 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${widget.commandeId}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusInfo['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusInfo['color']),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusInfo['icon'],
                        size: 16,
                        color: statusInfo['color'],
                      ),
                      SizedBox(width: 6),
                      Text(
                        statusInfo['label'],
                        style: TextStyle(
                          color: statusInfo['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            Row(
              children: [
                Icon(Icons.attach_money, size: 20, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Total: ${prixTotal.toStringAsFixed(0)} F CFA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimatedTime() {
    if (estimatedTime == null || estimatedTime! <= 0) {
      return Container();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule,
                color: Colors.blue,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temps estimé',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '$estimatedTime minutes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suivi de la commande',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),
            ...statusHistory.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> status = entry.value;
              bool isLast = index == statusHistory.length - 1;
              
              return _buildTimelineItem(
                status['status'],
                status['message'],
                status['timestamp'],
                isLast,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String status, String message, String timestamp, bool isLast) {
    final statusInfo = _getStatusInfo(status);
    final currentStatus = commande!['status'] as String? ?? 'en_attente';
    final isActive = _isStatusActive(status, currentStatus);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? statusInfo['color'] : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusInfo['icon'],
                size: 16,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? Colors.grey[800] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    final plats = commande!['plats'] as List? ?? [];
    
    if (plats.isEmpty) {
      return Container();
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails de la commande',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            ...plats.map((plat) => _buildPlatItem(plat)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatItem(Map<String, dynamic> plat) {
    final prix = plat['prix'] is String 
        ? double.tryParse(plat['prix']) ?? 0.0
        : (plat['prix'] as num?)?.toDouble() ?? 0.0;
    final ingredients = plat['ingredients'] as List? ?? [];
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  plat['base'] ?? 'Plat personnalisé',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Text(
                '${prix.toStringAsFixed(0)} F',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (ingredients.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              'Ingrédients:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ingredients.map((ingredient) => Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ingredient['nom'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'panier':
        return {
          'label': 'Panier',
          'color': Colors.grey,
          'icon': Icons.shopping_cart,
        };
      case 'en_attente':
        return {
          'label': 'En attente',
          'color': Colors.orange,
          'icon': Icons.schedule,
        };
      case 'en_preparation':
        return {
          'label': 'En préparation',
          'color': Colors.blue,
          'icon': Icons.restaurant,
        };
      case 'pret':
        return {
          'label': 'Prêt',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'termine':
        return {
          'label': 'Terminé',
          'color': Colors.grey[600]!,
          'icon': Icons.done_all,
        };
      default:
        return {
          'label': status,
          'color': Colors.grey,
          'icon': Icons.help,
        };
    }
  }

  bool _isStatusActive(String status, String currentStatus) {
    const statusOrder = ['panier', 'en_attente', 'en_preparation', 'pret', 'termine'];
    final statusIndex = statusOrder.indexOf(status);
    final currentIndex = statusOrder.indexOf(currentStatus);
    return statusIndex <= currentIndex;
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}
