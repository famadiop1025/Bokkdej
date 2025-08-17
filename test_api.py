#!/usr/bin/env python
import requests
import json

BASE_URL = "http://localhost:8000"

def test_api_endpoint(endpoint, name):
    """Teste un endpoint API et affiche les résultats"""
    print(f"\n=== Test de {name} ===")
    try:
        response = requests.get(f"{BASE_URL}{endpoint}")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Nombre d'éléments: {len(data)}")
            if len(data) > 0:
                print(f"Premier élément: {data[0]}")
            else:
                print("Aucune donnée trouvée")
        else:
            print(f"Erreur: {response.text}")
    except Exception as e:
        print(f"Erreur de connexion: {e}")

def main():
    print("=== Test des APIs Bokk Déj' ===\n")
    
    # Test des endpoints principaux
    test_api_endpoint("/api/menu/", "Menu")
    test_api_endpoint("/api/ingredients/", "Ingrédients")
    test_api_endpoint("/api/bases/", "Bases")
    test_api_endpoint("/api/restaurants/", "Restaurants")
    test_api_endpoint("/api/orders/", "Commandes")
    
    print("\n=== Test terminé ===")

if __name__ == "__main__":
    main() 