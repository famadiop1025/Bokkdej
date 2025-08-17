#!/usr/bin/env python3
"""
Test rapide pour diagnostiquer l'erreur 415 lors de l'upload d'images
"""

import requests
import os

def test_upload_endpoints():
    """Tester les différents endpoints d'upload"""
    
    # Token admin généré précédemment
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU0NTMyNDA5LCJpYXQiOjE3NTQ1MzIxMDksImp0aSI6IjYyYTI0MWEzY2IzMzQ0MDM5ZTRmMTgzYWIzYzM2NjY0IiwidXNlcl9pZCI6IjEyIn0.O5dhPgl_vrsPIDxOFlAjfkMwIERtgROxcaym84MHZNA"
    
    headers = {
        'Authorization': f'Bearer {token}',
    }
    
    base_url = 'http://localhost:8000'
    
    print("🔍 Test des endpoints d'upload...")
    print("=" * 50)
    
    # Test 1: Vérifier l'endpoint menu
    try:
        response = requests.get(f'{base_url}/api/menu/', headers=headers)
        print(f"✅ GET /api/menu/ - Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            if data:
                menu_id = data[0]['id']
                print(f"📝 Premier plat trouvé: ID {menu_id}")
                
                # Test 2: PATCH sur un menu existant (simulation)
                patch_headers = headers.copy()
                patch_headers['Content-Type'] = 'application/json'
                
                test_data = {'disponible': True}
                patch_response = requests.patch(
                    f'{base_url}/api/menu/{menu_id}/',
                    json=test_data,
                    headers=patch_headers
                )
                print(f"✅ PATCH /api/menu/{menu_id}/ - Status: {patch_response.status_code}")
                
    except Exception as e:
        print(f"❌ Erreur lors du test: {e}")
    
    # Test 3: Vérifier les permissions
    try:
        # Test sans Content-Type pour multipart
        test_headers = {'Authorization': f'Bearer {token}'}
        response = requests.options(f'{base_url}/api/menu/', headers=test_headers)
        print(f"✅ OPTIONS /api/menu/ - Status: {response.status_code}")
        print(f"📋 Headers autorisés: {response.headers.get('Allow', 'Non spécifié')}")
        
    except Exception as e:
        print(f"❌ Erreur OPTIONS: {e}")
    
    # Test 4: Endpoint upload-image
    try:
        response = requests.get(f'{base_url}/api/upload-image/', headers=headers)
        print(f"✅ GET /api/upload-image/ - Status: {response.status_code}")
    except Exception as e:
        print(f"❌ /api/upload-image/ non disponible: {e}")
    
    print("\n🎯 DIAGNOSTIC:")
    print("=" * 50)
    print("Pour corriger l'erreur 415:")
    print("1. ✅ Utiliser PATCH /api/menu/{id}/ directement")
    print("2. ✅ Ne pas spécifier Content-Type pour multipart")
    print("3. ✅ Utiliser le token admin généré")
    print("4. ✅ Envoyer seulement le champ 'image' en multipart")

if __name__ == "__main__":
    test_upload_endpoints()
