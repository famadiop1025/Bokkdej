import requests
import json

def test_restaurants_endpoint():
    base_url = "http://localhost:8000"
    
    print("Test de l'endpoint restaurants...")
    
    try:
        # Test de l'endpoint principal
        response = requests.get(f"{base_url}/api/restaurants/")
        print(f"GET /api/restaurants/ - Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Nombre de restaurants: {len(data)}")
            
            for i, restaurant in enumerate(data, 1):
                print(f"\nRestaurant {i}:")
                print(f"  ID: {restaurant.get('id')}")
                print(f"  Nom: {restaurant.get('nom')}")
                print(f"  Adresse: {restaurant.get('adresse')}")
                print(f"  Telephone: {restaurant.get('telephone')}")
                print(f"  Description: {restaurant.get('description')}")
                print(f"  Statut: {restaurant.get('statut')}")
                print(f"  Actif: {restaurant.get('actif')}")
        else:
            print(f"Erreur: {response.text}")
            
    except Exception as e:
        print(f"Erreur de connexion: {e}")
    
    # Test aussi de l'URL complete que Flutter utilise
    print(f"\nTest de l'URL complete...")
    try:
        response = requests.get(f"{base_url}/api/restaurants/", 
                               headers={'Content-Type': 'application/json'})
        print(f"Avec headers - Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Reponse JSON: {json.dumps(data, indent=2, ensure_ascii=False)}")
    except Exception as e:
        print(f"Erreur: {e}")

if __name__ == "__main__":
    test_restaurants_endpoint()
