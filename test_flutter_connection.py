#!/usr/bin/env python
import requests
import json

def test_flutter_connection():
    """Test de la connexion Flutter avec l'API"""
    print("🧪 Test de la connexion Flutter...")
    
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
            access_token = token_data.get('access')
            user_data = token_data.get('user', {})
            
            print(f"🔑 Token d'accès: {access_token[:50]}...")
            print(f"👤 Utilisateur: {user_data.get('username', 'N/A')}")
            print(f"🏷️ Rôle: {user_data.get('role', 'N/A')}")
            print(f"🆔 ID: {user_data.get('id', 'N/A')}")
            
            # Test avec le token
            print("\n🧪 Test d'accès avec le token...")
            headers = {'Authorization': f'Bearer {access_token}'}
            menu_response = requests.get("http://localhost:8000/api/menu/", headers=headers)
            print(f"📡 Statut menu: {menu_response.status_code}")
            
            if menu_response.status_code == 200:
                print("✅ Accès au menu réussi!")
            else:
                print("❌ Échec d'accès au menu")
                
        else:
            print("❌ Échec de la connexion PIN")
            
    except requests.exceptions.ConnectionError:
        print("❌ Impossible de se connecter au serveur Django")
        print("💡 Assurez-vous que le serveur Django fonctionne sur http://localhost:8000")
    except Exception as e:
        print(f"❌ Erreur: {e}")

if __name__ == '__main__':
    test_flutter_connection() 