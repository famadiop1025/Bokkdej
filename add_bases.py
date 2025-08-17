#!/usr/bin/env python
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from api.models import Base

def add_test_bases():
    """Ajoute des bases de test dans la base de données"""
    
    # Supprimer les bases existantes pour éviter les doublons
    Base.objects.all().delete()
    
    # Créer les bases de test
    bases_data = [
        {
            'nom': 'Pain',
            'prix': 200.00,
            'description': 'Pain frais du jour',
            'disponible': True
        },
        {
            'nom': 'Riz',
            'prix': 300.00,
            'description': 'Riz blanc cuit à la vapeur',
            'disponible': True
        },
        {
            'nom': 'Pâtes',
            'prix': 350.00,
            'description': 'Pâtes al dente',
            'disponible': True
        },
        {
            'nom': 'Salade',
            'prix': 250.00,
            'description': 'Salade verte fraîche',
            'disponible': True
        },
        {
            'nom': 'Quinoa',
            'prix': 400.00,
            'description': 'Quinoa bio cuit',
            'disponible': True
        },
        {
            'nom': 'Pommes de terre',
            'prix': 280.00,
            'description': 'Pommes de terre vapeur',
            'disponible': True
        }
    ]
    
    bases_created = []
    for base_data in bases_data:
        base = Base.objects.create(**base_data)
        bases_created.append(base)
        print(f"Base créée : {base.nom} - {base.prix} F")
    
    print(f"\nTotal : {len(bases_created)} bases créées avec succès !")
    return bases_created

if __name__ == '__main__':
    print("Ajout des bases de test...")
    add_test_bases()
    print("Terminé !") 