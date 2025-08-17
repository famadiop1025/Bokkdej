#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test simple et direct de l'upload d'images pour le menu
Ce script teste tous les cas d'usage possibles
"""

import os
import sys
import django
import requests
from PIL import Image
import io
import time

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import MenuItem

def create_test_image():
    """Crée une image de test simple"""
    img = Image.new('RGB', (200, 200), color='red')
    buffer = io.BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)
    return buffer

def test_direct_model_upload():
    """Test direct via le modèle Django"""
    print("1. Test direct via modèle Django...")
    try:
        # Créer une image de test
        img_buffer = create_test_image()
        
        # Sauvegarder dans un fichier temporaire
        temp_path = 'temp_test_image.png'
        with open(temp_path, 'wb') as f:
            f.write(img_buffer.getvalue())
        
        # Prendre le premier menu item
        menu_item = MenuItem.objects.first()
        if not menu_item:
            print("❌ Aucun menu item trouvé")
            return False
        
        # Assigner l'image
        with open(temp_path, 'rb') as f:
            from django.core.files import File
            menu_item.image.save('test_direct.png', File(f), save=True)
        
        # Nettoyer
        os.remove(temp_path)
        
        print(f"✅ Image assignée directement au menu: {menu_item.nom}")
        print(f"   URL: {menu_item.image.url}")
        return True
        
    except Exception as e:
        print(f"❌ Erreur test direct: {e}")
        return False

def test_api_upload_general():
    """Test de l'endpoint général d'upload"""
    print("\n2. Test endpoint général d'upload...")
    try:
        # Attendre que le serveur soit prêt
        time.sleep(2)
        
        # Vérifier que le serveur répond
        response = requests.get('http://127.0.0.1:8000/api/menu/')
        if response.status_code != 200:
            print(f"❌ Serveur ne répond pas: {response.status_code}")
            return False
        
        # Prendre le premier menu item
        menu_items = response.json()
        if not menu_items:
            print("❌ Aucun menu item dans l'API")
            return False
        
        first_item = menu_items[0]
        item_id = first_item['id']
        
        # Créer une image de test
        img_buffer = create_test_image()
        
        # Préparer l'upload
        files = {'image': ('test_api.png', img_buffer, 'image/png')}
        data = {
            'model_type': 'menu',
            'item_id': item_id
        }
        
        # Envoyer la requête
        response = requests.post('http://127.0.0.1:8000/api/upload_image/', 
                               files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Upload général réussi")
            print(f"   Message: {result.get('message')}")
            print(f"   URL: {result.get('image_url')}")
            return True
        else:
            print(f"❌ Upload général échoué: {response.status_code}")
            print(f"   Réponse: {response.text}")
            return False
        
    except Exception as e:
        print(f"❌ Erreur test API général: {e}")
        return False

def test_api_upload_viewset():
    """Test de l'endpoint spécifique du ViewSet"""
    print("\n3. Test endpoint ViewSet spécifique...")
    try:
        # Récupérer les menus
        response = requests.get('http://127.0.0.1:8000/api/menu/')
        if response.status_code != 200:
            print(f"❌ Serveur ne répond pas: {response.status_code}")
            return False
        
        menu_items = response.json()
        if not menu_items:
            print("❌ Aucun menu item dans l'API")
            return False
        
        first_item = menu_items[0]
        item_id = first_item['id']
        
        # Créer une image de test
        img_buffer = create_test_image()
        
        # Préparer l'upload
        files = {'image': ('test_viewset.png', img_buffer, 'image/png')}
        
        # Envoyer la requête au ViewSet
        response = requests.post(f'http://127.0.0.1:8000/api/menu/{item_id}/upload_image/', 
                               files=files)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Upload ViewSet réussi")
            print(f"   Message: {result.get('message')}")
            print(f"   URL: {result.get('image_url')}")
            return True
        else:
            print(f"❌ Upload ViewSet échoué: {response.status_code}")
            print(f"   Réponse: {response.text}")
            return False
        
    except Exception as e:
        print(f"❌ Erreur test ViewSet: {e}")
        return False

def test_api_menu_response():
    """Test que l'API menu retourne bien les images"""
    print("\n4. Test réponse API menu avec images...")
    try:
        response = requests.get('http://127.0.0.1:8000/api/menu/')
        if response.status_code != 200:
            print(f"❌ API menu ne répond pas: {response.status_code}")
            return False
        
        menu_items = response.json()
        items_with_images = 0
        
        for item in menu_items:
            if item.get('image'):
                items_with_images += 1
                print(f"✅ {item['nom']} a une image: {item['image']}")
        
        print(f"📊 Total: {items_with_images}/{len(menu_items)} items avec images")
        return items_with_images > 0
        
    except Exception as e:
        print(f"❌ Erreur test API menu: {e}")
        return False

def main():
    """Fonction principale de test"""
    print("🧪 TEST COMPLET UPLOAD IMAGES MENU")
    print("=" * 50)
    
    success_count = 0
    total_tests = 4
    
    # Test 1: Direct via modèle
    if test_direct_model_upload():
        success_count += 1
    
    # Test 2: API endpoint général
    if test_api_upload_general():
        success_count += 1
    
    # Test 3: API ViewSet spécifique
    if test_api_upload_viewset():
        success_count += 1
    
    # Test 4: Vérification réponse API
    if test_api_menu_response():
        success_count += 1
    
    # Résumé
    print("\n" + "=" * 50)
    print("📊 RÉSUMÉ DES TESTS")
    print(f"Tests réussis: {success_count}/{total_tests}")
    print(f"Taux de réussite: {(success_count/total_tests)*100:.1f}%")
    
    if success_count == total_tests:
        print("\n🎉 PARFAIT ! L'upload d'images fonctionne complètement !")
        print("✅ Votre système est prêt pour la présentation")
    elif success_count >= 2:
        print(f"\n👍 BON ! {success_count} tests passent")
        print("⚠️ Quelques ajustements peuvent être nécessaires")
    else:
        print("\n❌ PROBLÈME ! La plupart des tests échouent")
        print("🔧 Vérifiez la configuration et les logs d'erreur")
    
    print("\n💡 POUR LA PRÉSENTATION:")
    print("1. Utilisez l'interface admin: http://127.0.0.1:8000/admin/")
    print("2. Ou l'API: POST /api/upload_image/")
    print("3. Les images apparaissent dans: GET /api/menu/")

if __name__ == "__main__":
    main()
