from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    MenuItem, Ingredient, CustomDish, Order, OrderItem, 
    UserProfile, Restaurant, Base, Category, SystemSettings
)
from django.contrib.auth.hashers import make_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['role', 'fcm_token', 'phone', 'date_embauche', 'salaire', 'actif']

class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(source='userprofile', read_only=True)
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'is_active', 'date_joined', 'profile']

# Serializers administrateur étendus
class AdminUserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = '__all__'

class AdminUserSerializer(serializers.ModelSerializer):
    profile = AdminUserProfileSerializer(source='userprofile')
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'is_active', 'is_staff', 'date_joined', 'profile']
    
    def update(self, instance, validated_data):
        profile_data = validated_data.pop('userprofile', {})
        
        # Mettre à jour l'utilisateur
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        # Mettre à jour le profil
        if profile_data and hasattr(instance, 'userprofile'):
            profile = instance.userprofile
            for attr, value in profile_data.items():
                setattr(profile, attr, value)
            profile.save()
        
        return instance

class IngredientSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    class Meta:
        model = Ingredient
        fields = '__all__'

    def get_image_url(self, obj):
        try:
            if not getattr(obj, 'image', None):
                return None
            request = self.context.get('request') if hasattr(self, 'context') else None
            url = obj.image.url if obj.image else None
            return request.build_absolute_uri(url) if request and url else url
        except Exception:
            return None

class MenuItemSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    class Meta:
        model = MenuItem
        fields = '__all__'

    def get_image_url(self, obj):
        try:
            if not getattr(obj, 'image', None):
                return None
            request = self.context.get('request') if hasattr(self, 'context') else None
            url = obj.image.url if obj.image else None
            return request.build_absolute_uri(url) if request and url else url
        except Exception:
            return None

class CustomDishSerializer(serializers.ModelSerializer):
    ingredients = IngredientSerializer(many=True, read_only=True)
    ingredients_ids = serializers.PrimaryKeyRelatedField(
        queryset=Ingredient.objects.all(), many=True, write_only=True, source='ingredients'
    )
    user = UserSerializer(read_only=True)

    class Meta:
        model = CustomDish
        fields = ['id', 'base', 'ingredients', 'ingredients_ids', 'user', 'prix', 'created_at']

    def create(self, validated_data):
        ingredients = validated_data.pop('ingredients', [])
        user = self.context['request'].user if self.context['request'].user.is_authenticated else None
        custom_dish = CustomDish.objects.create(user=user, **validated_data)
        custom_dish.ingredients.set(ingredients)
        return custom_dish

class OrderSerializer(serializers.ModelSerializer):
    plats = serializers.SerializerMethodField()
    plats_ids = serializers.PrimaryKeyRelatedField(
        queryset=CustomDish.objects.all(), many=True, write_only=True
    )
    user = UserSerializer(read_only=True)
    phone = serializers.CharField(max_length=15, required=False)

    class Meta:
        model = Order
        fields = ['id', 'plats', 'plats_ids', 'user', 'phone', 'prix_total', 'status', 'created_at']
    
    def get_plats(self, obj):
        """Récupérer les plats (CustomDish) associés à cette commande"""
        order_items = obj.order_items.all()
        plats_data = []
        
        for item in order_items:
            custom_dish = item.custom_dish
            # Simplifier la structure pour le frontend
            base_nom = custom_dish.base.nom if hasattr(custom_dish.base, 'nom') else str(custom_dish.base)
            plat_data = {
                'id': custom_dish.id,
                'base': f"{base_nom} - {custom_dish.prix} F",
                'ingredients': [{'nom': ing.nom, 'id': ing.id} for ing in custom_dish.ingredients.all()],
                'prix': float(custom_dish.prix),
                'created_at': custom_dish.created_at.isoformat(),
            }
            plats_data.append(plat_data)
        
        return plats_data

    def create(self, validated_data):
        plats_ids = validated_data.pop('plats_ids', [])
        user = self.context['request'].user if self.context['request'].user.is_authenticated else None
        phone = validated_data.pop('phone', None)
        
        # Réutiliser le panier existant si présent
        panier = None
        if user:
            panier = Order.objects.filter(user=user, status='panier').first()
        elif phone:
            panier = Order.objects.filter(phone=phone, user=None, status='panier').first()
            
        if panier:
            # Supprimer les anciens items du panier
            panier.order_items.all().delete()
            # Ajouter les nouveaux plats
            for custom_dish in plats_ids:
                OrderItem.objects.create(order=panier, custom_dish=custom_dish, quantity=1)
            # Mettre à jour les autres champs
            if phone:
                panier.phone = phone
            for key, value in validated_data.items():
                setattr(panier, key, value)
            panier.save()
            return panier
            
        # Sinon, créer un nouveau panier
        order = Order.objects.create(user=user, phone=phone, status='panier', **validated_data)
        # Créer les OrderItem pour lier les plats à la commande
        for custom_dish in plats_ids:
            OrderItem.objects.create(order=order, custom_dish=custom_dish, quantity=1)
        return order

class UserRegisterSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    pin = serializers.CharField(min_length=4, max_length=4)

    def validate_phone(self, value):
        from .models import UserProfile
        from django.contrib.auth.models import User
        # Vérifie si le téléphone existe déjà dans UserProfile
        if UserProfile.objects.filter(phone=value).exists():
            raise serializers.ValidationError("Ce numéro existe déjà.")
        # Vérifie aussi si le username (téléphone) existe déjà dans User
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("Ce numéro existe déjà.")
        return value

    def create(self, validated_data):
        from django.contrib.auth.models import User
        from .models import UserProfile
        phone = validated_data['phone']
        pin = validated_data['pin']
        user = User(username=phone)
        user.set_password(pin)
        user.save()
        UserProfile.objects.filter(user=user).update(phone=phone)
        return user

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    username = serializers.CharField(required=False)
    phone = serializers.CharField(required=False)
    password = serializers.CharField()

    def validate(self, attrs):
        username = attrs.get('username')
        phone = attrs.get('phone')
        password = attrs.get('password')
        
        if not password:
            raise serializers.ValidationError("Le mot de passe est requis.")
            
        # Accepter soit username soit phone
        if username:
            attrs['username'] = username
        elif phone:
            attrs['username'] = phone
        else:
            raise serializers.ValidationError("Le nom d'utilisateur ou le numéro de téléphone est requis.")
            
        return super().validate(attrs)

class RestaurantSerializer(serializers.ModelSerializer):
    logo_url = serializers.SerializerMethodField()
    class Meta:
        model = Restaurant
        fields = ['id', 'nom', 'adresse', 'telephone', 'email', 'statut', 'actif', 'logo_url']

    def get_logo_url(self, obj):
        try:
            if not getattr(obj, 'logo', None):
                return None
            request = self.context.get('request') if hasattr(self, 'context') else None
            url = obj.logo.url if obj.logo else None
            return request.build_absolute_uri(url) if request and url else url
        except Exception:
            return None

class BaseSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    class Meta:
        model = Base
        fields = ['id', 'nom', 'prix', 'description', 'disponible', 'image_url'] 

    def get_image_url(self, obj):
        try:
            if not getattr(obj, 'image', None):
                return None
            request = self.context.get('request') if hasattr(self, 'context') else None
            url = obj.image.url if obj.image else None
            return request.build_absolute_uri(url) if request and url else url
        except Exception:
            return None

# Nouveaux serializers pour l'administration
class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'

class AdminMenuItemSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    category_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = MenuItem
        fields = '__all__'

class AdminIngredientSerializer(serializers.ModelSerializer):
    is_low_stock = serializers.ReadOnlyField()
    image_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Ingredient
        fields = '__all__'

    def get_image_url(self, obj):
        try:
            if not getattr(obj, 'image', None):
                return None
            request = self.context.get('request') if hasattr(self, 'context') else None
            url = obj.image.url if obj.image else None
            return request.build_absolute_uri(url) if request and url else url
        except Exception:
            return None

class SystemSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = SystemSettings
        fields = '__all__'

class AdminRestaurantSerializer(serializers.ModelSerializer):
    logo_url = serializers.SerializerMethodField()
    class Meta:
        model = Restaurant
        fields = '__all__'

    def get_logo_url(self, obj):
        try:
            if not getattr(obj, 'logo', None):
                return None
            request = self.context.get('request') if hasattr(self, 'context') else None
            url = obj.logo.url if obj.logo else None
            return request.build_absolute_uri(url) if request and url else url
        except Exception:
            return None
