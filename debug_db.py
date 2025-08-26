#!/usr/bin/env python3
"""
Script de diagnostic de la base de données
"""

import os
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile

def debug_database():
    """Diagnostiquer la base de données"""
    
    print("🔍 Diagnostic de la base de données")
    print("=" * 50)
    
    # Vérifier les utilisateurs
    print(f"📊 Total d'utilisateurs: {User.objects.count()}")
    
    users = User.objects.all()[:10]  # Les 10 premiers
    for user in users:
        print(f"   👤 User ID: {user.id}, Username: {user.username}, Email: {user.email}")
    
    print()
    
    # Vérifier les profils
    print(f"📊 Total de profils utilisateur: {UserProfile.objects.count()}")
    
    profiles = UserProfile.objects.all()[:10]  # Les 10 premiers
    for profile in profiles:
        print(f"   📱 Profile ID: {profile.id}, User ID: {profile.user.id}, Phone: {profile.phone}, Role: {profile.role}")
    
    print()
    
    # Vérifier les conflits potentiels
    phone_to_check = "221771234567"
    print(f"🔍 Vérification du numéro: {phone_to_check}")
    
    try:
        existing_profile = UserProfile.objects.get(phone=phone_to_check)
        print(f"   ✅ Profil existant trouvé:")
        print(f"      Profile ID: {existing_profile.id}")
        print(f"      User ID: {existing_profile.user.id}")
        print(f"      Username: {existing_profile.user.username}")
        print(f"      Phone: {existing_profile.phone}")
        print(f"      Role: {existing_profile.role}")
    except UserProfile.DoesNotExist:
        print(f"   ❌ Aucun profil trouvé pour ce numéro")
    
    print()
    
    # Vérifier s'il y a des utilisateurs sans profil
    users_without_profile = []
    for user in User.objects.all():
        try:
            user.userprofile
        except UserProfile.DoesNotExist:
            users_without_profile.append(user)
    
    print(f"⚠️  Utilisateurs sans profil: {len(users_without_profile)}")
    for user in users_without_profile[:5]:  # Afficher les 5 premiers
        print(f"   👤 User ID: {user.id}, Username: {user.username}")
    
    print()
    
    # Vérifier s'il y a des doublons de numéro de téléphone
    phones = UserProfile.objects.values_list('phone', flat=True)
    unique_phones = set(phones)
    
    if len(phones) != len(unique_phones):
        print("⚠️  Doublons de numéros de téléphone détectés!")
        from collections import Counter
        phone_counts = Counter(phones)
        for phone, count in phone_counts.items():
            if count > 1:
                print(f"   📱 {phone}: {count} fois")
    else:
        print("✅ Aucun doublon de numéro de téléphone")

def fix_database():
    """Nettoyer la base de données"""
    
    print("\n🧹 Nettoyage de la base de données")
    print("=" * 50)
    
    phone_to_fix = "221771234567"
    
    # Supprimer les profils existants pour ce numéro
    existing_profiles = UserProfile.objects.filter(phone=phone_to_fix)
    
    if existing_profiles.exists():
        print(f"🗑️  Suppression des profils existants pour {phone_to_fix}")
        for profile in existing_profiles:
            print(f"   Suppression du profil ID: {profile.id}, User: {profile.user.username}")
            user = profile.user
            profile.delete()
            user.delete()  # Supprimer aussi l'utilisateur
        print("✅ Nettoyage terminé")
    else:
        print("✅ Aucun profil à nettoyer")

if __name__ == "__main__":
    debug_database()
    
    # Demander s'il faut nettoyer
    response = input("\n❓ Voulez-vous nettoyer les données conflictuelles ? (y/N): ")
    if response.lower() in ['y', 'yes', 'oui']:
        fix_database()
        print("\n🔄 Relancer le test maintenant...")
    else:
        print("\n✅ Diagnostic terminé.")
