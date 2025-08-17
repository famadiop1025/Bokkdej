#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from api.models import MenuItem

def create_sample_menu_items():
    """Créer des plats de test pour le menu"""
    
    # Supprimer les plats existants pour éviter les doublons
    MenuItem.objects.all().delete()
    
    # Plats de test
    menu_items = [
        {
            'nom': 'Omelette au fromage',
            'prix': 500,
            'type': 'petit_dej',
            'calories': 250,
            'temps_preparation': 10
        },
        {
            'nom': 'Pain au chocolat',
            'prix': 300,
            'type': 'petit_dej',
            'calories': 180,
            'temps_preparation': 5
        },
        {
            'nom': 'Riz au poisson',
            'prix': 1200,
            'type': 'dej',
            'calories': 450,
            'temps_preparation': 25
        },
        {
            'nom': 'Poulet Yassa',
            'prix': 1500,
            'type': 'dej',
            'calories': 380,
            'temps_preparation': 30
        },
        {
            'nom': 'Spaghetti Bolognaise',
            'prix': 1000,
            'type': 'diner',
            'calories': 420,
            'temps_preparation': 20
        },
        {
            'nom': 'Pizza Margherita',
            'prix': 2000,
            'type': 'diner',
            'calories': 550,
            'temps_preparation': 15
        },
        {
            'nom': 'Chips',
            'prix': 200,
            'type': 'snacks',
            'calories': 120,
            'temps_preparation': 3
        },
        {
            'nom': 'Sandwich Jambon',
            'prix': 800,
            'type': 'snacks',
            'calories': 280,
            'temps_preparation': 8
        },
        {
            'nom': 'Bissap',
            'prix': 300,
            'type': 'boissons',
            'calories': 80,
            'temps_preparation': 2
        },
        {
            'nom': 'Eau minérale',
            'prix': 200,
            'type': 'boissons',
            'calories': 0,
            'temps_preparation': 1
        }
    ]
    
    # Créer les plats
    for item_data in menu_items:
        MenuItem.objects.create(**item_data)
    
    print(f"✅ {len(menu_items)} plats créés avec succès !")
    print("\nPlats créés :")
    for item in MenuItem.objects.all():
        print(f"- {item.nom} ({item.type}) : {item.prix} F")

if __name__ == '__main__':
    create_sample_menu_items() 