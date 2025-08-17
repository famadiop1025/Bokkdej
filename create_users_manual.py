#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile

def create_users_manual():
    """Créer les utilisateurs manuellement"""
    print("🔧 Création manuelle des utilisateurs...")
    
    # 1. Vérifier les utilisateurs existants
    print("📋 Vérification des utilisateurs existants...")
    existing_users = User.objects.filter(username__in=['admin', 'staff'])
    for user in existing_users:
        print(f"👤 Utilisateur existant: {user.username}")
        try:
            profile = UserProfile.objects.get(user=user)
            pin = profile.phone[-4:] if profile.phone else "N/A"
            print(f"   📱 Téléphone: {profile.phone}, PIN: {pin}")
        except UserProfile.DoesNotExist:
            print(f"   ❌ Pas de profil")
    
    # 2. Créer l'utilisateur admin s'il n'existe pas
    print("\n👤 Création de l'utilisateur admin...")
    admin_user, admin_created = User.objects.get_or_create(
        username='admin',
        defaults={
            'email': 'admin@bokdej.com',
            'password': 'admin123'
        }
    )
    
    if admin_created:
        admin_user.set_password('admin123')
        admin_user.save()
        print("✅ Utilisateur admin créé")
    else:
        print("✅ Utilisateur admin existe déjà")
    
    # 3. Créer le profil admin
    try:
        admin_profile = UserProfile.objects.get(user=admin_user)
        print("✅ Profil admin existe déjà")
    except UserProfile.DoesNotExist:
        admin_profile = UserProfile.objects.create(
            user=admin_user,
            role='admin',
            phone='12345678901234'  # PIN: 1234
        )
        print("✅ Profil admin créé avec PIN: 1234")
    
    # 4. Créer l'utilisateur staff s'il n'existe pas
    print("\n👤 Création de l'utilisateur staff...")
    staff_user, staff_created = User.objects.get_or_create(
        username='staff',
        defaults={
            'email': 'staff@bokdej.com',
            'password': 'staff123'
        }
    )
    
    if staff_created:
        staff_user.set_password('staff123')
        staff_user.save()
        print("✅ Utilisateur staff créé")
    else:
        print("✅ Utilisateur staff existe déjà")
    
    # 5. Créer le profil staff
    try:
        staff_profile = UserProfile.objects.get(user=staff_user)
        print("✅ Profil staff existe déjà")
    except UserProfile.DoesNotExist:
        staff_profile = UserProfile.objects.create(
            user=staff_user,
            role='client',
            phone='12345678905678'  # PIN: 5678
        )
        print("✅ Profil staff créé avec PIN: 5678")
    
    # 6. Vérification finale
    print("\n📋 Vérification finale...")
    try:
        admin = User.objects.get(username='admin')
        admin_prof = UserProfile.objects.get(user=admin)
        admin_pin = admin_prof.phone[-4:]
        print(f"✅ Admin: PIN {admin_pin} (téléphone: {admin_prof.phone})")
        
        staff = User.objects.get(username='staff')
        staff_prof = UserProfile.objects.get(user=staff)
        staff_pin = staff_prof.phone[-4:]
        print(f"✅ Staff: PIN {staff_pin} (téléphone: {staff_prof.phone})")
        
        print("\n🎉 Utilisateurs prêts!")
        print("🔑 PINs pour tester:")
        print("   - Admin: 1234")
        print("   - Staff: 5678")
        
    except Exception as e:
        print(f"❌ Erreur lors de la vérification: {e}")

if __name__ == '__main__':
    create_users_manual() 