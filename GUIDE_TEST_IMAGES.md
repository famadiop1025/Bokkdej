# 📸 Guide de Test - Gestion des Images Flutter

## 🎯 Vue d'ensemble

Ce guide vous aide à tester la gestion complète des images dans l'application BOKDEJ Flutter.

## ✅ Prérequis

### 1. **Serveurs en cours d'exécution**
```bash
# Terminal 1 - Backend Django
cd BOKDEJ
python manage.py runserver

# Terminal 2 - Frontend Flutter
cd BOKDEJ/bokkdej_front
flutter run -d chrome --web-port=8081
```

### 2. **Dépendances installées**
```bash
# Vérifier que image_picker est installé
cd bokkdej_front
flutter pub get
```

## 🧪 Tests Backend

### 1. **Test de l'API d'Upload**
```bash
# Tester l'upload d'images
python test_image_upload.py
```

**Résultat attendu :**
```
✅ Upload d'image pour plat réussi!
✅ Upload d'image pour base réussi!
```

### 2. **Test de l'API Menu**
```bash
# Vérifier que les images sont dans la réponse
curl http://localhost:8000/api/menu/
```

## 📱 Tests Flutter

### 1. **Test de Connexion**
1. Ouvrir http://localhost:8081
2. Se connecter avec le PIN admin : `1234`
3. Vérifier que la connexion réussit

### 2. **Test d'Affichage des Images**

#### **Page du Menu**
1. Aller dans la section "Menu"
2. Vérifier que les images des plats s'affichent
3. Vérifier les placeholders pour les plats sans image
4. Tester le chargement des images

**Points à vérifier :**
- [ ] Images des plats s'affichent correctement
- [ ] Placeholders pour plats sans image
- [ ] Indicateur de chargement pendant le téléchargement
- [ ] Gestion des erreurs de chargement

### 3. **Test d'Upload d'Images**

#### **Page d'Administration**
1. Aller dans la section admin
2. Éditer un plat existant
3. Tester l'upload d'image

**Étapes détaillées :**
1. **Sélectionner une image** :
   - Cliquer sur "Galerie" ou "Caméra"
   - Choisir une image
   - Vérifier l'aperçu

2. **Uploader l'image** :
   - Cliquer sur "Uploader l'image"
   - Vérifier le message de succès
   - Vérifier que l'image apparaît dans le menu

3. **Vérifier l'affichage** :
   - Retourner au menu
   - Vérifier que l'image s'affiche
   - Tester sur différents navigateurs

### 4. **Test des Widgets**

#### **ImageUploadWidget**
- [ ] Bouton "Galerie" fonctionne
- [ ] Bouton "Caméra" fonctionne
- [ ] Aperçu de l'image sélectionnée
- [ ] Upload avec indicateur de progression
- [ ] Messages de succès/erreur

#### **NetworkImageWidget**
- [ ] Affichage des images depuis l'URL
- [ ] Placeholder pour images manquantes
- [ ] Indicateur de chargement
- [ ] Gestion des erreurs de chargement
- [ ] Border radius appliqué correctement

## 🔧 Tests Techniques

### 1. **Test des URLs d'Images**
```bash
# Vérifier l'accessibilité des images
curl http://localhost:8000/media/menu_images/test_image.png
```

### 2. **Test des Permissions**
- [ ] Permission galerie sur mobile
- [ ] Permission caméra sur mobile
- [ ] Gestion des refus de permission

### 3. **Test des Formats**
- [ ] Images JPG
- [ ] Images PNG
- [ ] Images de grande taille
- [ ] Images de petite taille

## 🐛 Debugging

### 1. **Problèmes Courants**

#### **Images ne s'affichent pas**
```dart
// Vérifier dans la console Flutter
print('Image URL: $imageUrl');
```

#### **Upload échoue**
```dart
// Vérifier les logs de l'API
print('Upload response: $response');
```

#### **Erreurs de CORS**
- Vérifier que Django CORS est configuré
- Vérifier les URLs dans les widgets

### 2. **Logs de Debug**
```dart
// Dans image_upload_widget.dart
print('Uploading image for ${widget.modelType} ID ${widget.itemId}');
print('Response: $responseData');
```

## 📋 Checklist de Validation

### ✅ Backend
- [ ] API d'upload fonctionne
- [ ] Images stockées correctement
- [ ] URLs d'images accessibles
- [ ] Gestion des erreurs

### ✅ Frontend
- [ ] Widget d'upload fonctionne
- [ ] Widget d'affichage fonctionne
- [ ] Images s'affichent dans le menu
- [ ] Gestion des erreurs

### ✅ Intégration
- [ ] Upload depuis Flutter
- [ ] Affichage dans Flutter
- [ ] Synchronisation entre upload et affichage

## 🚀 Démarrage Rapide

### 1. **Démarrer les serveurs**
```bash
# Terminal 1
cd BOKDEJ
python manage.py runserver

# Terminal 2
cd BOKDEJ/bokkdej_front
flutter run -d chrome --web-port=8081
```

### 2. **Tester l'upload**
1. Ouvrir http://localhost:8081
2. Se connecter avec PIN `1234`
3. Aller dans admin
4. Éditer un plat
5. Uploader une image

### 3. **Vérifier l'affichage**
1. Retourner au menu
2. Vérifier que l'image s'affiche
3. Tester sur mobile si disponible

## 📞 Support

### **En cas de problème :**

1. **Vérifier les serveurs** :
   ```bash
   # Django
   curl http://localhost:8000/api/menu/
   
   # Flutter
   flutter doctor
   ```

2. **Vérifier les logs** :
   - Console Flutter (F12)
   - Logs Django
   - Console du navigateur

3. **Tester l'API directement** :
   ```bash
   python test_image_upload.py
   ```

4. **Vérifier les permissions** :
   - Permissions caméra/galerie
   - CORS configuration

**Application BOKDEJ - Test des Images Flutter** 📸 