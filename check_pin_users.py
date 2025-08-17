#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile

def check_and_fix_users():
    """Vérifier et corriger les utilisateurs pour la connexion PIN"""
    print("🔍 Diagnostic des utilisateurs pour connexion PIN...\n")
    
    # 1. Vérifier tous les utilisateurs existants
    print("=== UTILISATEURS EXISTANTS ===")
    users = User.objects.all()
    if not users:
        print("❌ Aucun utilisateur trouvé!")
        return
    
    for user in users:
        print(f"\n👤 User: {user.username}")
        print(f"   - Actif: {user.is_active}")
        print(f"   - Superuser: {user.is_superuser}")
        
        try:
            profile = user.userprofile
            print(f"   - Rôle: {profile.role}")
            print(f"   - Téléphone: {profile.phone}")
            if profile.phone:
                pin = profile.phone[-4:] if len(profile.phone) >= 4 else "TROP COURT"
                print(f"   - PIN calculé: {pin}")
            else:
                print(f"   - ⚠️  PAS DE TÉLÉPHONE!")
        except UserProfile.DoesNotExist:
            print(f"   - ❌ PAS DE PROFIL!")
    
    print("\n" + "="*50)
    
    # 2. Créer/corriger les utilisateurs de test
    print("\n🔧 Création/correction des utilisateurs de test...")
    
    # Admin user
    try:
        admin_user = User.objects.get(username='admin')
        print("✅ Utilisateur admin existe")
    except User.DoesNotExist:
        admin_user = User.objects.create_user(
            username='admin',
            password='admin123',
            is_staff=True,
            is_superuser=True
        )
        print("✅ Utilisateur admin créé")
    
    # Profil admin
    try:
        admin_profile = UserProfile.objects.get(user=admin_user)
        print("✅ Profil admin existe")
    except UserProfile.DoesNotExist:
        admin_profile = UserProfile.objects.create(user=admin_user, role='admin')
        print("✅ Profil admin créé")
    
    # Mettre à jour le téléphone admin
    admin_profile.phone = '33123456781234'  # PIN: 1234
    admin_profile.role = 'admin'
    admin_profile.save()
    print(f"✅ Admin - Téléphone: {admin_profile.phone}, PIN: {admin_profile.phone[-4:]}")
    
    # Staff user
    try:
        staff_user = User.objects.get(username='staff')
        print("✅ Utilisateur staff existe")
    except User.DoesNotExist:
        staff_user = User.objects.create_user(
            username='staff',
            password='staff123',
            is_staff=True,
        )
        print("✅ Utilisateur staff créé")
    
    # Profil staff
    try:
        staff_profile = UserProfile.objects.get(user=staff_user)
        print("✅ Profil staff existe")
    except UserProfile.DoesNotExist:
        staff_profile = UserProfile.objects.create(user=staff_user, role='admin')
        print("✅ Profil staff créé")
    
    # Mettre à jour le téléphone staff
    staff_profile.phone = '33123456785678'  # PIN: 5678
    staff_profile.role = 'admin'  # Changé en admin pour tester
    staff_profile.save()
    print(f"✅ Staff - Téléphone: {staff_profile.phone}, PIN: {staff_profile.phone[-4:]}")
    
    # 3. Vérification finale
    print("\n📋 VÉRIFICATION FINALE...")
    print("=== UTILISATEURS POUR CONNEXION PIN ===")
    
    staff_profiles = UserProfile.objects.filter(role__in=['admin', 'personnel', 'chef'])
    for profile in staff_profiles:
        if profile.phone:
            pin = profile.phone[-4:]
            print(f"✅ {profile.user.username}: PIN {pin} (rôle: {profile.role})")
        else:
            print(f"❌ {profile.user.username}: PAS DE TÉLÉPHONE (rôle: {profile.role})")
    
    print("\n🎯 PINS DE TEST:")
    print("   - Admin: 1234")
    print("   - Staff: 5678")
    print("\n✅ Configuration terminée!")

if __name__ == "__main__":
    check_and_fix_users()