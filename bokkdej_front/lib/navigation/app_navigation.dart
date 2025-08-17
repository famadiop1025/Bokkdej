import 'package:flutter/material.dart';
import '../home_page.dart';
import '../menu_page.dart';
import '../composer_page.dart';
import '../panier_page.dart';
import '../historique_commandes_page.dart';
import '../admin_dashboard.dart';
import '../selection_restaurant_page.dart';

class AppNavigation {
  static const String home = '/';
  static const String menu = '/menu';
  static const String composer = '/composer';
  static const String panier = '/panier';
  static const String historique = '/historique';
  static const String admin = '/admin';
  static const String restaurantChoice = '/restaurant-choice';

  static Route<dynamic> generateRoute(RouteSettings settings, String token) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => HomePage(token: token),
        );
      case menu:
        return MaterialPageRoute(
          builder: (_) => MenuPage(restaurantId: 0, restaurantName: 'Menu'),
        );
      case composer:
        return MaterialPageRoute(
          builder: (_) => ComposerPage(),
        );
      case panier:
        return MaterialPageRoute(
          builder: (_) => PanierPage(),
        );
      case historique:
        return MaterialPageRoute(
          builder: (_) => HistoriqueCommandesPage(token: token),
        );
      case admin:
        return MaterialPageRoute(
          builder: (_) => AdminDashboard(token: token),
        );
      case restaurantChoice:
        return MaterialPageRoute(
          builder: (_) => SelectionRestaurantPage(token: token),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Page non trouvée: ${settings.name}'),
            ),
          ),
        );
    }
  }
}

class MainNavigation extends StatefulWidget {
  final String token;
  const MainNavigation({Key? key, required this.token}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _showBottomNav = false; // Contrôle l'affichage de la barre de navigation

  void _goToHome() {
    setState(() {
      _currentIndex = 0;
      _showBottomNav = false; // Cacher la barre quand on retourne à l'accueil
    });
  }

  void _showNavigation() {
    setState(() {
      _showBottomNav = true; // Afficher la barre quand l'utilisateur clique sur "Voir le menu"
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(
            token: widget.token,
            onMenuPressed: () {
              setState(() {
                _currentIndex = 1; // Aller au menu
                _showBottomNav = true; // Afficher la barre de navigation
              });
            },
          ),
          MenuPage(restaurantId: 0, restaurantName: 'Menu'),
          ComposerPage(),
          PanierPage(),
          HistoriqueCommandesPage(token: widget.token),
        ],
      ),
      bottomNavigationBar: _showBottomNav ? BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFFD700), // Jaune doré
        unselectedItemColor: const Color(0xFF666666), // Gris foncé
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
      ) : null,
    );
  }
} 