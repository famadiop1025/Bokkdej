from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from pyfcm import FCMNotification
from django.conf import settings
from django.utils import timezone

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
    calories = models.PositiveIntegerField(null=True, blank=True)
    temps_preparation = models.PositiveIntegerField(help_text='Temps en minutes', null=True, blank=True)
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
    ingredients = models.ManyToManyField(Ingredient, through='CustomDishIngredient')
    restaurant = models.ForeignKey('Restaurant', on_delete=models.CASCADE, related_name='custom_dishes', null=True, blank=True)
    prix_total = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    disponible = models.BooleanField(default=True, null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)

    def __str__(self):
        return f"{self.base} - {self.prix_total} F"
    
    def calculer_prix_total(self):
        """Calculer le prix total basé sur les ingrédients"""
        total = 0
        for ingredient in self.ingredients.all():
            total += ingredient.prix
        self.prix_total = total
        self.save()
        return total

class CustomDishIngredient(models.Model):
    custom_dish = models.ForeignKey(CustomDish, on_delete=models.CASCADE)
    ingredient = models.ForeignKey(Ingredient, on_delete=models.CASCADE)
    quantite = models.PositiveIntegerField(default=1)
    
    class Meta:
        unique_together = ['custom_dish', 'ingredient']

class Restaurant(models.Model):
    STATUT_CHOICES = [
        ('actif', 'Actif'),
        ('inactif', 'Inactif'),
        ('suspendu', 'Suspendu'),
        ('en_attente', 'En attente de validation'),
    ]
    
    nom = models.CharField(max_length=100)
    adresse = models.TextField(blank=True, null=True)
    telephone = models.CharField(max_length=20, blank=True, null=True)
    email = models.EmailField(blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='actif')
    actif = models.BooleanField(default=True)
    logo = models.ImageField(upload_to='restaurant_logos/', blank=True, null=True)
    
    # Champs pour les demandes d'inscription
    nom_gerant = models.CharField(max_length=100, blank=True, null=True, help_text="Nom du gérant responsable")
    telephone_gerant = models.CharField(max_length=20, blank=True, null=True, help_text="Téléphone du gérant")
    type_cuisine = models.CharField(max_length=100, blank=True, null=True, help_text="Type de cuisine (sénégalaise, française, etc.)")
    capacite = models.PositiveIntegerField(default=0, help_text="Capacité d'accueil du restaurant")
    horaires = models.TextField(blank=True, null=True, help_text="Horaires d'ouverture")
    documents_legaux = models.BooleanField(default=False, help_text="Documents légaux fournis")
    
    # Configuration Wave
    wave_payment_link = models.URLField(
        blank=True, 
        null=True, 
        help_text="Lien de paiement Wave du restaurant"
    )
    wave_merchant_id = models.CharField(
        max_length=100, 
        blank=True, 
        null=True,
        help_text="ID marchand Wave (si API disponible)"
    )
    wave_api_key = models.CharField(
        max_length=200, 
        blank=True, 
        null=True,
        help_text="Clé API Wave (si API disponible)"
    )
    wave_webhook_secret = models.CharField(
        max_length=200, 
        blank=True, 
        null=True,
        help_text="Secret pour valider les webhooks Wave"
    )
    
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)

    class Meta:
        ordering = ['nom']

    def __str__(self):
        return self.nom

    def save(self, *args, **kwargs):
        # Gérer les champs de date pour les restaurants existants
        if not self.pk:  # Nouveau restaurant
            from django.utils import timezone
            if not self.created_at:
                self.created_at = timezone.now()
        if not self.updated_at:
            from django.utils import timezone
            self.updated_at = timezone.now()
        super().save(*args, **kwargs)

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

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    phone = models.CharField(max_length=20, blank=True, null=True)
    fcm_token = models.CharField(max_length=500, blank=True, null=True)
    
    def __str__(self):
        return f"Profile de {self.user.username}"

class Order(models.Model):
    STATUS_CHOICES = [
        ('panier', 'Panier'),
        ('en_attente', 'En attente'),
        ('en_preparation', 'En préparation'),
        ('pret', 'Prêt'),
        ('termine', 'Terminé'),
        ('annule', 'Annulé'),
    ]
    
    PAYMENT_STATUS_CHOICES = [
        ('pending', 'En attente de paiement'),
        ('paid', 'Payé'),
        ('failed', 'Échec du paiement'),
        ('cancelled', 'Paiement annulé'),
        ('refunded', 'Remboursé'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    restaurant = models.ForeignKey(Restaurant, on_delete=models.CASCADE)
    items = models.JSONField(default=list)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='panier')
    phone = models.CharField(max_length=20, blank=True, null=True)
    
    # Gestion des paiements Wave
    payment_status = models.CharField(
        max_length=20, 
        choices=PAYMENT_STATUS_CHOICES, 
        default='pending',
        help_text="Statut du paiement"
    )
    wave_payment_url = models.URLField(
        blank=True, 
        null=True,
        help_text="URL de paiement Wave générée"
    )
    wave_transaction_id = models.CharField(
        max_length=100, 
        blank=True, 
        null=True,
        help_text="ID de transaction Wave"
    )
    wave_payment_reference = models.CharField(
        max_length=100, 
        blank=True, 
        null=True,
        help_text="Référence de paiement Wave"
    )
    payment_date = models.DateTimeField(
        blank=True, 
        null=True,
        help_text="Date et heure du paiement"
    )
    payment_method = models.CharField(
        max_length=50, 
        default='wave',
        help_text="Méthode de paiement utilisée"
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Commande #{self.id} - {self.restaurant.nom}"
    
    @property
    def is_paid(self):
        """Vérifie si la commande est payée"""
        return self.payment_status == 'paid'
    
    @property
    def can_be_prepared(self):
        """Vérifie si la commande peut être préparée (payée et en attente)"""
        return self.is_paid and self.status == 'en_attente'

class WavePaymentLog(models.Model):
    """Log des transactions Wave pour audit et debugging"""
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='wave_logs')
    event_type = models.CharField(
        max_length=50,
        help_text="Type d'événement: payment_initiated, payment_success, payment_failed, webhook_received"
    )
    wave_transaction_id = models.CharField(max_length=100, blank=True, null=True)
    wave_reference = models.CharField(max_length=100, blank=True, null=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    status = models.CharField(max_length=50, blank=True, null=True)
    raw_data = models.JSONField(default=dict, help_text="Données brutes reçues de Wave")
    error_message = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Wave Log - {self.event_type} - Commande #{self.order.id}"

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
