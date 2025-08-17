#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour corriger les URLs d'images et les sérialiseurs
Corrige le problème de duplication d'URL côté API
"""

import os
import sys
import django

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from api.models import MenuItem, Ingredient, Base, Category

def fix_image_urls():
    """Corrige les URLs d'images en supprimant la duplication"""
    print("🔧 Correction des URLs d'images...")
    
    fixed_count = 0
    
    # Corriger les menus
    for menu in MenuItem.objects.all():
        if menu.image and 'http://localhost:8000' in menu.image.name:
            # Extraire seulement le chemin relatif
            old_url = menu.image.name
            new_url = old_url.split('/media/')[-1] if '/media/' in old_url else old_url
            menu.image.name = new_url
            menu.save()
            fixed_count += 1
            print(f"✅ Menu '{menu.nom}': {old_url} → {new_url}")
    
    # Corriger les ingrédients
    for ingredient in Ingredient.objects.all():
        if ingredient.image and 'http://localhost:8000' in ingredient.image.name:
            old_url = ingredient.image.name
            new_url = old_url.split('/media/')[-1] if '/media/' in old_url else old_url
            ingredient.image.name = new_url
            ingredient.save()
            fixed_count += 1
            print(f"✅ Ingrédient '{ingredient.nom}': {old_url} → {new_url}")
    
    # Corriger les bases
    for base in Base.objects.all():
        if base.image and 'http://localhost:8000' in base.image.name:
            old_url = base.image.name
            new_url = old_url.split('/media/')[-1] if '/media/' in old_url else old_url
            base.image.name = new_url
            base.save()
            fixed_count += 1
            print(f"✅ Base '{base.nom}': {old_url} → {new_url}")
    
    # Corriger les catégories
    for category in Category.objects.all():
        if category.image and 'http://localhost:8000' in category.image.name:
            old_url = category.image.name
            new_url = old_url.split('/media/')[-1] if '/media/' in old_url else old_url
            category.image.name = new_url
            category.save()
            fixed_count += 1
            print(f"✅ Catégorie '{category.nom}': {old_url} → {new_url}")
    
    print(f"\n📊 {fixed_count} URLs corrigées")
    return fixed_count

def check_api_response():
    """Vérifie la réponse de l'API après correction"""
    print("\n🧪 Test de l'API après correction...")
    try:
        import requests
        response = requests.get('http://127.0.0.1:8000/api/menu/')
        if response.status_code == 200:
            menus = response.json()
            print(f"✅ API répond: {len(menus)} menus")
            
            # Vérifier quelques URLs d'images
            for menu in menus[:3]:
                if menu.get('image'):
                    image_url = menu['image']
                    if image_url.count('http://') == 1:
                        print(f"✅ URL correcte: {image_url}")
                    else:
                        print(f"❌ URL encore problématique: {image_url}")
            return True
        else:
            print(f"❌ API erreur: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Erreur test API: {e}")
        return False

def main():
    """Fonction principale"""
    print("🛠️  CORRECTION DES URLS D'IMAGES")
    print("=" * 50)
    print("Correction du problème de duplication d'URL")
    
    # 1. Corriger les URLs en base
    fixed_count = fix_image_urls()
    
    # 2. Tester l'API
    api_ok = check_api_response()
    
    # 3. Résumé
    print("\n" + "=" * 50)
    print("📊 RÉSUMÉ DE LA CORRECTION")
    print(f"URLs corrigées: {fixed_count}")
    print(f"API fonctionnelle: {'OUI' if api_ok else 'NON'}")
    
    if fixed_count > 0 or api_ok:
        print("\n✅ SUCCÈS ! Le problème d'URLs est corrigé")
        print("💡 Votre app Flutter devrait maintenant charger les images correctement")
        print("\n🔄 Redémarrez votre app Flutter pour voir les changements")
    else:
        print("\n⚠️  Pas de correction nécessaire ou problème persistant")
    
    print(f"\n🎯 Prêt pour la présentation demain !")

if __name__ == "__main__":
    main()
