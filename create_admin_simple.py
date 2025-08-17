#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile, Restaurant

def create_admin_user():
    print("=== Creation d'un utilisateur administrateur ===")
    
    # Supprimer l'admin existant s'il existe
    try:
        existing_admin = User.objects.get(username='admin')
        existing_admin.delete()
        print("Ancien admin supprime")
    except User.DoesNotExist:
        pass
    
    # Créer le super utilisateur
    admin_user = User.objects.create_superuser(
        username='admin',
        email='admin@bokdej.com',
        password='admin123',
        first_name='Admin',
        last_name='BOKDEJ'
    )
    
    print(f"✅ Super utilisateur cree: {admin_user.username}")
    print(f"   Email: {admin_user.email}")
    print(f"   Mot de passe: admin123")
    
    # Créer un profil utilisateur
    try:
        profile, created = UserProfile.objects.get_or_create(
            user=admin_user,
            defaults={
                'phone': '123456789',
                'role': 'admin'
            }
        )
        
        if created:
            print(f"✅ Profil utilisateur cree")
        else:
            profile.phone = '123456789'
            profile.role = 'admin'
            profile.save()
            print(f"✅ Profil utilisateur mis a jour")
            
        print(f"   Telephone: {profile.phone}")
        print(f"   Role: {profile.role}")
        
    except Exception as e:
        print(f"❌ Erreur lors de la creation du profil: {e}")
    
    # Créer un restaurant de test pour l'admin
    try:
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
            print(f"✅ Restaurant de test existe deja: {restaurant.nom}")
            
    except Exception as e:
        print(f"❌ Erreur lors de la creation du restaurant: {e}")
    
    print("\n=== Informations de connexion ===")
    print("Pour se connecter via l'interface Staff Login:")
    print("  - Username: admin")
    print("  - Password: admin123")
    print("\nPour Django Admin (http://localhost:8000/admin/):")
    print("  - Username: admin")
    print("  - Password: admin123")
    
    print("\n✅ Configuration terminee avec succes!")
    print("\nPour tester l'admin dans Flutter:")
    print("1. Aller sur 'Connexion Staff'")
    print("2. Username: admin, Password: admin123")
    print("3. Vous serez redirige vers l'interface d'administration!")

if __name__ == '__main__':
    create_admin_user()
