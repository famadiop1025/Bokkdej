import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/base_provider.dart';
import 'providers/order_provider.dart';
import 'menu_page.dart';
import 'composer_page.dart';
import 'panier_page.dart';
import 'historique_commandes_page.dart';
import 'selection_restaurant_page.dart';
import 'staff_login_page.dart';
import 'widgets/enhanced_image.dart';

class HomePage extends StatefulWidget {
  final String token;
  final VoidCallback? onMenuPressed;
  const HomePage({Key? key, required this.token, this.onMenuPressed}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadSelectedRestaurant();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, restaurantProvider, child) {
        if (!restaurantProvider.hasSelectedRestaurant) {
          return _buildNoRestaurantSelected();
        }

        final restaurantInfo = restaurantProvider.restaurantInfo!;
        final themeColor = Color(restaurantInfo['theme_color']);
        final accentColor = Color(restaurantInfo['accent_color']);

    return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5), // Gris clair
          body: Stack(
                  children: [
              // Image de fond du restaurant
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Stack(
                  children: [
                    EnhancedImage(
                      imagePath: restaurantInfo['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      fallbackColor: const Color(0xFFFFD700),
                      fallbackIcon: Icons.restaurant,
                    ),
                    // Overlay sombre
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Section inférieure avec carte
                                    Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.5,
                                      child: Container(
                                        decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5), // Gris clair
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        // Nom du restaurant
                        Text(
                          restaurantInfo['nom'],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700), // Jaune doré
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Description
                        Text(
                          restaurantInfo['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF666666),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Note et spécialité
                        Row(
                          children: [
                            Icon(Icons.star, color: accentColor, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              restaurantInfo['note'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFD700), // Jaune doré
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                restaurantInfo['specialite'],
                                style: TextStyle(
                                  color: const Color(0xFFFFD700), // Jaune doré
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                          ),
                        const SizedBox(height: 32),
                        
                        // Bouton Commencer
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700), // Jaune doré
                              foregroundColor: const Color(0xFF333333), // Gris foncé pour contraste
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 4,
                            ),
                            onPressed: () {
                              // Utiliser le callback pour naviguer vers le menu
                              widget.onMenuPressed?.call();
                            },
                            child: const Text(
                              "Voir le menu",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Bouton Changer de restaurant
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SelectionRestaurantPage(
                                    token: widget.token,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Changer de restaurant',
                              style: TextStyle(
                                color: const Color(0xFFFFD700), // Jaune doré
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Bouton Suivi de commande
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => HistoriqueCommandesPage(
                                    token: widget.token,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.track_changes, color: const Color(0xFFFFD700), size: 18),
                            label: Text(
                              'Suivi de commande',
                              style: TextStyle(
                                color: const Color(0xFFFFD700), // Jaune doré
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Bouton Personnel (accès à l'interface admin)
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => StaffLoginPage(),
                                ),
                              );
                            },
                            icon: Icon(Icons.admin_panel_settings, color: const Color(0xFFFFD700), size: 18),
                            label: Text(
                              'Accès Personnel',
                              style: TextStyle(
                                color: const Color(0xFFFFD700), // Jaune doré
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
            ),
          ],
        ),
        );
      },
    );
  }

  Widget _buildNoRestaurantSelected() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Gris clair
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
      child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Icon(
                Icons.restaurant,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
                Text(
                'Aucun restaurant sélectionné',
                style: TextStyle(
                  fontSize: 20,
                    fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
                Text(
                'Veuillez sélectionner un restaurant pour continuer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SelectionRestaurantPage(
                        onSelected: () {
                          // Recharger le restaurant après la sélection
                          final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
                          restaurantProvider.loadSelectedRestaurant();
                        },
                                ),
                              ),
                            );
                          },
                child: Text('Choisir un restaurant'),
                ),
              ],
            ),
          ),
      ),
    );
  }
}

// Widget de navigation principale (à déplacer si nécessaire)
class MainNavigation extends StatefulWidget {
  final String token;
  const MainNavigation({Key? key, required this.token}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _goToHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider(widget.token)),
        ChangeNotifierProvider(create: (_) => OrderProvider(widget.token)),
        ChangeNotifierProvider(create: (_) => MenuProvider(widget.token)),
        ChangeNotifierProvider(create: (_) => BaseProvider(widget.token)),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomePage(token: widget.token),
            MenuPage(restaurantId: 0, restaurantName: 'Menu'),
            ComposerPage(),
            PanierPage(),
            HistoriqueCommandesPage(token: widget.token),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFFFC107),
          unselectedItemColor: const Color(0xFF222222),
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
            BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Composer'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Panier'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
          ],
        ),
      ),
    );
  }
} 