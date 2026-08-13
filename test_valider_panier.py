#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test du nouvel endpoint valider-panier
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def test_valider_panier():
    print("🧪 TEST NOUVEL ENDPOINT VALIDER-PANIER")
    print("=" * 50)
    
    # Test data
    test_data = {
        "items": [
            {
                "nom": "Plat test",
                "prix": 1500.0,
                "quantity": 2,
                "base": {"nom": "Riz", "prix": 500.0},
                "ingredients": [
                    {"nom": "Poulet", "prix": 1000.0}
                ]
            }
        ],
        "phone": "999test123",
        "client_name": "Client Test",
        "restaurant_id": 1
    }
    
    try:
        print("📤 Envoi de la requête POST...")
        response = requests.post(
            f"{BASE_URL}/api/orders/valider-panier/",
            json=test_data,
            timeout=10
        )
        
        print(f"📊 Status: {response.status_code}")
        print(f"📄 Response: {response.text[:200]}...")
        
        if response.status_code == 201:
            data = response.json()
            print("✅ SUCCÈS! Panier validé avec succès!")
            print(f"   ID commande: {data.get('commande', {}).get('id')}")
            print(f"   Message: {data.get('message')}")
            print(f"   Status: {data.get('commande', {}).get('status')}")
            return True
        else:
            print(f"❌ ÉCHEC: {response.status_code}")
            try:
                error_data = response.json()
                print(f"   Erreur: {error_data.get('error', 'Erreur inconnue')}")
            except:
                print(f"   Erreur: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ EXCEPTION: {e}")
        return False

if __name__ == "__main__":
    success = test_valider_panier()
    if success:
        print("\n🎉 Le nouvel endpoint valider-panier fonctionne parfaitement!")
    else:
        print("\n💥 Il y a encore un problème avec l'endpoint.")
