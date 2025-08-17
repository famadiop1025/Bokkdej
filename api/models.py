from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from pyfcm import FCMNotification
from django.conf import settings

class Base(models.Model):
    nom = models.CharField(max_length=100)
    prix = models.DecimalField(max_digits=6, decimal_places=2)
    description = models.TextField(blank=True, null=True)
    image = models.ImageField(upload_to='base_images/', blank=True, null=True)
    restaurant = models.ForeignKey('Restaurant', on_delete=models.CASCADE, related_name='bases', null=True, blank=True)
    disponible = models.BooleanField(default=True)
    
    class Meta:
        unique_together = ['nom', 'restaurant']

    def __str__(self):
        return f"{self.nom} - {self.prix} F"

class MenuItem(models.Model):
    TYPE_CHOICES = [
        ('petit_dej', 'Petit-déjeuner'),
        ('dej', 'Déjeuner'),
        ('diner', 'Dîner'),
    ]
    nom = models.CharField(max_length=100)
    prix = models.DecimalField(max_digits=6, decimal_places=2)
    image = models.ImageField(upload_to='menu_images/', blank=True, null=True)
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    category = models.ForeignKey('Category', on_delete=models.SET_NULL, null=True, blank=True)
    restaurant = models.ForeignKey('Restaurant', on_delete=models.CASCADE, related_name='menu_items', null=True, blank=True)
    calories = models.PositiveIntegerField()
    temps_preparation = models.PositiveIntegerField(help_text='Temps en minutes')
    description = models.TextField(blank=True, null=True)
    disponible = models.BooleanField(default=True, null=True, blank=True)
    populaire = models.BooleanField(default=False, null=True, blank=True)
    plat_du_jour = models.BooleanField(default=False, help_text="Ce plat est-il le plat du jour ?")
    
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)
    
    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=['restaurant'],
                condition=models.Q(plat_du_jour=True),
                name='unique_plat_du_jour_par_restaurant'
            )
        ]

    def __str__(self):
        return self.nom

class Ingredient(models.Model):
    TYPE_CHOICES = [
        ('legume', 'Légume'),
        ('viande', 'Viande'),
        ('poisson', 'Poisson'),
        ('fromage', 'Fromage'),
        ('sauce', 'Sauce'),
        ('epice', 'Épice'),
        ('protéine', 'Protéine'),
        ('autre', 'Autre'),
    ]
    
    nom = models.CharField(max_length=100)
    prix = models.DecimalField(max_digits=6, decimal_places=2)
    type = models.CharField(max_length=50, choices=TYPE_CHOICES)
    image = models.ImageField(upload_to='ingredient_images/', blank=True, null=True)
    restaurant = models.ForeignKey('Restaurant', on_delete=models.CASCADE, related_name='ingredients', null=True, blank=True)
    
    # Gestion du stock
    stock_actuel = models.PositiveIntegerField(default=0, null=True, blank=True)
    stock_min = models.PositiveIntegerField(default=0, null=True, blank=True)
    unite = models.CharField(max_length=20, default='pièce', null=True, blank=True)  # pièce, kg, g, L, ml
    
    # Informations nutritionnelles
    calories_pour_100g = models.PositiveIntegerField(null=True, blank=True)
    allergenes = models.CharField(max_length=200, blank=True, null=True)
    
    # Gestion
    disponible = models.BooleanField(default=True, null=True, blank=True)
    fournisseur = models.CharField(max_length=100, blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)

    def __str__(self):
        return self.nom
    
    @property
    def is_low_stock(self):
        """Vérifie si le stock est faible"""
        return self.stock_actuel <= self.stock_min

class CustomDish(models.Model):
    base = models.CharField(max_length=100)
    ingredients = models.ManyToManyField(Ingredient)
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)  # Rendu optionnel
    prix = models.DecimalField(max_digits=6, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.base} + {', '.join([i.nom for i in self.ingredients.all()])}"

class OrderItem(models.Model):
    order = models.ForeignKey('Order', on_delete=models.CASCADE, related_name='order_items')
    custom_dish = models.ForeignKey(CustomDish, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)

    def __str__(self):
        return f"{self.custom_dish} x {self.quantity} (Commande {self.order.id})"

class Order(models.Model):
    STATUS_CHOICES = [
        ('panier', 'Panier'),
        ('en_attente', 'En attente'),
        ('en_preparation', 'En préparation'),
        ('pret', 'Prêt'),
        ('termine', 'Terminé'),
    ]
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)  # Rendu optionnel
    phone = models.CharField(max_length=15, null=True, blank=True)  # Ajout du champ téléphone
    prix_total = models.DecimalField(max_digits=8, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='panier')
    created_at = models.DateTimeField(auto_now_add=True)
    restaurant = models.ForeignKey('Restaurant', on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        if self.user:
            return f"Commande - {self.user.username}"
        elif self.phone:
            return f"Commande - {self.phone}"
        return "Commande (anonyme)"

class UserProfile(models.Model):
    ROLE_CHOICES = [
        ('admin', 'Admin'),
        ('personnel', 'Personnel'),
        ('chef', 'Chef'),
        ('client', 'Client'),
    ]
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    role = models.CharField(max_length=15, choices=ROLE_CHOICES, default='client')
    phone = models.CharField(max_length=15, unique=True, null=True, blank=True)
    pin_code = models.CharField(max_length=10, null=True, blank=True)
    restaurant = models.ForeignKey('Restaurant', on_delete=models.CASCADE, null=True, blank=True)
    fcm_token = models.CharField(max_length=255, null=True, blank=True)
    date_embauche = models.DateField(null=True, blank=True)
    salaire = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    actif = models.BooleanField(default=True, null=True, blank=True)

    def __str__(self):
        return f"{self.user.username} - {self.role}"

class Restaurant(models.Model):
    STATUT_CHOICES = [
        ('en_attente', 'En attente de validation'),
        ('valide', 'Validé'),
        ('suspendu', 'Suspendu'),
        ('rejete', 'Rejeté'),
    ]
    
    nom = models.CharField(max_length=100, unique=True)
    adresse = models.TextField(blank=True, null=True)
    telephone = models.CharField(max_length=15, blank=True, null=True)
    email = models.EmailField(blank=True, null=True)
    horaires_ouverture = models.JSONField(default=dict, blank=True, null=True)
    logo = models.ImageField(upload_to='restaurant_logos/', blank=True, null=True)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')
    actif = models.BooleanField(default=True, null=True, blank=True)
    date_validation = models.DateTimeField(null=True, blank=True)
    validé_par = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='restaurants_valides')

    def __str__(self):
        return self.nom

class SystemSettings(models.Model):
    """Configuration système du restaurant"""
    restaurant = models.OneToOneField(Restaurant, on_delete=models.CASCADE)
    
    # Paramètres de commande
    commande_min = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    temps_preparation_defaut = models.PositiveIntegerField(default=30)  # minutes
    accepter_commandes_anonymes = models.BooleanField(default=True)
    
    # Paramètres de notification
    notifications_activees = models.BooleanField(default=True)
    email_notifications = models.BooleanField(default=True)
    sms_notifications = models.BooleanField(default=False)
    
    # Paramètres d'affichage
    devise = models.CharField(max_length=10, default='F CFA')
    langue = models.CharField(max_length=10, default='fr')
    
    # Paramètres de livraison
    livraison_activee = models.BooleanField(default=False)
    frais_livraison = models.DecimalField(max_digits=6, decimal_places=2, default=0)
    zone_livraison = models.TextField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)

    def __str__(self):
        return f"Paramètres - {self.restaurant.nom}"

class Category(models.Model):
    """Catégories pour les plats du menu"""
    nom = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    image = models.ImageField(upload_to='category_images/', blank=True, null=True)
    ordre = models.PositiveIntegerField(default=0)
    actif = models.BooleanField(default=True, null=True, blank=True)

    class Meta:
        ordering = ['ordre', 'nom']

    def __str__(self):
        return self.nom

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.userprofile.save()

@receiver(post_save, sender=Order)
def notify_order_status_change(sender, instance, created, **kwargs):
    if created:
        return  # Ne pas notifier à la création (panier)
    if not instance.user or not hasattr(instance.user, 'userprofile'):
        return
    token = instance.user.userprofile.fcm_token
    if not token:
        return
    if instance.status == 'panier':
        return  # Ne pas notifier pour le panier
    status_messages = {
        'en_attente': "Votre commande a été validée et est en attente de préparation.",
        'en_preparation': "Votre commande est en cours de préparation 👨‍🍳.",
        'pret': "Votre commande est prête ! 🎉.",
        'termine': "Votre commande a été livrée. Bon appétit ! 🍽️.",
    }
    message = status_messages.get(instance.status)
    if not message:
        return
    push_service = FCMNotification(api_key=settings.FCM_SERVER_KEY)
    try:
        push_service.notify_single_device(
            registration_id=token,
            message_title=f"Commande #{instance.id}",
            message_body=message
        )
    except Exception as e:
        print(f"Erreur envoi notification FCM: {e}")
