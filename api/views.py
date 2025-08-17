from rest_framework import viewsets, permissions
from django.contrib.auth.models import User
from .models import MenuItem, Ingredient, CustomDish, Order, Restaurant, Base
from .serializers import (
    MenuItemSerializer, IngredientSerializer, CustomDishSerializer, OrderSerializer, UserSerializer, UserRegisterSerializer, CustomTokenObtainPairSerializer, RestaurantSerializer, BaseSerializer
)
from rest_framework.permissions import BasePermission, SAFE_METHODS
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from pyfcm import FCMNotification
from .models import UserProfile

class IsAdminOrReadOnly(BasePermission):
    def has_permission(self, request, view):
        if request.method in SAFE_METHODS:
            return True
        # Vérifier que l'utilisateur est authentifié et a un profil admin
        if not request.user.is_authenticated:
            return False
        try:
            return hasattr(request.user, 'userprofile') and request.user.userprofile.role == 'admin'
        except:
            return False

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
    role = None
    restaurant_id = None
    try:
        if hasattr(user, 'userprofile'):
            role = user.userprofile.role
            restaurant_id = user.userprofile.restaurant.id if user.userprofile.restaurant else None
    except Exception:
        pass
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

class MenuItemViewSet(viewsets.ModelViewSet):
    queryset = MenuItem.objects.all()
    serializer_class = MenuItemSerializer
    permission_classes = [IsAdminOrReadOnly]
    parser_classes = [MultiPartParser, FormParser]
    
    def get_queryset(self):
        """Filtrer les menus par restaurant de l'utilisateur"""
        user = self.request.user
        if user.is_authenticated and hasattr(user, 'userprofile'):
            if user.userprofile.role == 'admin' and user.userprofile.restaurant:
                return MenuItem.objects.filter(restaurant=user.userprofile.restaurant)
            elif user.userprofile.role == 'admin':
                return MenuItem.objects.all()  # Super admin voit tout
        return MenuItem.objects.all()
    
    def perform_create(self, serializer):
        """Associer automatiquement le restaurant de l'utilisateur"""
        if self.request.user.is_authenticated and hasattr(self.request.user, 'userprofile'):
            if self.request.user.userprofile.restaurant:
                serializer.save(restaurant=self.request.user.userprofile.restaurant)
            else:
                # Pour les super admins sans restaurant spécifique
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
        if user.is_authenticated and hasattr(user, 'userprofile'):
            if user.userprofile.role == 'admin' and user.userprofile.restaurant:
                return Ingredient.objects.filter(restaurant=user.userprofile.restaurant)
            elif user.userprofile.role == 'admin':
                return Ingredient.objects.all()  # Super admin voit tout
        return Ingredient.objects.all()
    
    def perform_create(self, serializer):
        """Associer automatiquement le restaurant de l'utilisateur"""
        if self.request.user.is_authenticated and hasattr(self.request.user, 'userprofile'):
            if self.request.user.userprofile.restaurant:
                serializer.save(restaurant=self.request.user.userprofile.restaurant)
            else:
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
            if hasattr(self.request.user, 'userprofile') and self.request.user.userprofile.role == 'admin':
                return CustomDish.objects.all()
            # Sinon, voir seulement ses propres plats
            return CustomDish.objects.filter(user=self.request.user)
        # Utilisateurs anonymes peuvent seulement voir les plats publics
        return CustomDish.objects.filter(is_public=True) if hasattr(CustomDish, 'is_public') else CustomDish.objects.none()

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
                if hasattr(self.request.user, 'userprofile') and self.request.user.userprofile.role in ['admin', 'personnel', 'chef']:
                    queryset = Order.objects.all()
                    restaurant_id = self.request.query_params.get('restaurant') or self.request.query_params.get('restaurant_id')
                    if restaurant_id:
                        queryset = queryset.filter(restaurant_id=restaurant_id)
                    else:
                        # Par défaut, si l'utilisateur est rattaché à un restaurant, filtrer dessus
                        try:
                            if self.request.user.userprofile.restaurant_id:
                                queryset = queryset.filter(restaurant_id=self.request.user.userprofile.restaurant_id)
                        except Exception:
                            pass
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
            user = request.user if request.user.is_authenticated else None
            phone = data.get('phone')
            plats_ids = data.get('plats_ids', [])
            prix_total = data.get('prix_total', 0)
            
            # Validation
            if not plats_ids:
                return Response({'error': 'Aucun plat spécifié'}, status=400)
            
            if not user and not phone:
                return Response({'error': 'Utilisateur ou téléphone requis'}, status=400)
            
            # Récupérer ou créer le panier
            if user:
                panier, created = Order.objects.get_or_create(
                    user=user, 
                    status='panier',
                    defaults={'prix_total': prix_total}
                )
            else:
                panier, created = Order.objects.get_or_create(
                    phone=phone, 
                    user=None,
                    status='panier',
                    defaults={'prix_total': prix_total}
                )
            
            # Ajouter les plats
            from .models import MenuItem, CustomDish, OrderItem
            panier.order_items.all().delete()  # Vider le panier existant
            
            for plat_id in plats_ids:
                try:
                    # Essayer MenuItem d'abord (traité comme CustomDish)
                    menu_item = MenuItem.objects.get(id=plat_id)
                    
                    # Trouver ou créer une base par défaut
                    from .models import Base
                    base_obj, _ = Base.objects.get_or_create(
                        nom=menu_item.nom,
                        defaults={
                            'prix': menu_item.prix,
                            'image': menu_item.image,
                            'disponible': menu_item.disponible
                        }
                    )
                    
                    # Créer un CustomDish temporaire pour ce MenuItem
                    custom_dish = CustomDish.objects.create(
                        base=base_obj,
                        prix=menu_item.prix
                    )
                    
                    # Créer l'OrderItem
                    OrderItem.objects.create(
                        order=panier,
                        custom_dish=custom_dish,
                        quantity=1
                    )
                except MenuItem.DoesNotExist:
                    try:
                        # CustomDish existant
                        custom_dish = CustomDish.objects.get(id=plat_id)
                        OrderItem.objects.create(
                            order=panier,
                            custom_dish=custom_dish,
                            quantity=1
                        )
                    except CustomDish.DoesNotExist:
                        continue
            
            # Mettre à jour le prix
            panier.prix_total = prix_total
            panier.save()
            
            serializer = self.get_serializer(panier)
            return Response(serializer.data, status=201 if created else 200)
            
        except Exception as e:
            return Response({'error': str(e)}, status=400)

    @action(detail=True, methods=['post'], url_path='valider')
    def valider_panier(self, request, pk=None):
        order = self.get_object()
        if order.status != 'panier':
            return Response({'error': 'Commande déjà validée'}, status=400)
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
                        message_body=f"Votre commande #{order.id} a été validée et est en attente de préparation."
                    )
            except Exception as e:
                print(f"Erreur envoi notification FCM: {e}")
        serializer = self.get_serializer(order)
        return Response({'commande': serializer.data, 'message': 'Commande validée'})

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
        
        serializer = self.get_serializer(order)
        return Response({
            'commande': serializer.data,
            'message': f'Statut mis à jour vers {new_status}'
        })

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
        
        # Historique des statuts (simulation)
        status_history = [
            {
                'status': 'panier',
                'timestamp': order.created_at.isoformat(),
                'message': 'Commande créée'
            }
        ]
        
        if order.status != 'panier':
            status_history.append({
                'status': 'en_attente',
                'timestamp': order.created_at.isoformat(),
                'message': 'Commande validée, en attente de préparation'
            })
        
        if order.status in ['en_preparation', 'pret', 'termine']:
            from datetime import timedelta
            prep_time = order.created_at + timedelta(minutes=5)
            status_history.append({
                'status': 'en_preparation',
                'timestamp': prep_time.isoformat(),
                'message': 'Préparation en cours'
            })
        
        if order.status in ['pret', 'termine']:
            from datetime import timedelta
            ready_time = order.created_at + timedelta(minutes=25)
            status_history.append({
                'status': 'pret',
                'timestamp': ready_time.isoformat(),
                'message': 'Commande prête'
            })
        
        if order.status == 'termine':
            from datetime import timedelta
            finish_time = order.created_at + timedelta(minutes=30)
            status_history.append({
                'status': 'termine',
                'timestamp': finish_time.isoformat(),
                'message': 'Commande livrée'
            })
        
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
            try:
                if hasattr(request.user, 'userprofile') and request.user.userprofile.role in ['admin', 'personnel', 'chef']:
                    return True
            except:
                pass
            # Utilisateur peut voir ses propres commandes
            if order.user == request.user:
                return True
        
        # Utilisateur anonyme peut voir via téléphone
        phone = request.GET.get('phone')
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
            try:
                if hasattr(request.user, 'userprofile') and request.user.userprofile.role in ['admin', 'personnel', 'chef']:
                    return True
            except:
                pass
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

class RestaurantViewSet(viewsets.ReadOnlyModelViewSet):
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
        
        from .serializers import MenuItemSerializer
        serializer = MenuItemSerializer(menu_items, many=True)
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
        if user.is_authenticated and hasattr(user, 'userprofile'):
            if user.userprofile.role == 'admin' and user.userprofile.restaurant:
                return Base.objects.filter(restaurant=user.userprofile.restaurant, disponible=True)
            elif user.userprofile.role == 'admin':
                return Base.objects.filter(disponible=True)  # Super admin voit tout
        return Base.objects.filter(disponible=True)
    
    def perform_create(self, serializer):
        """Associer automatiquement le restaurant de l'utilisateur"""
        if self.request.user.is_authenticated and hasattr(self.request.user, 'userprofile'):
            if self.request.user.userprofile.restaurant:
                serializer.save(restaurant=self.request.user.userprofile.restaurant)
            else:
                serializer.save()

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

    def post(self, request, *args, **kwargs):
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"Payload reçu (connexion): {request.data}")
        print(f"[DEBUG TOKEN] Payload reçu: {request.data}")
        response = super().post(request, *args, **kwargs)
        if response.status_code != 200:
            logger.error(f"Erreur connexion: {response.data}")
            print(f"[DEBUG TOKEN] Erreur: {response.data}")
        return response

@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def register(request):
    serializer = UserRegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        }, status=status.HTTP_201_CREATED)
    # Ajout de logs détaillés
    import logging
    logger = logging.getLogger(__name__)
    logger.error(f"Erreur d'inscription: {serializer.errors}")
    print(f"[DEBUG REGISTER] Erreurs serializer: {serializer.errors}")
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

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
    """Connexion par PIN pour le personnel"""
    pin = request.data.get('pin')
    phone = request.data.get('phone') or request.data.get('username')
    if not pin:
        return Response({'error': 'PIN requis'}, status=400)
    
    try:
        # Chercher un utilisateur avec ce PIN exact ou qui a ce PIN comme suffixe de téléphone
        # On peut aussi ajouter un champ pin_code dédié dans UserProfile pour plus de sécurité
        user_profile = None
        
        # Option A: Si le téléphone est fourni, chercher d'abord par téléphone exact (personnel uniquement)
        if phone:
            candidate = UserProfile.objects.filter(
                role__in=['admin', 'personnel', 'chef'],
                phone=phone
            ).first()
            if candidate:
                # Valider le PIN: champ dédié si présent, sinon derniers chiffres du téléphone
                if getattr(candidate, 'pin_code', None):
                    if str(candidate.pin_code) == str(pin):
                        user_profile = candidate
                else:
                    # Vérifier que le PIN correspond aux derniers chiffres du téléphone
                    if candidate.phone and str(candidate.phone).endswith(str(pin)):
                        user_profile = candidate
        
        # Option B: Fallback global si non trouvé (scanner le personnel et matcher sur suffixe du téléphone)
        if not user_profile:
            # Rechercher uniquement les profils du personnel (éviter les clients)
            staff_profiles = UserProfile.objects.filter(
                role__in=['admin', 'personnel', 'chef']
            )
            for profile in staff_profiles:
                if profile.phone and profile.phone.endswith(pin):
                    user_profile = profile
                    break
        
        if not user_profile:
            return Response({'error': 'PIN incorrect'}, status=401)
        
        user = user_profile.user
        
        # Vérifier que l'utilisateur est actif
        if not user.is_active:
            return Response({'error': 'Compte désactivé'}, status=401)
        
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': {
                'id': user.id,
                'username': user.username,
                'role': user_profile.role,
                'first_name': user.first_name,
                'last_name': user.last_name,
            }
        })
    except Exception as e:
        print(f"[DEBUG PIN LOGIN] Erreur: {str(e)}")
        return Response({'error': f'Erreur de connexion: {str(e)}'}, status=500)
