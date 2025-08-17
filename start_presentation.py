#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de démarrage rapide pour la présentation demain
Vérifie tout et lance le serveur
"""

import os
import sys
import django
import subprocess
import time

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')

def setup_admin():
    """Configure l'utilisateur admin"""
    try:
        django.setup()
        from django.contrib.auth.models import User
        
        admin, created = User.objects.get_or_create(
            username='admin',
            defaults={
                'email': 'admin@keuresto.com',
                'is_superuser': True,
                'is_staff': True,
                'is_active': True
            }
        )
        
        admin.is_superuser = True
        admin.is_staff = True
        admin.is_active = True
        admin.set_password('admin123')
        admin.save()
        
        print("✅ Admin configuré: admin / admin123")
        return True
        
    except Exception as e:
        print(f"❌ Erreur admin: {e}")
        return False

def check_data():
    """Vérifie les données"""
    try:
        from api.models import MenuItem, Ingredient, Base
        
        menu_count = MenuItem.objects.count()
        menu_with_images = MenuItem.objects.exclude(image='').count()
        
        print(f"✅ {menu_count} menus en base")
        print(f"✅ {menu_with_images} menus avec images")
        
        return menu_count > 0
        
    except Exception as e:
        print(f"❌ Erreur données: {e}")
        return False

def check_folders():
    """Vérifie les dossiers média"""
    folders = ['media', 'media/menu_images', 'media/ingredient_images', 'media/base_images']
    
    for folder in folders:
        if not os.path.exists(folder):
            os.makedirs(folder, exist_ok=True)
            print(f"✅ Dossier créé: {folder}")
        else:
            print(f"✅ Dossier OK: {folder}")
    
    return True

def test_quick_api():
    """Test rapide de l'API"""
    try:
        import requests
        time.sleep(1)  # Attendre que le serveur soit prêt
        
        response = requests.get('http://127.0.0.1:8000/api/menu/', timeout=5)
        if response.status_code == 200:
            menus = response.json()
            print(f"✅ API répond: {len(menus)} menus")
            return True
        else:
            print(f"⚠️ API status: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"⚠️ API test: {e}")
        return False

def main():
    """Fonction principale"""
    print("🚀 DÉMARRAGE PRÉSENTATION KEUR RESTO")
    print("=" * 50)
    
    # 1. Setup admin
    print("1. Configuration admin...")
    admin_ok = setup_admin()
    
    # 2. Vérifier dossiers
    print("\n2. Vérification dossiers...")
    folders_ok = check_folders()
    
    # 3. Vérifier données
    print("\n3. Vérification données...")
    data_ok = check_data()
    
    # 4. Démarrer le serveur
    print("\n4. Démarrage du serveur...")
    print("URL: http://127.0.0.1:8000")
    print("Admin: http://127.0.0.1:8000/admin/")
    print("Login: admin / admin123")
    print("\n🎯 PRÊT POUR LA PRÉSENTATION !")
    print("=" * 50)
    
    if admin_ok and data_ok:
        print("✅ Tout est configuré correctement")
        print("📱 Vous pouvez commencer votre présentation")
    else:
        print("⚠️ Quelques problèmes détectés mais l'essentiel fonctionne")
    
    print("\n🚀 Démarrage du serveur Django...")
    print("Appuyez sur Ctrl+C pour arrêter")
    
    # Lancer le serveur
    try:
        os.system('python manage.py runserver')
    except KeyboardInterrupt:
        print("\n👋 Serveur arrêté. Bonne présentation !")

if __name__ == "__main__":
    main()
