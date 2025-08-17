#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile

def create_users_simple():
    """Créer les utilisateurs de manière simple"""
    print("🧹 Nettoyage complet...")
    
    # Supprimer tous les UserProfile d'abord
    UserProfile.objects.all().delete()
    print("✅ UserProfile supprimés")
    
    # Supprimer les utilisateurs spécifiques
    User.objects.filter(username__in=['admin', 'staff']).delete()
    print("✅ Utilisateurs supprimés")
    
    print("\n👤 Création de l'utilisateur admin...")
    try:
        # Créer l'utilisateur admin
        admin_user = User.objects.create_user(
            username='admin',
            email='admin@bokdej.com',
            password='admin123'
        )
        print("✅ Utilisateur admin créé")
        
        # Créer le profil admin
        admin_profile = UserProfile(
            user=admin_user,
            role='admin',
            phone='12345678901234'  # PIN: 1234
        )
        admin_profile.save()
        print("✅ Profil admin créé avec PIN: 1234")
        
    except Exception as e:
        print(f"❌ Erreur admin: {e}")
    
    print("\n👤 Création de l'utilisateur staff...")
    try:
        # Créer l'utilisateur staff
        staff_user = User.objects.create_user(
            username='staff',
            email='staff@bokdej.com',
            password='staff123'
        )
        print("✅ Utilisateur staff créé")
        
        # Créer le profil staff
        staff_profile = UserProfile(
            user=staff_user,
            role='client',
            phone='12345678905678'  # PIN: 5678
        )
        staff_profile.save()
        print("✅ Profil staff créé avec PIN: 5678")
        
    except Exception as e:
        print(f"❌ Erreur staff: {e}")
    
    print("\n📋 Vérification finale...")
    try:
        users = User.objects.filter(username__in=['admin', 'staff'])
        for user in users:
            profile = UserProfile.objects.get(user=user)
            pin = profile.phone[-4:]
            print(f"✅ {user.username}: PIN {pin} (téléphone: {profile.phone})")
    except Exception as e:
        print(f"❌ Erreur vérification: {e}")
    
    print("\n🎉 Utilisateurs créés avec succès!")
    print("🔑 PINs pour tester:")
    print("   - Admin: 1234")
    print("   - Staff: 5678")

if __name__ == '__main__':
    create_users_simple() 