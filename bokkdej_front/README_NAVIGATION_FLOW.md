# 🧭 Flux de Navigation - Bokk Déj

## 📱 Comportement de la Barre de Navigation

### 🎯 **Règle principale :**
La barre de navigation (BottomNavigationBar) est **cachée** jusqu'à ce que l'utilisateur :
1. ✅ Choisisse un restaurant
2. ✅ Clique sur "Voir le menu"

### 🔄 **Flux de Navigation :**

#### **Étape 1 : Accueil (Barre cachée)**
```
🏠 Page d'accueil
├── Sélection du restaurant (si pas encore fait)
├── Bouton "Voir le menu" 
└── ❌ Pas de barre de navigation
```

#### **Étape 2 : Menu (Barre visible)**
```
🍽️ Page menu
├── Liste des plats
├── Filtres par catégorie
└── ✅ Barre de navigation avec 5 onglets
```

#### **Étape 3 : Navigation complète**
```
📱 Onglets disponibles :
├── 🏠 Accueil (retour à la sélection)
├── 🍽️ Menu (plats du restaurant)
├── 🔧 Composer (plats personnalisés)
├── 🛒 Panier (gestion des commandes)
└── 📋 Historique (suivi des commandes)
```

### 🎨 **Avantages UX :**

#### ✅ **Expérience progressive :**
- L'utilisateur se concentre d'abord sur le choix du restaurant
- Pas de confusion avec trop d'options au début
- Navigation intuitive étape par étape

#### ✅ **Interface épurée :**
- Page d'accueil sans distractions
- Focus sur l'essentiel : choisir où manger
- Barre de navigation apparaît au bon moment

#### ✅ **Logique métier :**
- Impossible de voir le menu sans restaurant
- Impossible d'ajouter au panier sans restaurant
- Flux cohérent avec la logique de l'application

### 🔧 **Implémentation Technique :**

#### **Contrôle de la barre :**
```dart
bool _showBottomNav = false; // État de la barre

// Afficher la barre
void _showNavigation() {
  setState(() {
    _showBottomNav = true;
  });
}

// Cacher la barre
void _hideNavigation() {
  setState(() {
    _showBottomNav = false;
  });
}
```

#### **Condition d'affichage :**
```dart
bottomNavigationBar: _showBottomNav ? BottomNavigationBar(
  // Configuration de la barre
) : null,
```

#### **Callback de navigation :**
```dart
HomePage(
  onMenuPressed: () {
    setState(() {
      _currentIndex = 1; // Aller au menu
      _showBottomNav = true; // Afficher la barre
    });
  },
)
```

### 🚀 **États de l'Application :**

#### **État 1 : Pas de restaurant sélectionné**
- ✅ Page d'accueil visible
- ❌ Barre de navigation cachée
- 🔄 Utilisateur doit choisir un restaurant

#### **État 2 : Restaurant sélectionné, pas encore au menu**
- ✅ Page d'accueil avec restaurant affiché
- ❌ Barre de navigation cachée
- 🔄 Utilisateur doit cliquer sur "Voir le menu"

#### **État 3 : Menu ouvert**
- ✅ Page menu visible
- ✅ Barre de navigation visible
- ✅ Tous les onglets accessibles

### 📋 **Cas d'usage :**

#### **Première visite :**
1. Utilisateur arrive sur l'accueil
2. Choisit un restaurant
3. Clique sur "Voir le menu"
4. Barre de navigation apparaît
5. Peut naviguer entre tous les onglets

#### **Retour à l'accueil :**
1. Utilisateur clique sur "Accueil" dans la barre
2. Retourne à la page d'accueil
3. Barre de navigation se cache
4. Peut changer de restaurant si besoin

#### **Changement de restaurant :**
1. Utilisateur clique sur "Changer de restaurant"
2. Page de sélection s'ouvre
3. Nouveau restaurant sélectionné
4. Retour à l'accueil (barre cachée)
5. Doit cliquer sur "Voir le menu" pour continuer

### 🎯 **Résultat :**

L'application offre maintenant une **expérience utilisateur progressive et intuitive** :

- 🎯 **Focus** : L'utilisateur se concentre sur l'essentiel
- 🚀 **Simplicité** : Interface épurée au démarrage
- 🔄 **Logique** : Navigation qui suit le flux métier
- ✨ **Élégance** : Barre de navigation apparaît au bon moment

Cette approche respecte les principes UX modernes et offre une expérience fluide et cohérente ! 🎉 