#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test d'intégration Flutter - Simulation complète de l'app
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def test_flutter_integration():
    print("📱 TEST D'INTÉGRATION FLUTTER - VALIDER-PANIER")
    print("=" * 60)
    
    # Simulation exacte des données envoyées par Flutter
    flutter_data = {
        "items": [
            {
                "nom": "Plat personnalisé - Riz",
                "prix": 1500.0,
                "base": {
                    "nom": "Riz",
                    "prix": 500.0,
                    "id": 1
                },
                "ingredients": [
                    {
                        "nom": "Poulet",
                        "prix": 1000.0,
                        "id": 1
                    }
                ],
                "type": "custom",
                "quantity": 1
            },
            {
                "nom": "Thiéboudienne",
                "prix": 1200.0,
                "type": "menu",
                "quantity": 2
            }
        ],
        "phone": "+221777123456",
        "client_name": "Mamadou Diallo",
        "restaurant_id": 1
    }
    
    print("📋 Données Flutter simulées:")
    print(f"   - {len(flutter_data['items'])} items dans le panier")
    print(f"   - Téléphone: {flutter_data['phone']}")
    print(f"   - Client: {flutter_data['client_name']}")
    print(f"   - Restaurant ID: {flutter_data['restaurant_id']}")
    
    try:
        print("\n📤 Envoi de la requête POST à /api/orders/valider-panier/...")
        response = requests.post(
            f"{BASE_URL}/api/orders/valider-panier/",
            json=flutter_data,
            headers={'Content-Type': 'application/json'},
            timeout=10
        )
        
        print(f"📊 Status HTTP: {response.status_code}")
        
        if response.status_code == 201:
            data = response.json()
            print("✅ SUCCÈS! Intégration Flutter réussie!")
            print(f"   ID commande: {data.get('commande', {}).get('id')}")
            print(f"   Message: {data.get('message')}")
            print(f"   Status: {data.get('commande', {}).get('status')}")
            print(f"   Total: {data.get('commande', {}).get('total_amount')} F")
            print(f"   Items: {len(data.get('commande', {}).get('items', []))}")
            
            # Vérifier que la commande est bien en attente
            if data.get('commande', {}).get('status') == 'en_attente':
                print("   ✅ Status correct: commande en attente")
            else:
                print(f"   ⚠️ Status inattendu: {data.get('commande', {}).get('status')}")
            
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

def test_error_handling():
    print("\n🚨 TEST DE GESTION D'ERREURS")
    print("=" * 40)
    
    # Test 1: Panier vide
    print("1. Test panier vide...")
    try:
        response = requests.post(
            f"{BASE_URL}/api/orders/valider-panier/",
            json={"items": [], "restaurant_id": 1},
            headers={'Content-Type': 'application/json'}
        )
        if response.status_code == 400:
            print("   ✅ Erreur 400 correcte pour panier vide")
        else:
            print(f"   ⚠️ Status inattendu: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Exception: {e}")
    
    # Test 2: Restaurant manquant
    print("2. Test restaurant manquant...")
    try:
        response = requests.post(
            f"{BASE_URL}/api/orders/valider-panier/",
            json={"items": [{"nom": "Test", "prix": 1000}], "restaurant_id": None},
            headers={'Content-Type': 'application/json'}
        )
        if response.status_code == 400:
            print("   ✅ Erreur 400 correcte pour restaurant manquant")
        else:
            print(f"   ⚠️ Status inattendu: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Exception: {e}")

if __name__ == "__main__":
    print("🧪 TEST COMPLET D'INTÉGRATION FLUTTER")
    print("=" * 60)
    
    # Test principal
    success = test_flutter_integration()
    
    # Test de gestion d'erreurs
    test_error_handling()
    
    if success:
        print("\n🎉 L'intégration Flutter est parfaitement fonctionnelle!")
        print("   L'erreur 'Method Not Allowed' est maintenant résolue.")
        print("   L'endpoint /api/orders/valider-panier/ accepte les requêtes POST.")
    else:
        print("\n💥 Il y a encore un problème avec l'intégration.")
