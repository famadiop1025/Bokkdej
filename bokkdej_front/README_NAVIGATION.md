# 🧭 Navigation de l'Application Bokk Déj

## 📁 Structure de Navigation

### 🏗️ Architecture Centralisée

L'application utilise maintenant une navigation centralisée pour éviter les incohérences :

```
lib/
├── navigation/
│   └── app_navigation.dart     # Navigation centralisée
├── theme/
│   └── app_theme.dart          # Thème global
├── constants/
│   └── app_colors.dart         # Couleurs centralisées
├── main.dart                   # Point d'entrée
└── [pages]                     # Pages de l'application
```

### 🎯 Navigation Principale

L'application utilise `MainNavigation` avec `IndexedStack` et `BottomNavigationBar` :

#### 📱 Onglets de Navigation :
1. **Accueil** (`index: 0`) - Page d'accueil avec sélection de restaurant
2. **Menu** (`index: 1`) - Liste des plats disponibles
3. **Composer** (`index: 2`) - Création de plats personnalisés
4. **Panier** (`index: 3`) - Gestion du panier et validation
5. **Historique** (`index: 4`) - Suivi des commandes

### 🎨 Thème Centralisé

#### 🌈 Couleurs Principales :
- **Jaune doré** (`#FFD700`) - Couleur principale
- **Gris clair** (`#F5F5F5`) - Fond de l'application
- **Noir** (`#222222`) - Texte principal
- **Gris foncé** (`#666666`) - Texte secondaire

#### 🎯 Avantages :
- ✅ **Cohérence** : Même thème partout
- ✅ **Maintenance** : Changements centralisés
- ✅ **Performance** : Navigation fluide avec IndexedStack
- ✅ **UX** : Navigation intuitive avec BottomNavigationBar

### 🔧 Utilisation

#### Dans les pages :
```dart
// Navigation vers l'accueil
onHomePressed?.call();

// Navigation vers une page spécifique
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => MainNavigation(token: token),
  ),
);
```

#### Thème automatique :
```dart
// Les couleurs sont automatiquement appliquées
AppColors.primary    // Jaune doré
AppColors.background // Gris clair
AppColors.textPrimary // Noir
```

### 🚀 Fonctionnalités

#### ✅ Navigation Fluide :
- Changement d'onglet instantané
- État préservé entre les pages
- Pas de rechargement inutile

#### ✅ Design Cohérent :
- Même palette de couleurs
- Même style de boutons
- Même typographie

#### ✅ Gestion d'État :
- Providers centralisés
- État partagé entre les pages
- Persistance des données

### 🔄 Workflow Utilisateur

1. **Accueil** → Sélection du restaurant
2. **Menu** → Choix des plats
3. **Composer** → Création personnalisée
4. **Panier** → Validation de commande
5. **Historique** → Suivi des commandes

### 🎯 Résolution des Incohérences

#### ❌ Avant :
- Pages indépendantes
- Couleurs différentes
- Navigation incohérente

#### ✅ Maintenant :
- Navigation centralisée
- Thème unifié
- Expérience cohérente

### 📱 Responsive Design

L'application s'adapte automatiquement :
- **Mobile** : BottomNavigationBar
- **Tablet** : Navigation adaptée
- **Desktop** : Interface optimisée

### 🔧 Maintenance

Pour modifier la navigation :
1. Éditer `app_navigation.dart`
2. Modifier les couleurs dans `app_colors.dart`
3. Ajuster le thème dans `app_theme.dart`

Tous les changements sont automatiquement appliqués à toute l'application ! 