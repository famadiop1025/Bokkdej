from django.contrib import admin
from django.utils.html import format_html
from .models import MenuItem, Ingredient, Base, Category, CustomDish, Order, Restaurant, UserProfile

class BaseImageAdmin(admin.ModelAdmin):
    """Classe de base pour l'administration avec gestion d'images"""
    
    def image_preview(self, obj):
        if obj.image:
            return format_html(
                '<img src="{}" style="max-height: 100px; max-width: 100px; border-radius: 8px;" />',
                obj.image.url
            )
        return "Pas d'image"
    image_preview.short_description = "Aperçu"

@admin.register(Category)
class CategoryAdmin(BaseImageAdmin):
    list_display = ['nom', 'image_preview', 'ordre', 'actif']
    list_editable = ['ordre', 'actif']
    list_filter = ['actif']
    search_fields = ['nom', 'description']
    ordering = ['ordre', 'nom']

@admin.register(MenuItem)
class MenuItemAdmin(BaseImageAdmin):
    list_display = ['nom', 'image_preview', 'prix', 'type', 'category', 'disponible', 'populaire']
    list_editable = ['prix', 'disponible', 'populaire']
    list_filter = ['type', 'category', 'disponible', 'populaire']
    search_fields = ['nom', 'description']
    ordering = ['category', 'nom']
    
    fieldsets = (
        ('Informations générales', {
            'fields': ('nom', 'description', 'image', 'category')
        }),
        ('Prix et détails', {
            'fields': ('prix', 'type', 'calories', 'temps_preparation')
        }),
        ('Statut', {
            'fields': ('disponible', 'populaire')
        }),
    )

@admin.register(Ingredient)
class IngredientAdmin(BaseImageAdmin):
    list_display = ['nom', 'image_preview', 'prix', 'type', 'stock_actuel', 'stock_min', 'disponible']
    list_editable = ['prix', 'stock_actuel', 'disponible']
    list_filter = ['type', 'disponible']
    search_fields = ['nom', 'fournisseur']
    ordering = ['type', 'nom']
    
    fieldsets = (
        ('Informations générales', {
            'fields': ('nom', 'type', 'image', 'prix')
        }),
        ('Stock', {
            'fields': ('stock_actuel', 'stock_min', 'unite', 'fournisseur')
        }),
        ('Informations nutritionnelles', {
            'fields': ('calories_pour_100g', 'allergenes')
        }),
        ('Statut', {
            'fields': ('disponible',)
        }),
    )

@admin.register(Base)
class BaseAdmin(BaseImageAdmin):
    list_display = ['nom', 'image_preview', 'prix', 'disponible']
    list_editable = ['prix', 'disponible']
    list_filter = ['disponible']
    search_fields = ['nom', 'description']
    ordering = ['nom']

@admin.register(CustomDish)
class CustomDishAdmin(admin.ModelAdmin):
    list_display = ['__str__', 'prix_total', 'disponible', 'created_at']
    list_filter = ['created_at', 'disponible']
    search_fields = ['base']
    readonly_fields = ['created_at']

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ['id', 'user_or_phone', 'status', 'total_display', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['user__username', 'phone']
    readonly_fields = ['created_at']
    
    def user_or_phone(self, obj):
        return obj.user.username if obj.user else obj.phone
    user_or_phone.short_description = "Client"
    
    def total_display(self, obj):
        return f"{obj.total_amount} F CFA"
    total_display.short_description = "Total"

@admin.register(Restaurant)
class RestaurantAdmin(admin.ModelAdmin):
    list_display = ['nom', 'logo_preview', 'telephone', 'email', 'statut', 'actif']
    list_editable = ['statut', 'actif']
    list_filter = ['statut', 'actif']
    search_fields = ['nom', 'telephone', 'email']
    
    def logo_preview(self, obj):
        if obj.logo:
            return format_html(
                '<img src="{}" style="max-height: 50px; max-width: 50px; border-radius: 8px;" />',
                obj.logo.url
            )
        return "Pas de logo"
    logo_preview.short_description = "Logo"

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'phone', 'has_fcm_token']
    search_fields = ['user__username', 'user__email', 'phone']
    
    def has_fcm_token(self, obj):
        return bool(obj.fcm_token)
    has_fcm_token.boolean = True
    has_fcm_token.short_description = "Token FCM"

# Configuration de l'admin
admin.site.site_header = "Administration Keur Resto"
admin.site.site_title = "Keur Resto"
admin.site.index_title = "Panneau d'administration"
