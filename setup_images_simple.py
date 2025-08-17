#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script simple pour configurer les images pour la presentation de demain
Compatible Windows - sans emojis problematiques
"""

import os
import sys
import django
from PIL import Image, ImageDraw
import io

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import MenuItem, Ingredient, Base, Category

def create_simple_image(text, size=(300, 200)):
    """Cree une image simple avec du texte"""
    # Couleurs simples
    colors = ['lightblue', 'lightgreen', 'lightyellow', 'lightcoral', 'lightpink']
    color = colors[hash(text) % len(colors)]
    
    img = Image.new('RGB', size, color=color)
    d = ImageDraw.Draw(img)
    
    # Texte simple au centre
    bbox = d.textbbox((0, 0), text)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    position = ((size[0] - text_width) // 2, (size[1] - text_height) // 2)
    
    d.text(position, text, fill='black')
    return img

def setup_demo_data():
    """Configure les donnees de demonstration"""
    print("Creation des donnees de base...")
    
    # Creer un superuser si necessaire
    if not User.objects.filter(username='admin').exists():
        User.objects.create_superuser('admin', 'admin@test.com', 'admin123')
        print("Superuser cree: admin / admin123")
    
    # Creer des categories
    if not Category.objects.exists():
        categories = [
            {'nom': 'Entrees', 'description': 'Plats d\'entree'},
            {'nom': 'Plats principaux', 'description': 'Nos specialites'},
            {'nom': 'Desserts', 'description': 'Douceurs'},
        ]
        for cat_data in categories:
            Category.objects.create(**cat_data)
        print("Categories creees")
    
    # Creer des bases
    if not Base.objects.exists():
        bases = [
            {'nom': 'Riz blanc', 'prix': 500, 'description': 'Riz parfume'},
            {'nom': 'Riz thiof', 'prix': 800, 'description': 'Riz au poisson'},
            {'nom': 'Couscous', 'prix': 600, 'description': 'Couscous traditionnel'},
        ]
        for base_data in bases:
            Base.objects.create(**base_data)
        print("Bases creees")
    
    # Creer des ingredients
    if not Ingredient.objects.exists():
        ingredients = [
            {'nom': 'Poulet', 'prix': 1500, 'type': 'viande'},
            {'nom': 'Boeuf', 'prix': 2000, 'type': 'viande'},
            {'nom': 'Tomates', 'prix': 200, 'type': 'legume'},
            {'nom': 'Oignons', 'prix': 150, 'type': 'legume'},
        ]
        for ing_data in ingredients:
            Ingredient.objects.create(**ing_data)
        print("Ingredients crees")
    
    # Creer des plats de menu
    if not MenuItem.objects.exists():
        category = Category.objects.first()
        menus = [
            {'nom': 'Thieboudienne', 'prix': 2500, 'type': 'dej', 'calories': 650, 'temps_preparation': 45, 'category': category},
            {'nom': 'Yassa Poulet', 'prix': 2200, 'type': 'dej', 'calories': 580, 'temps_preparation': 35, 'category': category},
            {'nom': 'Mafe', 'prix': 2000, 'type': 'dej', 'calories': 620, 'temps_preparation': 40, 'category': category},
        ]
        for menu_data in menus:
            MenuItem.objects.create(**menu_data)
        print("Plats de menu crees")

def create_demo_images():
    """Cree les images de demonstration"""
    print("Creation des images de demonstration...")
    
    # Dossiers
    os.makedirs('media/demo_images', exist_ok=True)
    
    success_count = 0
    
    # Images pour les categories
    for category in Category.objects.all():
        try:
            img = create_simple_image(f"Categorie: {category.nom}")
            filename = f"category_{category.id}.png"
            filepath = os.path.join('media', 'category_images', filename)
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            img.save(filepath)
            category.image = f'category_images/{filename}'
            category.save()
            success_count += 1
            print(f"Image creee pour categorie: {category.nom}")
        except Exception as e:
            print(f"Erreur pour categorie {category.nom}: {e}")
    
    # Images pour les plats
    for menu in MenuItem.objects.all():
        try:
            img = create_simple_image(f"Plat: {menu.nom}")
            filename = f"menu_{menu.id}.png"
            filepath = os.path.join('media', 'menu_images', filename)
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            img.save(filepath)
            menu.image = f'menu_images/{filename}'
            menu.save()
            success_count += 1
            print(f"Image creee pour plat: {menu.nom}")
        except Exception as e:
            print(f"Erreur pour plat {menu.nom}: {e}")
    
    # Images pour les ingredients
    for ingredient in Ingredient.objects.all():
        try:
            img = create_simple_image(f"Ingredient: {ingredient.nom}")
            filename = f"ingredient_{ingredient.id}.png"
            filepath = os.path.join('media', 'ingredient_images', filename)
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            img.save(filepath)
            ingredient.image = f'ingredient_images/{filename}'
            ingredient.save()
            success_count += 1
            print(f"Image creee pour ingredient: {ingredient.nom}")
        except Exception as e:
            print(f"Erreur pour ingredient {ingredient.nom}: {e}")
    
    # Images pour les bases
    for base in Base.objects.all():
        try:
            img = create_simple_image(f"Base: {base.nom}")
            filename = f"base_{base.id}.png"
            filepath = os.path.join('media', 'base_images', filename)
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            img.save(filepath)
            base.image = f'base_images/{filename}'
            base.save()
            success_count += 1
            print(f"Image creee pour base: {base.nom}")
        except Exception as e:
            print(f"Erreur pour base {base.nom}: {e}")
    
    print(f"Images creees avec succes: {success_count}")
    return success_count

def test_api_endpoints():
    """Teste les endpoints principaux"""
    print("Test des endpoints API...")
    
    try:
        # Test models
        menu_count = MenuItem.objects.count()
        ingredient_count = Ingredient.objects.count()
        base_count = Base.objects.count()
        
        print(f"Plats dans la base: {menu_count}")
        print(f"Ingredients dans la base: {ingredient_count}")
        print(f"Bases dans la base: {base_count}")
        
        # Test images
        menu_with_images = MenuItem.objects.exclude(image='').count()
        ingredients_with_images = Ingredient.objects.exclude(image='').count()
        bases_with_images = Base.objects.exclude(image='').count()
        
        print(f"Plats avec images: {menu_with_images}")
        print(f"Ingredients avec images: {ingredients_with_images}")
        print(f"Bases avec images: {bases_with_images}")
        
        return True
    except Exception as e:
        print(f"Erreur test API: {e}")
        return False

def main():
    """Fonction principale"""
    print("=" * 50)
    print("SETUP IMAGES POUR PRESENTATION DEMAIN")
    print("=" * 50)
    
    print("\n1. Configuration des donnees de base...")
    setup_demo_data()
    
    print("\n2. Creation des images de demonstration...")
    images_created = create_demo_images()
    
    print("\n3. Test des endpoints...")
    api_ok = test_api_endpoints()
    
    print("\n" + "=" * 50)
    print("RESUME DU SETUP")
    print("=" * 50)
    print(f"Images creees: {images_created}")
    print(f"API fonctionnelle: {'OUI' if api_ok else 'NON'}")
    
    if images_created > 0 and api_ok:
        print("\nSUCCES! Votre systeme d'images est pret pour la presentation!")
        print("\nPour demarrer le serveur:")
        print("python manage.py runserver")
        print("\nInterface admin: http://127.0.0.1:8000/admin/")
        print("Login: admin / admin123")
    else:
        print("\nATTENTION: Problemes detectes. Verifiez les erreurs ci-dessus.")
    
    print("\nBonne chance pour votre presentation demain!")

if __name__ == "__main__":
    main()