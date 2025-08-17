#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from api.models import MenuItem, Ingredient, Base, Restaurant

def setup_all_test_data():
    """Configure toutes les données de test pour l'application"""
    
    print("=== Configuration des données de test pour Bokk Déj' ===\n")
    
    # 1. Ajouter les restaurants
    print("1. Ajout des restaurants...")
    Restaurant.objects.all().delete()
    restaurants_data = [
        {'nom': 'Restaurant ISEP Diamniadio'},
        {'nom': 'Cafétéria Étudiante'},
        {'nom': 'Restaurant Universitaire'},
    ]
    for data in restaurants_data:
        restaurant = Restaurant.objects.create(**data)
        print(f"   ✓ Restaurant créé : {restaurant.nom}")
    
    # 2. Ajouter les bases
    print("\n2. Ajout des bases...")
    Base.objects.all().delete()
    bases_data = [
        {'nom': 'Pain', 'prix': 200.00, 'description': 'Pain frais du jour', 'disponible': True},
        {'nom': 'Riz', 'prix': 300.00, 'description': 'Riz blanc cuit à la vapeur', 'disponible': True},
        {'nom': 'Pâtes', 'prix': 350.00, 'description': 'Pâtes al dente', 'disponible': True},
        {'nom': 'Salade', 'prix': 250.00, 'description': 'Salade verte fraîche', 'disponible': True},
        {'nom': 'Quinoa', 'prix': 400.00, 'description': 'Quinoa bio cuit', 'disponible': True},
        {'nom': 'Pommes de terre', 'prix': 280.00, 'description': 'Pommes de terre vapeur', 'disponible': True},
    ]
    for data in bases_data:
        base = Base.objects.create(**data)
        print(f"   ✓ Base créée : {base.nom} - {base.prix} F")
    
    # 3. Ajouter les ingrédients
    print("\n3. Ajout des ingrédients...")
    Ingredient.objects.all().delete()
    ingredients_data = [
        {'nom': 'Mayonnaise', 'prix': 100.00, 'type': 'sauce'},
        {'nom': 'Omelette', 'prix': 200.00, 'type': 'protéine'},
        {'nom': 'Frites', 'prix': 150.00, 'type': 'accompagnement'},
        {'nom': 'Fromage', 'prix': 120.00, 'type': 'laitier'},
        {'nom': 'Jambon', 'prix': 180.00, 'type': 'protéine'},
        {'nom': 'Salade', 'prix': 80.00, 'type': 'légume'},
        {'nom': 'Tomate', 'prix': 50.00, 'type': 'légume'},
        {'nom': 'Oignon', 'prix': 30.00, 'type': 'légume'},
        {'nom': 'Thon', 'prix': 250.00, 'type': 'protéine'},
        {'nom': 'Ketchup', 'prix': 60.00, 'type': 'sauce'},
    ]
    for data in ingredients_data:
        ingredient = Ingredient.objects.create(**data)
        print(f"   ✓ Ingrédient créé : {ingredient.nom} ({ingredient.type}) - {ingredient.prix} F")
    
    # 4. Ajouter les plats du menu
    print("\n4. Ajout des plats du menu...")
    MenuItem.objects.all().delete()
    menu_data = [
        {
            'nom': 'Petit déjeuner complet',
            'prix': 800.00,
            'type': 'petit_dej',
            'calories': 450,
            'temps_preparation': 15,
        },
        {
            'nom': 'Omelette au fromage',
            'prix': 600.00,
            'type': 'petit_dej',
            'calories': 320,
            'temps_preparation': 10,
        },
        {
            'nom': 'Thiéboudienne',
            'prix': 1200.00,
            'type': 'dej',
            'calories': 650,
            'temps_preparation': 45,
        },
        {
            'nom': 'Yassa Poulet',
            'prix': 1000.00,
            'type': 'dej',
            'calories': 580,
            'temps_preparation': 35,
        },
        {
            'nom': 'Mafé',
            'prix': 1100.00,
            'type': 'diner',
            'calories': 620,
            'temps_preparation': 40,
        },
        {
            'nom': 'Salade composée',
            'prix': 700.00,
            'type': 'diner',
            'calories': 280,
            'temps_preparation': 15,
        },
        {
            'nom': 'Accara',
            'prix': 300.00,
            'type': 'snacks',
            'calories': 180,
            'temps_preparation': 20,
        },
        {
            'nom': 'Bissap',
            'prix': 200.00,
            'type': 'boissons',
            'calories': 80,
            'temps_preparation': 5,
        },
    ]
    for data in menu_data:
        menu_item = MenuItem.objects.create(**data)
        print(f"   ✓ Plat créé : {menu_item.nom} ({menu_item.type}) - {menu_item.prix} F")
    
    print(f"\n=== Configuration terminée avec succès ! ===")
    print(f"✓ {Restaurant.objects.count()} restaurants")
    print(f"✓ {Base.objects.count()} bases")
    print(f"✓ {Ingredient.objects.count()} ingrédients")
    print(f"✓ {MenuItem.objects.count()} plats du menu")
    print(f"\nL'application est prête à être utilisée !")

if __name__ == '__main__':
    setup_all_test_data() 