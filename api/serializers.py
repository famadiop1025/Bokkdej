from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    MenuItem, Ingredient, CustomDish, Order, 
    UserProfile, Restaurant, Base, Category, SystemSettings
)
from django.contrib.auth.hashers import make_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['phone', 'fcm_token']

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

    class Meta:
        model = CustomDish
        fields = ['id', 'base', 'ingredients', 'ingredients_ids', 'prix_total', 'disponible', 'created_at']

    def create(self, validated_data):
        ingredients = validated_data.pop('ingredients', [])
        custom_dish = CustomDish.objects.create(**validated_data)
        custom_dish.ingredients.set(ingredients)
        custom_dish.calculer_prix_total()
        return custom_dish

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
    
    def validate(self, attrs):
        # Validation personnalisée
        if attrs.get('prix', 0) <= 0:
            raise serializers.ValidationError("Le prix doit être supérieur à 0")
        
        # Valeurs par défaut pour les champs optionnels
        if not attrs.get('calories'):
            attrs['calories'] = 0
        if not attrs.get('temps_preparation'):
            attrs['temps_preparation'] = 15  # 15 minutes par défaut
            
        return attrs

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
            url = obj.logo.url if obj.image else None
            return request.build_absolute_uri(url) if request and url else url
        except Exception:
            return None

class OrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = ['id', 'user', 'restaurant', 'items', 'total_amount', 'status', 'phone', 'created_at', 'updated_at']
