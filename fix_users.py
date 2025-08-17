#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile

def fix_users():
    """Créer les utilisateurs avec une approche robuste"""
    print("🔧 Réparation des utilisateurs...")
    
    # 1. Supprimer tous les UserProfile existants
    print("🧹 Suppression de tous les UserProfile...")
    UserProfile.objects.all().delete()
    print("✅ UserProfile supprimés")
    
    # 2. Supprimer les utilisateurs spécifiques
    print("🧹 Suppression des utilisateurs existants...")
    User.objects.filter(username__in=['admin', 'staff']).delete()
    print("✅ Utilisateurs supprimés")
    
    # 3. Créer l'utilisateur admin
    print("\n👤 Création de l'utilisateur admin...")
    admin_user = User.objects.create_user(
        username='admin',
        email='admin@bokdej.com',
        password='admin123'
    )
    print("✅ Utilisateur admin créé")
    
    # 4. Créer le profil admin avec save() explicite
    admin_profile = UserProfile()
    admin_profile.user = admin_user
    admin_profile.role = 'admin'
    admin_profile.phone = '12345678901234'  # PIN: 1234
    admin_profile.save()
    print("✅ Profil admin créé avec PIN: 1234")
    
    # 5. Créer l'utilisateur staff
    print("\n👤 Création de l'utilisateur staff...")
    staff_user = User.objects.create_user(
        username='staff',
        email='staff@bokdej.com',
        password='staff123'
    )
    print("✅ Utilisateur staff créé")
    
    # 6. Créer le profil staff avec save() explicite
    staff_profile = UserProfile()
    staff_profile.user = staff_user
    staff_profile.role = 'client'
    staff_profile.phone = '12345678905678'  # PIN: 5678
    staff_profile.save()
    print("✅ Profil staff créé avec PIN: 5678")
    
    # 7. Vérification finale
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
        
        print("\n🎉 Utilisateurs créés avec succès!")
        print("🔑 PINs pour tester:")
        print("   - Admin: 1234")
        print("   - Staff: 5678")
        
    except Exception as e:
        print(f"❌ Erreur lors de la vérification: {e}")

if __name__ == '__main__':
    fix_users() 