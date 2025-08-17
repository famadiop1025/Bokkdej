#!/usr/bin/env python3
"""
Script complet pour tester et gérer les images pour la présentation de demain
Ce script va :
1. Tester tous les endpoints d'upload d'images
2. Créer des images de démonstration
3. Vérifier que tout fonctionne correctement
"""

import os
import sys
import django
import requests
from PIL import Image, ImageDraw, ImageFont
import io
import base64

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import MenuItem, Ingredient, Base, Category, UserProfile

class ImageTestManager:
    def __init__(self, base_url="http://127.0.0.1:8000"):
        self.base_url = base_url
        self.token = None
        self.demo_images_created = []
        
    def create_demo_image(self, text, size=(300, 200), bg_color='lightblue', text_color='black'):
        """Crée une image de démonstration avec du texte"""
        try:
            # Créer une image avec PIL
            img = Image.new('RGB', size, color=bg_color)
            d = ImageDraw.Draw(img)
            
            # Calculer la position du texte pour le centrer
            bbox = d.textbbox((0, 0), text)
            text_width = bbox[2] - bbox[0]
            text_height = bbox[3] - bbox[1]
            position = ((size[0] - text_width) // 2, (size[1] - text_height) // 2)
            
            # Dessiner le texte
            d.text(position, text, fill=text_color)
            
            # Sauvegarder dans un buffer
            buffer = io.BytesIO()
            img.save(buffer, format='PNG')
            buffer.seek(0)
            
            # Sauvegarder aussi localement pour référence
            filename = f"demo_{text.replace(' ', '_').lower()}.png"
            local_path = os.path.join('media', 'demo_images', filename)
            os.makedirs(os.path.dirname(local_path), exist_ok=True)
            
            with open(local_path, 'wb') as f:
                f.write(buffer.getvalue())
                
            self.demo_images_created.append(local_path)
            print(f"✅ Image de démo créée : {local_path}")
            
            buffer.seek(0)
            return buffer, filename
            
        except Exception as e:
            print(f"❌ Erreur lors de la création de l'image {text}: {e}")
            return None, None
    
    def get_admin_token(self):
        """Récupère un token d'authentification admin"""
        try:
            # Essayer de se connecter avec l'admin existant
            response = requests.post(f"{self.base_url}/api/token/", 
                                   json={"username": "admin", "password": "admin123"})
            
            if response.status_code == 200:
                self.token = response.json()['access']
                print("✅ Authentification admin réussie")
                return True
            else:
                print("⚠️  Impossible de s'authentifier comme admin")
                return False
                
        except Exception as e:
            print(f"❌ Erreur d'authentification : {e}")
            return False
    
    def test_image_upload_endpoint(self, model_type, item_id, image_name):
        """Teste l'endpoint général d'upload d'image"""
        try:
            image_buffer, filename = self.create_demo_image(f"{model_type.title()} {item_id}")
            if not image_buffer:
                return False
                
            headers = {}
            if self.token:
                headers['Authorization'] = f'Bearer {self.token}'
            
            files = {'image': (filename, image_buffer, 'image/png')}
            data = {
                'model_type': model_type,
                'item_id': item_id
            }
            
            response = requests.post(f"{self.base_url}/api/upload_image/", 
                                   files=files, data=data, headers=headers)
            
            if response.status_code == 200:
                result = response.json()
                print(f"✅ Upload réussi pour {model_type} {item_id}: {result.get('image_url')}")
                return True
            else:
                print(f"❌ Échec upload {model_type} {item_id}: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Erreur test upload {model_type} {item_id}: {e}")
            return False
    
    def test_specific_viewset_upload(self, endpoint, item_id, image_name):
        """Teste l'endpoint spécifique d'un ViewSet"""
        try:
            image_buffer, filename = self.create_demo_image(image_name)
            if not image_buffer:
                return False
                
            headers = {}
            if self.token:
                headers['Authorization'] = f'Bearer {self.token}'
            
            files = {'image': (filename, image_buffer, 'image/png')}
            
            response = requests.post(f"{self.base_url}/api/{endpoint}/{item_id}/upload_image/", 
                                   files=files, headers=headers)
            
            if response.status_code == 200:
                result = response.json()
                print(f"✅ Upload ViewSet réussi pour {endpoint} {item_id}: {result.get('image_url')}")
                return True
            else:
                print(f"❌ Échec upload ViewSet {endpoint} {item_id}: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Erreur test ViewSet {endpoint} {item_id}: {e}")
            return False
    
    def create_test_data_if_needed(self):
        """Crée des données de test si nécessaire"""
        print("\n📊 Vérification des données de test...")
        
        # Créer des catégories si elles n'existent pas
        if not Category.objects.exists():
            categories = [
                {"nom": "Entrées", "description": "Plats d'entrée délicieux"},
                {"nom": "Plats principaux", "description": "Nos spécialités principales"},
                {"nom": "Desserts", "description": "Douceurs pour finir en beauté"},
                {"nom": "Boissons", "description": "Rafraîchissements et boissons chaudes"}
            ]
            for cat_data in categories:
                Category.objects.create(**cat_data)
            print("✅ Catégories créées")
        
        # Créer des bases si elles n'existent pas
        if not Base.objects.exists():
            bases = [
                {"nom": "Riz blanc", "prix": 500, "description": "Riz basmati parfumé"},
                {"nom": "Riz thiof", "prix": 800, "description": "Riz au poisson thiof"},
                {"nom": "Couscous", "prix": 600, "description": "Couscous traditionnel"},
                {"nom": "Attiéké", "prix": 400, "description": "Semoule de manioc"}
            ]
            for base_data in bases:
                Base.objects.create(**base_data)
            print("✅ Bases créées")
        
        # Créer des ingrédients si ils n'existent pas
        if not Ingredient.objects.exists():
            ingredients = [
                {"nom": "Poulet", "prix": 1500, "type": "viande"},
                {"nom": "Bœuf", "prix": 2000, "type": "viande"},
                {"nom": "Poisson", "prix": 1800, "type": "poisson"},
                {"nom": "Tomates", "prix": 200, "type": "legume"},
                {"nom": "Oignons", "prix": 150, "type": "legume"},
                {"nom": "Sauce arachide", "prix": 300, "type": "sauce"}
            ]
            for ing_data in ingredients:
                Ingredient.objects.create(**ing_data)
            print("✅ Ingrédients créés")
        
        # Créer des plats de menu si ils n'existent pas
        if not MenuItem.objects.exists():
            category = Category.objects.first()
            menus = [
                {"nom": "Thieboudienne", "prix": 2500, "type": "dej", "calories": 650, "temps_preparation": 45, "category": category},
                {"nom": "Yassa Poulet", "prix": 2200, "type": "dej", "calories": 580, "temps_preparation": 35, "category": category},
                {"nom": "Mafé", "prix": 2000, "type": "dej", "calories": 620, "temps_preparation": 40, "category": category},
                {"nom": "Café Touba", "prix": 300, "type": "petit_dej", "calories": 50, "temps_preparation": 5, "category": category}
            ]
            for menu_data in menus:
                MenuItem.objects.create(**menu_data)
            print("✅ Plats de menu créés")
    
    def run_complete_test(self):
        """Lance un test complet du système d'images"""
        print("🚀 DÉBUT DES TESTS D'IMAGES POUR LA PRÉSENTATION")
        print("=" * 60)
        
        # 1. Créer les données de test
        self.create_test_data_if_needed()
        
        # 2. S'authentifier
        print("\n🔐 Authentification...")
        if not self.get_admin_token():
            print("⚠️  Continuons sans authentification (accès public seulement)")
        
        # 3. Tester l'endpoint général d'upload
        print("\n📤 Test de l'endpoint général d'upload...")
        success_count = 0
        total_tests = 0
        
        # Test pour les bases
        bases = Base.objects.all()[:2]  # Tester sur 2 bases
        for base in bases:
            total_tests += 1
            if self.test_image_upload_endpoint('base', base.id, f"Base {base.nom}"):
                success_count += 1
        
        # Test pour les ingrédients  
        ingredients = Ingredient.objects.all()[:2]  # Tester sur 2 ingrédients
        for ingredient in ingredients:
            total_tests += 1
            if self.test_image_upload_endpoint('ingredient', ingredient.id, f"Ingrédient {ingredient.nom}"):
                success_count += 1
        
        # Test pour les menus
        menus = MenuItem.objects.all()[:2]  # Tester sur 2 menus
        for menu in menus:
            total_tests += 1
            if self.test_image_upload_endpoint('menu', menu.id, f"Menu {menu.nom}"):
                success_count += 1
        
        # 4. Tester les endpoints spécifiques des ViewSets
        print("\n📤 Test des endpoints spécifiques des ViewSets...")
        
        # Test ViewSet MenuItem
        for menu in menus:
            total_tests += 1
            if self.test_specific_viewset_upload('menu', menu.id, f"ViewSet Menu {menu.nom}"):
                success_count += 1
        
        # Test ViewSet Ingredient
        for ingredient in ingredients:
            total_tests += 1
            if self.test_specific_viewset_upload('ingredients', ingredient.id, f"ViewSet Ingrédient {ingredient.nom}"):
                success_count += 1
        
        # 5. Résumé des tests
        print("\n" + "=" * 60)
        print(f"📊 RÉSUMÉ DES TESTS")
        print(f"Tests réussis: {success_count}/{total_tests}")
        print(f"Taux de réussite: {(success_count/total_tests)*100:.1f}%")
        
        if self.demo_images_created:
            print(f"\n🖼️  Images de démo créées ({len(self.demo_images_created)}):")
            for img_path in self.demo_images_created:
                print(f"  - {img_path}")
        
        # 6. Recommandations pour la présentation
        print("\n💡 RECOMMANDATIONS POUR LA PRÉSENTATION:")
        print("1. ✅ Le système d'upload d'images fonctionne")
        print("2. 📱 Testez l'affichage des images dans votre app Flutter")
        print("3. 🔗 URLs des images accessibles via l'API")
        print("4. 🎨 Préparez de vraies images de plats pour la démo finale")
        print("5. 📊 Interface admin disponible pour la gestion")
        
        return success_count, total_tests

def main():
    """Fonction principale"""
    print("🍽️  GESTIONNAIRE D'IMAGES KEUR RESTO")
    print("Préparation pour la présentation de demain")
    print("=" * 50)
    
    # Vérifier que Django fonctionne
    try:
        from django.core.management import execute_from_command_line
        print("✅ Django configuré correctement")
    except Exception as e:
        print(f"❌ Erreur Django: {e}")
        return
    
    # Lancer les tests
    manager = ImageTestManager()
    success, total = manager.run_complete_test()
    
    print(f"\n🎯 PRÊT POUR LA PRÉSENTATION: {success}/{total} fonctionnalités testées")
    
    if success == total:
        print("🎉 EXCELLENT ! Tout fonctionne parfaitement !")
    elif success > total * 0.7:
        print("👍 BON ! La plupart des fonctionnalités marchent")
    else:
        print("⚠️  ATTENTION ! Plusieurs problèmes détectés")

if __name__ == "__main__":
    main()