#!/usr/bin/env python3
"""
Script pour créer un token d'administrateur pour les tests Flutter
"""

import os
import sys
import django
from datetime import datetime, timedelta

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')

# Ajouter le répertoire du projet au path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Initialiser Django
django.setup()

from django.contrib.auth.models import User
from rest_framework_simplejwt.tokens import RefreshToken

def create_admin_token():
    """Créer un token pour l'admin"""
    try:
        # Vérifier si l'utilisateur admin existe
        try:
            admin_user = User.objects.get(username='admin')
        except User.DoesNotExist:
            print("❌ Utilisateur 'admin' non trouvé")
            print("Création de l'utilisateur admin...")
            admin_user = User.objects.create_superuser(
                username='admin',
                email='admin@keurrestobokdej.com',
                password='admin123',
                first_name='Admin',
                last_name='Système'
            )
            print("✅ Utilisateur admin créé")

        # S'assurer qu'il est superuser
        if not admin_user.is_superuser:
            admin_user.is_superuser = True
            admin_user.is_staff = True
            admin_user.save()
            print("✅ Privilèges admin accordés")

        # Générer le token JWT
        refresh = RefreshToken.for_user(admin_user)
        access_token = str(refresh.access_token)
        refresh_token = str(refresh)

        print("\n🔑 TOKEN D'ADMINISTRATION GÉNÉRÉ")
        print("=" * 50)
        print(f"📧 Utilisateur: {admin_user.username}")
        print(f"👑 Status: {'Superuser' if admin_user.is_superuser else 'User'}")
        print(f"📝 Token Access: {access_token}")
        print(f"🔄 Token Refresh: {refresh_token}")
        print("=" * 50)
        
        # Calculer l'expiration (par défaut 5 minutes pour access token)
        expiration = datetime.now() + timedelta(minutes=60)  # 1 heure
        print(f"⏰ Expire le: {expiration.strftime('%Y-%m-%d %H:%M:%S')}")
        
        print("\n📋 UTILISATION DANS FLUTTER:")
        print("=" * 50)
        print("1. Copiez le Token Access ci-dessus")
        print("2. Dans votre app Flutter, utilisez ce token")
        print("3. Le token est valide pendant 1 heure")
        
        return access_token

    except Exception as e:
        print(f"❌ Erreur lors de la création du token: {e}")
        return None

if __name__ == "__main__":
    print("🚀 Génération du token d'administration...")
    token = create_admin_token()
    
    if token:
        print("\n✅ Token généré avec succès!")
        print("Vous pouvez maintenant modifier les images dans votre app Flutter.")
    else:
        print("\n❌ Échec de la génération du token")
