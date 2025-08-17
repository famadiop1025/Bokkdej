#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile

def create_test_users():
    """Créer des utilisateurs de test avec des PINs"""
    
    print("🧹 Nettoyage de la base de données...")
    
    # Supprimer tous les profils orphelins
    UserProfile.objects.all().delete()
    
    # Supprimer les utilisateurs existants
    User.objects.filter(username__in=['admin', 'staff']).delete()
    
    print("✅ Nettoyage terminé")
    
    # Créer l'utilisateur admin
    print("👤 Création de l'utilisateur admin...")
    admin_user = User.objects.create_user(
        username='admin',
        email='admin@bokdej.com',
        password='admin123'
    )
    
    # Créer le profil admin avec PIN 1234
    UserProfile.objects.create(
        user=admin_user,
        role='admin',
        phone='12345678901234'  # Le PIN est les 4 derniers chiffres
    )
    
    # Créer l'utilisateur staff
    print("👤 Création de l'utilisateur staff...")
    staff_user = User.objects.create_user(
        username='staff',
        email='staff@bokdej.com',
        password='staff123'
    )
    
    # Créer le profil staff avec PIN 5678
    UserProfile.objects.create(
        user=staff_user,
        role='client',  # Role client pour le staff
        phone='12345678905678'  # Le PIN est les 4 derniers chiffres
    )
    
    print("✅ Utilisateurs de test créés avec succès!")
    print("📱 Admin: PIN 1234 (phone: 12345678901234)")
    print("📱 Staff: PIN 5678 (phone: 12345678905678)")
    print("🔑 Identifiants:")
    print("   - Admin: admin / admin123")
    print("   - Staff: staff / staff123")

if __name__ == '__main__':
    create_test_users() 