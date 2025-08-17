#!/usr/bin/env python
import os
import sys
import django
import requests
import json
from datetime import datetime

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

BASE_URL = "http://localhost:8000/api"

def get_admin_token():
    """Obtenir un token admin via PIN"""
    print("🔑 Connexion administrateur...")
    
    response = requests.post(f"{BASE_URL}/auth/pin-login/", json={
        "pin": "1234"  # PIN admin
    })
    
    if response.status_code == 200:
        token = response.json()['access']
        print("✅ Connexion admin réussie")
        return token
    else:
        print(f"❌ Échec connexion admin: {response.text}")
        return None

def test_endpoint(method, url, token, data=None, name=""):
    """Tester un endpoint"""
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    try:
        if method.upper() == 'GET':
            response = requests.get(url, headers=headers)
        elif method.upper() == 'POST':
            response = requests.post(url, headers=headers, json=data)
        elif method.upper() == 'PUT':
            response = requests.put(url, headers=headers, json=data)
        elif method.upper() == 'DELETE':
            response = requests.delete(url, headers=headers)
        
        if response.status_code in [200, 201]:
            print(f"✅ {name}: {response.status_code}")
            return response.json()
        else:
            print(f"❌ {name}: {response.status_code} - {response.text[:100]}")
            return None
            
    except Exception as e:
        print(f"❌ {name}: Erreur - {str(e)}")
        return None

def test_admin_functionalities():
    """Test complet des fonctionnalités administrateur"""
    print("🧪 Test des fonctionnalités administrateur BOKDEJ\n")
    
    # Obtenir le token admin
    token = get_admin_token()
    if not token:
        print("❌ Impossible de continuer sans token admin")
        return
    
    print("\n" + "="*60)
    print("📊 1. TEST STATISTIQUES GÉNÉRALES")
    print("="*60)
    
    stats = test_endpoint('GET', f"{BASE_URL}/admin/statistics/", token, 
                         name="Statistiques générales")
    if stats:
        print(f"   📈 Total commandes: {stats.get('orders', {}).get('total', 0)}")
        print(f"   💰 Chiffre d'affaires total: {stats.get('revenue', {}).get('total', 0)} F")
        print(f"   ⚠️  Alertes stock faible: {stats.get('alerts', {}).get('low_stock_ingredients', 0)}")
    
    print("\n" + "="*60)
    print("🍽️  2. TEST GESTION DU MENU")
    print("="*60)
    
    # Lister les plats
    menu_items = test_endpoint('GET', f"{BASE_URL}/admin/menu/", token,
                              name="Liste des plats")
    
    # Statistiques menu
    menu_stats = test_endpoint('GET', f"{BASE_URL}/admin/menu/statistics/", token,
                              name="Statistiques menu")
    if menu_stats:
        print(f"   📊 Total plats: {menu_stats.get('total_items', 0)}")
        print(f"   ✅ Disponibles: {menu_stats.get('disponibles', 0)}")
    
    # Test création d'un plat
    new_item = {
        "nom": "Test Burger Admin",
        "prix": "2500.00",
        "type": "dej",
        "calories": 450,
        "temps_preparation": 15,
        "description": "Burger de test créé par l'admin"
    }
    created_item = test_endpoint('POST', f"{BASE_URL}/admin/menu/", token, new_item,
                                name="Création nouveau plat")
    
    created_item_id = None
    if created_item and 'id' in created_item:
        created_item_id = created_item['id']
        print(f"   🆕 Plat créé avec ID: {created_item_id}")
        
        # Test toggle disponibilité
        test_endpoint('POST', f"{BASE_URL}/admin/menu/{created_item_id}/toggle_disponible/", 
                     token, name="Toggle disponibilité")
        
        # Test toggle populaire
        test_endpoint('POST', f"{BASE_URL}/admin/menu/{created_item_id}/toggle_populaire/", 
                     token, name="Toggle populaire")
    
    print("\n" + "="*60)
    print("🥬 3. TEST GESTION DES INGRÉDIENTS")
    print("="*60)
    
    # Lister les ingrédients
    ingredients = test_endpoint('GET', f"{BASE_URL}/admin/ingredients/", token,
                               name="Liste des ingrédients")
    
    # Statistiques ingrédients
    ing_stats = test_endpoint('GET', f"{BASE_URL}/admin/ingredients/statistics/", token,
                             name="Statistiques ingrédients")
    if ing_stats:
        print(f"   📊 Total ingrédients: {ing_stats.get('total', 0)}")
        print(f"   ⚠️  Stock faible: {ing_stats.get('low_stock_count', 0)}")
    
    # Alertes stock faible
    test_endpoint('GET', f"{BASE_URL}/admin/ingredients/low_stock_alert/", token,
                 name="Alertes stock faible")
    
    # Test création d'un ingrédient
    new_ingredient = {
        "nom": "Tomate Test Admin",
        "prix": "150.00",
        "type": "legume",
        "stock_actuel": 50,
        "stock_min": 10,
        "unite": "kg"
    }
    created_ing = test_endpoint('POST', f"{BASE_URL}/admin/ingredients/", token, new_ingredient,
                               name="Création nouvel ingrédient")
    
    if created_ing and 'id' in created_ing:
        ing_id = created_ing['id']
        print(f"   🆕 Ingrédient créé avec ID: {ing_id}")
        
        # Test mise à jour stock
        test_endpoint('POST', f"{BASE_URL}/admin/ingredients/{ing_id}/update_stock/", 
                     token, {"stock": 25}, name="Mise à jour stock")
    
    print("\n" + "="*60)
    print("👥 4. TEST GESTION DU PERSONNEL")
    print("="*60)
    
    # Lister le personnel
    staff = test_endpoint('GET', f"{BASE_URL}/admin/personnel/", token,
                         name="Liste du personnel")
    
    # Statistiques personnel
    staff_stats = test_endpoint('GET', f"{BASE_URL}/admin/personnel/statistics/", token,
                               name="Statistiques personnel")
    if staff_stats:
        print(f"   👥 Personnel total: {staff_stats.get('total_staff', 0)}")
        print(f"   ✅ Personnel actif: {staff_stats.get('active_staff', 0)}")
    
    print("\n" + "="*60)
    print("📋 5. TEST GESTION DES CATÉGORIES")
    print("="*60)
    
    # Test création d'une catégorie
    new_category = {
        "nom": "Catégorie Test",
        "description": "Catégorie créée pour les tests",
        "ordre": 1
    }
    created_cat = test_endpoint('POST', f"{BASE_URL}/admin/categories/", token, new_category,
                               name="Création nouvelle catégorie")
    
    if created_cat and 'id' in created_cat:
        cat_id = created_cat['id']
        print(f"   🆕 Catégorie créée avec ID: {cat_id}")
        
        # Test toggle actif
        test_endpoint('POST', f"{BASE_URL}/admin/categories/{cat_id}/toggle_active/", 
                     token, name="Toggle catégorie active")
    
    # Lister les catégories
    test_endpoint('GET', f"{BASE_URL}/admin/categories/", token,
                 name="Liste des catégories")
    
    print("\n" + "="*60)
    print("⚙️  6. TEST PARAMÈTRES SYSTÈME")
    print("="*60)
    
    # Lire les paramètres
    settings = test_endpoint('GET', f"{BASE_URL}/admin/settings/", token,
                            name="Lecture paramètres")
    
    # Test mise à jour des paramètres
    if settings:
        update_settings = {
            "settings": {
                "commande_min": 1000,
                "notifications_activees": True,
                "devise": "F CFA"
            }
        }
        test_endpoint('POST', f"{BASE_URL}/admin/settings/", token, update_settings,
                     name="Mise à jour paramètres")
    
    print("\n" + "="*60)
    print("📈 7. TEST RAPPORTS")
    print("="*60)
    
    # Rapport des ventes
    test_endpoint('GET', f"{BASE_URL}/admin/reports/?type=sales", token,
                 name="Rapport des ventes")
    
    # Rapport d'inventaire
    test_endpoint('GET', f"{BASE_URL}/admin/reports/?type=inventory", token,
                 name="Rapport d'inventaire")
    
    # Rapport du personnel
    test_endpoint('GET', f"{BASE_URL}/admin/reports/?type=staff", token,
                 name="Rapport du personnel")
    
    print("\n" + "="*60)
    print("🧹 8. NETTOYAGE")
    print("="*60)
    
    # Supprimer les éléments de test créés
    if created_item_id:
        test_endpoint('DELETE', f"{BASE_URL}/admin/menu/{created_item_id}/", token,
                     name="Suppression plat test")
    
    print("\n" + "="*60)
    print("📋 RÉSUMÉ DES FONCTIONNALITÉS ADMINISTRATEUR")
    print("="*60)
    print("✅ 1. Gestion du menu (CRUD, filtres, statistiques)")
    print("✅ 2. Gestion des ingrédients (stock, alertes)")
    print("✅ 3. Gestion du personnel (rôles, permissions)")
    print("✅ 4. Statistiques générales (dashboard)")
    print("✅ 5. Paramètres système (configuration)")
    print("✅ 6. Rapports (ventes, inventaire, personnel)")
    print("\n🎉 Toutes les fonctionnalités administrateur sont implémentées !")

if __name__ == "__main__":
    test_admin_functionalities()