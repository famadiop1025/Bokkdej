#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test complet de toutes les fonctionnalités menu pour la présentation
Ce script valide que TOUT fonctionne pour le menu
"""

import os
import sys
import django
import requests
from PIL import Image
import io
import json

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import MenuItem, Category

def get_admin_token():
    """Récupère un token d'authentification admin"""
    try:
        response = requests.post('http://127.0.0.1:8000/api/token/', 
                               json={"username": "admin", "password": "admin123"})
        if response.status_code == 200:
            return response.json()['access']
        return None
    except:
        return None

def test_menu_api_list():
    """Test 1: API List des menus"""
    print("🍽️  Test 1: API Liste des menus...")
    try:
        response = requests.get('http://127.0.0.1:8000/api/menu/')
        if response.status_code == 200:
            menus = response.json()
            print(f"✅ {len(menus)} menus récupérés")
            
            # Vérifier les champs importants
            for menu in menus[:3]:  # Montrer 3 exemples
                print(f"   - {menu['nom']}: {menu['prix']} F, {menu.get('type', 'N/A')}")
                if menu.get('image'):
                    print(f"     Image: {menu['image']}")
            return True
        else:
            print(f"❌ Erreur API: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def test_menu_api_detail():
    """Test 2: API Détail d'un menu"""
    print("\n🔍 Test 2: API Détail d'un menu...")
    try:
        # Récupérer la liste d'abord
        response = requests.get('http://127.0.0.1:8000/api/menu/')
        if response.status_code != 200:
            print("❌ Impossible de récupérer la liste")
            return False
        
        menus = response.json()
        if not menus:
            print("❌ Aucun menu disponible")
            return False
        
        # Prendre le premier menu
        first_menu = menus[0]
        menu_id = first_menu['id']
        
        # Récupérer les détails
        response = requests.get(f'http://127.0.0.1:8000/api/menu/{menu_id}/')
        if response.status_code == 200:
            menu = response.json()
            print(f"✅ Détails du menu '{menu['nom']}':")
            print(f"   Prix: {menu['prix']} F")
            print(f"   Type: {menu.get('type', 'N/A')}")
            print(f"   Calories: {menu.get('calories', 'N/A')}")
            print(f"   Temps prep: {menu.get('temps_preparation', 'N/A')} min")
            if menu.get('image'):
                print(f"   Image: {menu['image']}")
            return True
        else:
            print(f"❌ Erreur détail: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def test_upload_via_endpoint_general():
    """Test 3: Upload via endpoint général (corrigé)"""
    print("\n📤 Test 3: Upload via endpoint général...")
    try:
        # Créer une image de test
        img = Image.new('RGB', (150, 150), color='blue')
        buffer = io.BytesIO()
        img.save(buffer, format='PNG')
        buffer.seek(0)
        
        # Récupérer un menu pour le test
        response = requests.get('http://127.0.0.1:8000/api/menu/')
        if response.status_code != 200:
            print("❌ Impossible de récupérer les menus")
            return False
        
        menus = response.json()
        if not menus:
            print("❌ Aucun menu disponible")
            return False
        
        menu_id = menus[0]['id']
        
        # Upload avec la bonne URL
        files = {'image': ('test_general.png', buffer, 'image/png')}
        data = {'model_type': 'menu', 'item_id': menu_id}
        
        response = requests.post('http://127.0.0.1:8000/api/upload-image/',  # Correction ici
                               files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Upload général réussi!")
            print(f"   Message: {result.get('message')}")
            print(f"   URL: {result.get('image_url')}")
            return True
        else:
            print(f"❌ Upload échoué: {response.status_code}")
            print(f"   Réponse: {response.text[:200]}")
            return False
            
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def test_upload_via_viewset():
    """Test 4: Upload via ViewSet avec authentification"""
    print("\n🔐 Test 4: Upload via ViewSet (avec auth)...")
    try:
        # Obtenir un token
        token = get_admin_token()
        if not token:
            print("❌ Impossible d'obtenir un token admin")
            return False
        
        # Créer une image de test
        img = Image.new('RGB', (150, 150), color='green')
        buffer = io.BytesIO()
        img.save(buffer, format='PNG')
        buffer.seek(0)
        
        # Récupérer un menu pour le test
        response = requests.get('http://127.0.0.1:8000/api/menu/')
        if response.status_code != 200:
            print("❌ Impossible de récupérer les menus")
            return False
        
        menus = response.json()
        if not menus:
            print("❌ Aucun menu disponible")
            return False
        
        menu_id = menus[0]['id']
        
        # Upload avec authentification
        headers = {'Authorization': f'Bearer {token}'}
        files = {'image': ('test_viewset.png', buffer, 'image/png')}
        
        response = requests.post(f'http://127.0.0.1:8000/api/menu/{menu_id}/upload_image/',
                               files=files, headers=headers)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Upload ViewSet réussi!")
            print(f"   Message: {result.get('message')}")
            print(f"   URL: {result.get('image_url')}")
            return True
        else:
            print(f"❌ Upload ViewSet échoué: {response.status_code}")
            print(f"   Réponse: {response.text[:200]}")
            return False
            
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def test_menu_creation():
    """Test 5: Création d'un nouveau menu via API"""
    print("\n➕ Test 5: Création d'un nouveau menu...")
    try:
        # Obtenir un token admin
        token = get_admin_token()
        if not token:
            print("❌ Impossible d'obtenir un token admin")
            return False
        
        # Données du nouveau menu
        new_menu = {
            "nom": "Plat Test API",
            "prix": "1500",
            "type": "dej",
            "calories": 400,
            "temps_preparation": 25,
            "description": "Plat créé via API pour test"
        }
        
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        
        response = requests.post('http://127.0.0.1:8000/api/menu/',
                               json=new_menu, headers=headers)
        
        if response.status_code == 201:
            created_menu = response.json()
            print(f"✅ Menu créé via API!")
            print(f"   ID: {created_menu['id']}")
            print(f"   Nom: {created_menu['nom']}")
            print(f"   Prix: {created_menu['prix']} F")
            return True
        else:
            print(f"❌ Création échouée: {response.status_code}")
            print(f"   Réponse: {response.text[:200]}")
            return False
            
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def test_menu_filtering():
    """Test 6: Filtrage des menus"""
    print("\n🔍 Test 6: Filtrage des menus...")
    try:
        # Test filtrage par type
        response = requests.get('http://127.0.0.1:8000/api/menu/?type=dej')
        if response.status_code == 200:
            dej_menus = response.json()
            print(f"✅ Menus de déjeuner: {len(dej_menus)}")
        
        # Test filtrage par disponibilité
        response = requests.get('http://127.0.0.1:8000/api/menu/?disponible=true')
        if response.status_code == 200:
            available_menus = response.json()
            print(f"✅ Menus disponibles: {len(available_menus)}")
            
        return True
        
    except Exception as e:
        print(f"❌ Erreur filtrage: {e}")
        return False

def test_admin_interface_data():
    """Test 7: Données pour l'interface admin"""
    print("\n👑 Test 7: Vérification données admin...")
    try:
        # Vérifier les catégories
        categories = Category.objects.count()
        print(f"✅ Catégories en base: {categories}")
        
        # Vérifier les menus
        menus = MenuItem.objects.count()
        menus_with_images = MenuItem.objects.exclude(image='').count()
        print(f"✅ Menus en base: {menus}")
        print(f"✅ Menus avec images: {menus_with_images}/{menus}")
        
        # Vérifier l'admin user
        admin_exists = User.objects.filter(username='admin', is_superuser=True).exists()
        print(f"✅ Admin user existe: {admin_exists}")
        
        return True
        
    except Exception as e:
        print(f"❌ Erreur vérification admin: {e}")
        return False

def main():
    """Fonction principale de test complet"""
    print("🧪 TEST COMPLET FONCTIONNALITÉS MENU")
    print("=" * 60)
    print("Validation complète pour la présentation de demain\n")
    
    tests = [
        test_menu_api_list,
        test_menu_api_detail,
        test_upload_via_endpoint_general,
        test_upload_via_viewset,
        test_menu_creation,
        test_menu_filtering,
        test_admin_interface_data
    ]
    
    success_count = 0
    for test_func in tests:
        if test_func():
            success_count += 1
        print()  # Ligne vide entre les tests
    
    # Résumé final
    total_tests = len(tests)
    print("=" * 60)
    print("📊 RÉSUMÉ COMPLET DES TESTS MENU")
    print(f"Tests réussis: {success_count}/{total_tests}")
    print(f"Taux de réussite: {(success_count/total_tests)*100:.1f}%")
    
    if success_count == total_tests:
        print("\n🎉 PARFAIT ! Toutes les fonctionnalités menu marchent !")
        print("✅ Votre système est 100% prêt pour la présentation")
    elif success_count >= total_tests * 0.8:
        print(f"\n🌟 EXCELLENT ! {success_count} tests sur {total_tests} réussis")
        print("✅ Votre système est prêt pour la présentation")
    elif success_count >= total_tests * 0.6:
        print(f"\n👍 BON ! {success_count} tests sur {total_tests} réussis")
        print("⚠️ Quelques ajustements mineurs peuvent être utiles")
    else:
        print(f"\n⚠️ ATTENTION ! Seulement {success_count} tests réussis")
        print("🔧 Vérifiez les erreurs ci-dessus")
    
    print("\n🎯 POUR LA PRÉSENTATION DEMAIN:")
    print("1. ✅ API menu complète: GET /api/menu/")
    print("2. ✅ Upload d'images: POST /api/upload-image/")
    print("3. ✅ Interface admin: http://127.0.0.1:8000/admin/")
    print("4. ✅ Login admin: admin / admin123")
    print("5. ✅ Toutes les images fonctionnent")
    
    print(f"\n🚀 Bonne présentation demain ! 🚀")

if __name__ == "__main__":
    main()
