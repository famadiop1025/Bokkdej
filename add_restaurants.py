#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from api.models import Restaurant

def add_test_restaurants():
    """Ajoute des restaurants de test dans la base de données"""
    
    # Supprimer les restaurants existants pour éviter les doublons
    Restaurant.objects.all().delete()
    
    # Créer les restaurants de test
    restaurants_data = [
        {
            'nom': 'Restaurant ISEP Diamniadio',
        },
        {
            'nom': 'Cafétéria Étudiante',
        },
        {
            'nom': 'Restaurant Universitaire',
        },
    ]
    
    restaurants_created = []
    for restaurant_data in restaurants_data:
        restaurant = Restaurant.objects.create(**restaurant_data)
        restaurants_created.append(restaurant)
        print(f"Restaurant créé : {restaurant.nom}")
    
    print(f"\nTotal : {len(restaurants_created)} restaurants créés avec succès !")
    return restaurants_created

if __name__ == '__main__':
    print("Ajout des restaurants de test...")
    add_test_restaurants()
    print("Terminé !") 