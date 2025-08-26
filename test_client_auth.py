#!/usr/bin/env python3
"""
Script de test pour l'endpoint de création automatique de compte client
"""

import requests
import json

def test_create_client():
    """Tester la création automatique d'un compte client"""
    
    # URL de l'API
    base_url = "http://localhost:8000"
    endpoint = f"{base_url}/api/auth/create-client/"
    
    # Données de test
    test_data = {
        "phone": "221771234567",
        "name": "Client Test"
    }
    
    print(f"🧪 Test de création de compte client...")
    print(f"📡 Endpoint: {endpoint}")
    print(f"📱 Données: {json.dumps(test_data, indent=2)}")
    
    try:
        # Faire la requête POST
        response = requests.post(
            endpoint,
            headers={"Content-Type": "application/json"},
            json=test_data,
            timeout=10
        )
        
        print(f"\n📊 Réponse:")
        print(f"   Status Code: {response.status_code}")
        print(f"   Headers: {dict(response.headers)}")
        
        if response.status_code in [200, 201]:
            try:
                data = response.json()
                print(f"   ✅ Succès!")
                print(f"   Token: {data.get('access', 'N/A')[:20]}...")
                print(f"   User ID: {data.get('user', {}).get('id', 'N/A')}")
                print(f"   Role: {data.get('user', {}).get('role', 'N/A')}")
                print(f"   Phone: {data.get('user', {}).get('phone', 'N/A')}")
            except json.JSONDecodeError:
                print(f"   ⚠️  Réponse non-JSON: {response.text}")
        else:
            print(f"   ❌ Erreur!")
            try:
                error_data = response.json()
                print(f"   Message: {error_data.get('error', 'Erreur inconnue')}")
            except:
                print(f"   Message: {response.text}")
                
    except requests.exceptions.ConnectionError:
        print(f"❌ Erreur de connexion: Impossible de se connecter à {base_url}")
        print("   Assurez-vous que le serveur Django est démarré")
    except requests.exceptions.Timeout:
        print(f"❌ Timeout: La requête a pris trop de temps")
    except Exception as e:
        print(f"❌ Erreur inattendue: {e}")

def test_client_login():
    """Tester la connexion client avec le même numéro"""
    
    base_url = "http://localhost:8000"
    endpoint = f"{base_url}/api/auth/client-login/"
    
    test_data = {
        "phone": "221771234567"
    }
    
    print(f"\n🧪 Test de connexion client...")
    print(f"📡 Endpoint: {endpoint}")
    
    try:
        response = requests.post(
            endpoint,
            headers={"Content-Type": "application/json"},
            json=test_data,
            timeout=10
        )
        
        print(f"📊 Réponse:")
        print(f"   Status Code: {response.status_code}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                print(f"   ✅ Connexion réussie!")
                print(f"   Token: {data.get('access', 'N/A')[:20]}...")
                print(f"   User ID: {data.get('user', {}).get('id', 'N/A')}")
            except json.JSONDecodeError:
                print(f"   ⚠️  Réponse non-JSON: {response.text}")
        else:
            print(f"   ❌ Erreur de connexion!")
            
    except Exception as e:
        print(f"❌ Erreur: {e}")

if __name__ == "__main__":
    print("🚀 Test de l'API d'authentification client")
    print("=" * 50)
    
    # Test 1: Création de compte
    test_create_client()
    
    # Test 2: Connexion avec le même numéro
    test_client_login()
    
    print("\n" + "=" * 50)
    print("✅ Tests terminés!")
