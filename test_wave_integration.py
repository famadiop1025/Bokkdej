#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test d'intégration Wave - Système de paiement multi-restaurants
"""

import requests
import json
import time
from datetime import datetime

BASE_URL = "http://localhost:8000"

def test_wave_integration():
    print("🌊 TEST D'INTÉGRATION WAVE - SYSTÈME MULTI-RESTAURANTS")
    print("=" * 70)
    
    # Étape 1: Créer une commande
    print("1. 📱 Création d'une commande...")
    order_data = {
        "items": [
            {
                "nom": "Thiéboudienne Spéciale",
                "prix": 2500.0,
                "type": "menu",
                "quantity": 2,
                "ingredients": ["riz", "poisson", "légumes"]
            },
            {
                "nom": "Jus de Bissap",
                "prix": 500.0,
                "type": "boisson",
                "quantity": 1
            }
        ],
        "phone": "+221777123456",
        "client_name": "Moussa Diallo",
        "restaurant_id": 6
    }
    
    try:
        response = requests.post(f"{BASE_URL}/api/orders/valider-panier/", json=order_data)
        if response.status_code == 201:
            order = response.json()['commande']
            order_id = order['id']
            print(f"✅ Commande créée: #{order_id}")
            print(f"   Montant: {order['total_amount']} F CFA")
            print(f"   Restaurant: {order['restaurant']}")
        else:
            print(f"❌ Erreur création commande: {response.status_code}")
            print(f"   Réponse: {response.text}")
            return
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return
    
    # Étape 2: Configurer le restaurant avec un lien Wave (simulation)
    print("\n2. 🏪 Configuration du restaurant avec Wave...")
    # Note: Dans un vrai test, on configurerait le restaurant via l'admin
    print("   (Simulation: Restaurant configuré avec lien Wave)")
    
    # Étape 3: Créer un paiement Wave
    print("\n3. 💳 Création du paiement Wave...")
    payment_data = {
        "order_id": order_id
    }
    
    try:
        response = requests.post(f"{BASE_URL}/api/wave/create-payment/", json=payment_data)
        if response.status_code == 200:
            payment_info = response.json()
            print(f"✅ Paiement Wave créé")
            print(f"   URL: {payment_info['payment_url']}")
            print(f"   Montant: {payment_info['amount']} F CFA")
            print(f"   Restaurant: {payment_info['restaurant']}")
        else:
            print(f"❌ Erreur création paiement: {response.status_code}")
            print(f"   Réponse: {response.text}")
            return
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return
    
    # Étape 4: Vérifier le statut de paiement
    print("\n4. 🔍 Vérification du statut de paiement...")
    try:
        response = requests.get(f"{BASE_URL}/api/wave/payment-status/{order_id}/")
        if response.status_code == 200:
            status_info = response.json()
            print(f"✅ Statut récupéré")
            print(f"   Statut: {status_info['payment_status']}")
            print(f"   Méthode: {status_info['payment_method']}")
            print(f"   Montant: {status_info['amount']} F CFA")
            print(f"   Logs récents: {len(status_info['recent_logs'])} événements")
        else:
            print(f"❌ Erreur statut: {response.status_code}")
            print(f"   Réponse: {response.text}")
    except Exception as e:
        print(f"❌ Erreur: {e}")
    
    # Étape 5: Simuler un webhook de paiement réussi
    print("\n5. 🔔 Simulation webhook paiement réussi...")
    webhook_data = {
        "transaction_id": f"WAVE_TXN_{order_id}_{int(time.time())}",
        "reference": f"ORDER_{order_id}",
        "status": "success",
        "amount": float(order['total_amount']),
        "currency": "XOF",
        "timestamp": datetime.now().isoformat()
    }
    
    try:
        response = requests.post(f"{BASE_URL}/api/wave/webhook/", json=webhook_data)
        if response.status_code == 200:
            webhook_result = response.json()
            print(f"✅ Webhook traité: {webhook_result['status']}")
            print(f"   Message: {webhook_result['message']}")
        else:
            print(f"❌ Erreur webhook: {response.status_code}")
            print(f"   Réponse: {response.text}")
    except Exception as e:
        print(f"❌ Erreur: {e}")
    
    # Étape 6: Vérifier le statut final
    print("\n6. ✅ Vérification du statut final...")
    try:
        response = requests.get(f"{BASE_URL}/api/wave/payment-status/{order_id}/")
        if response.status_code == 200:
            final_status = response.json()
            print(f"✅ Statut final récupéré")
            print(f"   Statut: {final_status['payment_status']}")
            print(f"   Date paiement: {final_status['payment_date']}")
            print(f"   Transaction ID: {final_status['wave_transaction_id']}")
            
            if final_status['payment_status'] == 'paid':
                print("🎉 PAIEMENT CONFIRMÉ AVEC SUCCÈS!")
            else:
                print("⚠️ Paiement non confirmé")
        else:
            print(f"❌ Erreur statut final: {response.status_code}")
    except Exception as e:
        print(f"❌ Erreur: {e}")
    
    print("\n" + "=" * 70)
    print("🏁 TEST TERMINÉ")
    print("=" * 70)

def test_wave_error_cases():
    print("\n🧪 TEST DES CAS D'ERREUR WAVE")
    print("=" * 50)
    
    # Test 1: Commande inexistante
    print("1. ❌ Test commande inexistante...")
    try:
        response = requests.post(f"{BASE_URL}/api/wave/create-payment/", json={"order_id": 99999})
        if response.status_code == 404:
            print("✅ Erreur correctement gérée: Commande introuvable")
        else:
            print(f"❌ Erreur inattendue: {response.status_code}")
    except Exception as e:
        print(f"❌ Erreur: {e}")
    
    # Test 2: Données manquantes
    print("\n2. ❌ Test données manquantes...")
    try:
        response = requests.post(f"{BASE_URL}/api/wave/create-payment/", json={})
        if response.status_code == 400:
            print("✅ Erreur correctement gérée: ID de commande requis")
        else:
            print(f"❌ Erreur inattendue: {response.status_code}")
    except Exception as e:
        print(f"❌ Erreur: {e}")
    
    # Test 3: Webhook avec données invalides
    print("\n3. ❌ Test webhook invalide...")
    try:
        response = requests.post(f"{BASE_URL}/api/wave/webhook/", json={"invalid": "data"})
        if response.status_code == 400:
            print("✅ Erreur correctement gérée: Transaction ID manquant")
        else:
            print(f"❌ Erreur inattendue: {response.status_code}")
    except Exception as e:
        print(f"❌ Erreur: {e}")

if __name__ == "__main__":
    test_wave_integration()
    test_wave_error_cases()
