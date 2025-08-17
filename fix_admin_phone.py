#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile

def fix_admin_phone():
    """Corriger le téléphone de l'utilisateur admin"""
    print("🔧 Correction du téléphone admin...")
    
    try:
        # Récupérer l'utilisateur admin
        admin_user = User.objects.get(username='admin')
        print("✅ Utilisateur admin trouvé")
        
        # Récupérer ou créer le profil admin
        try:
            admin_profile = UserProfile.objects.get(user=admin_user)
            print("✅ Profil admin trouvé")
        except UserProfile.DoesNotExist:
            admin_profile = UserProfile.objects.create(
                user=admin_user,
                role='admin',
                phone='12345678901234'  # PIN: 1234
            )
            print("✅ Profil admin créé")
        
        # Mettre à jour le téléphone
        admin_profile.phone = '12345678901234'  # PIN: 1234
        admin_profile.save()
        print("✅ Téléphone admin mis à jour")
        
        # Vérifier le staff aussi
        try:
            staff_user = User.objects.get(username='staff')
            staff_profile = UserProfile.objects.get(user=staff_user)
            staff_profile.phone = '12345678905678'  # PIN: 5678
            staff_profile.save()
            print("✅ Téléphone staff mis à jour")
        except Exception as e:
            print(f"⚠️ Erreur staff: {e}")
        
        # Vérification finale
        print("\n📋 Vérification finale...")
        admin = User.objects.get(username='admin')
        admin_prof = UserProfile.objects.get(user=admin)
        admin_pin = admin_prof.phone[-4:]
        print(f"✅ Admin: PIN {admin_pin} (téléphone: {admin_prof.phone})")
        
        staff = User.objects.get(username='staff')
        staff_prof = UserProfile.objects.get(user=staff)
        staff_pin = staff_prof.phone[-4:]
        print(f"✅ Staff: PIN {staff_pin} (téléphone: {staff_prof.phone})")
        
        print("\n🎉 Utilisateurs corrigés!")
        print("🔑 PINs pour tester:")
        print("   - Admin: 1234")
        print("   - Staff: 5678")
        
    except Exception as e:
        print(f"❌ Erreur: {e}")

if __name__ == '__main__':
    fix_admin_phone() 