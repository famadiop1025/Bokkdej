# 🍽️ BOKDEJ - Application de Commande de Nourriture

Une application moderne de commande de nourriture développée pour les écoles, avec une interface simplifiée et intuitive, incluant une gestion complète des images.

## 🚀 Fonctionnalités

### 📱 Interface Utilisateur
- **Accueil moderne** : Design épuré avec illustration et bouton "Commencer"
- **Menu dynamique** : Catégories fixes (Petit-déjeuner, Déjeuner, Dîner, Snacks, Boissons, Combinaisons)
- **Filtres par catégorie** : Navigation facile entre les types de plats
- **Composition personnalisée** : Création de plats sur mesure avec bases et ingrédients
- **Panier intelligent** : Regroupement automatique des plats identiques avec quantités
- **Historique des commandes** : Suivi des commandes passées avec statuts

### 🖼️ Gestion des Images (Nouveau!)
- **Upload d'images** : Interface intuitive pour uploader des images depuis la galerie ou la caméra
- **Affichage dynamique** : Images des plats dans le menu avec placeholders
- **Gestion par catégorie** : Upload d'images pour plats, ingrédients et bases
- **Interface d'administration** : Page dédiée à la gestion des images avec statistiques
- **Optimisation automatique** : Redimensionnement et compression des images
- **Gestion des erreurs** : Placeholders et messages d'erreur appropriés

### 🛒 Expérience d'Achat
- **Pas de connexion requise** : Commande simplifiée avec numéro de téléphone uniquement
- **Ajout/Suppression** : Boutons +/- directement sur la page menu
- **Quantités groupées** : Affichage "x5" pour 5 plats identiques
- **Calcul automatique** : Prix unitaire × quantité = total par groupe
- **Validation en une étape** : Numéro de téléphone + validation

### 🎨 Design System
- **Couleurs** : Jaune (#FFD700), Noir (#222222), Blanc (#FFFFFF), Gris (#F5F5F5)
- **Interface moderne** : Ombres, coins arrondis, animations fluides
- **Responsive** : Adaptation automatique à différentes tailles d'écran
- **Feedback visuel** : SnackBars, boutons interactifs, états de chargement

## 🛠️ Technologies

### Frontend (Flutter)
- **Framework** : Flutter 3.x
- **State Management** : Provider pattern
- **HTTP Client** : http package
- **Local Storage** : SharedPreferences
- **UI Components** : Material Design 3
- **Image Picker** : image_picker package pour la sélection d'images

### Backend (Django)
- **Framework** : Django 5.2.4
- **API** : Django REST Framework 3.16.0
- **Authentification** : JWT (JSON Web Tokens)
- **Base de données** : SQLite
- **CORS** : django-cors-headers
- **Gestion des médias** : Configuration pour servir les images

## 📦 Installation

### Prérequis
- Python 3.10+
- Flutter 3.x
- Git

### 1. Cloner le projet
```bash
git clone <repository-url>
cd BOKDEJ
```

### 2. Configuration Backend
```bash
# Créer l'environnement virtuel
python -m venv venv

# Activer l'environnement (Windows)
venv\Scripts\activate

# Activer l'environnement (Linux/Mac)
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt

# Configurer la base de données
python manage.py makemigrations
python manage.py migrate

# Ajouter les données de test
python setup_test_data.py

# Lancer le serveur Django
python manage.py runserver
```

### 3. Configuration Frontend
```bash
cd bokkdej_front

# Installer les dépendances Flutter
flutter pub get

# Lancer l'application
flutter run -d chrome --web-port=8081
```

### 4. Lancement automatique
```bash
# Depuis la racine du projet
python run_app.py
```

## 🗄️ Structure des Données

### Modèles Django
```python
# MenuItem - Plats du menu
- nom: Nom du plat
- description: Description détaillée
- prix: Prix en FCFA
- type: Catégorie (petit_dej, dej, diner, snacks, boissons, combinaisons)
- disponible: Statut de disponibilité
- image: ImageField pour les photos des plats

# Ingredient - Ingrédients pour compositions
- nom: Nom de l'ingrédient
- prix: Prix supplémentaire
- disponible: Statut de disponibilité
- image: ImageField pour les photos des ingrédients

# Base - Bases pour compositions personnalisées
- nom: Nom de la base (riz, pain, etc.)
- prix: Prix de base
- description: Description
- disponible: Statut de disponibilité
- image: ImageField pour les photos des bases

# Order - Commandes
- user: Utilisateur (optionnel)
- phone: Numéro de téléphone
- items: Plats commandés
- total: Montant total
- status: Statut de la commande
- created_at: Date de création

# CustomDish - Plats personnalisés
- base: Base choisie
- ingredients: Ingrédients sélectionnés
- user: Utilisateur (optionnel)
- prix_total: Prix calculé
```

## 🎯 Fonctionnalités Détaillées

### Page d'Accueil
- **Design moderne** : Illustration + bouton "Commencer"
- **Plats en vedette** : Affichage des plats populaires
- **Tous les plats** : Grille complète avec filtres
- **Navigation fluide** : Transition vers le menu

### Page Menu
- **Catégories fixes** : 6 catégories prédéfinies
- **Filtres dynamiques** : Sélection par catégorie
- **Ajout direct** : Bouton "Ajouter" puis contrôles +/- 
- **Prix formatés** : Affichage en FCFA
- **Images dynamiques** : Chargement depuis l'API avec placeholders

### Page Composition
- **Bases dynamiques** : Chargement depuis l'API
- **Ingrédients multiples** : Sélection multiple
- **Calcul automatique** : Prix base + ingrédients
- **Ajout au panier** : Intégration avec CartProvider

### Page Panier
- **Regroupement intelligent** : Plats identiques groupés
- **Quantités** : Affichage "x5" pour 5 plats
- **Totaux par groupe** : Prix unitaire × quantité
- **Contrôles +/-** : Modification directe des quantités
- **Champ téléphone** : Saisie du numéro
- **Validation** : Envoi de la commande

### Page Confirmation
- **Récapitulatif détaillé** : Tous les plats commandés
- **Total final** : Montant total de la commande
- **Bouton retour** : Navigation vers l'accueil
- **Design épuré** : Interface de confirmation

### Page Historique
- **Commandes passées** : Liste chronologique
- **Statuts** : En cours, terminée, annulée
- **Détails** : Plats, quantités, prix
- **Design cohérent** : Couleurs du thème

### 🖼️ Gestion des Images (Nouveau!)

#### Interface d'Administration des Images
- **Page dédiée** : Interface complète pour gérer les images
- **Onglets par catégorie** : Plats, ingrédients, bases
- **Statistiques en temps réel** : Taux de complétude des images
- **Upload par élément** : Interface intuitive pour chaque élément
- **Aperçu des images** : Affichage des images actuelles

#### Widgets d'Images
- **ImageUploadWidget** : Upload depuis galerie ou caméra
- **NetworkImageWidget** : Affichage avec placeholders et gestion d'erreurs
- **ImageStatsWidget** : Statistiques et progression
- **GlobalImageStatsWidget** : Vue d'ensemble des images

#### Fonctionnalités d'Upload
- **Sélection multiple** : Galerie ou caméra
- **Optimisation automatique** : Redimensionnement et compression
- **Feedback visuel** : Indicateurs de progression
- **Gestion d'erreurs** : Messages appropriés
- **Callback de succès** : Rafraîchissement automatique

## 🔧 Corrections et Améliorations

### Erreurs Corrigées
- ✅ **RangeError** : Correction des URLs API et gestion des tokens
- ✅ **TypeError** : Conversion explicite des types de données
- ✅ **RenderFlex overflow** : Ajustement des layouts et contraintes
- ✅ **401 Unauthorized** : Suppression de l'authentification obligatoire
- ✅ **NoSuchMethodError** : Gestion robuste des prix (String/double)
- ✅ **IntegrityError** : Modification des modèles pour permettre les commandes sans utilisateur

### Améliorations UI/UX
- ✅ **Design moderne** : Couleurs, ombres, animations
- ✅ **Navigation fluide** : Transitions et callbacks
- ✅ **Feedback utilisateur** : SnackBars et états de chargement
- ✅ **Responsive** : Adaptation aux différentes tailles d'écran
- ✅ **Accessibilité** : Textes lisibles et contrastes appropriés

### Optimisations Techniques
- ✅ **Gestion d'erreurs** : ErrorWidget global et try-catch
- ✅ **Performance** : Chargement dynamique des données
- ✅ **Maintenabilité** : Code structuré et commenté
- ✅ **Sécurité** : Validation des données côté client et serveur

### 🖼️ Nouvelles Fonctionnalités d'Images
- ✅ **Upload d'images** : Interface complète pour plats, ingrédients, bases
- ✅ **Affichage dynamique** : Images dans le menu avec placeholders
- ✅ **Gestion d'erreurs** : Placeholders et messages appropriés
- ✅ **Optimisation** : Redimensionnement et compression automatiques
- ✅ **Statistiques** : Monitoring du taux de complétude des images
- ✅ **Interface admin** : Page dédiée à la gestion des images

## 🧪 Tests

### Tests Backend
```bash
# Test de l'API d'upload d'images
python test_image_upload.py

# Test complet des fonctionnalités d'images
python test_complete_images.py

# Test de connexion PIN
python test_pin_login.py
```

### Tests Frontend
1. **Démarrer l'application** : `flutter run -d chrome --web-port=8081`
2. **Se connecter** : PIN admin `1234`
3. **Tester l'upload** : Aller dans admin → Gestion des images
4. **Vérifier l'affichage** : Retourner au menu pour voir les images

## 🚀 Déploiement

### Production Django
```bash
# Configuration production
DEBUG = False
ALLOWED_HOSTS = ['votre-domaine.com']

# Base de données PostgreSQL
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'bokdej_db',
        'USER': 'user',
        'PASSWORD': 'password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}

# Configuration des médias
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Collecter les fichiers statiques
python manage.py collectstatic

# Gunicorn
gunicorn keur_resto.wsgi:application
```

### Production Flutter
```bash
# Build pour le web
flutter build web

# Build pour Android
flutter build apk --release

# Build pour iOS
flutter build ios --release
```

## 📋 Guides de Test

### Guide de Test des Images
```bash
# Voir le guide complet
cat GUIDE_TEST_IMAGES.md
```

### Guide de Test Complet
```bash
# Voir le guide de test général
cat GUIDE_TEST_COMPLET.md
```

## 🤝 Contribution

### Guidelines
1. **Fork** le projet
2. **Créer** une branche feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** les changements (`git commit -m 'Add AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrir** une Pull Request

### Standards de Code
- **Flutter** : Suivre les conventions Dart
- **Django** : Suivre PEP 8
- **Tests** : Ajouter des tests pour les nouvelles fonctionnalités
- **Documentation** : Commenter le code complexe

## 📞 Support

Pour toute question ou problème :
- **Issues** : Créer une issue sur GitHub
- **Email** : contact@bokdej.com
- **Documentation** : Consulter la documentation technique

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

---

**BOKDEJ** - Simplifiez la commande de nourriture dans votre école ! 🍽️✨📸 
