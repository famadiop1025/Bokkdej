#!/usr/bin/env python
import os
import sys
import django
import requests
import json

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

# Test de l'endpoint pin-login avec les vraies informations d'administrateur
url = "http://localhost:8000/api/auth/pin-login/"

# Test avec l'administrateur 123456789 (téléphone: 783693567, PIN: 3567)
data = {
    "pin": "3567",
    "phone": "783693567"
}

print("🧪 Test de connexion PIN avec l'administrateur existant...")
print(f"📱 Téléphone: {data['phone']}")
print(f"🔑 PIN: {data['pin']}")

try:
    response = requests.post(url, json=data)
    print(f"📡 Status Code: {response.status_code}")
    print(f"📄 Response: {response.text}")
    
    if response.status_code == 200:
        print("✅ Connexion PIN réussie!")
        token_data = response.json()
        print(f"🔑 Token reçu: {token_data.get('access', 'Non trouvé')}")
        print(f"👤 Utilisateur: {token_data.get('user', {}).get('username', 'Non trouvé')}")
    else:
        print("❌ Échec de la connexion PIN")
        
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