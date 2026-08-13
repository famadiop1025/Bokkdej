from rest_framework import viewsets, permissions
from django.db.models import Q
from django.contrib.auth.models import User
from .models import MenuItem, Ingredient, CustomDish, Order, Restaurant, Base, WavePaymentLog
from .serializers import (
    MenuItemSerializer, IngredientSerializer, CustomDishSerializer, UserSerializer, RestaurantSerializer, BaseSerializer, OrderSerializer
)
from rest_framework.permissions import BasePermission, SAFE_METHODS, AllowAny
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from pyfcm import FCMNotification
from .models import UserProfile
from django.conf import settings
from django.utils import timezone
import json

class IsAdminOrReadOnly(BasePermission):
    def has_permission(self, request, view):
        if request.method in SAFE_METHODS:
            return True
        # Vérifier que l'utilisateur est authentifié et est staff
        if not request.user.is_authenticated:
            return False
        return request.user.is_staff

class UserViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['post'], url_path='set_fcm_token')
    def set_fcm_token(self, request):
        user = request.user
        token = request.data.get('fcm_token')
        if not token:
            return Response({'error': 'Token FCM manquant'}, status=400)
        
        # Vérifier que l'utilisateur a un profil
        try:
            if hasattr(user, 'userprofile'):
                user.userprofile.fcm_token = token
                user.userprofile.save()
            else:
                # Créer le profil s'il n'existe pas
                from .models import UserProfile
                profile = UserProfile.objects.create(user=user, fcm_token=token)
            return Response({'message': 'Token FCM mis à jour'})
        except Exception as e:
            return Response({'error': f'Erreur lors de la mise à jour: {str(e)}'}, status=500)

# ========= Profil Utilisateur Authentifié =========
@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def user_profile(request):
    """Retourne les informations du profil de l'utilisateur connecté"""
    user = request.user
    restaurant_id = None
    try:
        if hasattr(user, 'userprofile'):
            # Le champ role n'existe plus, on utilise is_staff à la place
            role = 'admin' if user.is_staff else 'client'
            restaurant_id = None  # Le champ restaurant n'existe plus non plus
    except Exception:
        role = 'client'
        restaurant_id = None
    return Response({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'first_name': user.first_name,
        'last_name': user.last_name,
        'role': role,
        'restaurant': restaurant_id,
        'is_active': user.is_active,
    })

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def update_fcm_token(request):
    try:
        token = request.data.get('fcm_token')
        if not token:
            return Response({'error': 'fcm_token requis'}, status=400)
        if not hasattr(request.user, 'userprofile'):
            return Response({'error': 'Profil introuvable'}, status=400)
        profile = request.user.userprofile
        profile.fcm_token = token
        profile.save()
        return Response({'ok': True})
    except Exception as e:
        return Response({'error': str(e)}, status=500)

class MenuItemViewSet(viewsets.ModelViewSet):
    queryset = MenuItem.objects.all()
    serializer_class = MenuItemSerializer
    permission_classes = [IsAdminOrReadOnly]
    parser_classes = [MultiPartParser, FormParser]
    
    def get_queryset(self):
        """Supporte le filtre par restaurant et la visibilité publique (disponible).
        Si aucun plat disponible n'est trouvé, on renvoie en fallback tous les plats pour éviter un menu vide involontaire.
        """
        qs = MenuItem.objects.all()
        request = self.request
        restaurant_id = request.query_params.get('restaurant') or request.query_params.get('restaurant_id')
        if restaurant_id:
            qs = qs.filter(restaurant_id=restaurant_id)
            # Fallback: si aucun plat trouvé pour ce restaurant, renvoyer les plats globaux (restaurant null)
            try:
                if not qs.exists():
                    qs = MenuItem.objects.filter(restaurant__isnull=True)
            except Exception:
                pass

        user = request.user
        if user.is_authenticated and user.is_staff:
            # Admin: voit tout (ou selon filtre restaurant)
            return qs
        # Public/clients: ne voir que les plats disponibles, avec fallback si aucun
        public_qs = qs.filter(disponible=True)
        try:
            return public_qs if public_qs.exists() else qs
        except Exception:
            return public_qs
    
    def perform_create(self, serializer):
        """Associer automatiquement le restaurant de l'utilisateur"""
        # Pour l'instant, on laisse l'utilisateur spécifier le restaurant manuellement
        serializer.save()

    @action(detail=True, methods=['post'])
    def upload_image(self, request, pk=None):
        menu_item = self.get_object()
        if 'image' in request.FILES:
            menu_item.image = request.FILES['image']
            menu_item.save()
            return Response({
                'message': 'Image uploadée avec succès',
                'image_url': request.build_absolute_uri(menu_item.image.url) if menu_item.image else None
            })
        return Response({'error': 'Aucune image fournie'}, status=400)

class IngredientViewSet(viewsets.ModelViewSet):
    queryset = Ingredient.objects.all()
    serializer_class = IngredientSerializer
    permission_classes = [IsAdminOrReadOnly]
    parser_classes = [MultiPartParser, FormParser]
    
    def get_queryset(self):
        """Filtrer les ingrédients par restaurant de l'utilisateur"""
        user = self.request.user
        if user.is_authenticated and user.is_staff:
            # Admin: voir tous les ingrédients
            return Ingredient.objects.all()
        return Ingredient.objects.all()
    
    def perform_create(self, serializer):
        """Associer automatiquement le restaurant de l'utilisateur"""
        # Pour l'instant, on laisse l'utilisateur spécifier le restaurant manuellement
        serializer.save()

    @action(detail=True, methods=['post'])
    def upload_image(self, request, pk=None):
        ingredient = self.get_object()
        if 'image' in request.FILES:
            ingredient.image = request.FILES['image']
            ingredient.save()
            return Response({
                'message': 'Image uploadée avec succès',
                'image_url': request.build_absolute_uri(ingredient.image.url) if ingredient.image else None
            })
        return Response({'error': 'Aucune image fournie'}, status=400)

class CustomDishViewSet(viewsets.ModelViewSet):
    queryset = CustomDish.objects.all()
    serializer_class = CustomDishSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
    def get_queryset(self):
        """Filtrer les plats personnalisés selon l'utilisateur"""
        if self.request.user.is_authenticated:
            # Si l'utilisateur est admin, voir tous les plats
            if self.request.user.is_staff:
                return CustomDish.objects.all()
            # Sinon, voir seulement les plats disponibles
            return CustomDish.objects.filter(disponible=True)
        # Utilisateurs anonymes peuvent seulement voir les plats disponibles
        return CustomDish.objects.filter(disponible=True)

class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.all()
    serializer_class = OrderSerializer
    permission_classes = [permissions.AllowAny]

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
    def get_queryset(self):
        """Filtrer les commandes selon l'utilisateur et/ou le restaurant"""
        if self.request.user.is_authenticated:
            try:
                # Personnel/Admin/Chef: accès élargi avec filtre restaurant optionnel
                if self.request.user.is_staff:
                    queryset = Order.objects.all()
                    restaurant_id = self.request.query_params.get('restaurant') or self.request.query_params.get('restaurant_id')
                    if restaurant_id:
                        queryset = queryset.filter(restaurant_id=restaurant_id)
                    return queryset
            except Exception:
                pass
            # Client authentifié: seulement ses propres commandes
            return Order.objects.filter(user=self.request.user)
        # Utilisateur anonyme: accès via phone
        phone = self.request.GET.get('phone')
        if phone:
            return Order.objects.filter(phone=phone, user=None)
        return Order.objects.none()

    @action(detail=False, methods=['get', 'post'], url_path='panier')
    def panier(self, request):
        if request.method == 'GET':
            return self.get_panier(request)
        elif request.method == 'POST':
            return self.create_panier(request)
    
    def get_panier(self, request):
        user = request.user if request.user.is_authenticated else None
        phone = request.GET.get('phone')
        
        if user:
            # Utilisateur connecté
            panier = Order.objects.filter(user=user, status='panier').first()
        elif phone:
            # Utilisateur anonyme avec numéro de téléphone
            panier = Order.objects.filter(phone=phone, user=None, status='panier').first()
        else:
            # Aucune identification
            return Response({'panier': None})
            
        if not panier:
            return Response({'panier': None})
        serializer = self.get_serializer(panier)
        return Response({'panier': serializer.data})
    
    def create_panier(self, request):
        """Créer ou mettre à jour un panier"""
        try:
            data = request.data
            print('[PANIER] Payload reçu:', data)
            user = request.user if request.user.is_authenticated else None
            phone = data.get('phone')
            items = data.get('items', [])
            restaurant_id = data.get('restaurant_id')
            
            # Validations explicites pour éviter les 500
            if not user and (not phone or str(phone).strip() == ''):
                return Response({'error': 'Téléphone requis pour les utilisateurs non authentifiés'}, status=400)
            if not items:
                return Response({'error': 'Aucun item spécifié (items vide)'}, status=400)
            if not restaurant_id:
                return Response({'error': 'Restaurant requis'}, status=400)
            
            # Calculer le prix total
            total_amount = 0.0
            for item in items:
                prix = item.get('prix', 0)
                quantity = item.get('quantity', 1)
                if isinstance(prix, str):
                    prix = float(prix)
                total_amount += prix * quantity
            
            # Récupérer ou créer le panier
            if user:
                panier, created = Order.objects.get_or_create(
                    user=user, 
                    status='panier',
                    restaurant_id=restaurant_id,
                    defaults={'total_amount': total_amount, 'items': items}
                )
            else:
                panier, created = Order.objects.get_or_create(
                    phone=phone, 
                    user=None,
                    status='panier',
                    restaurant_id=restaurant_id,
                    defaults={'total_amount': total_amount, 'items': items}
                )
            
            # Mettre à jour le panier
            if not created:
                panier.items = items
                panier.total_amount = total_amount
                panier.restaurant_id = restaurant_id
                if phone:
                    panier.phone = phone
                panier.save()
            
            serializer = self.get_serializer(panier)
            payload = serializer.data
            return Response(payload, status=201 if created else 200)
            
        except Exception as e:
            import traceback
            print('[PANIER][ERROR]', str(e))
            print(traceback.format_exc())
            return Response({'error': str(e)}, status=500)

    @action(detail=True, methods=['post'], url_path='valider')
    def valider_panier(self, request, pk=None):
        order = self.get_object()
        if order.status != 'panier':
            return Response({'error': 'Commande déjà validée'}, status=400)
        
        # Mettre à jour le statut de la commande
        order.status = 'en_attente'
        order.save()
        
        # Envoi notification push si possible
        user = order.user
        if user and hasattr(user, 'userprofile'):
            try:
                if user.userprofile.fcm_token:
                    push_service = FCMNotification(api_key='VOTRE_CLE_FCM')
                    push_service.notify_single_device(
                        registration_id=user.userprofile.fcm_token,
                        message_title="Commande validée !",
                        message_body=f"Votre commande #{order.id} a été validée et est en cours de préparation."
                    )
            except Exception as e:
                print(f"Erreur envoi notification FCM: {e}")
        
        # Notifier le personnel du restaurant
        try:
            self._notify_restaurant_staff(order.restaurant, title="Nouvelle commande", body=f"Commande #{order.id} validée.")
        except Exception as e:
            print(f"[FCM] Erreur notif staff: {e}")
        
        serializer = self.get_serializer(order)
        return Response({
            'commande': serializer.data, 
            'message': 'Commande validée avec succès'
        })

    @action(detail=False, methods=['post'], url_path='valider-panier')
    def valider_panier_direct(self, request):
        """Valider un panier directement depuis les données du panier"""
        try:
            items = request.data.get('items', [])
            phone = request.data.get('phone')
            client_name = request.data.get('client_name')
            restaurant_id = request.data.get('restaurant_id')
            
            if not items:
                return Response({'error': 'Aucun item dans le panier'}, status=400)
            
            if not restaurant_id:
                return Response({'error': 'ID du restaurant requis'}, status=400)
            
            # Calculer le total
            total_amount = sum(
                float(item.get('prix', 0)) * int(item.get('quantity', 1))
                for item in items
            )
            
            # Créer la commande validée directement
            order_data = {
                'restaurant_id': restaurant_id,
                'items': items,
                'total_amount': total_amount,
                'status': 'en_attente',  # Directement en attente
                'phone': phone,
            }
            
            # Si on a un utilisateur authentifié, l'associer
            if request.user.is_authenticated:
                order_data['user'] = request.user
            
            # Créer la commande
            order = Order.objects.create(**order_data)
            
            # Envoi notification push si possible
            user = order.user
            if user and hasattr(user, 'userprofile'):
                try:
                    if user.userprofile.fcm_token:
                        push_service = FCMNotification(api_key='VOTRE_CLE_FCM')
                        push_service.notify_single_device(
                            registration_id=user.userprofile.fcm_token,
                            message_title="Commande validée !",
                            message_body=f"Votre commande #{order.id} a été validée et est en cours de préparation."
                        )
                except Exception as e:
                    print(f"Erreur envoi notification FCM: {e}")
            
            # Notifier le personnel du restaurant
            try:
                self._notify_restaurant_staff(order.restaurant, title="Nouvelle commande", body=f"Commande #{order.id} validée.")
            except Exception as e:
                print(f"[FCM] Erreur notif staff: {e}")
            
            serializer = self.get_serializer(order)
            return Response({
                'commande': serializer.data,
                'message': 'Panier validé avec succès'
            }, status=201)
            
        except Exception as e:
            import traceback
            print('[VALIDER-PANIER][ERROR]', str(e))
            print(traceback.format_exc())
            return Response({'error': str(e)}, status=500)

    @action(detail=True, methods=['post'], url_path='update-status')
    def update_status(self, request, pk=None):
        """Mettre à jour le statut d'une commande"""
        order = self.get_object()
        new_status = request.data.get('status')
        
        if not new_status:
            return Response({'error': 'Statut requis'}, status=400)
        
        if new_status not in dict(Order.STATUS_CHOICES):
            return Response({'error': 'Statut invalide'}, status=400)
        
        order.status = new_status
        order.save()
        try:
            OrderStatusLog.objects.create(order=order, status=new_status, message=f'status={new_status}')
        except Exception:
            pass

        # Envoi SMS automatique si terminé
        if new_status == 'termine':
            try:
                phone = getattr(order, 'phone', None)
                if not phone and order.user and hasattr(order.user, 'userprofile'):
                    phone = getattr(order.user.userprofile, 'phone', None)
                if phone:
                    # Normaliser (ajouter indicatif si manquant)
                    code = getattr(settings, 'DEFAULT_SMS_COUNTRY_CODE', '+221')
                    num = str(phone)
                    if not num.startswith('+'):
                        # garder uniquement les chiffres
                        digits = ''.join([c for c in num if c.isdigit()])
                        if not digits.startswith(code.replace('+','')):
                            num = f"{code}{digits}"
                        else:
                            num = f"+{digits}"
                    self._send_sms(num, f"Votre commande #{order.id} est terminée. Merci pour votre confiance !")
            except Exception as e:
                print(f"[SMS] Erreur post-statut termine: {e}")
        
        # Envoi notification push si possible
        user = order.user
        if user and hasattr(user, 'userprofile'):
            try:
                if user.userprofile.fcm_token:
                    push_service = FCMNotification(api_key='VOTRE_CLE_FCM')
                    status_text = dict(Order.STATUS_CHOICES)[new_status]
                    push_service.notify_single_device(
                        registration_id=user.userprofile.fcm_token,
                        message_title="Mise à jour de commande",
                        message_body=f"Votre commande #{order.id} est maintenant {status_text}."
                    )
            except Exception as e:
                print(f"Erreur envoi notification FCM: {e}")
        # Notifier le personnel du restaurant pour certains statuts
        try:
            if new_status in ['en_attente', 'en_preparation', 'pret']:
                self._notify_restaurant_staff(order.restaurant, title="Commande mise à jour", body=f"Commande #{order.id}: {new_status}")
        except Exception as e:
            print(f"[FCM] Erreur notif staff: {e}")
        
        serializer = self.get_serializer(order)
        return Response({
            'commande': serializer.data,
            'message': f'Statut mis à jour vers {new_status}'
        })

    # --- Utilitaires internes ---
    def _send_sms(self, phone: str, message: str):
        try:
            # Envoi via Twilio si configuré
            from twilio.rest import Client  # type: ignore
            account_sid = getattr(settings, 'TWILIO_ACCOUNT_SID', None)
            auth_token = getattr(settings, 'TWILIO_AUTH_TOKEN', None)
            from_number = getattr(settings, 'TWILIO_FROM_NUMBER', None)
            if account_sid and auth_token and from_number:
                client = Client(account_sid, auth_token)
                client.messages.create(body=message, from_=from_number, to=phone)
                return
        except Exception as e:
            print(f"[SMS] Erreur envoi SMS: {e}")
        # Fallback: log console si non configuré
        print(f"[SMS][FAKE] to={phone} msg={message}")

    def _notify_restaurant_staff(self, restaurant, title: str, body: str):
        # Fonction simplifiée pour éviter les erreurs liées aux champs supprimés
        try:
            # Utiliser is_staff au lieu du champ role
            staff_users = User.objects.filter(is_staff=True, is_active=True)
            staff_profiles = UserProfile.objects.filter(user__in=staff_users).exclude(fcm_token__isnull=True).exclude(fcm_token='')
            if not staff_profiles:
                return
            push_service = FCMNotification(api_key=getattr(settings, 'FCM_SERVER_KEY', ''))
            for prof in staff_profiles:
                try:
                    push_service.notify_single_device(registration_id=prof.fcm_token, message_title=title, message_body=body)
                except Exception as e:
                    print(f"[FCM] Erreur envoi staff {prof.user_id}: {e}")
        except Exception as e:
            print(f"[FCM] Erreur préparation staff list: {e}")

    def update(self, request, *args, **kwargs):
        order = self.get_object()
        
        # Vérifier les permissions
        if not self._can_modify_order(request, order):
            return Response({'error': 'Permission refusée'}, status=403)
        
        if order.status != 'panier':
            return Response({'error': 'Impossible de modifier une commande validée'}, status=400)
        return super().update(request, *args, **kwargs)

    def partial_update(self, request, *args, **kwargs):
        order = self.get_object()
        
        # Vérifier les permissions
        if not self._can_modify_order(request, order):
            return Response({'error': 'Permission refusée'}, status=403)
        
        if order.status != 'panier':
            return Response({'error': 'Impossible de modifier une commande validée'}, status=400)
        return super().partial_update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        order = self.get_object()
        
        # Vérifier les permissions
        if not self._can_modify_order(request, order):
            return Response({'error': 'Permission refusée'}, status=403)
        
        if order.status != 'panier':
            return Response({'error': 'Impossible de supprimer une commande validée'}, status=400)
        return super().destroy(request, *args, **kwargs)
    
    @action(detail=False, methods=['get'])
    def historique(self, request):
        """Historique des commandes de l'utilisateur"""
        user = request.user
        phone = request.GET.get('phone')
        
        if user.is_authenticated:
            orders = Order.objects.filter(
                user=user
            ).exclude(status='panier').order_by('-created_at')
        elif phone:
            orders = Order.objects.filter(
                phone=phone,
                user=None
            ).exclude(status='panier').order_by('-created_at')
        else:
            return Response({'orders': []})
        
        serializer = self.get_serializer(orders, many=True)
        return Response({'orders': serializer.data})
    
    @action(detail=True, methods=['get'])
    def suivi(self, request, pk=None):
        """Suivi détaillé d'une commande"""
        order = self.get_object()
        
        # Vérifier que l'utilisateur peut voir cette commande
        if not self._can_view_order(request, order):
            return Response({'error': 'Permission refusée'}, status=403)
        
        # Historique simple basé sur le statut actuel
        status_history = [
            {
                'status': order.status,
                'timestamp': order.created_at.isoformat(),
                'message': f'Commande {order.status}'
            }
        ]
        
        serializer = self.get_serializer(order)
        return Response({
            'order': serializer.data,
            'status_history': status_history,
            'estimated_time': self._get_estimated_time(order)
        })
    
    def _can_view_order(self, request, order):
        """Vérifier si l'utilisateur peut voir cette commande"""
        if request.user.is_authenticated:
            # Admin peut voir toutes les commandes
            if request.user.is_staff:
                return True
            # Utilisateur peut voir ses propres commandes
            if order.user == request.user:
                return True
        
        # Utilisateur anonyme peut voir via téléphone (GET ou POST)
        phone = request.GET.get('phone') or getattr(request, 'data', {}).get('phone')
        if phone and order.phone == phone and order.user is None:
            return True
        
        return False
    
    def _get_estimated_time(self, order):
        """Calculer le temps estimé de préparation"""
        if order.status == 'termine':
            return None
        
        if order.status == 'panier':
            return None
        
        base_time = 20  # minutes de base
        if order.status == 'en_attente':
            return base_time + 10
        elif order.status == 'en_preparation':
            return base_time
        elif order.status == 'pret':
            return 0
        
        return base_time
    
    def _can_modify_order(self, request, order):
        """Vérifier si l'utilisateur peut modifier cette commande"""
        # Le personnel peut modifier toutes les commandes
        if request.user.is_authenticated:
            if request.user.is_staff:
                return True
            # L'utilisateur connecté peut modifier ses propres commandes
            if order.user == request.user:
                return True
        
        # Utilisateur anonyme peut modifier sa commande via le téléphone
        phone = request.data.get('phone') or request.GET.get('phone')
        if phone and order.phone == phone and order.user is None:
            return True
        
        return False

    def create(self, request, *args, **kwargs):
        # Log pour debug
        print(f"[DEBUG ORDERS CREATE] Data reçue: {request.data}")
        print(f"[DEBUG ORDERS CREATE] Headers: {request.headers}")
        print(f"[DEBUG ORDERS CREATE] User: {request.user}")
        
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            print(f"[DEBUG ORDERS CREATE] Erreurs de validation: {serializer.errors}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        order = serializer.save()
        print(f"[DEBUG ORDERS CREATE] Commande créée avec succès: {order.id}")
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def list(self, request, *args, **kwargs):
        # Log pour debug
        print(f"[DEBUG ORDERS] Headers reçus: {request.headers}")
        print(f"[DEBUG ORDERS] Token: {request.headers.get('Authorization')}")
        return super().list(request, *args, **kwargs)

    @action(detail=False, methods=['get'], url_path='events')
    def events(self, request):
        """Flux d'événements (logs de statut) pour un restaurant (staff seulement)"""
        user = request.user
        if not user.is_authenticated:
            return Response({'error': 'Auth requise'}, status=401)
        if not user.is_staff:
            return Response({'error': 'Permission refusée'}, status=403)

        restaurant_id = request.GET.get('restaurant') or request.GET.get('restaurant_id')
        qs = Order.objects.all()
        if restaurant_id:
            qs = qs.filter(restaurant_id=restaurant_id)
        limit = int(request.GET.get('limit', '50'))
        qs = qs.order_by('-created_at')[:max(1, min(limit, 200))]
        data = [
            {
                'id': order.id,
                'order_id': order.id,
                'restaurant_id': getattr(order, 'restaurant_id', None),
                'status': order.status,
                'message': f'Commande {order.status}',
                'created_at': order.created_at.isoformat(),
            }
            for order in qs
        ]
        return Response({'events': data})

    @action(detail=True, methods=['post'], url_path='feedback')
    def leave_feedback(self, request, pk=None):
        """Permettre au client (auth ou anonyme via phone) de laisser un avis sur sa commande"""
        # Ne pas utiliser self.get_object() pour éviter les filtres de get_queryset (anonymes)
        try:
            order = Order.objects.get(pk=pk)
        except Order.DoesNotExist:
            return Response({'error': 'Commande introuvable'}, status=404)
        # Vérifier le droit de commenter (mêmes règles que _can_view_order)
        if not self._can_view_order(request, order):
            return Response({'error': 'Permission refusée'}, status=403)
        
        # Pour l'instant, retourner un message indiquant que les feedbacks ne sont pas encore implémentés
        return Response({'message': 'Les feedbacks ne sont pas encore implémentés'}, status=501)

class RestaurantViewSet(viewsets.ReadOnlyModelViewSet):
    # Évite que des slugs non numériques (ex: "register") soient capturés par la route détail
    lookup_value_regex = r"\d+"
    queryset = Restaurant.objects.all()
    serializer_class = RestaurantSerializer
    permission_classes = [permissions.AllowAny]
    
    def get_queryset(self):
        """Seuls les restaurants validés et actifs sont visibles par les clients"""
        return Restaurant.objects.filter(statut='valide', actif=True)
    
    @action(detail=True, methods=['get'])
    def menu(self, request, pk=None):
        """Récupérer le menu d'un restaurant spécifique"""
        restaurant = self.get_object()
        menu_items = MenuItem.objects.filter(
            restaurant=restaurant,
            disponible=True
        ).order_by('type', 'nom')
        # Fallback si aucun plat marqué disponible
        if not menu_items.exists():
            menu_items = MenuItem.objects.filter(restaurant=restaurant).order_by('type', 'nom')
        # Fallback supplémentaires: plats globaux sans restaurant
        if not menu_items.exists():
            menu_items = MenuItem.objects.filter(restaurant__isnull=True, disponible=True).order_by('type', 'nom')
        
        from .serializers import MenuItemSerializer
        serializer = MenuItemSerializer(menu_items, many=True, context={'request': request})
        return Response({
            'restaurant': RestaurantSerializer(restaurant).data,
            'menu': serializer.data
        })
    
    @action(detail=True, methods=['get'])
    def plat_du_jour(self, request, pk=None):
        """Récupérer le plat du jour d'un restaurant"""
        restaurant = self.get_object()
        plat_du_jour = MenuItem.objects.filter(
            restaurant=restaurant,
            plat_du_jour=True,
            disponible=True
        ).first()
        
        if plat_du_jour:
            from .serializers import MenuItemSerializer
            serializer = MenuItemSerializer(plat_du_jour)
            return Response({
                'restaurant': RestaurantSerializer(restaurant).data,
                'plat_du_jour': serializer.data
            })
        else:
            return Response({
                'restaurant': RestaurantSerializer(restaurant).data,
                'plat_du_jour': None,
                'message': 'Aucun plat du jour défini'
            })

class BaseViewSet(viewsets.ModelViewSet):
    queryset = Base.objects.filter(disponible=True)
    serializer_class = BaseSerializer
    permission_classes = [IsAdminOrReadOnly]

    def get_queryset(self):
        """Filtrer les bases par restaurant de l'utilisateur"""
        user = self.request.user
        if user.is_authenticated and user.is_staff:
            return Base.objects.filter(disponible=True)  # Admin voit tout
        return Base.objects.filter(disponible=True)
    
    def perform_create(self, serializer):
        """Associer automatiquement le restaurant de l'utilisateur"""
        # Pour l'instant, on laisse l'utilisateur spécifier le restaurant manuellement
        serializer.save()

@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def upload_image(request):
    """Endpoint général pour uploader des images"""
    try:
        if 'image' not in request.FILES:
            return Response({'error': 'Aucune image fournie'}, status=400)
        
        image_file = request.FILES['image']
        model_type = request.data.get('model_type', 'menu')  # menu, ingredient, base
        item_id = request.data.get('item_id')
        
        if not item_id:
            return Response({'error': 'ID de l\'élément manquant'}, status=400)
        
        # Déterminer le modèle à mettre à jour
        if model_type == 'menu':
            try:
                item = MenuItem.objects.get(id=item_id)
                item.image = image_file
                item.save()
                return Response({
                    'message': 'Image uploadée avec succès',
                    'image_url': request.build_absolute_uri(item.image.url) if item.image else None,
                    'model_type': 'menu',
                    'item_id': item_id
                })
            except MenuItem.DoesNotExist:
                return Response({'error': 'Plat non trouvé'}, status=404)
        
        elif model_type == 'ingredient':
            try:
                item = Ingredient.objects.get(id=item_id)
                item.image = image_file
                item.save()
                return Response({
                    'message': 'Image uploadée avec succès',
                    'image_url': request.build_absolute_uri(item.image.url) if item.image else None,
                    'model_type': 'ingredient',
                    'item_id': item_id
                })
            except Ingredient.DoesNotExist:
                return Response({'error': 'Ingrédient non trouvé'}, status=404)
        
        elif model_type == 'base':
            try:
                item = Base.objects.get(id=item_id)
                item.image = image_file
                item.save()
                return Response({
                    'message': 'Image uploadée avec succès',
                    'image_url': request.build_absolute_uri(item.image.url) if item.image else None,
                    'model_type': 'base',
                    'item_id': item_id
                })
            except Base.DoesNotExist:
                return Response({'error': 'Base non trouvée'}, status=404)
        elif model_type == 'restaurant':
            try:
                item = Restaurant.objects.get(id=item_id)
                # Champ logo pour Restaurant
                item.logo = image_file
                item.save()
                return Response({
                    'message': 'Logo uploadé avec succès',
                    'image_url': request.build_absolute_uri(item.logo.url) if item.logo else None,
                    'model_type': 'restaurant',
                    'item_id': item_id
                })
            except Restaurant.DoesNotExist:
                return Response({'error': 'Restaurant non trouvé'}, status=404)
        
        else:
            return Response({'error': 'Type de modèle non supporté'}, status=400)
            
    except Exception as e:
        return Response({'error': f'Erreur lors de l\'upload: {str(e)}'}, status=500)

@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def pin_login(request):
    """Connexion par téléphone + PIN selon la logique Django standard :
    - username = numéro de téléphone
    - password = code PIN
    """
    def _normalize_phone(value):
        if not value:
            return None
        import re
        digits = re.sub(r'[^0-9]', '', str(value))
        return digits

    pin = request.data.get('pin') or request.data.get('pin_code')
    phone_raw = request.data.get('phone') or request.data.get('username')
    phone = _normalize_phone(phone_raw)

    if not phone:
        return Response({'error': 'Numéro requis'}, status=400)
    if not pin:
        return Response({'error': 'PIN requis'}, status=400)

    try:
        # Logique normale Django: username = téléphone, password = PIN
        user = authenticate(username=phone, password=str(pin))

        if user is None:
            # Compatibilité avec les anciens comptes créés via le suffixe de téléphone
            legacy_profile = None
            if phone:
                legacy_profile = UserProfile.objects.filter(phone=phone).first()
            if legacy_profile is not None:
                legacy_user = legacy_profile.user
                if legacy_user.check_password(str(pin)):
                    user = legacy_user

        if user is None:
            return Response({'error': 'PIN incorrect'}, status=401)

        if not user.is_active:
            return Response({'error': 'Compte désactivé'}, status=401)

        refresh = RefreshToken.for_user(user)

        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': {
                'id': user.id,
                'username': user.username,
                'role': 'admin' if user.is_staff else 'client',
                'first_name': user.first_name,
                'last_name': user.last_name,
            }
        })
    except Exception as e:
        print(f"[DEBUG PIN LOGIN] Erreur: {str(e)}")
        return Response({'error': f'Erreur de connexion: {str(e)}'}, status=500)

# ========= INTÉGRATION WAVE =========

@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def create_wave_payment(request):
    """Créer une URL de paiement Wave pour une commande"""
    try:
        order_id = request.data.get('order_id')
        if not order_id:
            return Response({'error': 'ID de commande requis'}, status=400)
        
        try:
            order = Order.objects.get(id=order_id)
        except Order.DoesNotExist:
            return Response({'error': 'Commande introuvable'}, status=404)
        
        # Vérifier que la commande peut être payée
        if order.payment_status != 'pending':
            return Response({'error': 'Cette commande a déjà été traitée'}, status=400)
        
        # Vérifier que le restaurant a un lien Wave configuré
        restaurant = order.restaurant
        if not restaurant.wave_payment_link:
            return Response({'error': 'Paiement Wave non configuré pour ce restaurant'}, status=400)
        
        # Générer l'URL de paiement Wave
        wave_url = _generate_wave_payment_url(order, restaurant)
        
        # Mettre à jour la commande avec l'URL de paiement
        order.wave_payment_url = wave_url
        order.save()
        
        # Logger l'événement
        WavePaymentLog.objects.create(
            order=order,
            event_type='payment_initiated',
            amount=order.total_amount,
            raw_data={'wave_url': wave_url}
        )
        
        return Response({
            'payment_url': wave_url,
            'order_id': order.id,
            'amount': float(order.total_amount),
            'restaurant': restaurant.nom,
            'message': 'URL de paiement générée avec succès'
        })
        
    except Exception as e:
        print(f"[WAVE PAYMENT] Erreur: {str(e)}")
        return Response({'error': f'Erreur lors de la création du paiement: {str(e)}'}, status=500)

@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def wave_webhook(request):
    """Webhook Wave pour recevoir les notifications de paiement"""
    try:
        # Récupérer les données du webhook
        data = request.data
        print(f"[WAVE WEBHOOK] Données reçues: {data}")
        
        # Extraire les informations importantes
        transaction_id = data.get('transaction_id') or data.get('id')
        reference = data.get('reference') or data.get('order_reference')
        status = data.get('status') or data.get('state')
        amount = data.get('amount')
        
        if not transaction_id:
            return Response({'error': 'Transaction ID manquant'}, status=400)
        
        # Trouver la commande correspondante
        order = None
        if reference:
            try:
                order = Order.objects.get(wave_payment_reference=reference)
            except Order.DoesNotExist:
                pass
        
        if not order and transaction_id:
            # Fallback: chercher par transaction_id dans les logs
            log = WavePaymentLog.objects.filter(
                wave_transaction_id=transaction_id
            ).first()
            if log:
                order = log.order
        
        if not order:
            # Logger l'événement même si on ne trouve pas la commande
            WavePaymentLog.objects.create(
                order=None,
                event_type='webhook_received',
                wave_transaction_id=transaction_id,
                wave_reference=reference,
                status=status,
                amount=amount,
                raw_data=data,
                error_message='Commande introuvable'
            )
            return Response({'error': 'Commande introuvable'}, status=404)
        
        # Logger l'événement
        WavePaymentLog.objects.create(
            order=order,
            event_type='webhook_received',
            wave_transaction_id=transaction_id,
            wave_reference=reference,
            status=status,
            amount=amount,
            raw_data=data
        )
        
        # Traiter le statut du paiement
        if status in ['success', 'completed', 'paid']:
            # Paiement réussi
            order.payment_status = 'paid'
            order.wave_transaction_id = transaction_id
            order.wave_payment_reference = reference
            order.payment_date = timezone.now()
            order.save()
            
            # Logger le succès
            WavePaymentLog.objects.create(
                order=order,
                event_type='payment_success',
                wave_transaction_id=transaction_id,
                wave_reference=reference,
                status=status,
                amount=amount,
                raw_data=data
            )
            
            # Notifier le client
            _notify_payment_success(order)
            
            return Response({'status': 'success', 'message': 'Paiement confirmé'})
            
        elif status in ['failed', 'cancelled', 'expired']:
            # Paiement échoué
            order.payment_status = 'failed'
            order.wave_transaction_id = transaction_id
            order.wave_payment_reference = reference
            order.save()
            
            # Logger l'échec
            WavePaymentLog.objects.create(
                order=order,
                event_type='payment_failed',
                wave_transaction_id=transaction_id,
                wave_reference=reference,
                status=status,
                amount=amount,
                raw_data=data
            )
            
            # Notifier le client
            _notify_payment_failed(order)
            
            return Response({'status': 'failed', 'message': 'Paiement échoué'})
        
        else:
            # Statut inconnu
            return Response({'status': 'unknown', 'message': f'Statut non traité: {status}'})
            
    except Exception as e:
        print(f"[WAVE WEBHOOK] Erreur: {str(e)}")
        return Response({'error': f'Erreur webhook: {str(e)}'}, status=500)

@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def check_payment_status(request, order_id):
    """Vérifier le statut de paiement d'une commande"""
    try:
        order = Order.objects.get(id=order_id)
        
        # Récupérer les logs de paiement récents
        logs = WavePaymentLog.objects.filter(order=order).order_by('-created_at')[:5]
        
        return Response({
            'order_id': order.id,
            'payment_status': order.payment_status,
            'payment_method': order.payment_method,
            'amount': float(order.total_amount),
            'payment_date': order.payment_date.isoformat() if order.payment_date else None,
            'wave_transaction_id': order.wave_transaction_id,
            'wave_payment_url': order.wave_payment_url,
            'recent_logs': [
                {
                    'event_type': log.event_type,
                    'status': log.status,
                    'created_at': log.created_at.isoformat(),
                    'error_message': log.error_message
                }
                for log in logs
            ]
        })
        
    except Order.DoesNotExist:
        return Response({'error': 'Commande introuvable'}, status=404)
    except Exception as e:
        return Response({'error': f'Erreur: {str(e)}'}, status=500)

# ========= FONCTIONS UTILITAIRES WAVE =========

def _generate_wave_payment_url(order, restaurant):
    """Générer l'URL de paiement Wave pour une commande"""
    base_url = restaurant.wave_payment_link
    
    # Si c'est un lien Wave personnalisé, ajouter les paramètres
    if 'wave.com' in base_url or 'waveapp.com' in base_url:
        # Format Wave standard
        params = {
            'amount': str(int(float(order.total_amount) * 100)),  # Wave utilise les centimes
            'currency': 'XOF',
            'reference': f'ORDER_{order.id}',
            'description': f'Commande #{order.id} - {restaurant.nom}',
            'callback_url': f'{settings.BASE_URL}/api/wave/webhook/',
            'return_url': f'{settings.BASE_URL}/payment/success/{order.id}/',
            'cancel_url': f'{settings.BASE_URL}/payment/cancel/{order.id}/'
        }
        
        # Construire l'URL avec les paramètres
        from urllib.parse import urlencode
        wave_url = f"{base_url}?{urlencode(params)}"
        
        # Mettre à jour la référence de paiement
        order.wave_payment_reference = params['reference']
        order.save()
        
        return wave_url
    else:
        # Lien personnalisé du restaurant
        return base_url

def _notify_payment_success(order):
    """Notifier le succès du paiement"""
    try:
        # Notification push au client
        if order.user and hasattr(order.user, 'userprofile'):
            token = order.user.userprofile.fcm_token
            if token:
                push_service = FCMNotification(api_key=getattr(settings, 'FCM_SERVER_KEY', ''))
                push_service.notify_single_device(
                    registration_id=token,
                    message_title="Paiement confirmé ! 🎉",
                    message_body=f"Votre paiement de {order.total_amount} F CFA a été confirmé. Votre commande #{order.id} est en cours de préparation."
                )
        
        # Notification au restaurant
        _notify_restaurant_staff(
            order.restaurant,
            title="Paiement reçu 💰",
            body=f"Commande #{order.id} payée - {order.total_amount} F CFA"
        )
        
    except Exception as e:
        print(f"[NOTIFICATION] Erreur paiement réussi: {e}")

def _notify_payment_failed(order):
    """Notifier l'échec du paiement"""
    try:
        # Notification push au client
        if order.user and hasattr(order.user, 'userprofile'):
            token = order.user.userprofile.fcm_token
            if token:
                push_service = FCMNotification(api_key=getattr(settings, 'FCM_SERVER_KEY', ''))
                push_service.notify_single_device(
                    registration_id=token,
                    message_title="Paiement échoué ❌",
                    message_body=f"Le paiement de votre commande #{order.id} a échoué. Veuillez réessayer."
                )
        
    except Exception as e:
        print(f"[NOTIFICATION] Erreur paiement échoué: {e}")

def _notify_restaurant_staff(restaurant, title, body):
    """Notifier le personnel du restaurant"""
    try:
        staff_users = User.objects.filter(is_staff=True, is_active=True)
        staff_profiles = UserProfile.objects.filter(
            user__in=staff_users
        ).exclude(fcm_token__isnull=True).exclude(fcm_token='')
        
        if staff_profiles:
            push_service = FCMNotification(api_key=getattr(settings, 'FCM_SERVER_KEY', ''))
            for profile in staff_profiles:
                try:
                    push_service.notify_single_device(
                        registration_id=profile.fcm_token,
                        message_title=title,
                        message_body=body
                    )
                except Exception as e:
                    print(f"[FCM] Erreur envoi staff {profile.user_id}: {e}")
    except Exception as e:
        print(f"[FCM] Erreur préparation staff list: {e}")

# ========== ENDPOINT PUBLIC POUR DEMANDES D'INSCRIPTION RESTAURANTS ==========

@api_view(['POST'])
@permission_classes([AllowAny])
def restaurant_registration_request(request):
    """
    Endpoint public pour que les restaurants puissent faire une demande d'inscription
    """
    try:
        data = json.loads(request.body)
        
        # Validation des champs obligatoires
        required_fields = ['nom', 'adresse', 'telephone', 'email', 'nom_gerant', 'telephone_gerant']
        missing_fields = [field for field in required_fields if not data.get(field)]
        
        if missing_fields:
            return Response({
                'error': f'Champs manquants: {", ".join(missing_fields)}'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Vérifier si un restaurant avec ce nom ou téléphone existe déjà
        existing_restaurant = Restaurant.objects.filter(
            Q(nom__iexact=data['nom']) | Q(telephone=data['telephone'])
        ).first()
        
        if existing_restaurant:
            return Response({
                'error': 'Un restaurant avec ce nom ou ce numéro de téléphone existe déjà'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Créer la demande d'inscription (statut 'en_attente')
        restaurant = Restaurant.objects.create(
            nom=data['nom'],
            adresse=data['adresse'],
            telephone=data['telephone'],
            email=data['email'],
            description=data.get('description', ''),
            statut='en_attente',  # En attente de validation
            actif=False,  # Inactif jusqu'à validation
            # Champs supplémentaires pour la demande
            nom_gerant=data['nom_gerant'],
            telephone_gerant=data['telephone_gerant'],
            type_cuisine=data.get('type_cuisine', ''),
            capacite=data.get('capacite', 0),
            horaires=data.get('horaires', ''),
            documents_legaux=data.get('documents_legaux', False),
            # Configuration Wave
            wave_payment_link=data.get('wave_payment_link', ''),
            wave_merchant_id=data.get('wave_merchant_id', ''),
            wave_api_key=data.get('wave_api_key', '')
        )
        
        # Notifier les admins de la nouvelle demande
        try:
            send_notification_to_admins(
                "Nouvelle demande d'inscription",
                f"Le restaurant '{restaurant.nom}' a soumis une demande d'inscription",
                "restaurant_request"
            )
        except Exception as e:
            print(f"Erreur notification admin: {e}")
        
        return Response({
            'success': True,
            'message': 'Votre demande d\'inscription a été soumise avec succès. Vous recevrez une réponse sous 24-48h.',
            'restaurant_id': restaurant.id,
            'statut': restaurant.statut
        }, status=status.HTTP_201_CREATED)
        
    except json.JSONDecodeError:
        return Response({
            'error': 'Données JSON invalides'
        }, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({
            'error': f'Erreur lors de la soumission: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@permission_classes([AllowAny])
def restaurant_registration_info(request):
    """
    Informations sur le processus d'inscription pour les restaurants
    """
    return Response({
        'process': {
            'etapes': [
                '1. Soumettre votre demande avec tous les documents requis',
                '2. Notre équipe examine votre dossier sous 24-48h',
                '3. Si approuvé, vous recevez vos identifiants de connexion',
                '4. Vous pouvez alors configurer votre menu et commencer à recevoir des commandes'
            ],
            'documents_requis': [
                'Nom et adresse du restaurant',
                'Numéro de téléphone et email',
                'Nom du gérant responsable',
                'Type de cuisine proposée',
                'Documents légaux (optionnel)'
            ],
            'avantages': [
                'Interface de gestion complète',
                'Gestion des commandes en temps réel',
                'Système de paiement intégré (Wave)',
                'Statistiques et rapports',
                'Support client dédié'
            ],
            'wave_configuration': {
                'description': 'Vous pouvez configurer vos paramètres Wave directement lors de l\'inscription ou plus tard dans votre espace admin',
                'champs': [
                    'Lien de paiement Wave (pour recevoir les paiements)',
                    'ID Marchand Wave (identifiant unique)',
                    'Clé API Wave (pour l\'intégration automatique)'
                ],
                'optionnel': True,
                'aide': 'Contactez le support Wave si vous n\'avez pas encore ces informations'
            }
        }
    })

@api_view(['POST'])
@permission_classes([AllowAny])
def validate_wave_link(request):
    """
    Valider un lien de paiement Wave
    """
    try:
        data = json.loads(request.body)
        wave_link = data.get('wave_link', '')
        
        if not wave_link:
            return Response({
                'valid': False,
                'error': 'Lien Wave requis'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Validation basique de l'URL Wave
        if not wave_link.startswith('https://wave.com/pay/'):
            return Response({
                'valid': False,
                'error': 'Le lien doit commencer par https://wave.com/pay/'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Ici, vous pourriez faire une vraie validation avec l'API Wave
        # Pour l'instant, on fait juste une validation de format
        
        return Response({
            'valid': True,
            'message': 'Lien Wave valide',
            'formatted_link': wave_link
        })
        
    except json.JSONDecodeError:
        return Response({
            'valid': False,
            'error': 'Données JSON invalides'
        }, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({
            'valid': False,
            'error': f'Erreur de validation: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
