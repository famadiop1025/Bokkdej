#!/usr/bin/env python
import requests
import os

def test_image_upload():
    """Test de l'upload d'images"""
    print("🧪 Test de l'upload d'images...")
    
    # URL de l'API
    url = "http://localhost:8000/api/upload-image/"
    
    # Créer un fichier image de test (1x1 pixel PNG)
    test_image_path = "test_image.png"
    
    # Créer une image de test simple
    try:
        # Créer un fichier PNG minimal (1x1 pixel transparent)
        png_data = b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\xff\xff?\x00\x05\xfe\x02\xfe\xdc\xccY\xe7\x00\x00\x00\x00IEND\xaeB`\x82'
        
        with open(test_image_path, 'wb') as f:
            f.write(png_data)
        
        print("✅ Fichier image de test créé")
        
        # Test d'upload pour un plat (menu)
        print("\n📤 Test d'upload pour un plat...")
        with open(test_image_path, 'rb') as f:
            files = {'image': f}
            data = {
                'model_type': 'menu',
                'item_id': 1  # Premier plat
            }
            
            response = requests.post(url, files=files, data=data)
            print(f"📡 Statut: {response.status_code}")
            print(f"📄 Réponse: {response.text}")
            
            if response.status_code == 200:
                print("✅ Upload d'image pour plat réussi!")
            else:
                print("❌ Échec de l'upload pour plat")
        
        # Test d'upload pour un ingrédient
        print("\n📤 Test d'upload pour un ingrédient...")
        with open(test_image_path, 'rb') as f:
            files = {'image': f}
            data = {
                'model_type': 'ingredient',
                'item_id': 1  # Premier ingrédient
            }
            
            response = requests.post(url, files=files, data=data)
            print(f"📡 Statut: {response.status_code}")
            print(f"📄 Réponse: {response.text}")
            
            if response.status_code == 200:
                print("✅ Upload d'image pour ingrédient réussi!")
            else:
                print("❌ Échec de l'upload pour ingrédient")
        
        # Test d'upload pour une base
        print("\n📤 Test d'upload pour une base...")
        with open(test_image_path, 'rb') as f:
            files = {'image': f}
            data = {
                'model_type': 'base',
                'item_id': 1  # Première base
            }
            
            response = requests.post(url, files=files, data=data)
            print(f"📡 Statut: {response.status_code}")
            print(f"📄 Réponse: {response.text}")
            
            if response.status_code == 200:
                print("✅ Upload d'image pour base réussi!")
            else:
                print("❌ Échec de l'upload pour base")
        
        # Nettoyer le fichier de test
        os.remove(test_image_path)
        print("\n🧹 Fichier de test supprimé")
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
    
    print("\n📋 Résumé des tests d'upload d'images")
    print("💡 Pour tester manuellement:")
    print("   - Utiliser un client HTTP (Postman, curl)")
    print("   - Envoyer une requête POST à /api/upload-image/")
    print("   - Inclure le fichier image et les paramètres model_type et item_id")

if __name__ == '__main__':
    test_image_upload() 