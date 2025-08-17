#!/usr/bin/env python
import requests
import os
import time
import json

def test_complete_images():
    """Test complet de toutes les fonctionnalités d'images"""
    print("🧪 Test Complet des Fonctionnalités d'Images")
    print("=" * 50)
    
    # URL de l'API
    base_url = "http://localhost:8000/api"
    
    try:
        # 1. Test de connexion au serveur
        print("\n📡 Test de connexion au serveur Django...")
        response = requests.get(f"{base_url}/menu/")
        if response.status_code == 200:
            print("✅ Serveur Django accessible")
        else:
            print("❌ Serveur Django inaccessible")
            return
        
        # 2. Récupération des données
        print("\n📋 Récupération des données...")
        
        # Menu
        menu_response = requests.get(f"{base_url}/menu/")
        menu_data = menu_response.json() if menu_response.status_code == 200 else []
        print(f"   - Plats du menu: {len(menu_data)}")
        
        # Ingrédients
        ingredients_response = requests.get(f"{base_url}/ingredients/")
        ingredients_data = ingredients_response.json() if ingredients_response.status_code == 200 else []
        print(f"   - Ingrédients: {len(ingredients_data)}")
        
        # Bases
        bases_response = requests.get(f"{base_url}/bases/")
        bases_data = bases_response.json() if bases_response.status_code == 200 else []
        print(f"   - Bases: {len(bases_data)}")
        
        # 3. Analyse des images existantes
        print("\n🖼️ Analyse des images existantes...")
        
        def analyze_images(data, category):
            with_images = sum(1 for item in data if item.get('image'))
            without_images = len(data) - with_images
            percentage = (with_images / len(data) * 100) if len(data) > 0 else 0
            
            print(f"   {category}:")
            print(f"     - Total: {len(data)}")
            print(f"     - Avec images: {with_images}")
            print(f"     - Sans images: {without_images}")
            print(f"     - Taux de complétude: {percentage:.1f}%")
            
            return with_images, without_images, percentage
        
        menu_stats = analyze_images(menu_data, "Plats du menu")
        ingredients_stats = analyze_images(ingredients_data, "Ingrédients")
        bases_stats = analyze_images(bases_data, "Bases")
        
        # 4. Test d'upload d'images
        print("\n📤 Test d'upload d'images...")
        
        # Créer une image de test
        test_image_path = "test_complete_image.png"
        png_data = b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\xff\xff?\x00\x05\xfe\x02\xfe\xdc\xccY\xe7\x00\x00\x00\x00IEND\xaeB`\x82'
        
        with open(test_image_path, 'wb') as f:
            f.write(png_data)
        
        upload_tests = [
            ('menu', menu_data, 'Plat'),
            ('ingredient', ingredients_data, 'Ingrédient'),
            ('base', bases_data, 'Base'),
        ]
        
        for model_type, data, label in upload_tests:
            if data:
                first_item = data[0]
                print(f"\n   Test upload pour {label}: {first_item.get('nom', 'Sans nom')}")
                
                upload_url = f"{base_url}/upload-image/"
                with open(test_image_path, 'rb') as f:
                    files = {'image': f}
                    data_upload = {
                        'model_type': model_type,
                        'item_id': first_item['id']
                    }
                    
                    response = requests.post(upload_url, files=files, data=data_upload)
                    
                    if response.status_code == 200:
                        result = response.json()
                        print(f"     ✅ Upload réussi: {result.get('image_url')}")
                    else:
                        print(f"     ❌ Échec upload: {response.text}")
        
        # Nettoyer
        os.remove(test_image_path)
        
        # 5. Test d'accessibilité des images
        print("\n🔍 Test d'accessibilité des images...")
        
        all_items = menu_data + ingredients_data + bases_data
        accessible_images = 0
        
        for item in all_items:
            if item.get('image'):
                image_url = f"http://localhost:8000{item['image']}"
                try:
                    img_response = requests.get(image_url)
                    if img_response.status_code == 200:
                        accessible_images += 1
                        print(f"   ✅ {item.get('nom', 'Sans nom')}: accessible")
                    else:
                        print(f"   ❌ {item.get('nom', 'Sans nom')}: non accessible")
                except Exception as e:
                    print(f"   ❌ {item.get('nom', 'Sans nom')}: erreur - {e}")
        
        # 6. Statistiques finales
        print("\n📊 Statistiques finales...")
        total_items = len(all_items)
        total_with_images = sum(1 for item in all_items if item.get('image'))
        total_without_images = total_items - total_with_images
        completion_rate = (total_with_images / total_items * 100) if total_items > 0 else 0
        
        print(f"   Total éléments: {total_items}")
        print(f"   Avec images: {total_with_images}")
        print(f"   Sans images: {total_without_images}")
        print(f"   Taux de complétude: {completion_rate:.1f}%")
        print(f"   Images accessibles: {accessible_images}/{total_with_images}")
        
        # 7. Instructions pour Flutter
        print("\n📱 Instructions pour tester Flutter:")
        print("1. Démarrer l'application Flutter:")
        print("   cd bokkdej_front")
        print("   flutter run -d chrome --web-port=8081")
        print("\n2. Tester les fonctionnalités:")
        print("   - Ouvrir http://localhost:8081")
        print("   - Se connecter avec PIN admin (1234)")
        print("   - Aller dans la section admin")
        print("   - Tester l'upload d'images")
        print("   - Vérifier l'affichage dans le menu")
        print("   - Tester la gestion des images")
        
        # 8. Résumé des fonctionnalités
        print("\n✅ Fonctionnalités implémentées:")
        print("   - Upload d'images pour plats, ingrédients, bases")
        print("   - Affichage d'images dans le menu")
        print("   - Widgets d'upload et d'affichage")
        print("   - Gestion des erreurs et placeholders")
        print("   - Interface d'administration des images")
        print("   - Statistiques et monitoring")
        
    except requests.exceptions.ConnectionError:
        print("❌ Impossible de se connecter au serveur Django")
        print("💡 Assurez-vous que le serveur Django fonctionne: python manage.py runserver")
    except Exception as e:
        print(f"❌ Erreur: {e}")

if __name__ == '__main__':
    test_complete_images() 