#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from api.models import Ingredient

def create_sample_ingredients():
    """Créer des ingrédients de test"""
    
    # Supprimer les ingrédients existants pour éviter les doublons
    Ingredient.objects.all().delete()
    
    # Ingrédients de test
    ingredients = [
        {
            'nom': 'Mayonnaise',
            'prix': 100.0,
            'type': 'sauce'
        },
        {
            'nom': 'Omelette',
            'prix': 200.0,
            'type': 'protéine'
        },
        {
            'nom': 'Frites',
            'prix': 150.0,
            'type': 'accompagnement'
        },
        {
            'nom': 'Fromage',
            'prix': 120.0,
            'type': 'laitier'
        },
        {
            'nom': 'Jambon',
            'prix': 180.0,
            'type': 'protéine'
        },
        {
            'nom': 'Salade',
            'prix': 80.0,
            'type': 'légume'
        },
        {
            'nom': 'Tomate',
            'prix': 50.0,
            'type': 'légume'
        },
        {
            'nom': 'Oignon',
            'prix': 30.0,
            'type': 'légume'
        },
        {
            'nom': 'Thon',
            'prix': 250.0,
            'type': 'protéine'
        },
        {
            'nom': 'Ketchup',
            'prix': 60.0,
            'type': 'sauce'
        }
    ]
    
    # Créer les ingrédients
    for ingredient_data in ingredients:
        Ingredient.objects.create(**ingredient_data)
    
    print(f"✅ {len(ingredients)} ingrédients créés avec succès !")
    print("\nIngrédients créés :")
    for ingredient in Ingredient.objects.all():
        print(f"- {ingredient.nom} ({ingredient.type}) : {ingredient.prix} F")

if __name__ == '__main__':
    create_sample_ingredients() 