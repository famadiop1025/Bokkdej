#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile, Restaurant

def clean_and_create_admin():
    print("=== Nettoyage et creation admin PIN ===")
    
    # Supprimer tous les profils utilisateur existants
    UserProfile.objects.all().delete()
    print("✅ Profils utilisateur supprimes")
    
    # Supprimer tous les utilisateurs admin
    User.objects.filter(username__in=['admin', '123456789']).delete()
    print("✅ Utilisateurs admin supprimes")
    
    # Créer un utilisateur avec le téléphone comme username pour l'auth PIN
    pin_user = User.objects.create_user(
        username='123456789',  # Le téléphone comme username
        password='1234',       # Le PIN comme password
        email='admin@bokdej.com',
        first_name='Admin',
        last_name='Restaurant',
        is_staff=True,
        is_superuser=True,
        is_active=True
    )
    
    print(f"✅ Utilisateur PIN cree: {pin_user.username}")
    
    # Créer le profil utilisateur
    profile = UserProfile.objects.create(
        user=pin_user,
        phone='123456789',
        role='admin'
    )
    
    print(f"✅ Profil cree - Telephone: {profile.phone}, Role: {profile.role}")
    
    # Créer un admin classique pour Django admin
    classic_admin = User.objects.create_superuser(
        username='admin',
        email='admin@django.com',
        password='admin123',
        first_name='Django',
        last_name='Admin'
    )
    
    # Créer son profil aussi
    admin_profile = UserProfile.objects.create(
        user=classic_admin,
        phone='000000000',
        role='admin'
    )
    
    print(f"✅ Admin Django cree: {classic_admin.username}")
    
    print("\n" + "="*60)
    print("🔐 CONNEXION PIN FLUTTER:")
    print("="*60)
    print("   📱 Telephone: 123456789")
    print("   🔑 PIN: 1234")
    print("\n   1. Page d'accueil → 'Connexion Restaurant'")
    print("   2. Entrer le telephone: 123456789")  
    print("   3. Entrer le PIN: 1234")
    print("   4. Se connecter → Interface d'administration!")
    
    print("\n🌐 DJANGO ADMIN:")
    print("   Username: admin")
    print("   Password: admin123")
    
    print("\n✅ TOUT EST CONFIGURE!")
    print("Testez maintenant l'authentification PIN dans Flutter!")

if __name__ == '__main__':
    clean_and_create_admin()
