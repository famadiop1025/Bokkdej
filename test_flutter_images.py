#!/usr/bin/env python
import requests
import os
import time

def test_flutter_images():
    """Test de l'intégration des images dans Flutter"""
    print("🧪 Test de l'intégration des images Flutter...")
    
    # URL de l'API
    base_url = "http://localhost:8000/api"
    
    try:
        # 1. Vérifier que le serveur Django fonctionne
        print("\n📡 Test de connexion au serveur Django...")
        response = requests.get(f"{base_url}/menu/")
        if response.status_code == 200:
            print("✅ Serveur Django accessible")
            menu_data = response.json()
            print(f"📋 {len(menu_data)} plats trouvés")
        else:
            print("❌ Serveur Django inaccessible")
            return
        
        # 2. Vérifier les images existantes
        print("\n🖼️ Vérification des images existantes...")
        images_count = 0
        for plat in menu_data:
            if plat.get('image'):
                images_count += 1
                image_url = f"http://localhost:8000{plat['image']}"
                print(f"   - {plat['nom']}: {image_url}")
        
        print(f"📊 {images_count}/{len(menu_data)} plats ont des images")
        
        # 3. Test d'upload d'image pour le premier plat
        if menu_data:
            first_plat = menu_data[0]
            print(f"\n📤 Test d'upload d'image pour '{first_plat['nom']}'...")
            
            # Créer une image de test
            test_image_path = "test_flutter_image.png"
            png_data = b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\xff\xff?\x00\x05\xfe\x02\xfe\xdc\xccY\xe7\x00\x00\x00\x00IEND\xaeB`\x82'
            
            with open(test_image_path, 'wb') as f:
                f.write(png_data)
            
            # Upload de l'image
            upload_url = f"{base_url}/upload-image/"
            with open(test_image_path, 'rb') as f:
                files = {'image': f}
                data = {
                    'model_type': 'menu',
                    'item_id': first_plat['id']
                }
                
                response = requests.post(upload_url, files=files, data=data)
                
                if response.status_code == 200:
                    print("✅ Upload d'image réussi!")
                    result = response.json()
                    print(f"   URL de l'image: {result.get('image_url')}")
                else:
                    print(f"❌ Échec de l'upload: {response.text}")
            
            # Nettoyer
            os.remove(test_image_path)
        
        # 4. Vérifier l'accessibilité des images
        print("\n🔍 Test d'accessibilité des images...")
        for plat in menu_data[:3]:  # Tester les 3 premiers plats
            if plat.get('image'):
                image_url = f"http://localhost:8000{plat['image']}"
                try:
                    img_response = requests.get(image_url)
                    if img_response.status_code == 200:
                        print(f"✅ Image accessible: {plat['nom']}")
                    else:
                        print(f"❌ Image non accessible: {plat['nom']}")
                except Exception as e:
                    print(f"❌ Erreur d'accès à l'image: {plat['nom']} - {e}")
        
        # 5. Instructions pour tester Flutter
        print("\n📱 Instructions pour tester Flutter:")
        print("1. Démarrer l'application Flutter:")
        print("   cd bokkdej_front")
        print("   flutter run -d chrome --web-port=8081")
        print("\n2. Tester dans l'application:")
        print("   - Ouvrir http://localhost:8081")
        print("   - Se connecter avec le PIN admin (1234)")
        print("   - Aller dans la section admin")
        print("   - Éditer un plat pour tester l'upload d'image")
        print("   - Vérifier l'affichage des images dans le menu")
        
    except requests.exceptions.ConnectionError:
        print("❌ Impossible de se connecter au serveur Django")
        print("💡 Assurez-vous que le serveur Django fonctionne: python manage.py runserver")
    except Exception as e:
        print(f"❌ Erreur: {e}")

if __name__ == '__main__':
    test_flutter_images() 