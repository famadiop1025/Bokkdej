#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour configurer un restaurant avec Wave
"""

import os
import sys
import django

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from api.models import Restaurant

def configure_restaurant_wave():
    print("🏪 CONFIGURATION RESTAURANT AVEC WAVE")
    print("=" * 50)
    
    # Récupérer le premier restaurant
    try:
        restaurant = Restaurant.objects.first()
        if not restaurant:
            print("❌ Aucun restaurant trouvé. Créons-en un...")
            restaurant = Restaurant.objects.create(
                nom="Restaurant Test Wave",
                adresse="Dakar, Sénégal",
                telephone="+221777123456",
                email="test@wave.com",
                description="Restaurant de test pour l'intégration Wave",
                statut="actif",
                actif=True
            )
            print(f"✅ Restaurant créé: {restaurant.nom}")
        
        # Configurer Wave
        restaurant.wave_payment_link = "https://pay.wave.com/checkout"
        restaurant.wave_merchant_id = "WAVE_MERCHANT_123"
        restaurant.wave_api_key = "WAVE_API_KEY_123"
        restaurant.wave_webhook_secret = "WAVE_WEBHOOK_SECRET_123"
        restaurant.save()
        
        print(f"✅ Restaurant configuré avec Wave:")
        print(f"   Nom: {restaurant.nom}")
        print(f"   ID: {restaurant.id}")
        print(f"   Lien Wave: {restaurant.wave_payment_link}")
        print(f"   Merchant ID: {restaurant.wave_merchant_id}")
        
        return restaurant
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return None

if __name__ == "__main__":
    configure_restaurant_wave()
