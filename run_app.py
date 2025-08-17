#!/usr/bin/env python
import os
import sys
import subprocess
import time
import requests

def check_django_server():
    """Vérifie si le serveur Django fonctionne"""
    try:
        response = requests.get("http://localhost:8000/api/menu/", timeout=5)
        return response.status_code == 200
    except:
        return False

def setup_django():
    """Configure Django avec les données de test"""
    print("=== Configuration de Django ===")
    
    # Vérifier si Django est déjà en cours d'exécution
    if check_django_server():
        print("✓ Serveur Django déjà en cours d'exécution")
        return True
    
    print("1. Application des migrations...")
    try:
        subprocess.run(["python", "manage.py", "migrate"], check=True, capture_output=True)
        print("   ✓ Migrations appliquées")
    except subprocess.CalledProcessError as e:
        print(f"   ✗ Erreur lors des migrations: {e}")
        return False
    
    print("2. Configuration des données de test...")
    try:
        subprocess.run(["python", "setup_test_data.py"], check=True, capture_output=True)
        print("   ✓ Données de test configurées")
    except subprocess.CalledProcessError as e:
        print(f"   ✗ Erreur lors de la configuration des données: {e}")
        return False
    
    print("3. Démarrage du serveur Django...")
    try:
        # Démarrer le serveur en arrière-plan
        subprocess.Popen(["python", "manage.py", "runserver"], 
                        stdout=subprocess.DEVNULL, 
                        stderr=subprocess.DEVNULL)
        
        # Attendre que le serveur démarre
        print("   Attente du démarrage du serveur...")
        for i in range(10):
            time.sleep(1)
            if check_django_server():
                print("   ✓ Serveur Django démarré avec succès")
                return True
            print(f"   Tentative {i+1}/10...")
        
        print("   ✗ Le serveur n'a pas démarré dans les temps")
        return False
        
    except Exception as e:
        print(f"   ✗ Erreur lors du démarrage du serveur: {e}")
        return False

def test_apis():
    """Teste toutes les APIs"""
    print("\n=== Test des APIs ===")
    
    if not check_django_server():
        print("✗ Serveur Django non disponible")
        return False
    
    try:
        subprocess.run(["python", "test_api.py"], check=True)
        print("✓ Tous les tests API réussis")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ Erreur lors des tests API: {e}")
        return False

def main():
    print("🚀 Démarrage de l'application Bokk Déj'")
    print("=" * 50)
    
    # Configuration de Django
    if not setup_django():
        print("\n❌ Échec de la configuration de Django")
        return
    
    # Test des APIs
    if not test_apis():
        print("\n❌ Échec des tests API")
        return
    
    print("\n" + "=" * 50)
    print("✅ Application prête !")
    print("\n📱 Pour lancer l'application Flutter :")
    print("   cd bokkdej_front")
    print("   flutter run")
    print("\n🌐 Serveur Django : http://localhost:8000")
    print("📊 Admin Django : http://localhost:8000/admin")
    print("\n🎯 Fonctionnalités disponibles :")
    print("   • Page d'accueil moderne")
    print("   • Menu dynamique avec catégories")
    print("   • Composition de plats personnalisés")
    print("   • Panier fonctionnel")
    print("   • Historique des commandes")
    print("   • Authentification utilisateur")
    print("\n💡 Toutes les données sont dynamiques !")

if __name__ == "__main__":
    main() 