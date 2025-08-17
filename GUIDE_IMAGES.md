# 📸 Guide de Gestion des Images - Application BOKDEJ

## 📋 Vue d'ensemble

L'application BOKDEJ supporte maintenant la gestion complète des images pour :
- **Plats du menu** (`MenuItem`)
- **Ingrédients** (`Ingredient`)
- **Bases** (`Base`)

## 🔧 Configuration Backend

### 1. **Modèles avec Images**
```python
# api/models.py
class MenuItem(models.Model):
    image = models.ImageField(upload_to='menu_images/', blank=True, null=True)

class Ingredient(models.Model):
    image = models.ImageField(upload_to='ingredient_images/', blank=True, null=True)

class Base(models.Model):
    image = models.ImageField(upload_to='base_images/', blank=True, null=True)
```

### 2. **Configuration Django**
```python
# settings.py
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# URLs pour servir les médias en développement
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

## 🚀 API Endpoints

### 1. **Upload d'Image Général**
```http
POST /api/upload-image/
Content-Type: multipart/form-data

Parameters:
- image: fichier image
- model_type: 'menu', 'ingredient', ou 'base'
- item_id: ID de l'élément
```

### 2. **Upload d'Image Spécifique**
```http
POST /api/menu/{id}/upload_image/
POST /api/ingredients/{id}/upload_image/
```

### 3. **Accès aux Images**
```http
GET /media/menu_images/nom_image.jpg
GET /media/ingredient_images/nom_image.jpg
GET /media/base_images/nom_image.jpg
```

## 🧪 Tests d'Upload

### 1. **Test avec Python**
```python
import requests

# Upload d'image pour un plat
url = "http://localhost:8000/api/upload-image/"
files = {'image': open('image.jpg', 'rb')}
data = {
    'model_type': 'menu',
    'item_id': 1
}
response = requests.post(url, files=files, data=data)
print(response.json())
```

### 2. **Test avec cURL**
```bash
# Upload d'image pour un plat
curl -X POST http://localhost:8000/api/upload-image/ \
  -F "image=@image.jpg" \
  -F "model_type=menu" \
  -F "item_id=1"
```

### 3. **Test avec Postman**
1. **Méthode** : POST
2. **URL** : `http://localhost:8000/api/upload-image/`
3. **Body** : form-data
   - `image` : fichier image
   - `model_type` : menu/ingredient/base
   - `item_id` : ID de l'élément

## 📱 Intégration Flutter

### 1. **Widget d'Upload d'Image**
```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageUploadWidget extends StatefulWidget {
  final String modelType;
  final int itemId;
  
  const ImageUploadWidget({
    Key? key,
    required this.modelType,
    required this.itemId,
  }) : super(key: key);

  @override
  _ImageUploadWidgetState createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/api/upload-image/'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
        ),
      );

      request.fields['model_type'] = widget.modelType;
      request.fields['item_id'] = widget.itemId.toString();

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploadée avec succès!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'upload')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_imageFile != null)
          Image.file(
            _imageFile!,
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          ),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Sélectionner une image'),
        ),
        if (_imageFile != null)
          ElevatedButton(
            onPressed: _isUploading ? null : _uploadImage,
            child: _isUploading 
              ? CircularProgressIndicator()
              : Text('Uploader l\'image'),
          ),
      ],
    );
  }
}
```

### 2. **Widget d'Affichage d'Image**
```dart
class NetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const NetworkImageWidget({
    Key? key,
    this.imageUrl,
    this.width = 200,
    this.height = 200,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
      );
    }

    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                  loadingProgress.expectedTotalBytes!
                : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.error, size: 50, color: Colors.red),
        );
      },
    );
  }
}
```

## 🎯 Utilisation dans l'Application

### 1. **Page d'Administration des Plats**
```dart
// Dans admin_add_edit_plat.dart
class AdminAddEditPlatPage extends StatefulWidget {
  final MenuItem? plat; // null pour création, non-null pour édition
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gérer un plat')),
      body: Column(
        children: [
          // Formulaire existant...
          
          // Widget d'upload d'image
          ImageUploadWidget(
            modelType: 'menu',
            itemId: plat?.id ?? 0,
          ),
          
          // Affichage de l'image actuelle
          if (plat?.image != null)
            NetworkImageWidget(
              imageUrl: 'http://localhost:8000${plat!.image}',
              width: 200,
              height: 200,
            ),
        ],
      ),
    );
  }
}
```

### 2. **Page du Menu**
```dart
// Dans menu_page.dart
Widget _buildMenuItemCard(MenuItem item) {
  return Card(
    child: Column(
      children: [
        // Image du plat
        NetworkImageWidget(
          imageUrl: item.image != null 
            ? 'http://localhost:8000${item.image}'
            : null,
          width: double.infinity,
          height: 150,
        ),
        
        // Informations du plat
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(item.nom, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${item.prix} F'),
            ],
          ),
        ),
      ],
    ),
  );
}
```

## 🔧 Configuration Flutter

### 1. **Dépendances à ajouter**
```yaml
# pubspec.yaml
dependencies:
  image_picker: ^1.0.7
  http: ^1.1.0
```

### 2. **Permissions Android**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

### 3. **Permissions iOS**
```xml
<!-- ios/Runner/Info.plist -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Cette application nécessite l'accès à la galerie pour sélectionner des images.</string>
<key>NSCameraUsageDescription</key>
<string>Cette application nécessite l'accès à la caméra pour prendre des photos.</string>
```

## 🧪 Tests

### 1. **Test de l'API**
```bash
# Tester l'upload d'images
python test_image_upload.py
```

### 2. **Test Flutter**
1. Ouvrir l'application
2. Aller dans la section admin
3. Tester l'upload d'images pour les plats
4. Vérifier l'affichage des images dans le menu

## 📋 Checklist

### ✅ Backend
- [ ] Modèles avec champs image
- [ ] Endpoints d'upload
- [ ] Configuration des médias
- [ ] Migrations appliquées

### ✅ Frontend
- [ ] Widget d'upload d'image
- [ ] Widget d'affichage d'image
- [ ] Intégration dans les pages
- [ ] Gestion des erreurs

### ✅ Tests
- [ ] Upload d'images fonctionne
- [ ] Affichage des images fonctionne
- [ ] Gestion des erreurs fonctionne

## 🚀 Démarrage Rapide

1. **Installer les dépendances Flutter** :
   ```bash
   cd bokkdej_front
   flutter pub get
   ```

2. **Tester l'upload** :
   ```bash
   python test_image_upload.py
   ```

3. **Tester l'application** :
   - Ouvrir http://localhost:8081
   - Aller dans la section admin
   - Tester l'upload d'images

**Application BOKDEJ - Gestion des Images** 📸 