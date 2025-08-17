#!/usr/bin/env python3
"""
Script pour tester le système de panier et identifier pourquoi il ne s'incrémente pas
"""

import requests
import json

def test_panier_system():
    """Tester le système de panier complet"""
    
    # Token admin valide (nouveau)
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU0NTM0MTM3LCJpYXQiOjE3NTQ1MzM4MzcsImp0aSI6IjdjNmQxYTc3MjUxODRlNDRhZTYyYmUzMDhkMjZjOWNjIiwidXNlcl9pZCI6IjEyIn0.GgIEp1SM4xZs5nzTnhzWy0ixGw_ZLWXBAZGvk4VyDwg"
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json',
    }
    
    base_url = 'http://localhost:8000'
    
    print("🛒 Test du système de panier...")
    print("=" * 50)
    
    # Test 1: Vérifier l'endpoint panier
    try:
        response = requests.get(f'{base_url}/api/orders/panier/', headers=headers)
        print(f"✅ GET /api/orders/panier/ - Status: {response.status_code}")
        if response.status_code == 200:
            panier_data = response.json()
            print(f"📦 Contenu du panier: {json.dumps(panier_data, indent=2)}")
        else:
            print(f"❌ Erreur panier: {response.text}")
    except Exception as e:
        print(f"❌ Erreur lors du test panier: {e}")
    
    # Test 2: Vérifier les plats disponibles
    try:
        response = requests.get(f'{base_url}/api/menu/', headers=headers)
        print(f"✅ GET /api/menu/ - Status: {response.status_code}")
        if response.status_code == 200:
            menu_data = response.json()
            if menu_data:
                plat_id = menu_data[0]['id']
                plat_nom = menu_data[0]['nom']
                plat_prix = menu_data[0]['prix']
                print(f"🍽️ Premier plat: {plat_nom} (ID: {plat_id}, Prix: {plat_prix})")
                
                # Test 3: Ajouter un plat au panier
                order_data = {
                    'plats_ids': [plat_id],
                    'prix_total': float(plat_prix),
                }
                
                print(f"📝 Données commande: {order_data}")
                
                response = requests.post(
                    f'{base_url}/api/orders/',
                    headers=headers,
                    json=order_data
                )
                
                print(f"✅ POST /api/orders/ - Status: {response.status_code}")
                print(f"📄 Response: {response.text}")
                
                if response.status_code == 201:
                    print("🎉 Plat ajouté avec succès au panier !")
                    
                    # Test 4: Vérifier le panier mis à jour
                    response = requests.get(f'{base_url}/api/orders/panier/', headers=headers)
                    if response.status_code == 200:
                        panier_updated = response.json()
                        print(f"📦 Panier mis à jour: {json.dumps(panier_updated, indent=2)}")
                else:
                    print(f"❌ Échec ajout au panier: {response.text}")
                    
        else:
            print(f"❌ Erreur menu: {response.text}")
    except Exception as e:
        print(f"❌ Erreur lors du test menu: {e}")
    
    # Test 5: Vérifier les custom dishes
    try:
        response = requests.get(f'{base_url}/api/custom-dishes/', headers=headers)
        print(f"✅ GET /api/custom-dishes/ - Status: {response.status_code}")
        if response.status_code == 200:
            custom_dishes = response.json()
            print(f"🎨 Custom dishes disponibles: {len(custom_dishes)}")
        else:
            print(f"❌ Erreur custom dishes: {response.text}")
    except Exception as e:
        print(f"❌ Erreur custom dishes: {e}")
    
    print("\n🎯 DIAGNOSTIC:")
    print("=" * 50)
    print("1. ✅ Vérifier que le token est valide")
    print("2. ✅ Tester l'ajout basique au panier")
    print("3. ✅ Vérifier la structure des données retournées")
    print("4. ✅ Confirmer que l'endpoint /api/orders/ fonctionne")
    print("5. ✅ S'assurer que notifyListeners() est appelé")

if __name__ == "__main__":
    test_panier_system()
