# 🚀 Démarrage Rapide - Gestion des Images BOKDEJ

## ⚡ Test Rapide (5 minutes)

### 1. **Démarrer les serveurs**
```bash
# Terminal 1 - Backend Django
cd BOKDEJ
python manage.py runserver

# Terminal 2 - Frontend Flutter
cd BOKDEJ/bokkdej_front
flutter run -d chrome --web-port=8081
```

### 2. **Tester l'upload d'images**
1. Ouvrir http://localhost:8081
2. Se connecter avec PIN admin : `1234`
3. Aller dans la section admin
4. Éditer un plat existant
5. Utiliser le widget d'upload d'image
6. Sélectionner une image depuis la galerie
7. Uploader l'image
8. Vérifier le message de succès

### 3. **Vérifier l'affichage**
1. Retourner au menu principal
2. Vérifier que l'image s'affiche dans la carte du plat
3. Tester avec différents navigateurs

## 🧪 Tests Automatisés

### Test Backend
```bash
# Test de l'API d'upload
python test_image_upload.py

# Test complet des fonctionnalités
python test_complete_images.py
```

### Test Frontend
1. Ouvrir l'application Flutter
2. Se connecter avec PIN `1234`
3. Aller dans admin → Gestion des images
4. Tester l'upload pour différents types (plats, ingrédients, bases)

## 📱 Fonctionnalités Testées

### ✅ Upload d'Images
- [ ] Sélection depuis la galerie
- [ ] Prise de photo avec la caméra
- [ ] Aperçu avant upload
- [ ] Indicateur de progression
- [ ] Messages de succès/erreur

### ✅ Affichage d'Images
- [ ] Images dans le menu des plats
- [ ] Placeholders pour images manquantes
- [ ] Indicateur de chargement
- [ ] Gestion des erreurs de chargement

### ✅ Interface d'Administration
- [ ] Page de gestion des images
- [ ] Onglets par catégorie
- [ ] Statistiques en temps réel
- [ ] Upload par élément

## 🔧 Configuration

### Backend Django
- ✅ Modèles avec champs image
- ✅ Endpoint d'upload : `/api/upload-image/`
- ✅ Configuration des médias
- ✅ Migrations appliquées

### Frontend Flutter
- ✅ Widget `ImageUploadWidget`
- ✅ Widget `NetworkImageWidget`
- ✅ Intégration dans le menu
- ✅ Interface d'administration

## 📊 Statistiques

### Éléments avec Images
- **Plats du menu** : X/Y (Z%)
- **Ingrédients** : X/Y (Z%)
- **Bases** : X/Y (Z%)
- **Total** : X/Y (Z%)

### Accessibilité
- **Images accessibles** : X/Y
- **Images manquantes** : X
- **Taux de complétude** : Z%

## 🐛 Problèmes Courants

### Images ne s'affichent pas
```bash
# Vérifier que le serveur Django fonctionne
curl http://localhost:8000/api/menu/

# Vérifier les permissions
ls -la media/
```

### Upload échoue
```bash
# Vérifier les logs Django
python manage.py runserver

# Tester l'API directement
python test_image_upload.py
```

### Erreurs Flutter
```bash
# Vérifier les dépendances
cd bokkdej_front
flutter pub get

# Vérifier la configuration
flutter doctor
```

## 📞 Support

### En cas de problème :
1. **Vérifier les serveurs** : Django et Flutter en cours d'exécution
2. **Consulter les logs** : Console Flutter et logs Django
3. **Tester l'API** : Utiliser les scripts de test
4. **Vérifier les permissions** : Accès aux fichiers et médias

### Guides détaillés :
- `GUIDE_TEST_IMAGES.md` - Guide complet des tests
- `GUIDE_TEST_COMPLET.md` - Guide de test général
- `README.md` - Documentation complète

---

**BOKDEJ Images** - Testez rapidement la gestion des images ! 📸⚡ 