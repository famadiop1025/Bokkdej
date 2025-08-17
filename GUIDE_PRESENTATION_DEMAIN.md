
# 🚀 GUIDE DÉMARRAGE RAPIDE - PRÉSENTATION DEMAIN

## Démarrer le serveur
```bash
python manage.py runserver
```

## URLs importantes
- **API**: http://127.0.0.1:8000/api/
- **Admin**: http://127.0.0.1:8000/admin/
- **Upload images**: http://127.0.0.1:8000/api/upload_image/

## Connexion admin
- **Utilisateur**: admin
- **Mot de passe**: admin123

## Endpoints d'images
- `GET /api/menu/` - Liste des plats avec images
- `GET /api/ingredients/` - Liste des ingrédients avec images  
- `GET /api/bases/` - Liste des bases avec images
- `POST /api/upload_image/` - Upload général d'image

## Structure des URLs d'images
- Menu: `/media/menu_images/`
- Ingrédients: `/media/ingredient_images/`
- Bases: `/media/base_images/`
- Démo: `/media/demo_images/`

## Test rapide
```bash
python test_images_complete.py
```

## Points clés pour la présentation
1. ✅ Système d'upload d'images fonctionnel
2. ✅ API REST avec images
3. ✅ Interface admin avec aperçu d'images
4. ✅ Images de démonstration créées
5. ✅ Endpoints testés et validés

**Bonne présentation ! 🎉**
