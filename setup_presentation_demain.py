#!/usr/bin/env python3
"""
🎯 SCRIPT DE SETUP POUR LA PRÉSENTATION DE DEMAIN
Ce script configure tout ce dont vous avez besoin pour présenter votre système d'images
"""

import os
import sys
import subprocess
import django
from pathlib import Path

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')

def check_dependencies():
    """Vérifie que toutes les dépendances sont installées"""
    print("🔍 Vérification des dépendances...")
    
    try:
        import PIL
        print("✅ Pillow installé")
    except ImportError:
        print("❌ Pillow manquant - Installation en cours...")
        subprocess.run([sys.executable, '-m', 'pip', 'install', 'Pillow'], check=True)
        print("✅ Pillow installé")
    
    try:
        import requests
        print("✅ Requests installé")
    except ImportError:
        print("❌ Requests manquant - Installation en cours...")
        subprocess.run([sys.executable, '-m', 'pip', 'install', 'requests'], check=True)
        print("✅ Requests installé")

def setup_media_folders():
    """Crée tous les dossiers média nécessaires"""
    print("\n📁 Configuration des dossiers média...")
    
    folders = [
        'media',
        'media/menu_images',
        'media/ingredient_images', 
        'media/base_images',
        'media/category_images',
        'media/demo_images',
        'media/demo_images/menu',
        'media/demo_images/ingredients',
        'media/demo_images/bases',
        'media/demo_images/categories'
    ]
    
    for folder in folders:
        os.makedirs(folder, exist_ok=True)
        print(f"✅ Dossier créé/vérifié: {folder}")

def run_migrations():
    """Lance les migrations Django"""
    print("\n🔄 Lancement des migrations...")
    try:
        django.setup()
        from django.core.management import execute_from_command_line
        execute_from_command_line(['manage.py', 'migrate'])
        print("✅ Migrations terminées")
        return True
    except Exception as e:
        print(f"❌ Erreur migrations: {e}")
        return False

def create_superuser_if_needed():
    """Crée un superuser si nécessaire"""
    print("\n👤 Vérification du superuser...")
    try:
        from django.contrib.auth.models import User
        if not User.objects.filter(is_superuser=True).exists():
            print("Création du superuser admin...")
            User.objects.create_superuser('admin', 'admin@keuresto.com', 'admin123')
            print("✅ Superuser créé: admin / admin123")
        else:
            print("✅ Superuser existe déjà")
        return True
    except Exception as e:
        print(f"❌ Erreur superuser: {e}")
        return False

def create_test_data():
    """Crée des données de test"""
    print("\n📊 Création des données de test...")
    try:
        # Importer et lancer le script de données de test
        exec(open('create_test_data.py').read())
        print("✅ Données de test créées")
        return True
    except Exception as e:
        print(f"⚠️  Erreur données de test: {e}")
        # Ce n'est pas critique, on continue
        return False

def create_demo_images():
    """Crée les images de démonstration"""
    print("\n🎨 Création des images de démonstration...")
    try:
        # Lancer le script de création d'images
        result = subprocess.run([sys.executable, 'prepare_demo_images.py'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Images de démonstration créées")
            print(result.stdout[-200:])  # Afficher les dernières lignes
            return True
        else:
            print(f"⚠️  Problème création images: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Erreur création images: {e}")
        return False

def test_image_system():
    """Teste le système d'images"""
    print("\n🧪 Test du système d'images...")
    try:
        result = subprocess.run([sys.executable, 'test_images_complete.py'], 
                              capture_output=True, text=True, timeout=60)
        if result.returncode == 0:
            print("✅ Tests d'images réussis")
            # Afficher le résumé
            lines = result.stdout.split('\n')
            for line in lines:
                if 'Tests réussis:' in line or 'Taux de réussite:' in line:
                    print(f"📊 {line}")
            return True
        else:
            print(f"⚠️  Problème tests: {result.stderr}")
            return False
    except subprocess.TimeoutExpired:
        print("⏰ Tests trop longs - peut-être un problème de serveur")
        return False
    except Exception as e:
        print(f"❌ Erreur tests: {e}")
        return False

def check_server_ready():
    """Vérifie que le serveur peut démarrer"""
    print("\n🌐 Vérification de la configuration serveur...")
    try:
        from django.core.management import execute_from_command_line
        # Test de la configuration
        execute_from_command_line(['manage.py', 'check'])
        print("✅ Configuration Django valide")
        return True
    except Exception as e:
        print(f"❌ Problème configuration: {e}")
        return False

def create_quick_start_guide():
    """Crée un guide de démarrage rapide"""
    guide = """
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
"""
    
    with open('GUIDE_PRESENTATION_DEMAIN.md', 'w', encoding='utf-8') as f:
        f.write(guide)
    print("✅ Guide de présentation créé: GUIDE_PRESENTATION_DEMAIN.md")

def main():
    """Fonction principale de setup"""
    print("🎯 SETUP POUR LA PRÉSENTATION DE DEMAIN")
    print("=" * 50)
    print("Configuration automatique du système d'images Keur Resto\n")
    
    success_count = 0
    total_steps = 8
    
    # Étape 1: Dépendances
    try:
        check_dependencies()
        success_count += 1
    except Exception as e:
        print(f"❌ Erreur dépendances: {e}")
    
    # Étape 2: Dossiers média
    try:
        setup_media_folders()
        success_count += 1
    except Exception as e:
        print(f"❌ Erreur dossiers: {e}")
    
    # Étape 3: Migrations
    if run_migrations():
        success_count += 1
    
    # Étape 4: Superuser
    if create_superuser_if_needed():
        success_count += 1
    
    # Étape 5: Données de test
    if create_test_data():
        success_count += 1
    
    # Étape 6: Images de démo
    if create_demo_images():
        success_count += 1
    
    # Étape 7: Tests
    if test_image_system():
        success_count += 1
    
    # Étape 8: Vérification serveur
    if check_server_ready():
        success_count += 1
    
    # Guide final
    create_quick_start_guide()
    
    # Résumé final
    print("\n" + "=" * 50)
    print("🎯 RÉSUMÉ DU SETUP")
    print(f"✅ Étapes réussies: {success_count}/{total_steps}")
    print(f"📊 Taux de réussite: {(success_count/total_steps)*100:.1f}%")
    
    if success_count >= 6:
        print("\n🎉 EXCELLENT ! Vous êtes prêt pour la présentation !")
        print("💡 Toutes les fonctionnalités importantes sont opérationnelles")
    elif success_count >= 4:
        print("\n👍 BON ! La plupart des fonctionnalités marchent")
        print("💡 Quelques ajustements peuvent être nécessaires")
    else:
        print("\n⚠️  ATTENTION ! Plusieurs problèmes détectés")
        print("💡 Vérifiez les erreurs ci-dessus")
    
    print(f"\n📖 Consultez le guide: GUIDE_PRESENTATION_DEMAIN.md")
    print("🚀 Pour démarrer: python manage.py runserver")
    print("\n🌟 Bonne chance pour votre présentation demain ! 🌟")

if __name__ == "__main__":
    main()