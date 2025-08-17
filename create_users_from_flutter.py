#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import UserProfile

def create_flutter_users():
    print("=== Creation des utilisateurs de test Flutter ===")
    
    # Utilisateurs de test de l'interface Flutter
    flutter_users = [
        {
            'nom': 'Aminata Diallo',
            'telephone': '221771234567',
            'email': 'aminata@email.com',
            'pin': '5678',
            'role': 'client',
            'actif': True,
        },
        {
            'nom': 'Ousmane Fall',
            'telephone': '221776543210',
            'email': 'ousmane@email.com',
            'pin': '9012',
            'role': 'personnel',
            'actif': True,
        },
        {
            'nom': 'Fatou Sow',
            'telephone': '221779876543',
            'email': 'fatou@email.com',
            'pin': '3456',
            'role': 'client',
            'actif': False,
        },
    ]
    
    print(f"Creation de {len(flutter_users)} utilisateurs...")
    
    for user_data in flutter_users:
        try:
            # Vérifier si l'utilisateur existe déjà
            if User.objects.filter(username=user_data['telephone']).exists():
                print(f"   ⚠️  Utilisateur {user_data['nom']} existe déjà")
                continue
            
            # Créer l'utilisateur Django
            user = User.objects.create_user(
                username=user_data['telephone'],  # Téléphone comme username
                password=user_data['pin'],        # PIN comme password
                email=user_data['email'],
                first_name=user_data['nom'].split()[0],
                last_name=' '.join(user_data['nom'].split()[1:]) if len(user_data['nom'].split()) > 1 else '',
                is_active=user_data['actif']
            )
            
            # Créer le profil utilisateur
            profile = UserProfile.objects.create(
                user=user,
                phone=user_data['telephone'],
                role=user_data['role']
            )
            
            print(f"   ✅ {user_data['nom']} créé - Tel: {user_data['telephone']}, PIN: {user_data['pin']}")
            
        except Exception as e:
            print(f"   ❌ Erreur pour {user_data['nom']}: {e}")
    
    print("\n" + "="*60)
    print("🔐 UTILISATEURS CRÉÉS - INFORMATIONS DE CONNEXION")
    print("="*60)
    
    # Afficher tous les utilisateurs disponibles
    all_users = User.objects.all()
    for user in all_users:
        try:
            profile = user.userprofile
            print(f"\n👤 {user.first_name} {user.last_name}")
            print(f"   📱 Téléphone: {user.username}")
            print(f"   🔑 PIN: Utilisez le mot de passe défini")
            print(f"   👔 Rôle: {profile.role}")
            print(f"   ✅ Actif: {'Oui' if user.is_active else 'Non'}")
        except:
            print(f"\n👤 {user.username} (pas de profil)")
    
    print("\n🎯 POUR TESTER LA CONNEXION:")
    print("1. Page d'accueil → 'Connexion Restaurant'")
    print("2. Utilisez un des téléphones ci-dessus")
    print("3. Utilisez le PIN correspondant")
    print("\n✅ TOUS LES UTILISATEURS SONT PRÊTS !")

if __name__ == '__main__':
    create_flutter_users()
