# 🧪 Guide de Test Complet - Application BOKDEJ

## 📋 Prérequis

### Serveurs en cours d'exécution
```bash
# Terminal 1 - Backend Django
cd BOKDEJ
python manage.py runserver

# Terminal 2 - Frontend Flutter
cd BOKDEJ/bokkdej_front
flutter run -d chrome --web-port=8080
```

### Utilisateurs de Test Créés
- **Admin**: `fama` / `admin123` (PIN: 1234)
- **Staff**: `staff` / `staff123` (PIN: 5678)

---

## 🎯 Tests Client (Frontend)

### 1. Page d'Accueil
- [ ] **Bouton "Choisir un restaurant"** → Redirige vers `RestaurantChoicePage`
- [ ] **Bouton "Voir le Menu"** → Redirige vers `MainNavigation`
- [ ] **Interface accessible** → Boutons grands et lisibles

### 2. Sélection de Restaurant
- [ ] **Clic sur restaurant** → Affiche SnackBar de confirmation
- [ ] **Navigation automatique** → Redirige vers `MainNavigation`
- [ ] **Images des restaurants** → S'affichent correctement

### 3. Navigation Principale
- [ ] **Icône Home** → Fonctionne dans toutes les pages
- [ ] **Icône Menu** → Redirige vers `MenuPage`
- [ ] **Icône Panier** → Redirige vers `PanierPage`
- [ ] **Icône Historique** → Redirige vers `HistoriquePage`

### 4. Page Menu
- [ ] **Filtres par catégorie** → Fonctionnent correctement
- [ ] **Ajout au panier** → Incrémente la quantité
- [ ] **Bouton "Créer mon plat"** → Redirige vers `ComposerPage`
- [ ] **Interface accessible** → Boutons grands et lisibles

### 5. Composer un Plat
- [ ] **Sélection de base** → Fonctionne
- [ ] **Sélection d'ingrédients** → Fonctionne
- [ ] **Calcul du prix** → Correct
- [ ] **Ajout au panier** → Fonctionne avec SnackBar
- [ ] **Navigation vers panier** → Fonctionne

### 6. Panier
- [ ] **Boutons +/-** → Incrémentent/décrémentent correctement
- [ ] **Calcul du total** → Correct
- [ ] **Bouton "Voir le menu"** → Redirige vers `MenuPage`
- [ ] **Bouton "Suivi commande"** → Redirige vers `OrderTrackingPage`
- [ ] **Validation de commande** → Fonctionne
- [ ] **Panier vide** → Affiche "Suivi commande" uniquement

### 7. Suivi de Commande
- [ ] **Liste des commandes actives** → S'affiche
- [ ] **Statuts des commandes** → Avec icônes et couleurs
- [ ] **Actualisation automatique** → Toutes les 30 secondes
- [ ] **Navigation Home** → Fonctionne

### 8. Historique
- [ ] **Liste des commandes passées** → S'affiche
- [ ] **Détails des commandes** → Visibles
- [ ] **Navigation Home** → Fonctionne

---

## 🔧 Tests Staff (Backend + Frontend)

### 1. Connexion PIN
- [ ] **PIN Admin (1234)** → Connexion réussie
- [ ] **PIN Staff (5678)** → Connexion réussie
- [ ] **PIN incorrect** → Message d'erreur
- [ ] **Token JWT** → Généré correctement

### 2. Gestion des Commandes
- [ ] **Voir les commandes** → Liste complète
- [ ] **Changer le statut** → Fonctionne
- [ ] **Notifications FCM** → Envoyées lors du changement
- [ ] **Interface admin** → Accessible

### 3. Gestion des Plats
- [ ] **Ajouter un plat** → Fonctionne
- [ ] **Modifier un plat** → Fonctionne
- [ ] **Supprimer un plat** → Fonctionne
- [ ] **Gestion des prix** → Correcte

### 4. Gestion des Ingrédients
- [ ] **Ajouter un ingrédient** → Fonctionne
- [ ] **Modifier un ingrédient** → Fonctionne
- [ ] **Supprimer un ingrédient** → Fonctionne
- [ ] **Gestion des prix** → Correcte

### 5. Gestion des Bases
- [ ] **Ajouter une base** → Fonctionne
- [ ] **Modifier une base** → Fonctionne
- [ ] **Supprimer une base** → Fonctionne
- [ ] **Gestion des prix** → Correcte

---

## 🧪 Tests API (Backend)

### 1. Authentification
```bash
# Test PIN Login
curl -X POST http://localhost:8000/api/auth/pin-login/ \
  -H "Content-Type: application/json" \
  -d '{"pin": "1234"}'
```

### 2. Commandes
```bash
# Lister les commandes
curl -X GET http://localhost:8000/api/orders/ \
  -H "Authorization: Bearer <token>"

# Mettre à jour le statut
curl -X POST http://localhost:8000/api/orders/<id>/update_status/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"status": "en_attente"}'
```

### 3. Menu
```bash
# Lister les plats
curl -X GET http://localhost:8000/api/menu/

# Lister les ingrédients
curl -X GET http://localhost:8000/api/ingredients/

# Lister les bases
curl -X GET http://localhost:8000/api/bases/
```

---

## 🐛 Tests de Robustesse

### 1. Gestion des Erreurs
- [ ] **Connexion échouée** → Message d'erreur clair
- [ ] **Réseau indisponible** → Message d'erreur
- [ ] **Données manquantes** → Gestion gracieuse
- [ ] **Types de données** → Parsing robuste

### 2. Performance
- [ ] **Chargement des pages** → Rapide
- [ ] **Actualisation du suivi** → Fluide
- [ ] **Calculs de prix** → Corrects
- [ ] **Navigation** → Fluide

### 3. Accessibilité
- [ ] **Boutons grands** → Faciles à toucher
- [ ] **Texte lisible** → Taille appropriée
- [ ] **Contraste** → Suffisant
- [ ] **Navigation intuitive** → Logique

---

## 📱 Tests Spécifiques Flutter

### 1. État de l'Application
- [ ] **Provider Cart** → État cohérent
- [ ] **Provider Menu** → Données à jour
- [ ] **Provider Auth** → Token valide
- [ ] **Cache local** → Fonctionne

### 2. Navigation
- [ ] **Stack de navigation** → Propre
- [ ] **Retour arrière** → Fonctionne
- [ ] **Redirection** → Correcte
- [ ] **Paramètres** → Passés correctement

### 3. UI/UX
- [ ] **Responsive** → S'adapte à la taille
- [ ] **Animations** → Fluides
- [ ] **Feedback utilisateur** → SnackBar, etc.
- [ ] **Chargement** → Indicateurs visuels

---

## 🔍 Checklist de Validation

### ✅ Fonctionnalités Principales
- [ ] Création de compte utilisateur
- [ ] Connexion PIN pour staff
- [ ] Sélection de restaurant
- [ ] Consultation du menu
- [ ] Composition de plats personnalisés
- [ ] Gestion du panier (ajout/suppression)
- [ ] Validation de commande
- [ ] Suivi en temps réel
- [ ] Historique des commandes
- [ ] Gestion admin des commandes
- [ ] Gestion admin du menu

### ✅ Interface Utilisateur
- [ ] Design accessible et intuitif
- [ ] Navigation fluide
- [ ] Boutons grands et lisibles
- [ ] Feedback utilisateur approprié
- [ ] Gestion des erreurs gracieuse

### ✅ Backend
- [ ] API REST fonctionnelle
- [ ] Authentification JWT
- [ ] Base de données SQLite
- [ ] Notifications push FCM
- [ ] Gestion des statuts de commande

---

## 🚀 Démarrage Rapide

1. **Démarrer les serveurs** :
   ```bash
   # Terminal 1
   cd BOKDEJ
   python manage.py runserver
   
   # Terminal 2
   cd BOKDEJ/bokkdej_front
   flutter run -d chrome --web-port=8080
   ```

2. **Tester l'application** :
   - Ouvrir http://localhost:8080
   - Suivre le guide de test ci-dessus

3. **Tester les APIs** :
   - Utiliser les commandes curl fournies
   - Vérifier les réponses JSON

4. **Tester l'accès staff** :
   - Utiliser les PINs : 1234 (admin) ou 5678 (staff)
   - Vérifier les fonctionnalités admin

---

## 📞 Support

En cas de problème :
1. Vérifier les logs des serveurs
2. Contrôler la base de données
3. Tester les APIs individuellement
4. Vérifier la configuration réseau

**Application BOKDEJ - Système de commande de restauration** 🍽️ 