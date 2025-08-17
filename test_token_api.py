#!/usr/bin/env python
import requests
import json

def test_token_authentication():
    print("=== Test API Token Authentication ===")
    
    url = "http://127.0.0.1:8000/api/token/"
    
    # Test 1: Avec phone et password (comme Flutter)
    print("\n1. Test avec phone et password (Flutter style):")
    data_flutter = {
        "phone": "123456789",
        "password": "1234"
    }
    
    try:
        response = requests.post(url, json=data_flutter, headers={'Content-Type': 'application/json'})
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
    except Exception as e:
        print(f"   Erreur: {e}")
    
    # Test 2: Avec username et password
    print("\n2. Test avec username et password:")
    data_username = {
        "username": "123456789",
        "password": "1234"
    }
    
    try:
        response = requests.post(url, json=data_username, headers={'Content-Type': 'application/json'})
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
    except Exception as e:
        print(f"   Erreur: {e}")
    
    # Test 3: Vérifier que l'utilisateur existe
    print("\n3. Verification de l'utilisateur en base:")
    import os
    import django
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
    django.setup()
    
    from django.contrib.auth.models import User
    try:
        user = User.objects.get(username='123456789')
        print(f"   ✅ Utilisateur trouvé: {user.username}")
        print(f"   ✅ Email: {user.email}")
        print(f"   ✅ Active: {user.is_active}")
        print(f"   ✅ Staff: {user.is_staff}")
        
        # Test du mot de passe
        if user.check_password('1234'):
            print(f"   ✅ Mot de passe correct")
        else:
            print(f"   ❌ Mot de passe incorrect")
            
    except User.DoesNotExist:
        print(f"   ❌ Utilisateur non trouvé")

if __name__ == '__main__':
    test_token_authentication()
