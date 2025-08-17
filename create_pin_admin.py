#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile, Restaurant

def create_pin_admin():
    print("=== Creation d'un admin avec authentification PIN ===")
    
    # Supprimer les anciens utilisateurs admin
    User.objects.filter(username__in=['admin', '123456789']).delete()
    print("Anciens utilisateurs supprimes")
    
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
    
    # Créer aussi un admin classique pour Django admin
    classic_admin = User.objects.create_superuser(
        username='admin',
        email='admin@bokdej.com',
        password='admin123',
        first_name='Admin',
        last_name='Django'
    )
    
    print(f"✅ Admin Django cree: {classic_admin.username}")
    
    # Créer un restaurant de test
    restaurant, created = Restaurant.objects.get_or_create(
        nom='Restaurant Admin',
        defaults={
            'adresse': 'Dakar, Senegal',
            'telephone': '123456789',
            'email': 'restaurant@admin.com',
            'actif': True
        }
    )
    
    print(f"✅ Restaurant {'cree' if created else 'trouve'}: {restaurant.nom}")
    
    print("\n" + "="*60)
    print("🔐 INFORMATIONS DE CONNEXION")
    print("="*60)
    print("\n📱 AUTHENTIFICATION PIN FLUTTER:")
    print("   1. Page d'accueil → 'Connexion Restaurant'")
    print("   2. Numero de telephone: 123456789")
    print("   3. PIN: 1234")
    print("   ➜ Accès direct à l'interface d'administration!")
    
    print("\n🌐 DJANGO ADMIN (http://localhost:8000/admin/):")
    print("   Username: admin")
    print("   Password: admin123")
    
    print("\n✅ CONFIGURATION TERMINEE!")
    print("L'authentification PIN fonctionne maintenant correctement!")

if __name__ == '__main__':
    create_pin_admin()
