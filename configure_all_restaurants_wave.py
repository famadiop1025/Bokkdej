#!/usr/bin/env python
"""
Script pour configurer tous les restaurants avec des liens Wave
"""
import os
import sys
import django

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from api.models import Restaurant

def configure_all_restaurants_wave():
    print("🌊 CONFIGURATION WAVE POUR TOUS LES RESTAURANTS")
    print("=" * 60)
    
    restaurants = Restaurant.objects.all()
    
    if not restaurants.exists():
        print("❌ Aucun restaurant trouvé dans la base de données")
        return
    
    print(f"📊 {restaurants.count()} restaurant(s) à configurer\n")
    
    # Configuration Wave pour chaque restaurant
    wave_configs = {
        1: {
            'wave_payment_link': 'https://pay.wave.com/checkout/restaurant-isep-diamniadio',
            'wave_merchant_id': 'WAVE_MERCHANT_ISEP_001',
            'wave_api_key': 'wave_api_key_isep_001',
            'wave_webhook_secret': 'webhook_secret_isep_001'
        },
        2: {
            'wave_payment_link': 'https://pay.wave.com/checkout/lambouroise',
            'wave_merchant_id': 'WAVE_MERCHANT_LAMB_002',
            'wave_api_key': 'wave_api_key_lamb_002',
            'wave_webhook_secret': 'webhook_secret_lamb_002'
        },
        3: {
            'wave_payment_link': 'https://pay.wave.com/checkout/mere-diagne',
            'wave_merchant_id': 'WAVE_MERCHANT_MERE_003',
            'wave_api_key': 'wave_api_key_mere_003',
            'wave_webhook_secret': 'webhook_secret_mere_003'
        },
        4: {
            'wave_payment_link': 'https://pay.wave.com/checkout/keur-resto-thies',
            'wave_merchant_id': 'WAVE_MERCHANT_THIES_004',
            'wave_api_key': 'wave_api_key_thies_004',
            'wave_webhook_secret': 'webhook_secret_thies_004'
        },
        5: {
            'wave_payment_link': 'https://pay.wave.com/checkout/restaurant-isep',
            'wave_merchant_id': 'WAVE_MERCHANT_ISEP2_005',
            'wave_api_key': 'wave_api_key_isep2_005',
            'wave_webhook_secret': 'webhook_secret_isep2_005'
        },
        7: {
            'wave_payment_link': 'https://pay.wave.com/checkout/le-gourmet',
            'wave_merchant_id': 'WAVE_MERCHANT_GOURMET_007',
            'wave_api_key': 'wave_api_key_gourmet_007',
            'wave_webhook_secret': 'webhook_secret_gourmet_007'
        },
        8: {
            'wave_payment_link': 'https://pay.wave.com/checkout/restaurant-admin-test',
            'wave_merchant_id': 'WAVE_MERCHANT_ADMIN_008',
            'wave_api_key': 'wave_api_key_admin_008',
            'wave_webhook_secret': 'webhook_secret_admin_008'
        },
        9: {
            'wave_payment_link': 'https://pay.wave.com/checkout/dimbal-jaboot',
            'wave_merchant_id': 'WAVE_MERCHANT_DIMBAL_009',
            'wave_api_key': 'wave_api_key_dimbal_009',
            'wave_webhook_secret': 'webhook_secret_dimbal_009'
        }
    }
    
    updated_count = 0
    
    for restaurant in restaurants:
        print(f"🏪 Configuration de: {restaurant.nom} (ID: {restaurant.id})")
        
        # Vérifier si le restaurant a déjà une configuration Wave
        if restaurant.wave_payment_link and restaurant.wave_merchant_id:
            print(f"   ⚠️  Déjà configuré - Passage au suivant")
            print()
            continue
        
        # Appliquer la configuration Wave
        if restaurant.id in wave_configs:
            config = wave_configs[restaurant.id]
            
            restaurant.wave_payment_link = config['wave_payment_link']
            restaurant.wave_merchant_id = config['wave_merchant_id']
            restaurant.wave_api_key = config['wave_api_key']
            restaurant.wave_webhook_secret = config['wave_webhook_secret']
            
            try:
                restaurant.save()
                print(f"   ✅ Configuration Wave appliquée")
                print(f"      🔗 Lien: {config['wave_payment_link']}")
                print(f"      🏪 Merchant ID: {config['wave_merchant_id']}")
                updated_count += 1
            except Exception as e:
                print(f"   ❌ Erreur lors de la sauvegarde: {e}")
        else:
            print(f"   ⚠️  Aucune configuration prédéfinie pour ce restaurant")
        
        print()
    
    print("=" * 60)
    print(f"🎉 CONFIGURATION TERMINÉE")
    print(f"📊 {updated_count} restaurant(s) configuré(s) avec Wave")
    print(f"📊 {restaurants.count() - updated_count} restaurant(s) déjà configuré(s) ou ignoré(s)")

def verify_configuration():
    print("\n🔍 VÉRIFICATION DE LA CONFIGURATION")
    print("=" * 40)
    
    restaurants = Restaurant.objects.all()
    configured_count = 0
    
    for restaurant in restaurants:
        if restaurant.wave_payment_link and restaurant.wave_merchant_id:
            configured_count += 1
            print(f"✅ {restaurant.nom} - Configuré")
        else:
            print(f"❌ {restaurant.nom} - Non configuré")
    
    print(f"\n📊 Résultat: {configured_count}/{restaurants.count()} restaurants configurés")

if __name__ == "__main__":
    configure_all_restaurants_wave()
    verify_configuration()
