#!/usr/bin/env python
import os
import sys
import django
import requests
import json

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

def test_pin_login():
    """Test de la connexion PIN"""
    print("🧪 Test de la connexion PIN...")
    
    # URL de l'API
    url = "http://localhost:8000/api/auth/pin-login/"
    
    # Test avec le PIN admin (1234)
    data = {"pin": "1234"}
    
    try:
        response = requests.post(url, json=data, headers={'Content-Type': 'application/json'})
        print(f"📡 Statut de la réponse: {response.status_code}")
        print(f"📄 Contenu de la réponse: {response.text}")
        
        if response.status_code == 200:
            print("✅ Connexion PIN réussie!")
            token_data = response.json()
            print(f"🔑 Token reçu: {token_data.get('access', 'Non trouvé')}")
        else:
            print("❌ Échec de la connexion PIN")
            
    except requests.exceptions.ConnectionError:
        print("❌ Impossible de se connecter au serveur Django")
        print("💡 Assurez-vous que le serveur Django fonctionne sur http://localhost:8000")
    except Exception as e:
        print(f"❌ Erreur: {e}")

def test_menu_api():
    """Test de l'API menu"""
    print("\n🍽️ Test de l'API menu...")
    
    url = "http://localhost:8000/api/menu/"
    
    try:
        response = requests.get(url)
        print(f"📡 Statut de la réponse: {response.status_code}")
        print(f"📄 Contenu de la réponse: {response.text[:200]}...")
        
        if response.status_code == 200:
            print("✅ API menu accessible!")
        else:
            print("❌ API menu inaccessible")
            
    except requests.exceptions.ConnectionError:
        print("❌ Impossible de se connecter au serveur Django")
    except Exception as e:
        print(f"❌ Erreur: {e}")

if __name__ == '__main__':
    print("🔍 Test des APIs BOKDEJ")
    print("=" * 50)
    
    test_pin_login()
    test_menu_api()
    
    print("\n" + "=" * 50)
    print("📋 Résumé des tests")
    print("💡 Si les tests échouent, vérifiez que:")
    print("   1. Le serveur Django fonctionne: python manage.py runserver")
    print("   2. Les utilisateurs de test existent")
    print("   3. L'API est correctement configurée") 