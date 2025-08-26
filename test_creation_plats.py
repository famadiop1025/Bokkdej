#!/usr/bin/env python
import requests
import json

def test_creation_plat():
    """Test de création d'un plat via l'API admin"""
    
    base_url = "http://localhost:8000"
    
    # 1. Connexion admin
    print("🔐 Connexion admin...")
    login_data = {
        "pin": "1234"
    }
    
    try:
        login_response = requests.post(
            f"{base_url}/api/auth/pin-login/",
            json=login_data,
            headers={'Content-Type': 'application/json'}
        )
        
        if login_response.status_code != 200:
            print(f"❌ Erreur connexion: {login_response.status_code}")
            print(login_response.text)
            return
            
        token_data = login_response.json()
        token = token_data['access']
        print("✅ Connexion réussie")
        
    except Exception as e:
        print(f"❌ Erreur connexion: {e}")
        return
    
    # 2. Récupérer un restaurant
    print("\n🏪 Récupération d'un restaurant...")
    try:
        restaurants_response = requests.get(
            f"{base_url}/api/restaurants/",
            headers={'Authorization': f'Bearer {token}'}
        )
        
        if restaurants_response.status_code != 200:
            print(f"❌ Erreur récupération restaurants: {restaurants_response.status_code}")
            return
            
        restaurants = restaurants_response.json()
        if not restaurants:
            print("❌ Aucun restaurant trouvé")
            return
            
        restaurant = restaurants[0]
        restaurant_id = restaurant['id']
        print(f"✅ Restaurant trouvé: {restaurant['nom']} (ID: {restaurant_id})")
        
    except Exception as e:
        print(f"❌ Erreur récupération restaurant: {e}")
        return
    
    # 3. Créer un plat
    print("\n🍽️ Création d'un plat...")
    plat_data = {
        "nom": "Test Plat Création",
        "prix": "1500.00",
        "type": "dej",
        "description": "Plat de test pour vérifier la création",
        "restaurant": restaurant_id,
        "disponible": True,
        "populaire": False,
        "plat_du_jour": False,
        "temps_preparation": 25,
        "calories": 450
    }
    
    try:
        creation_response = requests.post(
            f"{base_url}/api/admin/menu/",
            json=plat_data,
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json'
            }
        )
        
        print(f"📊 Statut réponse: {creation_response.status_code}")
        print(f"📝 Contenu réponse: {creation_response.text}")
        
        if creation_response.status_code == 201:
            plat_creer = creation_response.json()
            print(f"✅ Plat créé avec succès! ID: {plat_creer['id']}")
            
            # 4. Vérifier que le plat existe
            print("\n🔍 Vérification de l'existence du plat...")
            verification_response = requests.get(
                f"{base_url}/api/admin/menu/{plat_creer['id']}/",
                headers={'Authorization': f'Bearer {token}'}
            )
            
            if verification_response.status_code == 200:
                plat_verifie = verification_response.json()
                print(f"✅ Plat vérifié: {plat_verifie['nom']} - {plat_verifie['prix']} F")
            else:
                print(f"❌ Erreur vérification: {verification_response.status_code}")
                
        else:
            print(f"❌ Erreur création: {creation_response.status_code}")
            print(f"📝 Détails: {creation_response.text}")
            
    except Exception as e:
        print(f"❌ Erreur création plat: {e}")
    
    print("\n🏁 Test terminé!")

if __name__ == "__main__":
    test_creation_plat()
