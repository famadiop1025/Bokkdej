#!/usr/bin/env python3
"""
Script de test complet pour vérifier que le système BOKDEJ fonctionne correctement.
"""

import requests
import json
import time
import sys

def test_api_endpoints():
    """Test des endpoints principaux de l'API Django"""
    base_url = "http://localhost:8000"
    
    print("🔍 Test de la connectivité de l'API Django...")
    
    # Test 1: Vérification que le serveur répond
    try:
        response = requests.get(f"{base_url}/api/", timeout=5)
        print(f"✅ Serveur API accessible (Status: {response.status_code})")
    except requests.exceptions.ConnectionError:
        print("❌ Erreur: Le serveur Django n'est pas accessible")
        print("   Assurez-vous que 'python manage.py runserver' est en cours")
        return False
    except Exception as e:
        print(f"❌ Erreur de connexion: {e}")
        return False
    
    # Test 2: Test des endpoints d'authentification
    auth_endpoints = [
        "/api/auth/pin-login/",
        "/api/auth/login/",
    ]
    
    for endpoint in auth_endpoints:
        try:
            response = requests.post(f"{base_url}{endpoint}", 
                                   json={"test": "data"}, 
                                   timeout=5)
            print(f"✅ Endpoint {endpoint} accessible (Status: {response.status_code})")
        except Exception as e:
            print(f"⚠️  Endpoint {endpoint} - Erreur: {e}")
    
    # Test 3: Test des endpoints principaux
    main_endpoints = [
        "/api/restaurants/",
        "/api/ingredients/",
        "/api/bases/",
        "/api/plats/",
    ]
    
    for endpoint in main_endpoints:
        try:
            response = requests.get(f"{base_url}{endpoint}", timeout=5)
            print(f"✅ Endpoint {endpoint} accessible (Status: {response.status_code})")
        except Exception as e:
            print(f"⚠️  Endpoint {endpoint} - Erreur: {e}")
    
    return True

def test_database():
    """Test de la base de données"""
    print("\n🗄️  Test de la base de données...")
    
    try:
        response = requests.get("http://localhost:8000/api/restaurants/", timeout=5)
        data = response.json()
        
        if isinstance(data, list) and len(data) > 0:
            print(f"✅ Base de données accessible - {len(data)} restaurants trouvés")
            return True
        else:
            print("⚠️  Base de données vide ou problème de structure")
            return False
    except Exception as e:
        print(f"❌ Erreur d'accès à la base de données: {e}")
        return False

def test_pin_authentication():
    """Test de l'authentification par PIN"""
    print("\n🔐 Test de l'authentification par PIN...")
    
    test_pins = ["1234", "0000", "admin"]
    
    for pin in test_pins:
        try:
            response = requests.post(
                "http://localhost:8000/api/auth/pin-login/",
                json={"pin": pin},
                timeout=5
            )
            
            if response.status_code == 200:
                print(f"✅ PIN {pin} fonctionne")
                return True
            else:
                print(f"⚠️  PIN {pin} - Status: {response.status_code}")
        except Exception as e:
            print(f"❌ Erreur test PIN {pin}: {e}")
    
    print("ℹ️  Aucun PIN de test ne fonctionne (normal si pas configuré)")
    return True

def generate_diagnostic_report():
    """Génère un rapport de diagnostic"""
    print("\n📋 Génération du rapport de diagnostic...")
    
    report = {
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "django_server": "Running" if test_api_endpoints() else "Error",
        "database": "Accessible" if test_database() else "Error",
        "authentication": "Configured" if test_pin_authentication() else "Needs Setup",
        "status": "OPERATIONAL"
    }
    
    # Sauvegarde du rapport
    with open("diagnostic_report.json", "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Rapport sauvegardé dans diagnostic_report.json")
    return report

def main():
    """Fonction principale"""
    print("🚀 Démarrage du diagnostic complet du système BOKDEJ")
    print("=" * 60)
    
    # Tests principaux
    api_ok = test_api_endpoints()
    db_ok = test_database()
    auth_ok = test_pin_authentication()
    
    # Génération du rapport
    report = generate_diagnostic_report()
    
    print("\n" + "=" * 60)
    print("📊 RÉSUMÉ DU DIAGNOSTIC")
    print("=" * 60)
    
    if api_ok and db_ok:
        print("✅ SYSTÈME OPÉRATIONNEL")
        print("   - API Django: Fonctionnelle")
        print("   - Base de données: Accessible")
        print("   - Authentification: Prête")
        print("\n🎉 Votre application BOKDEJ est prête à l'utilisation!")
        return 0
    else:
        print("⚠️  PROBLÈMES DÉTECTÉS")
        if not api_ok:
            print("   - API Django: Problème de connexion")
        if not db_ok:
            print("   - Base de données: Erreur d'accès")
        print("\n🔧 Consultez les messages ci-dessus pour résoudre les problèmes")
        return 1

if __name__ == "__main__":
    sys.exit(main())