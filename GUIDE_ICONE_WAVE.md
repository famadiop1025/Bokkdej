# 🌊 Guide d'Utilisation de l'Icône Wave

## 📋 Vue d'ensemble

L'icône Wave a été intégrée dans l'application Flutter pour améliorer l'expérience utilisateur lors des paiements. Elle est disponible dans plusieurs tailles et couleurs.

## 🎨 Composants Disponibles

### 1. **WaveIcon**
Icône Wave simple personnalisable.

```dart
WaveIcon(
  size: 24.0,           // Taille de l'icône
  color: Colors.blue,   // Couleur de l'icône
)
```

### 2. **WaveLogo**
Logo Wave avec texte optionnel.

```dart
WaveLogo(
  iconSize: 24.0,       // Taille de l'icône
  fontSize: 14.0,       // Taille du texte
  color: Colors.blue,   // Couleur
  showText: true,       // Afficher le texte "Wave"
)
```

## 🎯 Utilisations dans l'Application

### 1. **Bouton de Paiement Wave**
```dart
// Dans wave_payment_button.dart
WaveIcon(size: 24, color: Colors.white)
```

### 2. **Page de Paiement**
```dart
// Dans payment_page.dart
WaveIcon(size: 28, color: Colors.white)
```

### 3. **Page du Panier**
```dart
// Dans cart_page_with_wave.dart
WaveIcon(size: 20, color: Colors.white)
```

## 🎨 Couleurs Recommandées

### Couleurs Principales
- **Bleu Wave**: `Color(0xFF0066CC)` - Couleur officielle Wave
- **Vert Wave**: `Color(0xFF00D4AA)` - Couleur secondaire Wave
- **Blanc**: `Colors.white` - Pour les boutons sombres
- **Noir**: `Colors.black` - Pour les fonds clairs

### Exemples d'Utilisation
```dart
// Bouton principal
WaveIcon(size: 24, color: Color(0xFF00D4AA))

// Icône d'information
WaveIcon(size: 20, color: Color(0xFF0066CC))

// Icône sur fond sombre
WaveIcon(size: 24, color: Colors.white)
```

## 📏 Tailles Recommandées

| Contexte | Taille | Utilisation |
|----------|--------|-------------|
| Boutons | 20-24px | Boutons de paiement |
| En-têtes | 28-32px | Titres de pages |
| Cartes | 24-32px | Informations de paiement |
| Listes | 16-20px | Éléments de liste |

## 🔧 Personnalisation

### Créer une Icône Personnalisée
```dart
class CustomWaveIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: WaveIcon(
        size: 24,
        color: Colors.blue,
      ),
    );
  }
}
```

### Animation de l'Icône
```dart
class AnimatedWaveIcon extends StatefulWidget {
  @override
  _AnimatedWaveIconState createState() => _AnimatedWaveIconState();
}

class _AnimatedWaveIconState extends State<AnimatedWaveIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: WaveIcon(size: 24, color: Colors.blue),
        );
      },
    );
  }
}
```

## 📱 Responsive Design

### Adaptation aux Tailles d'Écran
```dart
class ResponsiveWaveIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth > 600 ? 32.0 : 24.0;
    
    return WaveIcon(
      size: iconSize,
      color: Color(0xFF0066CC),
    );
  }
}
```

## 🎯 Bonnes Pratiques

### 1. **Cohérence**
- Utilisez toujours la même couleur pour les éléments Wave
- Respectez les tailles recommandées selon le contexte

### 2. **Accessibilité**
- Assurez-vous que l'icône est visible sur tous les fonds
- Utilisez des couleurs contrastées

### 3. **Performance**
- L'icône est dessinée avec CustomPainter pour de meilleures performances
- Pas besoin d'images externes

## 🧪 Test de l'Icône

Pour tester l'icône Wave, utilisez le widget de démonstration :

```dart
// Ajoutez cette route dans votre app
MaterialPageRoute(
  builder: (context) => WaveIconDemo(),
)
```

## 📁 Fichiers Concernés

- `lib/widgets/wave_icon.dart` - Composant principal
- `lib/widgets/wave_icon_demo.dart` - Démonstration
- `lib/widgets/wave_payment_button.dart` - Bouton de paiement
- `lib/pages/payment_page.dart` - Page de paiement
- `lib/pages/cart_page_with_wave.dart` - Page du panier

## 🚀 Prochaines Étapes

1. **Tests** - Tester l'icône sur différents appareils
2. **Animations** - Ajouter des animations pour les interactions
3. **Thèmes** - Adapter aux thèmes sombre/clair
4. **Accessibilité** - Améliorer l'accessibilité

---

*L'icône Wave est maintenant intégrée dans toute l'application pour une expérience utilisateur cohérente et professionnelle.* 🌊
