#!/usr/bin/env python
import os
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from api.models import Restaurant

def add_wave_links():
    """Ajouter des liens Wave Marchand aux restaurants existants"""
    
    # Liens Wave Marchand d'exemple (à remplacer par les vrais liens)
    wave_links = {
        'Restaurant ISEP Diamniadio': 'https://wave.com/pay/restaurant-isep-diamniadio',
        'Chez Fatou': 'https://wave.com/pay/chez-fatou-restaurant',
        'Mère Diagne Cooking': 'https://wave.com/pay/mere-diagne-cooking',
        'Lambouroise Restaurant': 'https://wave.com/pay/lambouroise-restaurant',
        'Modern Eclectic Restaurant': 'https://wave.com/pay/modern-eclectic-restaurant',
    }
    
    print("🔗 Ajout des liens Wave Marchand aux restaurants...")
    
    for restaurant in Restaurant.objects.all():
        if restaurant.nom in wave_links:
            restaurant.wave_payment_link = wave_links[restaurant.nom]
            restaurant.save()
            print(f"✅ {restaurant.nom}: {restaurant.wave_payment_link}")
        else:
            # Lien générique pour les autres restaurants
            generic_link = f"https://wave.com/pay/{restaurant.nom.lower().replace(' ', '-')}"
            restaurant.wave_payment_link = generic_link
            restaurant.save()
            print(f"✅ {restaurant.nom}: {restaurant.wave_payment_link}")
    
    print(f"\n🏁 {Restaurant.objects.count()} restaurants mis à jour avec des liens Wave!")

if __name__ == "__main__":
    add_wave_links()
