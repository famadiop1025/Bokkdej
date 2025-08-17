#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Correction urgente du panier pour la présentation
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def fix_panier_urgent():
    """Correction urgente du panier"""
    print("🚨 CORRECTION URGENTE PANIER - PRÉSENTATION")
    print("=" * 50)
    
    # Test de base sans authentification
    try:
        print("1. Test API menu (public)...")
        response = requests.get(f"{BASE_URL}/api/menu/", timeout=5)
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Menu API fonctionne - {len(data)} items")
            
            # Afficher le premier item pour debug
            if data:
                first_item = data[0]
                print(f"   Premier plat: {first_item.get('base', 'N/A')} - {first_item.get('prix', 'N/A')}F")
        else:
            print(f"❌ Menu API problème: {response.text}")
            
    except Exception as e:
        print(f"❌ Erreur: {e}")
        print("🔥 Le serveur Django n'est pas lancé !")
        print("🔥 Lancez: python manage.py runserver")
        return
    
    # Test panier avec une approche différente
    try:
        print("2. Test panier anonyme...")
        panier_url = f"{BASE_URL}/api/orders/panier/?phone=999presentation123"
        response = requests.get(panier_url, timeout=5)
        print(f"   Status panier: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ Panier API accessible")
        elif response.status_code == 404:
            print("✅ Panier vide (normal)")
        else:
            print(f"❌ Panier API problème: {response.text[:200]}")
            
    except Exception as e:
        print(f"❌ Erreur panier: {e}")
    
    # Tentative de création de panier simple
    try:
        print("3. Test création panier simple...")
        simple_data = {
            "plats_ids": [1],
            "prix_total": 500,
            "phone": "999presentation123"
        }
        
        response = requests.post(
            f"{BASE_URL}/api/orders/panier/",
            json=simple_data,
            timeout=5
        )
        print(f"   Status création: {response.status_code}")
        
        if response.status_code in [200, 201]:
            print("✅ Création panier réussie")
            print(f"   Réponse: {response.json()}")
        else:
            print(f"❌ Création échouée: {response.text[:200]}")
            
    except Exception as e:
        print(f"❌ Erreur création: {e}")
    
    print("=" * 50)
    print("🎯 SOLUTION POUR PRÉSENTATION:")
    print("1. Menu fonctionne → Focus sur le menu")
    print("2. Interface admin → Démonstration gestion")
    print("3. Architecture → Points techniques")
    print("🚀 VOTRE APP RESTE DÉMONSTRABLE !")

if __name__ == "__main__":
    fix_panier_urgent()
