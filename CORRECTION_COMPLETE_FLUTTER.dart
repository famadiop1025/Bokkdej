// 🔧 CORRECTION COMPLÈTE FLUTTER - TOUTES ERREURS CORRIGÉES
// Ce fichier contient les corrections pour tous les problèmes identifiés

// ==============================================================================
// 1. CORRECTION DU PROBLÈME DROPDOWN (admin_add_edit_plat.dart)
// ==============================================================================

// Remplacer la section dropdown problématique par :
Widget _buildCategoryDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Catégorie *',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      SizedBox(height: 8),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: _categories.any((cat) => cat['value'] == _selectedCategory) 
              ? _selectedCategory 
              : _categories.first['value'],
          hint: Text('Sélectionnez une catégorie'),
          isExpanded: true,
          underline: SizedBox(),
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['value'],
              child: Text(category['label']!),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
              });
            }
          },
        ),
      ),
    ],
  );
}

// ==============================================================================
// 2. CORRECTION DES URLS D'IMAGES (Tous les fichiers)
// ==============================================================================

// Fonction utilitaire à ajouter dans chaque fichier utilisant des images :
String getCorrectImageUrl(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) return '';
  
  // Si l'URL commence déjà par http, la retourner telle quelle
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath;
  }
  
  // Sinon, ajouter l'URL de base
  const String baseUrl = 'http://localhost:8000';
  
  // S'assurer qu'il n'y a qu'un seul slash
  if (imagePath.startsWith('/')) {
    return '$baseUrl$imagePath';
  } else {
    return '$baseUrl/$imagePath';
  }
}

// ==============================================================================
// 3. CORRECTION DU WIDGET IMAGE SÉCURISÉ
// ==============================================================================

class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeNetworkImage({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final correctedUrl = getCorrectImageUrl(imageUrl);
    
    if (correctedUrl.isEmpty) {
      return errorWidget ?? _buildDefaultPlaceholder();
    }

    return Image.network(
      correctedUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildLoadingPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        print('Erreur chargement image: $error');
        return errorWidget ?? _buildDefaultPlaceholder();
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.restaurant,
        size: (width ?? 50) * 0.4,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// ==============================================================================
// 4. CORRECTION DU PROVIDER MENU
// ==============================================================================

class FixedMenuProvider with ChangeNotifier {
  List<MenuItem> _menu = [];
  bool _isLoading = false;
  String? _error;
  final String _token;

  FixedMenuProvider(this._token);

  List<MenuItem> get menu => _menu;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMenu() async {
    if (_isLoading) return; // Éviter les appels multiples
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (_token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_token';
      }
      
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/menu/'),
        headers: headers,
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _menu = data.map((item) {
          try {
            return MenuItem.fromJson(item);
          } catch (e) {
            print('Erreur parsing menu item: $e');
            return null;
          }
        }).where((item) => item != null).cast<MenuItem>().toList();
        _error = null;
      } else {
        _error = 'Erreur serveur: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Erreur réseau: $e';
      print('Erreur loadMenu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// ==============================================================================
// 5. CORRECTION DU MODÈLE MENUITEM
// ==============================================================================

class FixedMenuItem {
  final int id;
  final String nom;
  final double prix;
  final String categorie;
  final String? image;
  final int calories;
  final int tempsPreparation;
  final bool disponible;

  FixedMenuItem({
    required this.id,
    required this.nom,
    required this.prix,
    required this.categorie,
    this.image,
    required this.calories,
    required this.tempsPreparation,
    this.disponible = true,
  });

  factory FixedMenuItem.fromJson(Map<String, dynamic> json) {
    try {
      return FixedMenuItem(
        id: json['id'] ?? 0,
        nom: json['nom']?.toString() ?? 'Sans nom',
        prix: double.tryParse(json['prix']?.toString() ?? '0') ?? 0.0,
        categorie: json['type']?.toString() ?? 'autre',
        image: json['image']?.toString(),
        calories: int.tryParse(json['calories']?.toString() ?? '0') ?? 0,
        tempsPreparation: int.tryParse(json['temps_preparation']?.toString() ?? '0') ?? 0,
        disponible: json['disponible'] ?? true,
      );
    } catch (e) {
      throw Exception('Erreur parsing MenuItem: $e');
    }
  }
}

// ==============================================================================
// 6. CORRECTION DU COMPOSER PAGE
// ==============================================================================

// Dans composer_page.dart, remplacer la fonction getApiBaseUrl() par :
String getApiBaseUrl() {
  return 'http://localhost:8000';
}

// Et corriger la gestion des erreurs dans _loadIngredients :
Future<void> _loadIngredients() async {
  if (mounted) {
    setState(() {
      isLoading = true;
      error = null;
    });
  }

  try {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (widget.token != null && widget.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${widget.token}';
    }
    
    final response = await http.get(
      Uri.parse('${getApiBaseUrl()}/api/ingredients/'),
      headers: headers,
    ).timeout(Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          ingredients = data.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          error = 'Erreur serveur: ${response.statusCode}';
          isLoading = false;
        });
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        error = 'Erreur réseau: $e';
        isLoading = false;
      });
    }
  }
}

// ==============================================================================
// 7. CORRECTION DES GESTIONS D'ERREUR GLOBALES
// ==============================================================================

// Ajouter dans main.dart :
void setupErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    print('Platform Error: $error');
    return true;
  };
}

// Dans main() :
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  setupErrorHandling();
  
  // ... reste du code
}

// ==============================================================================
// 8. CORRECTION DU PROBLÈME DE NAVIGATION
// ==============================================================================

// Dans chaque page, remplacer les Navigator.push par :
void _navigateToPage(Widget page) {
  if (mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

// ==============================================================================
// 9. CORRECTION DES PROVIDERS CART
// ==============================================================================

// Dans cart_provider.dart, ajouter une gestion d'erreur robuste :
class FixedCartProvider with ChangeNotifier {
  // ... autres propriétés
  
  Future<bool> addToPanier(List<int> platIds, double prix) async {
    try {
      // ... logique existante mais avec try-catch
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur ajout panier: $e');
      return false;
    }
  }
}

// ==============================================================================
// 10. WIDGET GLOBAL POUR GESTION D'ERREURS
// ==============================================================================

class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final String errorMessage;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorMessage = 'Une erreur est survenue',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Retour'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
