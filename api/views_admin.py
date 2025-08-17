from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from django.contrib.auth.models import User
from django.db.models import Count, Sum, Avg, Q
from django.utils import timezone
from datetime import datetime, timedelta
from .models import (
    MenuItem, Ingredient, UserProfile, Order, OrderItem, 
    Restaurant, SystemSettings, Category, CustomDish
)
from .serializers import (
    AdminMenuItemSerializer, AdminIngredientSerializer, AdminUserSerializer, 
    OrderSerializer, AdminRestaurantSerializer, CategorySerializer,
    SystemSettingsSerializer
)

class IsAdminPermission(permissions.BasePermission):
    """Permission pour les administrateurs uniquement"""
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        
        # Superuser a toujours accès
        if request.user.is_superuser:
            return True
            
        try:
            return hasattr(request.user, 'userprofile') and request.user.userprofile.role in ['admin', 'personnel', 'chef']
        except:
            return False

# ========== 1. GESTION DU MENU ==========

class AdminMenuViewSet(viewsets.ModelViewSet):
    """Administration complète du menu"""
    queryset = MenuItem.objects.all()
    serializer_class = AdminMenuItemSerializer
    permission_classes = [IsAdminPermission]
    
    def get_queryset(self):
        queryset = MenuItem.objects.all()
        
        # Filtres optionnels
        category = self.request.query_params.get('category')
        type_plat = self.request.query_params.get('type')
        disponible = self.request.query_params.get('disponible')
        
        restaurant_id = self.request.query_params.get('restaurant') or self.request.query_params.get('restaurant_id')
        if restaurant_id:
            queryset = queryset.filter(restaurant_id=restaurant_id)
        if category:
            queryset = queryset.filter(category__id=category)
        if type_plat:
            queryset = queryset.filter(type=type_plat)
        if disponible is not None:
            queryset = queryset.filter(disponible=disponible.lower() == 'true')
            
        return queryset.order_by('-created_at')
    
    @action(detail=True, methods=['post'])
    def toggle_disponible(self, request, pk=None):
        """Activer/désactiver la disponibilité d'un plat"""
        item = self.get_object()
        item.disponible = not item.disponible
        item.save()
        return Response({
            'message': f'Plat {"activé" if item.disponible else "désactivé"}',
            'disponible': item.disponible
        })
    
    @action(detail=True, methods=['post'])
    def toggle_populaire(self, request, pk=None):
        """Marquer/démarquer comme populaire"""
        item = self.get_object()
        item.populaire = not item.populaire
        item.save()
        return Response({
            'message': f'Plat {"marqué" if item.populaire else "démarqué"} comme populaire',
            'populaire': item.populaire
        })

    @action(detail=True, methods=['post'])
    def set_plat_du_jour(self, request, pk=None):
        """Marquer ce plat comme plat du jour (unique par restaurant)"""
        item = self.get_object()
        if not item.restaurant_id:
            return Response({'error': "Le plat n'est pas associé à un restaurant."}, status=400)
        # Désactiver les autres plats du jour de ce restaurant
        MenuItem.objects.filter(restaurant_id=item.restaurant_id, plat_du_jour=True).exclude(id=item.id).update(plat_du_jour=False)
        # Activer sur l'item
        item.plat_du_jour = True
        item.save()
        return Response({'message': 'Plat marqué comme plat du jour', 'plat_du_jour': True})

    @action(detail=True, methods=['post'])
    def unset_plat_du_jour(self, request, pk=None):
        """Retirer le statut plat du jour"""
        item = self.get_object()
        item.plat_du_jour = False
        item.save()
        return Response({'message': 'Plat du jour retiré', 'plat_du_jour': False})
    
    @action(detail=False, methods=['get'])
    def statistics(self, request):
        """Statistiques du menu"""
        total_items = MenuItem.objects.count()
        disponibles = MenuItem.objects.filter(disponible=True).count()
        populaires = MenuItem.objects.filter(populaire=True).count()
        
        by_category = MenuItem.objects.values('category__nom').annotate(
            count=Count('id')
        ).order_by('-count')
        
        by_type = MenuItem.objects.values('type').annotate(
            count=Count('id')
        )
        
        return Response({
            'total_items': total_items,
            'disponibles': disponibles,
            'populaires': populaires,
            'by_category': by_category,
            'by_type': by_type
        })

# ========== 2. GESTION DES INGRÉDIENTS ==========

class AdminIngredientViewSet(viewsets.ModelViewSet):
    """Administration complète des ingrédients"""
    queryset = Ingredient.objects.all()
    serializer_class = AdminIngredientSerializer
    permission_classes = [IsAdminPermission]
    
    def get_queryset(self):
        queryset = Ingredient.objects.all()
        
        # Filtres
        type_ingredient = self.request.query_params.get('type')
        low_stock = self.request.query_params.get('low_stock')
        disponible = self.request.query_params.get('disponible')
        
        restaurant_id = self.request.query_params.get('restaurant') or self.request.query_params.get('restaurant_id')
        if restaurant_id:
            queryset = queryset.filter(restaurant_id=restaurant_id)
        if type_ingredient:
            queryset = queryset.filter(type=type_ingredient)
        if low_stock == 'true':
            # Filtrer en base de données puis en Python pour is_low_stock
            all_ingredients = list(queryset)
            queryset = [ing for ing in all_ingredients if ing.is_low_stock]
        if disponible is not None:
            queryset = queryset.filter(disponible=disponible.lower() == 'true')
            
        return queryset
    
    @action(detail=True, methods=['post'])
    def update_stock(self, request, pk=None):
        """Mettre à jour le stock"""
        ingredient = self.get_object()
        new_stock = request.data.get('stock')
        
        if new_stock is None:
            return Response({'error': 'Stock requis'}, status=400)
        
        try:
            ingredient.stock_actuel = int(new_stock)
            ingredient.save()
            return Response({
                'message': 'Stock mis à jour',
                'stock_actuel': ingredient.stock_actuel,
                'is_low_stock': ingredient.is_low_stock
            })
        except ValueError:
            return Response({'error': 'Stock invalide'}, status=400)
    
    @action(detail=False, methods=['get'])
    def low_stock_alert(self, request):
        """Alerte stock faible"""
        low_stock_items = [
            {
                'id': ing.id,
                'nom': ing.nom,
                'stock_actuel': ing.stock_actuel,
                'stock_min': ing.stock_min,
                'unite': ing.unite
            }
            for ing in Ingredient.objects.all() if ing.is_low_stock
        ]
        
        return Response({
            'count': len(low_stock_items),
            'items': low_stock_items
        })
    
    @action(detail=False, methods=['get'])
    def statistics(self, request):
        """Statistiques des ingrédients"""
        total = Ingredient.objects.count()
        disponibles = Ingredient.objects.filter(disponible=True).count()
        low_stock_count = len([ing for ing in Ingredient.objects.all() if ing.is_low_stock])
        
        by_type = Ingredient.objects.values('type').annotate(
            count=Count('id')
        )
        
        return Response({
            'total': total,
            'disponibles': disponibles,
            'low_stock_count': low_stock_count,
            'by_type': by_type
        })

# ========== GESTION DES CATÉGORIES ==========

class AdminCategoryViewSet(viewsets.ModelViewSet):
    """Administration des catégories"""
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [IsAdminPermission]
    
    def get_queryset(self):
        return Category.objects.all().order_by('ordre', 'nom')
    
    @action(detail=True, methods=['post'])
    def toggle_active(self, request, pk=None):
        """Activer/désactiver une catégorie"""
        category = self.get_object()
        category.actif = not category.actif
        category.save()
        return Response({
            'message': f'Catégorie {"activée" if category.actif else "désactivée"}',
            'actif': category.actif
        })

# ========== 3. GESTION DES RESTAURANTS ==========

class AdminRestaurantViewSet(viewsets.ModelViewSet):
    """Administration des restaurants"""
    queryset = Restaurant.objects.all()
    serializer_class = AdminRestaurantSerializer
    permission_classes = [IsAdminPermission]
    
    def get_queryset(self):
        queryset = Restaurant.objects.all()
        
        # Filtres
        statut = self.request.query_params.get('statut')
        if statut:
            queryset = queryset.filter(statut=statut)
            
        return queryset.order_by('-id')
    
    @action(detail=True, methods=['post'])
    def valider_restaurant(self, request, pk=None):
        """Valider un restaurant"""
        restaurant = self.get_object()
        
        if restaurant.statut == 'valide':
            return Response({'error': 'Restaurant déjà validé'}, status=400)
        
        restaurant.statut = 'valide'
        restaurant.date_validation = timezone.now()
        restaurant.validé_par = request.user
        restaurant.save()
        
        return Response({
            'message': 'Restaurant validé avec succès',
            'statut': restaurant.statut
        })
    
    @action(detail=True, methods=['post'])
    def suspendre_restaurant(self, request, pk=None):
        """Suspendre un restaurant"""
        restaurant = self.get_object()
        raison = request.data.get('raison', '')
        
        restaurant.statut = 'suspendu'
        restaurant.actif = False
        restaurant.save()
        
        # Désactiver aussi tous les utilisateurs du restaurant
        UserProfile.objects.filter(restaurant=restaurant).update(actif=False)
        
        return Response({
            'message': 'Restaurant suspendu',
            'statut': restaurant.statut
        })
    
    @action(detail=True, methods=['post'])
    def reactiver_restaurant(self, request, pk=None):
        """Réactiver un restaurant"""
        restaurant = self.get_object()
        
        restaurant.statut = 'valide'
        restaurant.actif = True
        restaurant.save()
        
        # Réactiver les utilisateurs du restaurant
        UserProfile.objects.filter(restaurant=restaurant).update(actif=True)
        
        return Response({
            'message': 'Restaurant réactivé',
            'statut': restaurant.statut
        })
    
    @action(detail=True, methods=['post'])
    def rejeter_restaurant(self, request, pk=None):
        """Rejeter un restaurant"""
        restaurant = self.get_object()
        raison = request.data.get('raison', '')
        
        restaurant.statut = 'rejete'
        restaurant.actif = False
        restaurant.save()
        
        return Response({
            'message': 'Restaurant rejeté',
            'statut': restaurant.statut
        })
    
    @action(detail=False, methods=['get'])
    def en_attente(self, request):
        """Restaurants en attente de validation"""
        restaurants = Restaurant.objects.filter(statut='en_attente')
        serializer = self.get_serializer(restaurants, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def statistics(self, request):
        """Statistiques des restaurants"""
        total = Restaurant.objects.count()
        en_attente = Restaurant.objects.filter(statut='en_attente').count()
        valides = Restaurant.objects.filter(statut='valide').count()
        suspendus = Restaurant.objects.filter(statut='suspendu').count()
        rejetes = Restaurant.objects.filter(statut='rejete').count()
        
        return Response({
            'total': total,
            'en_attente': en_attente,
            'valides': valides,
            'suspendus': suspendus,
            'rejetes': rejetes
        })

# ========== 4. GESTION DU PERSONNEL ==========

class AdminPersonnelViewSet(viewsets.ModelViewSet):
    """Administration de tous les utilisateurs (personnel + clients)"""
    queryset = User.objects.all()
    serializer_class = AdminUserSerializer
    permission_classes = [IsAdminPermission]
    
    def get_queryset(self):
        # Afficher tous les utilisateurs avec profil, avec filtre optionnel par restaurant
        queryset = User.objects.filter(userprofile__isnull=False).order_by('-date_joined')
        restaurant_id = self.request.query_params.get('restaurant') or self.request.query_params.get('restaurant_id')
        if restaurant_id:
            queryset = queryset.filter(userprofile__restaurant_id=restaurant_id)
        role = self.request.query_params.get('role')
        if role:
            queryset = queryset.filter(userprofile__role=role)
        return queryset

    def create(self, request, *args, **kwargs):
        """Créer un nouvel utilisateur avec profil, lié à un restaurant si fourni"""
        from django.contrib.auth.hashers import make_password
        from .models import Restaurant

        data = request.data

        # Lecture des champs principaux
        username = data.get('username', data.get('phone'))
        if not username:
            return Response({'username': ['Ce champ est requis (username ou phone).']}, status=status.HTTP_400_BAD_REQUEST)

        role = (data.get('role') or data.get('profile', {}).get('role') or 'client')
        restaurant_id = data.get('restaurant') or data.get('restaurant_id') or data.get('profile', {}).get('restaurant')

        # Règle métier: le personnel (admin/personnel/chef) doit appartenir à un restaurant
        restaurant = None
        if role in ['admin', 'personnel', 'chef']:
            if not restaurant_id:
                return Response({'restaurant': ['Obligatoire pour le personnel.']}, status=status.HTTP_400_BAD_REQUEST)
            try:
                restaurant = Restaurant.objects.get(pk=restaurant_id)
            except Restaurant.DoesNotExist:
                return Response({'restaurant': ['Restaurant introuvable.']}, status=status.HTTP_400_BAD_REQUEST)

        # Créer l'utilisateur
        user = User.objects.create(
            username=username,
            email=data.get('email', ''),
            first_name=data.get('first_name', ''),
            last_name=data.get('last_name', ''),
            password=make_password(data.get('password', data.get('pin'))),
            is_active=data.get('is_active', True)
        )

        # Créer le profil
        profile = UserProfile.objects.create(
            user=user,
            phone=data.get('phone', username),
            role=role,
            restaurant=restaurant
        )

        serializer = self.get_serializer(user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def update(self, request, *args, **kwargs):
        """Mettre à jour un utilisateur et son profil (incluant restaurant)"""
        from .models import Restaurant

        user = self.get_object()
        data = request.data

        # Mettre à jour l'utilisateur
        user.username = data.get('username', data.get('phone', user.username))
        user.email = data.get('email', user.email)
        user.first_name = data.get('first_name', user.first_name)
        user.last_name = data.get('last_name', user.last_name)

        # Mettre à jour le mot de passe si fourni
        if 'password' in data or 'pin' in data:
            new_password = data.get('password', data.get('pin'))
            user.set_password(new_password)

        user.save()

        # Mettre à jour le profil
        if hasattr(user, 'userprofile'):
            profile = user.userprofile
            profile.phone = data.get('phone', data.get('username', profile.phone))

            # Rôle
            if 'role' in data:
                profile.role = data['role']
            elif 'profile' in data and 'role' in data['profile']:
                profile.role = data['profile']['role']

            # Restaurant
            restaurant_id = data.get('restaurant') or data.get('restaurant_id')
            if not restaurant_id and 'profile' in data:
                restaurant_id = data['profile'].get('restaurant')
            if restaurant_id is not None:
                if restaurant_id == '' or restaurant_id is False:
                    profile.restaurant = None
                else:
                    try:
                        profile.restaurant = Restaurant.objects.get(pk=restaurant_id)
                    except Restaurant.DoesNotExist:
                        return Response({'restaurant': ['Restaurant introuvable.']}, status=status.HTTP_400_BAD_REQUEST)

            profile.save()

        serializer = self.get_serializer(user)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def toggle_active(self, request, pk=None):
        """Activer/désactiver un membre du personnel"""
        user = self.get_object()
        user.is_active = not user.is_active
        user.save()
        
        # Mettre à jour aussi le profil
        if hasattr(user, 'userprofile'):
            user.userprofile.actif = user.is_active
            user.userprofile.save()
        
        return Response({
            'message': f'Utilisateur {"activé" if user.is_active else "désactivé"}',
            'is_active': user.is_active
        })
    
    @action(detail=True, methods=['post'])
    def change_role(self, request, pk=None):
        """Changer le rôle d'un utilisateur"""
        user = self.get_object()
        new_role = request.data.get('role')
        
        valid_roles = ['admin', 'personnel', 'chef']
        if new_role not in valid_roles:
            return Response({'error': 'Rôle invalide'}, status=400)
        
        if hasattr(user, 'userprofile'):
            user.userprofile.role = new_role
            user.userprofile.save()
            
            return Response({
                'message': f'Rôle changé vers {new_role}',
                'role': new_role
            })
        
        return Response({'error': 'Profil utilisateur non trouvé'}, status=400)
    
    @action(detail=False, methods=['get'])
    def statistics(self, request):
        """Statistiques du personnel"""
        total_staff = User.objects.filter(
            userprofile__role__in=['admin', 'personnel', 'chef']
        ).count()
        
        active_staff = User.objects.filter(
            userprofile__role__in=['admin', 'personnel', 'chef'],
            is_active=True
        ).count()
        
        by_role = UserProfile.objects.filter(
            role__in=['admin', 'personnel', 'chef']
        ).values('role').annotate(count=Count('id'))
        
        return Response({
            'total_staff': total_staff,
            'active_staff': active_staff,
            'by_role': by_role
        })

# ========== 4. STATISTIQUES GÉNÉRALES ==========

@api_view(['GET'])
@permission_classes([IsAdminPermission])
def admin_statistics(request):
    """Statistiques générales pour le dashboard admin, filtrables par restaurant (?restaurant=ID)"""
    today = timezone.now().date()
    week_ago = today - timedelta(days=7)
    month_ago = today - timedelta(days=30)
    
    # Filtre restaurant optionnel
    restaurant_id = request.query_params.get('restaurant') or request.query_params.get('restaurant_id')

    base_orders = Order.objects.exclude(status='panier')
    if restaurant_id:
        base_orders = base_orders.filter(restaurant_id=restaurant_id)

    # Statistiques des commandes (filtrées si restaurant fourni)
    total_orders = base_orders.count()
    orders_today = base_orders.filter(created_at__date=today).count()
    orders_week = base_orders.filter(created_at__date__gte=week_ago).count()
    orders_month = base_orders.filter(created_at__date__gte=month_ago).count()
    
    # Chiffre d'affaires  
    total_revenue = base_orders.aggregate(
        total=Sum('prix_total')
    )['total'] or 0
    
    revenue_today = base_orders.filter(created_at__date=today).aggregate(total=Sum('prix_total'))['total'] or 0
    
    revenue_week = base_orders.filter(created_at__date__gte=week_ago).aggregate(total=Sum('prix_total'))['total'] or 0
    
    revenue_month = base_orders.filter(created_at__date__gte=month_ago).aggregate(total=Sum('prix_total'))['total'] or 0
    
    # Commandes par statut
    orders_by_status = base_orders.values('status').annotate(count=Count('id'))
    
    # Plats les plus populaires (simplifié car structure différente)
    popular_dishes = []
    try:
        # Essayer avec les OrderItems si ils existent
        popular_dishes = OrderItem.objects.values(
            'custom_dish__base'
        ).annotate(
            total_quantity=Sum('quantity')
        ).order_by('-total_quantity')[:5]
    except:
        # Si erreur, laisser liste vide
        pass
    
    # Moyennes
    avg_order_value = Order.objects.exclude(status='panier').aggregate(
        avg=Avg('prix_total')
    )['avg'] or 0
    
    # Alertes
    low_stock_count = len([ing for ing in Ingredient.objects.all() if ing.is_low_stock])
    pending_orders = Order.objects.filter(status='en_attente').count()
    
    # Statistiques du menu (filtrées si restaurant fourni)
    menu_qs = MenuItem.objects.all()
    ing_qs = Ingredient.objects.all()
    if restaurant_id:
        menu_qs = menu_qs.filter(restaurant_id=restaurant_id)
        ing_qs = ing_qs.filter(restaurant_id=restaurant_id)
    total_menu_items = menu_qs.count()
    available_items = menu_qs.filter(disponible=True).count()
    
    # Statistiques des ingrédients (filtrées)
    total_ingredients = ing_qs.count()
    
    return Response({
        'orders': {
            'total': total_orders,
            'today': orders_today,
            'week': orders_week,
            'month': orders_month,
            'by_status': list(orders_by_status)
        },
        'revenue': {
            'total': float(total_revenue),
            'today': float(revenue_today),
            'week': float(revenue_week),
            'month': float(revenue_month),
            'avg_order_value': float(avg_order_value)
        },
        'menu': {
            'total_items': total_menu_items,
            'available': available_items
        },
        'ingredients': {
            'total': total_ingredients,
            'low_stock': low_stock_count
        },
        'popular_dishes': list(popular_dishes),
        'alerts': {
            'low_stock_ingredients': low_stock_count,
            'pending_orders': pending_orders
        }
    })

# ========== 4.5. DONNÉES DASHBOARD ==========

@api_view(['GET'])
@permission_classes([IsAdminPermission])
def admin_dashboard_data(request):
    """Données pour le dashboard admin (restaurant info + commandes récentes)"""
    try:
        # Informations du restaurant
        restaurant_info = {
            'id': 1,
            'nom': 'BOKDEJ',
            'adresse': '123 Avenue de la République, Dakar',
            'telephone': '+221 77 123 45 67',
            'email': 'contact@bokdej.sn',
            'horaires_ouverture': 'Lun-Sam: 8h-22h, Dim: 10h-20h',
            'logo': None,
            'actif': True
        }
        
        # Essayer de récupérer les vraies données du restaurant
        try:
            restaurant = Restaurant.objects.first()
            if restaurant:
                restaurant_info = {
                    'id': restaurant.id,
                    'nom': restaurant.nom,
                    'adresse': restaurant.adresse or '',
                    'telephone': restaurant.telephone or '',
                    'email': restaurant.email or '',
                    'horaires_ouverture': restaurant.horaires_ouverture or '',
                    'logo': restaurant.logo.url if restaurant.logo else None,
                    'actif': getattr(restaurant, 'actif', True)
                }
        except:
            pass  # Utiliser les données par défaut
        
        # Commandes récentes - version simplifiée
        orders_data = []
        try:
            recent_orders = Order.objects.all().order_by('-created_at')[:5]
            
            for order in recent_orders:
                user_name = 'Client anonyme'
                if order.user:
                    user_name = f"{order.user.first_name} {order.user.last_name}".strip()
                    if not user_name:
                        user_name = order.user.username
                elif getattr(order, 'phone', None):
                    user_name = f"Tel: {order.phone}"
                
                orders_data.append({
                    'id': order.id,
                    'user': user_name,
                    'telephone': getattr(order, 'phone', ''),
                    'total': float(getattr(order, 'prix_total', 0)),
                    'statut': getattr(order, 'status', 'en_attente'),
                    'created_at': order.created_at.strftime('%Y-%m-%d %H:%M:%S') if order.created_at else '',
                    'items_count': 0
                })
        except Exception as e:
            print(f"Erreur commandes: {e}")
            # Données factices si erreur
            orders_data = [
                {
                    'id': 1,
                    'user': 'Client Test',
                    'telephone': '+221 77 123 456',
                    'total': 2500.0,
                    'statut': 'en_preparation',
                    'created_at': '2025-08-06 01:00:00',
                    'items_count': 2
                }
            ]
        
        return Response({
            'restaurant': restaurant_info,
            'recent_orders': orders_data
        })
        
    except Exception as e:
        return Response({'error': str(e)}, status=500)

# ========== 5. PARAMÈTRES SYSTÈME ==========

@api_view(['GET', 'POST'])
@permission_classes([IsAdminPermission])
def admin_settings(request):
    """Gestion des paramètres système"""
    
    if request.method == 'GET':
        try:
            restaurant = Restaurant.objects.first()
            if not restaurant:
                return Response({'error': 'Restaurant non configuré'}, status=404)
            
            settings, created = SystemSettings.objects.get_or_create(
                restaurant=restaurant
            )
            
            return Response({
                'restaurant': {
                    'nom': restaurant.nom,
                    'adresse': restaurant.adresse,
                    'telephone': restaurant.telephone,
                    'email': restaurant.email,
                    'horaires_ouverture': restaurant.horaires_ouverture
                },
                'settings': {
                    'commande_min': float(settings.commande_min),
                    'temps_preparation_defaut': settings.temps_preparation_defaut,
                    'accepter_commandes_anonymes': settings.accepter_commandes_anonymes,
                    'notifications_activees': settings.notifications_activees,
                    'email_notifications': settings.email_notifications,
                    'sms_notifications': settings.sms_notifications,
                    'devise': settings.devise,
                    'langue': settings.langue,
                    'livraison_activee': settings.livraison_activee,
                    'frais_livraison': float(settings.frais_livraison),
                    'zone_livraison': settings.zone_livraison
                }
            })
        except Exception as e:
            return Response({'error': str(e)}, status=500)
    
    elif request.method == 'POST':
        try:
            restaurant = Restaurant.objects.first()
            if not restaurant:
                return Response({'error': 'Restaurant non configuré'}, status=404)
            
            settings, created = SystemSettings.objects.get_or_create(
                restaurant=restaurant
            )
            
            # Mettre à jour les paramètres
            restaurant_data = request.data.get('restaurant', {})
            settings_data = request.data.get('settings', {})
            
            # Mise à jour restaurant
            for field, value in restaurant_data.items():
                if hasattr(restaurant, field):
                    setattr(restaurant, field, value)
            restaurant.save()
            
            # Mise à jour settings
            for field, value in settings_data.items():
                if hasattr(settings, field):
                    setattr(settings, field, value)
            settings.save()
            
            return Response({'message': 'Paramètres mis à jour avec succès'})
            
        except Exception as e:
            return Response({'error': str(e)}, status=500)

# ========== 6. RAPPORTS ==========

@api_view(['GET'])
@permission_classes([IsAdminPermission])
def admin_reports(request):
    """Génération de rapports"""
    report_type = request.query_params.get('type', 'sales')
    start_date = request.query_params.get('start_date')
    end_date = request.query_params.get('end_date')
    
    # Dates par défaut (dernier mois)
    if not end_date:
        end_date = timezone.now().date()
    else:
        end_date = datetime.strptime(end_date, '%Y-%m-%d').date()
    
    if not start_date:
        start_date = end_date - timedelta(days=30)
    else:
        start_date = datetime.strptime(start_date, '%Y-%m-%d').date()
    
    if report_type == 'sales':
        return _sales_report(start_date, end_date)
    elif report_type == 'inventory':
        return _inventory_report()
    elif report_type == 'staff':
        return _staff_report()
    else:
        return Response({'error': 'Type de rapport invalide'}, status=400)

def _sales_report(start_date, end_date):
    """Rapport des ventes"""
    orders = Order.objects.filter(
        created_at__date__gte=start_date,
        created_at__date__lte=end_date
    ).exclude(status='panier')
    
    total_orders = orders.count()
    total_revenue = orders.aggregate(total=Sum('prix_total'))['total'] or 0
    avg_order_value = orders.aggregate(avg=Avg('prix_total'))['avg'] or 0
    
    # Ventes par jour
    daily_sales = orders.extra(
        select={'day': 'date(created_at)'}
    ).values('day').annotate(
        orders_count=Count('id'),
        revenue=Sum('prix_total')
    ).order_by('day')
    
    # Top plats
    top_dishes = OrderItem.objects.filter(
        order__created_at__date__gte=start_date,
        order__created_at__date__lte=end_date
    ).exclude(order__status='panier').values('custom_dish__base').annotate(
        quantity=Sum('quantity')
    ).order_by('-quantity')[:10]
    
    return Response({
        'period': {'start': start_date, 'end': end_date},
        'summary': {
            'total_orders': total_orders,
            'total_revenue': float(total_revenue),
            'avg_order_value': float(avg_order_value)
        },
        'daily_sales': daily_sales,
        'top_dishes': top_dishes
    })

def _inventory_report():
    """Rapport d'inventaire"""
    ingredients = Ingredient.objects.all()
    
    low_stock = [ing for ing in ingredients if ing.is_low_stock]
    out_of_stock = ingredients.filter(stock_actuel=0)
    
    by_type = ingredients.values('type').annotate(
        total_items=Count('id'),
        avg_stock=Avg('stock_actuel')
    )
    
    return Response({
        'total_ingredients': ingredients.count(),
        'low_stock_count': len(low_stock),
        'out_of_stock_count': out_of_stock.count(),
        'low_stock_items': [
            {
                'id': ing.id,
                'nom': ing.nom,
                'stock_actuel': ing.stock_actuel,
                'stock_min': ing.stock_min
            } for ing in low_stock
        ],
        'by_type': by_type
    })

def _staff_report():
    """Rapport du personnel"""
    staff = UserProfile.objects.filter(
        role__in=['admin', 'personnel', 'chef']
    )
    
    active_staff = staff.filter(user__is_active=True)
    inactive_staff = staff.filter(user__is_active=False)
    
    by_role = staff.values('role').annotate(
        count=Count('id'),
        active_count=Count('id', filter=Q(user__is_active=True))
    )
    
    return Response({
        'total_staff': staff.count(),
        'active_staff': active_staff.count(),
        'inactive_staff': inactive_staff.count(),
        'by_role': by_role
    })