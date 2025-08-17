#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile, Restaurant
from django.contrib.auth.hashers import make_password

def create_admin_with_pin():
    print("=== Creation d'un utilisateur administrateur avec PIN ===")
    
    # Créer/Mettre à jour l'utilisateur admin
    admin_user, created = User.objects.get_or_create(
        username='admin',
        defaults={
            'email': 'admin@bokdej.com',
            'first_name': 'Admin',
            'last_name': 'BOKDEJ',
            'is_superuser': True,
            'is_staff': True,
            'is_active': True,
        }
    )
    
    # Définir le mot de passe (peut servir pour l'authentification)
    admin_user.set_password('1234')
    admin_user.save()
    
    if created:
        print(f"✅ Utilisateur admin cree: {admin_user.username}")
    else:
        print(f"✅ Utilisateur admin mis a jour: {admin_user.username}")
    
    # Créer/Mettre à jour le profil avec téléphone
    profile, created = UserProfile.objects.get_or_create(
        user=admin_user,
        defaults={
            'phone': '123456789',
            'role': 'admin'
        }
    )
    
    if not created:
        profile.phone = '123456789'
        profile.role = 'admin'
        profile.save()
    
    print(f"✅ Profil utilisateur {'cree' if created else 'mis a jour'}")
    print(f"   Telephone: {profile.phone}")
    print(f"   Role: {profile.role}")
    
    # Créer un restaurant de test
    restaurant, created = Restaurant.objects.get_or_create(
        nom='Restaurant Admin Test',
        defaults={
            'adresse': '123 Rue de Test, Dakar',
            'telephone': '123456789',
            'email': 'admin@restaurant.com',
            'actif': True
        }
    )
    
    if created:
        print(f"✅ Restaurant de test cree: {restaurant.nom}")
    else:
        print(f"✅ Restaurant de test existe: {restaurant.nom}")
    
    print("\n" + "="*50)
    print("🔐 INFORMATIONS DE CONNEXION ADMIN")
    print("="*50)
    print("\n📱 Pour se connecter dans Flutter:")
    print("1. Page d'accueil → 'Connexion Restaurant'")
    print("2. Numero de telephone: 123456789")
    print("3. PIN: 1234")
    print("\n🌐 Pour Django Admin (http://localhost:8000/admin/):")
    print("   Username: admin")
    print("   Password: 1234")
    
    print("\n✅ TOUT EST PRET POUR VOTRE PRESENTATION!")
    print("Vous pouvez maintenant acceder a l'interface d'administration!")

if __name__ == '__main__':
    create_admin_with_pin()
