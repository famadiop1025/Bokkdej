#!/usr/bin/env python
"""
Script pour vérifier la configuration Wave des restaurants
"""
import os
import sys
import django

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from api.models import Restaurant

def check_restaurants_wave():
    print("🔍 VÉRIFICATION DE LA CONFIGURATION WAVE DES RESTAURANTS")
    print("=" * 60)
    
    restaurants = Restaurant.objects.all()
    
    if not restaurants.exists():
        print("❌ Aucun restaurant trouvé dans la base de données")
        return
    
    print(f"📊 {restaurants.count()} restaurant(s) trouvé(s)\n")
    
    for restaurant in restaurants:
        print(f"🏪 Restaurant: {restaurant.nom} (ID: {restaurant.id})")
        print(f"   📍 Adresse: {restaurant.adresse}")
        print(f"   📞 Téléphone: {restaurant.telephone}")
        
        # Vérifier la configuration Wave
        wave_config = {
            'wave_payment_link': restaurant.wave_payment_link,
            'wave_merchant_id': restaurant.wave_merchant_id,
            'wave_api_key': restaurant.wave_api_key,
            'wave_webhook_secret': restaurant.wave_webhook_secret,
        }
        
        configured_fields = sum(1 for value in wave_config.values() if value)
        total_fields = len(wave_config)
        
        if configured_fields == 0:
            print("   ❌ Aucune configuration Wave")
        elif configured_fields < total_fields:
            print(f"   ⚠️  Configuration Wave partielle ({configured_fields}/{total_fields})")
            for field, value in wave_config.items():
                status = "✅" if value else "❌"
                print(f"      {status} {field}: {'Configuré' if value else 'Manquant'}")
        else:
            print("   ✅ Configuration Wave complète")
            print(f"      🔗 Lien Wave: {restaurant.wave_payment_link}")
            print(f"      🏪 Merchant ID: {restaurant.wave_merchant_id}")
        
        print()

if __name__ == "__main__":
    check_restaurants_wave()
