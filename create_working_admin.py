#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile

def create_working_admin():
    print("=== Creation admin fonctionnel ===")
    
    # Supprimer l'utilisateur s'il existe
    try:
        old_user = User.objects.get(username='123456789')
        old_user.delete()
        print("Ancien utilisateur supprime")
    except User.DoesNotExist:
        pass
    
    # Créer l'utilisateur
    user = User.objects.create_user(
        username='123456789',  # Téléphone comme username
        password='1234',       # PIN comme password
        email='admin@test.com',
        is_staff=True,
        is_superuser=True,
        is_active=True
    )
    
    print(f"✅ Utilisateur cree: {user.username}")
    
    # Créer ou récupérer le profil
    profile, created = UserProfile.objects.get_or_create(
        user=user,
        defaults={
            'phone': '123456789',
            'role': 'admin'
        }
    )
    
    if not created:
        profile.phone = '123456789'
        profile.role = 'admin'
        profile.save()
    
    print(f"✅ Profil {'cree' if created else 'mis a jour'}: {profile.phone} - {profile.role}")
    
    print("\n" + "="*50)
    print("🔐 CONNEXION ADMIN FLUTTER")
    print("="*50)
    print("📱 Telephone: 123456789")
    print("🔑 PIN: 1234")
    print("\n1. Page d'accueil → 'Connexion Restaurant'")
    print("2. Entrer: 123456789")
    print("3. PIN: 1234")
    print("4. Se connecter!")
    print("\n✅ PRET POUR VOTRE PRESENTATION!")

if __name__ == '__main__':
    create_working_admin()
