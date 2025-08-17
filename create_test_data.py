#!/usr/bin/env python
"""
Script pour créer des données de test pour l'application BOKDEJ
"""
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import (
    Restaurant, MenuItem, Ingredient, UserProfile, Order, OrderItem,
    SystemSettings, Category
)
from decimal import Decimal

def create_restaurant():
    """Créer ou mettre à jour le restaurant principal"""
    restaurant, created = Restaurant.objects.get_or_create(
        nom="BOKDEJ",
        defaults={
            'adresse': "123 Avenue de la République, Dakar",
            'telephone': "+221 77 123 45 67",
            'email': "contact@bokdej.sn",
            'horaires_ouverture': "Lun-Sam: 8h-22h, Dim: 10h-20h",
            'actif': True
        }
    )
    
    if created:
        print("✅ Restaurant BOKDEJ créé")
    else:
        print("ℹ️ Restaurant BOKDEJ existe déjà")
    
    return restaurant

def create_categories():
    """Créer les catégories de base"""
    categories_data = [
        {'nom': 'Petit-déjeuner', 'description': 'Plats pour le matin', 'ordre': 1, 'actif': True},
        {'nom': 'Déjeuner/Dîner', 'description': 'Plats principaux', 'ordre': 2, 'actif': True},
        {'nom': 'Desserts', 'description': 'Sucreries et desserts', 'ordre': 3, 'actif': True},
        {'nom': 'Boissons', 'description': 'Boissons chaudes et froides', 'ordre': 4, 'actif': True},
    ]
    
    for cat_data in categories_data:
        category, created = Category.objects.get_or_create(
            nom=cat_data['nom'],
            defaults=cat_data
        )
        if created:
            print(f"✅ Catégorie '{cat_data['nom']}' créée")

def create_ingredients():
    """Créer quelques ingrédients de base"""
    ingredients_data = [
        {'nom': 'Riz', 'prix': 500, 'type': 'autre', 'stock_actuel': 50, 'stock_min': 10, 'unite': 'kg'},
        {'nom': 'Poulet', 'prix': 2000, 'type': 'viande', 'stock_actuel': 20, 'stock_min': 5, 'unite': 'kg'},
        {'nom': 'Poisson', 'prix': 1500, 'type': 'poisson', 'stock_actuel': 15, 'stock_min': 3, 'unite': 'kg'},
        {'nom': 'Tomate', 'prix': 200, 'type': 'legume', 'stock_actuel': 30, 'stock_min': 8, 'unite': 'kg'},
        {'nom': 'Oignon', 'prix': 150, 'type': 'legume', 'stock_actuel': 25, 'stock_min': 5, 'unite': 'kg'},
        {'nom': 'Huile', 'prix': 800, 'type': 'autre', 'stock_actuel': 10, 'stock_min': 2, 'unite': 'L'},
    ]
    
    for ing_data in ingredients_data:
        ingredient, created = Ingredient.objects.get_or_create(
            nom=ing_data['nom'],
            defaults=ing_data
        )
        if created:
            print(f"✅ Ingrédient '{ing_data['nom']}' créé")

def create_menu_items():
    """Créer quelques plats de base"""
    menu_items_data = [
        {
            'nom': 'Thieboudienne Rouge',
            'prix': 2500,
            'type': 'din',
            'description': 'Riz au poisson rouge traditionnel sénégalais',
            'disponible': True,
            'calories': 450,
            'temps_preparation': 45
        },
        {
            'nom': 'Thieboudienne Blanc',
            'prix': 2300,
            'type': 'din',
            'description': 'Riz au poisson blanc avec légumes',
            'disponible': True,
            'calories': 420,
            'temps_preparation': 40
        },
        {
            'nom': 'Yassa Poulet',
            'prix': 2000,
            'type': 'din',
            'description': 'Poulet mariné aux oignons et citron',
            'disponible': True,
            'calories': 380,
            'temps_preparation': 35
        },
        {
            'nom': 'Café Touba',
            'prix': 300,
            'type': 'boi',
            'description': 'Café traditionnel sénégalais épicé',
            'disponible': True,
            'calories': 25,
            'temps_preparation': 5
        },
        {
            'nom': 'Thiakry',
            'prix': 800,
            'type': 'des',
            'description': 'Dessert traditionnel au couscous et lait',
            'disponible': True,
            'calories': 280,
            'temps_preparation': 15
        },
    ]
    
    for item_data in menu_items_data:
        menu_item, created = MenuItem.objects.get_or_create(
            nom=item_data['nom'],
            defaults=item_data
        )
        if created:
            print(f"✅ Plat '{item_data['nom']}' créé")

def create_test_users():
    """Créer des utilisateurs de test"""
    # Admin user
    admin_user, created = User.objects.get_or_create(
        username='admin',
        defaults={
            'email': 'admin@bokdej.sn',
            'first_name': 'Admin',
            'last_name': 'BOKDEJ',
            'is_staff': True,
            'is_superuser': True
        }
    )
    
    if created:
        admin_user.set_password('admin123')
        admin_user.save()
        print("✅ Utilisateur admin créé")
    
    # Profil admin
    admin_profile, created = UserProfile.objects.get_or_create(
        user=admin_user,
        defaults={
            'role': 'admin',
            'phone': '+22177123456',
            'pin_code': '1234',
            'actif': True
        }
    )
    
    if created:
        print("✅ Profil admin créé")
    
    # Staff user
    staff_user, created = User.objects.get_or_create(
        username='staff',
        defaults={
            'email': 'staff@bokdej.sn',
            'first_name': 'Staff',
            'last_name': 'BOKDEJ'
        }
    )
    
    if created:
        staff_user.set_password('staff123')
        staff_user.save()
        print("✅ Utilisateur staff créé")
    
    # Profil staff
    staff_profile, created = UserProfile.objects.get_or_create(
        user=staff_user,
        defaults={
            'role': 'personnel',
            'phone': '+22177123457',
            'pin_code': '5678',
            'actif': True
        }
    )
    
    if created:
        print("✅ Profil staff créé")

def create_test_orders():
    """Créer quelques commandes de test"""
    # Récupérer l'utilisateur admin pour les commandes
    try:
        admin_user = User.objects.get(username='admin')
        
        # Commande 1
        order1, created = Order.objects.get_or_create(
            user=admin_user,
            phone='+22177123456',
            defaults={
                'status': 'en_preparation',
                'prix_total': Decimal('5000.00')
            }
        )
        
        if created:
            print("✅ Commande de test 1 créée")
        
        # Commande 2
        order2, created = Order.objects.get_or_create(
            phone='+22177999888',
            defaults={
                'status': 'en_attente',
                'prix_total': Decimal('2500.00')
            }
        )
        
        if created:
            print("✅ Commande de test 2 créée")
            
        # Commande 3 (terminée)
        order3, created = Order.objects.get_or_create(
            phone='+22177888999',
            defaults={
                'status': 'termine',
                'prix_total': Decimal('3000.00')
            }
        )
        
        if created:
            print("✅ Commande de test 3 créée")
                
    except Exception as e:
        print(f"⚠️ Erreur création commandes: {e}")

def create_system_settings():
    """Créer les paramètres système"""
    restaurant = Restaurant.objects.first()
    if restaurant:
        settings, created = SystemSettings.objects.get_or_create(
            restaurant=restaurant,
            defaults={
                'commande_min': Decimal('1000.00'),
                'temps_preparation_defaut': 30,
                'accepter_commandes_anonymes': True,
                'notifications_activees': True,
                'email_notifications': True,
                'sms_notifications': False,
                'devise': 'FCFA',
                'langue': 'fr',
                'livraison_activee': True,
                'frais_livraison': Decimal('500.00'),
                'zone_livraison': 'Dakar et banlieue'
            }
        )
        
        if created:
            print("✅ Paramètres système créés")

def main():
    """Fonction principale"""
    print("🚀 Création des données de test BOKDEJ...")
    print("=" * 50)
    
    try:
        create_restaurant()
        create_categories()
        create_ingredients()
        create_menu_items()
        create_test_users()
        create_test_orders()
        create_system_settings()
        
        print("=" * 50)
        print("✅ Toutes les données de test ont été créées avec succès!")
        print("\n📋 Comptes de test créés:")
        print("   👤 Admin: username=admin, password=admin123, PIN=1234")
        print("   👤 Staff: username=staff, password=staff123, PIN=5678")
        print("\n🌐 Vous pouvez maintenant tester l'application:")
        print("   - Backend: http://localhost:8000/api/")
        print("   - Dashboard Admin: PIN 1234")
        print("   - Interface Staff: PIN 5678")
        
    except Exception as e:
        print(f"❌ Erreur lors de la création des données: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()