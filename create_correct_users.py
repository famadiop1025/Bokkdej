#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile

def create_correct_users():
    """Créer les utilisateurs avec les bons PINs"""
    print("🧹 Nettoyage de la base de données...")
    UserProfile.objects.all().delete()
    User.objects.filter(username__in=['admin', 'staff', 'fama']).delete()
    print("✅ Nettoyage terminé")

    print("\n👤 Création de l'utilisateur admin...")
    admin_user = User.objects.create_user(
        username='admin',
        email='admin@bokdej.com',
        password='admin123'
    )
    # PIN 1234 = téléphone se terminant par 1234
    UserProfile.objects.create(
        user=admin_user,
        role='admin',
        phone='12345678901234'  # PIN: 1234
    )
    print("✅ Admin créé avec PIN: 1234")

    print("\n👤 Création de l'utilisateur staff...")
    staff_user = User.objects.create_user(
        username='staff',
        email='staff@bokdej.com',
        password='staff123'
    )
    # PIN 5678 = téléphone se terminant par 5678
    UserProfile.objects.create(
        user=staff_user,
        role='client',
        phone='12345678905678'  # PIN: 5678
    )
    print("✅ Staff créé avec PIN: 5678")

    print("\n📋 Vérification des utilisateurs créés...")
    users = User.objects.all()
    for user in users:
        if user.username in ['admin', 'staff']:
            profile = UserProfile.objects.get(user=user)
            pin = profile.phone[-4:]
            print(f"👤 {user.username}: PIN {pin} (téléphone: {profile.phone})")

    print("\n✅ Utilisateurs de test créés avec succès!")
    print("🔑 PINs pour tester:")
    print("   - Admin: 1234")
    print("   - Staff: 5678")

if __name__ == '__main__':
    create_correct_users() 