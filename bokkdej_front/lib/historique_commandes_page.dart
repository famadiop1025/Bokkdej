import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'suivi_commande_page.dart';
import 'constants/app_colors.dart';

class HistoriqueCommandesPage extends StatefulWidget {
  final String? token;
  final String? phone;
  
  const HistoriqueCommandesPage({
    Key? key, 
    this.token, 
    this.phone
  }) : super(key: key);

  @override
  State<HistoriqueCommandesPage> createState() => _HistoriqueCommandesPageState();
}

class _HistoriqueCommandesPageState extends State<HistoriqueCommandesPage> {
  List<Map<String, dynamic>> commandes = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String url = 'http://localhost:8000/api/orders/historique/';
      
      if (widget.token != null) {
        headers['Authorization'] = 'Bearer ${widget.token}';
      } else if (widget.phone != null) {
        url += '?phone=${widget.phone}';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          commandes = List<Map<String, dynamic>>.from(data['orders'] ?? []);
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
          'Historique des Commandes',
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
            onPressed: _loadHistorique,
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
              'Chargement de l\'historique...',
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
                onPressed: _loadHistorique,
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

    if (commandes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Aucune commande trouvée',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Vos commandes passées apparaîtront ici',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistorique,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: commandes.length,
        itemBuilder: (context, index) {
          final commande = commandes[index];
          return _buildCommandeCard(commande);
        },
      ),
    );
  }

  Widget _buildCommandeCard(Map<String, dynamic> commande) {
    final status = commande['status'] as String? ?? 'en_attente';
    final statusInfo = _getStatusInfo(status);
    final prixTotal = commande['prix_total'] is String 
        ? double.tryParse(commande['prix_total']) ?? 0.0
        : (commande['prix_total'] as num?)?.toDouble() ?? 0.0;
    
    final plats = commande['plats'] as List? ?? [];
    final createdAt = commande['created_at'] as String?;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _voirSuivi(commande),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec numéro et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commande #${commande['id']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        SizedBox(width: 4),
                        Text(
                          statusInfo['label'],
                          style: TextStyle(
                            color: statusInfo['color'],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Informations de la commande
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Prix total
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    '${prixTotal.toStringAsFixed(0)} F CFA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Résumé des plats
              if (plats.isNotEmpty) ...[
                Text(
                  'Plats commandés:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                ...plats.take(2).map((plat) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plat['base'] ?? 'Plat personnalisé',
                          style: TextStyle(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                if (plats.length > 2)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '... et ${plats.length - 2} autre(s) plat(s)',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
              
              SizedBox(height: 16),
              
              // Bouton d'action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _voirSuivi(commande),
                  icon: Icon(Icons.visibility),
                  label: Text('Voir le suivi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date inconnue';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Aujourd\'hui à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Hier à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Date invalide';
    }
  }

  void _voirSuivi(Map<String, dynamic> commande) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuiviCommandePage(
          commandeId: commande['id'],
          token: widget.token,
          phone: widget.phone,
        ),
      ),
    );
  }
}
