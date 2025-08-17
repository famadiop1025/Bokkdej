#!/usr/bin/env python3
"""
Script pour préparer des images de démonstration réalistes pour la présentation
Ce script crée de belles images de démonstration pour tous vos plats
"""

import os
import sys
import django
from PIL import Image, ImageDraw, ImageFont
import io

# Configuration Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'keur_resto.settings')
django.setup()

from api.models import MenuItem, Ingredient, Base, Category

class DemoImageCreator:
    def __init__(self):
        self.colors = {
            'thieboudienne': '#FF6B35',  # Orange pour les plats de riz
            'yassa': '#FFC107',          # Jaune pour le yassa  
            'mafe': '#8BC34A',           # Vert pour le mafé
            'cafe': '#795548',           # Marron pour le café
            'poulet': '#FF9800',         # Orange pour la viande
            'boeuf': '#F44336',          # Rouge pour le bœuf
            'poisson': '#2196F3',        # Bleu pour le poisson
            'legume': '#4CAF50',         # Vert pour les légumes
            'sauce': '#9C27B0',          # Violet pour les sauces
            'riz': '#FFEB3B',           # Jaune pour le riz
            'couscous': '#FF5722',       # Orange pour le couscous
            'default': '#607D8B'         # Gris pour le reste
        }
        
        self.demo_folder = os.path.join('media', 'demo_images')
        os.makedirs(self.demo_folder, exist_ok=True)
    
    def get_color_for_item(self, name, item_type=None):
        """Détermine la couleur selon le nom et le type d'item"""
        name_lower = name.lower()
        
        # Couleurs spécifiques selon le nom
        for key, color in self.colors.items():
            if key in name_lower:
                return color
        
        # Couleurs selon le type
        type_colors = {
            'viande': '#FF9800',
            'poisson': '#2196F3', 
            'legume': '#4CAF50',
            'sauce': '#9C27B0',
            'petit_dej': '#795548',
            'dej': '#FF6B35',
            'diner': '#673AB7'
        }
        
        if item_type and item_type in type_colors:
            return type_colors[item_type]
            
        return self.colors['default']
    
    def create_food_image(self, name, description="", item_type=None, size=(400, 300)):
        """Crée une belle image de nourriture avec design moderne"""
        try:
            # Choisir la couleur
            bg_color = self.get_color_for_item(name, item_type)
            
            # Créer l'image
            img = Image.new('RGB', size, color='white')
            d = ImageDraw.Draw(img)
            
            # Dessiner un fond dégradé simple
            for i in range(size[1]):
                alpha = i / size[1]
                # Calculer la couleur intermédiaire
                color = self._blend_colors('white', bg_color, alpha)
                d.line([(0, i), (size[0], i)], fill=color)
            
            # Dessiner un cercle central pour représenter le plat
            circle_size = min(size[0], size[1]) // 3
            circle_x = (size[0] - circle_size) // 2
            circle_y = (size[1] - circle_size) // 2
            
            d.ellipse([circle_x, circle_y, circle_x + circle_size, circle_y + circle_size], 
                     fill=bg_color, outline='white', width=3)
            
            # Ajouter le nom du plat
            try:
                font_size = 24
                font = ImageFont.truetype("arial.ttf", font_size)
            except:
                font = ImageFont.load_default()
            
            # Calculer la position du texte
            bbox = d.textbbox((0, 0), name, font=font)
            text_width = bbox[2] - bbox[0]
            text_x = (size[0] - text_width) // 2
            text_y = circle_y + circle_size + 20
            
            # Dessiner un fond pour le texte
            d.rectangle([text_x - 10, text_y - 5, text_x + text_width + 10, text_y + 30], 
                       fill='white', outline=bg_color, width=2)
            
            # Dessiner le texte
            d.text((text_x, text_y), name, fill=bg_color, font=font)
            
            # Ajouter une description si fournie
            if description and len(description) < 30:
                try:
                    desc_font = ImageFont.truetype("arial.ttf", 16)
                except:
                    desc_font = ImageFont.load_default()
                    
                bbox = d.textbbox((0, 0), description, font=desc_font)
                desc_width = bbox[2] - bbox[0]
                desc_x = (size[0] - desc_width) // 2
                desc_y = text_y + 40
                
                d.text((desc_x, desc_y), description, fill='gray', font=desc_font)
            
            return img
            
        except Exception as e:
            print(f"❌ Erreur création image {name}: {e}")
            # Image de fallback simple
            img = Image.new('RGB', size, color=bg_color)
            d = ImageDraw.Draw(img)
            d.text((20, size[1]//2), name, fill='white')
            return img
    
    def _blend_colors(self, color1, color2, alpha):
        """Mélange deux couleurs"""
        if isinstance(color1, str):
            color1 = self._hex_to_rgb(color1)
        if isinstance(color2, str):
            color2 = self._hex_to_rgb(color2)
            
        r = int(color1[0] * (1 - alpha) + color2[0] * alpha)
        g = int(color1[1] * (1 - alpha) + color2[1] * alpha) 
        b = int(color1[2] * (1 - alpha) + color2[2] * alpha)
        
        return (r, g, b)
    
    def _hex_to_rgb(self, hex_color):
        """Convertit hex en RGB"""
        if hex_color == 'white':
            return (255, 255, 255)
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    
    def save_image_for_model(self, img, model_instance, folder_name):
        """Sauvegarde l'image et met à jour le modèle"""
        try:
            filename = f"{model_instance.nom.replace(' ', '_').lower()}.png"
            filepath = os.path.join(self.demo_folder, folder_name, filename)
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            
            # Sauvegarder l'image
            img.save(filepath)
            
            # Mettre à jour le modèle
            relative_path = f"demo_images/{folder_name}/{filename}"
            model_instance.image = relative_path
            model_instance.save()
            
            print(f"✅ Image créée et assignée: {relative_path}")
            return True
            
        except Exception as e:
            print(f"❌ Erreur sauvegarde {model_instance.nom}: {e}")
            return False
    
    def create_all_demo_images(self):
        """Crée toutes les images de démonstration"""
        print("🎨 CRÉATION DES IMAGES DE DÉMONSTRATION")
        print("=" * 50)
        
        success_count = 0
        total_count = 0
        
        # Images pour les catégories
        print("\n📂 Création d'images pour les catégories...")
        for category in Category.objects.all():
            total_count += 1
            img = self.create_food_image(category.nom, category.description, 'category')
            if self.save_image_for_model(img, category, 'categories'):
                success_count += 1
        
        # Images pour les plats de menu
        print("\n🍽️  Création d'images pour les plats...")
        for menu_item in MenuItem.objects.all():
            total_count += 1
            img = self.create_food_image(menu_item.nom, menu_item.description, menu_item.type)
            if self.save_image_for_model(img, menu_item, 'menu'):
                success_count += 1
        
        # Images pour les ingrédients
        print("\n🥘 Création d'images pour les ingrédients...")
        for ingredient in Ingredient.objects.all():
            total_count += 1
            img = self.create_food_image(ingredient.nom, f"Type: {ingredient.get_type_display()}", ingredient.type)
            if self.save_image_for_model(img, ingredient, 'ingredients'):
                success_count += 1
        
        # Images pour les bases
        print("\n🍚 Création d'images pour les bases...")
        for base in Base.objects.all():
            total_count += 1
            img = self.create_food_image(base.nom, base.description, 'base')
            if self.save_image_for_model(img, base, 'bases'):
                success_count += 1
        
        # Résumé
        print("\n" + "=" * 50)
        print(f"📊 RÉSUMÉ DE LA CRÉATION D'IMAGES")
        print(f"Images créées avec succès: {success_count}/{total_count}")
        print(f"Taux de réussite: {(success_count/total_count)*100:.1f}%")
        print(f"📁 Dossier: {self.demo_folder}")
        
        return success_count, total_count

def main():
    """Fonction principale"""
    print("🖼️  CRÉATEUR D'IMAGES DE DÉMONSTRATION")
    print("Pour la présentation Keur Resto")
    print("=" * 40)
    
    creator = DemoImageCreator()
    success, total = creator.create_all_demo_images()
    
    if success == total:
        print("\n🎉 PARFAIT ! Toutes les images ont été créées !")
        print("💡 Votre application aura de belles images pour la présentation !")
    elif success > 0:
        print(f"\n👍 BON ! {success} images créées sur {total}")
        print("💡 Certaines images peuvent être manquantes mais l'essentiel est là")
    else:
        print("\n⚠️  PROBLÈME ! Aucune image n'a pu être créée")
        print("💡 Vérifiez les permissions et les dépendances PIL/Pillow")
    
    print(f"\n📱 Prêt pour votre présentation de demain !")

if __name__ == "__main__":
    main()