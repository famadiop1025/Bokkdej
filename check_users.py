#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile

def check_users():
    """Vérifier les utilisateurs existants"""
    print("🔍 Vérification des utilisateurs dans la base de données...")
    print("=" * 60)
    
    # Vérifier tous les utilisateurs
    users = User.objects.all()
    print(f"👥 Nombre total d'utilisateurs: {users.count()}")
    
    for user in users:
        print(f"\n👤 Utilisateur: {user.username}")
        print(f"   📧 Email: {user.email}")
        print(f"   🔑 Mot de passe: {'Défini' if user.password else 'Non défini'}")
        
        # Vérifier le profil utilisateur
        try:
            profile = UserProfile.objects.get(user=user)
            print(f"   📱 Téléphone: {profile.phone}")
            print(f"   🏷️ Rôle: {profile.role}")
            
            # Calculer le PIN (4 derniers chiffres du téléphone)
            if profile.phone and len(profile.phone) >= 4:
                pin = profile.phone[-4:]
                print(f"   🔢 PIN calculé: {pin}")
            else:
                print(f"   ❌ Téléphone invalide pour calculer le PIN")
                
        except UserProfile.DoesNotExist:
            print(f"   ❌ Pas de profil utilisateur trouvé")
    
    print("\n" + "=" * 60)
    print("📋 Résumé")
    print("💡 Pour tester la connexion PIN:")
    print("   - Utilisez les 4 derniers chiffres du numéro de téléphone")
    print("   - Exemple: si téléphone = '12345678901234', PIN = '1234'")

if __name__ == '__main__':
    check_users() 