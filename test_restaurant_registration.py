#!/usr/bin/env python
import os
import sys
import django
import requests
import json

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

def test_restaurant_registration():
    """Test de l'endpoint d'inscription des restaurants"""
    
    print("=== Test de l'inscription des restaurants ===")
    
    # URL de l'endpoint
    url = 'http://localhost:8000/api/restaurants/register/'
    
    # Données de test
    test_data = {
        'nom': 'Restaurant Test BOKDEJ',
        'adresse': '123 Avenue de la République, Dakar, Sénégal',
        'telephone': '221771234567',
        'email': 'test@restaurant.com',
        'nom_gerant': 'Moussa Diallo',
        'telephone_gerant': '221771234568',
        'type_cuisine': 'Cuisine sénégalaise',
        'capacite': 50,
        'horaires': '8h-22h tous les jours',
        'description': 'Restaurant de cuisine traditionnelle sénégalaise',
        'documents_legaux': True,
        # Configuration Wave
        'wave_payment_link': 'https://wave.com/pay/restaurant-test-bokdej',
        'wave_merchant_id': 'MERCHANT_TEST_123',
        'wave_api_key': 'sk_test_123456789abcdef'
    }
    
    try:
        # Faire la requête POST
        response = requests.post(
            url,
            headers={'Content-Type': 'application/json'},
            data=json.dumps(test_data)
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 201:
            print("✅ Inscription réussie !")
            response_data = response.json()
            print(f"Restaurant ID: {response_data.get('restaurant_id')}")
            print(f"Statut: {response_data.get('statut')}")
        else:
            print("❌ Erreur lors de l'inscription")
            
    except requests.exceptions.ConnectionError:
        print("❌ Impossible de se connecter au serveur")
        print("Assurez-vous que le serveur Django est démarré sur localhost:8000")
    except Exception as e:
        print(f"❌ Erreur: {e}")

def test_registration_info():
    """Test de l'endpoint d'informations sur l'inscription"""
    
    print("\n=== Test des informations d'inscription ===")
    
    url = 'http://localhost:8000/api/restaurants/register-info/'
    
    try:
        response = requests.get(url)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ Informations récupérées avec succès !")
            data = response.json()
            print("Processus d'inscription:")
            for etape in data['process']['etapes']:
                print(f"  {etape}")
        else:
            print("❌ Erreur lors de la récupération des informations")
            
    except requests.exceptions.ConnectionError:
        print("❌ Impossible de se connecter au serveur")
    except Exception as e:
        print(f"❌ Erreur: {e}")

if __name__ == '__main__':
    print("Test du système d'inscription des restaurants BOKDEJ")
    print("=" * 50)
    
    # Tester les informations d'inscription
    test_registration_info()
    
    # Tester l'inscription
    test_restaurant_registration()
    
    print("\n" + "=" * 50)
    print("Test terminé !")
