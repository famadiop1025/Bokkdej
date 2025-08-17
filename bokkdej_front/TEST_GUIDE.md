# 🚀 Guide de Test - Application BOKDEJ

## 📋 **Prérequis**

### **1. Backend Django**
```bash
# Dans le dossier racine BOKDEJ
cd ..
# Activer l'environnement virtuel
venv\Scripts\Activate.ps1
# Démarrer le serveur Django
python manage.py runserver
```

### **2. Frontend Flutter**
```bash
# Dans le dossier bokkdej_front
flutter run -d chrome --web-port=8080
```

## 🎯 **Scénarios de Test**

### **📱 Test Client (Utilisateur Final)**

#### **1. Navigation Principale**
- [ ] **Page d'accueil** : Vérifier l'affichage du logo et des boutons
- [ ] **"Choisir un restaurant"** : Navigation vers la sélection
- [ ] **"Voir le Menu"** : Navigation directe vers le menu

#### **2. Sélection de Restaurant**
- [ ] **Liste des restaurants** : Affichage des restaurants disponibles
- [ ] **Sélection** : Cliquer sur un restaurant et vérifier la navigation
- [ ] **Feedback visuel** : Message de confirmation après sélection

#### **3. Menu et Commandes**
- [ ] **Affichage du menu** : Vérifier les catégories et plats
- [ ] **Filtres** : Tester les filtres par catégorie
- [ ] **Ajout au panier** : Ajouter des plats et vérifier l'incrémentation
- [ ] **Icône panier** : Navigation vers le panier depuis le menu

#### **4. Composition de Plat**
- [ ] **Sélection de base** : Choisir une base (Pain, Riz, etc.)
- [ ] **Ajout d'ingrédients** : Sélectionner plusieurs ingrédients
- [ ] **Calcul du prix** : Vérifier le calcul automatique
- [ ] **Ajout au panier** : Tester l'ajout du plat personnalisé

#### **5. Panier**
- [ ] **Affichage des articles** : Vérifier la liste des plats
- [ ] **Incrémentation/Décrémentation** : Tester les boutons + et -
- [ ] **Calcul du total** : Vérifier le calcul correct
- [ ] **Validation de commande** : Tester la finalisation

#### **6. Suivi de Commande**
- [ ] **Page de suivi** : Vérifier l'affichage des commandes actives
- [ ] **Actualisation** : Tester l'actualisation automatique
- [ ] **Statuts visuels** : Vérifier les couleurs et icônes

#### **7. Historique**
- [ ] **Liste des commandes** : Vérifier l'affichage des commandes passées
- [ ] **Détails** : Tester l'affichage des détails de commande

### **👨‍💼 Test Personnel (Administration)**

#### **1. Accès Personnel**
- [ ] **Page de connexion** : Vérifier l'interface de login
- [ ] **Connexion par PIN** : Tester avec un PIN valide
- [ ] **Connexion par identifiants** : Tester avec username/password

#### **2. Interface d'Administration**
- [ ] **Dashboard** : Vérifier l'affichage des statistiques
- [ ] **Gestion des commandes** : Tester la vue des commandes
- [ ] **Gestion du menu** : Tester l'ajout/modification de plats
- [ ] **Gestion des ingrédients** : Tester l'ajout/modification d'ingrédients

## 🔧 **Données de Test**

### **PINs de Test**
```
Admin: 1234
Staff: 5678
```

### **Identifiants de Test**
```
Admin: admin / admin123
Staff: staff / staff123
```

## 🐛 **Points de Vérification**

### **✅ Fonctionnalités Critiques**
- [ ] **Navigation fluide** entre toutes les pages
- [ ] **Icônes fonctionnelles** (Home, Menu, Panier, etc.)
- [ ] **Calculs corrects** des prix
- [ ] **Persistance des données** (panier, commandes)
- [ ] **Responsive design** sur différentes tailles d'écran

### **✅ Interface Utilisateur**
- [ ] **Couleurs cohérentes** (jaune doré, noir, blanc)
- [ ] **Boutons accessibles** (taille suffisante)
- [ ] **Feedback visuel** (SnackBars, animations)
- [ ] **Messages d'erreur** clairs et informatifs

### **✅ Performance**
- [ ] **Chargement rapide** des pages
- [ ] **Actualisation fluide** des données
- [ ] **Pas de blocage** lors des interactions

## 🚨 **Problèmes Courants**

### **1. Erreurs de Connexion**
- Vérifier que le serveur Django est démarré
- Vérifier l'URL de l'API dans `getApiBaseUrl()`

### **2. Erreurs de Navigation**
- Vérifier les imports des pages
- Vérifier les paramètres requis (token, etc.)

### **3. Erreurs d'Affichage**
- Vérifier les données reçues de l'API
- Vérifier les conditions d'affichage

## 📊 **Métriques de Test**

### **Temps de Réponse**
- [ ] **Page d'accueil** : < 2 secondes
- [ ] **Chargement du menu** : < 3 secondes
- [ ] **Ajout au panier** : < 1 seconde
- [ ] **Validation de commande** : < 2 secondes

### **Taux de Succès**
- [ ] **Navigation** : 100%
- [ ] **Ajout au panier** : 100%
- [ ] **Validation de commande** : 100%
- [ ] **Connexion admin** : 100%

## 🎉 **Validation Finale**

L'application est prête si :
- ✅ Tous les scénarios de test passent
- ✅ Aucune erreur dans la console
- ✅ Interface fluide et intuitive
- ✅ Fonctionnalités complètes opérationnelles

---

**Date de test** : [Date]
**Testeur** : [Nom]
**Version** : 1.0.0 