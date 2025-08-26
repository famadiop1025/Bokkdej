from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.db import transaction
from .models import UserProfile
import json

@api_view(['POST'])
@permission_classes([AllowAny])
def create_client_account(request):
    """
    Créer automatiquement un compte client avec juste un numéro de téléphone
    """
    try:
        data = json.loads(request.body)
        phone = data.get('phone')
        name = data.get('name', f'Client {phone}')
        
        print(f"DEBUG: Création de compte pour le téléphone: {phone}")
        
        if not phone:
            return Response(
                {'error': 'Numéro de téléphone requis'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Utiliser une transaction pour éviter les conflits
        with transaction.atomic():
            # Vérifier si un utilisateur avec ce numéro existe déjà
            try:
                user_profile = UserProfile.objects.get(phone=phone)
                user = user_profile.user
                print(f"DEBUG: Utilisateur existant trouvé: {user.username}")
            except UserProfile.DoesNotExist:
                print(f"DEBUG: Aucun profil trouvé pour {phone}, création d'un nouveau compte")
                
                # Vérifier si l'utilisateur existe déjà (par sécurité)
                existing_user = User.objects.filter(username__startswith=f'client_{phone}').first()
                if existing_user:
                    print(f"DEBUG: Utilisateur existant trouvé avec username: {existing_user.username}")
                    # Vérifier s'il a déjà un profil
                    try:
                        existing_profile = UserProfile.objects.get(user=existing_user)
                        print(f"DEBUG: Profil existant trouvé pour cet utilisateur")
                        user = existing_user
                    except UserProfile.DoesNotExist:
                        print(f"DEBUG: Aucun profil pour cet utilisateur, création du profil")
                        # Créer le profil pour l'utilisateur existant
                        user_profile = UserProfile.objects.create(
                            user=existing_user,
                            phone=phone,
                            role='client'
                        )
                        user = existing_user
                else:
                    # Créer un nouvel utilisateur avec un nom d'utilisateur unique
                    base_username = f'client_{phone}'
                    username = base_username
                    counter = 1
                    
                    # Chercher un nom d'utilisateur unique
                    while User.objects.filter(username=username).exists():
                        username = f'{base_username}_{counter}'
                        counter += 1
                    
                    print(f"DEBUG: Création d'un nouvel utilisateur avec username: {username}")
                    
                    # Créer l'utilisateur
                    user = User.objects.create_user(
                        username=username,
                        email=f'{username}@example.com',
                        password=phone,  # Utiliser le numéro comme mot de passe temporaire
                        first_name=name
                    )
                    print(f"DEBUG: Nouvel utilisateur créé: {user.username}")
                    
                    # Créer le profil utilisateur
                    user_profile = UserProfile.objects.create(
                        user=user,
                        phone=phone,
                        role='client'
                    )
                    print(f"DEBUG: Profil utilisateur créé pour: {user.username}")
        
        # Générer le token JWT
        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)
        
        print(f"DEBUG: Token généré avec succès pour {user.username}")
        
        return Response({
            'access': access_token,
            'refresh': str(refresh),
            'user': {
                'id': user.id,
                'username': user.username,
                'name': user.first_name,
                'role': 'client',
                'phone': phone
            }
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        print(f"DEBUG: Erreur dans create_client_account: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response(
            {'error': f'Erreur lors de la création du compte: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['POST'])
@permission_classes([AllowAny])
def client_login(request):
    """
    Connexion simple pour les clients avec juste le numéro de téléphone
    """
    try:
        data = json.loads(request.body)
        phone = data.get('phone')
        
        if not phone:
            return Response(
                {'error': 'Numéro de téléphone requis'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Vérifier si l'utilisateur existe
        try:
            user_profile = UserProfile.objects.get(phone=phone)
            user = user_profile.user
            
            # Générer le token JWT
            refresh = RefreshToken.for_user(user)
            access_token = str(refresh.access_token)
            
            return Response({
                'access': access_token,
                'refresh': str(refresh),
                'user': {
                    'id': user.id,
                    'username': user.username,
                    'name': user.first_name,
                    'role': 'client',
                    'phone': phone
                }
            }, status=status.HTTP_200_OK)
            
        except UserProfile.DoesNotExist:
            # Créer automatiquement un compte en utilisant la même logique
            # mais sans récursion pour éviter les conflits
            try:
                with transaction.atomic():
                    # Créer un nouvel utilisateur avec un nom d'utilisateur unique
                    base_username = f'client_{phone}'
                    username = base_username
                    counter = 1
                    
                    # Chercher un nom d'utilisateur unique
                    while User.objects.filter(username=username).exists():
                        username = f'{base_username}_{counter}'
                        counter += 1
                    
                    # Créer l'utilisateur
                    user = User.objects.create_user(
                        username=username,
                        email=f'{username}@example.com',
                        password=phone,  # Utiliser le numéro comme mot de passe temporaire
                        first_name=f'Client {phone}'
                    )
                    print(f"DEBUG: Nouvel utilisateur créé via login: {user.username}")
                    
                    # Créer le profil utilisateur
                    user_profile = UserProfile.objects.create(
                        user=user,
                        phone=phone,
                        role='client'
                    )
                    print(f"DEBUG: Profil utilisateur créé via login pour: {user.username}")
                
                # Générer le token JWT
                refresh = RefreshToken.for_user(user)
                access_token = str(refresh.access_token)
                
                return Response({
                    'access': access_token,
                    'refresh': str(refresh),
                    'user': {
                        'id': user.id,
                        'username': user.username,
                        'name': user.first_name,
                        'role': 'client',
                        'phone': phone
                    }
                }, status=status.HTTP_201_CREATED)
                
            except Exception as e:
                print(f"DEBUG: Erreur lors de la création automatique: {str(e)}")
                return Response(
                    {'error': f'Erreur lors de la création automatique du compte: {str(e)}'}, 
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
        
    except Exception as e:
        print(f"DEBUG: Erreur dans client_login: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response(
            {'error': f'Erreur lors de la connexion: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
