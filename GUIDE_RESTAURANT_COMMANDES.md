# 🏪 GUIDE RESTAURANT : Comment recevoir et gérer les commandes

## 📋 **FLUX COMPLET D'UNE COMMANDE**

### **1. 📱 Le client valide son panier**
```dart
// Le client clique sur "Valider la commande" dans l'app Flutter
final result = await cartProvider.submitOrder();
```

### **2. 🚀 L'API crée la commande**
- **Endpoint** : `POST /api/orders/valider-panier/`
- **Status** : `en_attente` (directement, pas de statut "panier")
- **Base de données** : Commande enregistrée avec tous les détails

### **3. 🔔 Notifications automatiques envoyées**
- **Client** : Notification push "Commande validée !"
- **Restaurant** : Notification push "Nouvelle commande #X validée"

---

## 🎯 **COMMENT LE RESTAURANT RECOIT LA COMMANDE**

### **A. Notifications Push (FCM)**
```python
# Dans api/views.py - valider_panier_direct()
self._notify_restaurant_staff(
    order.restaurant, 
    title="Nouvelle commande", 
    body=f"Commande #{order.id} validée."
)
```

**Qui reçoit** : Tous les utilisateurs `is_staff=True` avec un token FCM valide

### **B. Interface d'administration en temps réel**
- **Dashboard** : Affichage des commandes récentes
- **Polling automatique** : Actualisation toutes les 10-30 secondes
- **Indicateur "Live"** : Commandes en temps réel

---

## 🖥️ **INTERFACE DE GESTION DES COMMANDES**

### **1. Dashboard Principal**
```
📊 Tableau de Bord
├── Commandes récentes
├── Statut en temps réel
├── Total du jour
└── Alertes nouvelles commandes
```

### **2. Page Commandes Spécifique**
```
🛒 Gestion des Commandes
├── Filtres par statut
├── Liste des commandes
├── Actions rapides
└── Détails complets
```

### **3. Navigation par onglets**
```
🏪 Restaurant Dashboard
├── 📊 Dashboard
├── 🍽️ Menu  
├── 🛒 Commandes ← **ICI**
├── 👥 Personnel
└── 📈 Statistiques
```

---

## 🔄 **GESTION DES STATUTS DE COMMANDE**

### **A. Statuts disponibles**
```python
STATUS_CHOICES = [
    ('en_attente', 'En attente'),      # ← Commande reçue
    ('en_preparation', 'En préparation'), # ← En cours
    ('pret', 'Prêt'),                  # ← Prêt à livrer
    ('termine', 'Terminé'),            # ← Livré
    ('annule', 'Annulé'),              # ← Annulé
]
```

### **B. Actions du restaurant**
```dart
// Dans RestaurantSpecificOrders
void _updateOrderStatus(String newStatus) {
  // Appel API pour changer le statut
  // POST /api/orders/{id}/update-status/
  // body: {"status": "en_preparation"}
}
```

### **C. Workflow recommandé**
```
1. 📥 Commande reçue → "en_attente"
2. 👨‍🍳 Début préparation → "en_preparation"  
3. ✅ Prêt → "pret"
4. 🚚 Livré → "termine"
```

---

## 📱 **NOTIFICATIONS AUTOMATIQUES**

### **A. Pour le restaurant**
- **Nouvelle commande** : "Commande #X validée"
- **Changement de statut** : "Commande #X : en préparation"
- **Commande prête** : "Commande #X : prêt"

### **B. Pour le client**
- **Commande validée** : "Votre commande a été validée"
- **En préparation** : "Votre commande est en cours de préparation 👨‍🍳"
- **Prêt** : "Votre commande est prête ! 🎉"
- **Terminé** : "Votre commande a été livrée. Bon appétit ! 🍽️"

---

## 🛠️ **FONCTIONNALITÉS AVANCÉES**

### **A. Polling intelligent**
```dart
// Actualisation automatique sans surcharge
Timer.periodic(Duration(seconds: 10), (_) => _smartFetchOrders());

// Vérification des changements avant mise à jour
bool _hasOrdersChanged(List<dynamic> newOrders) {
  // Compare les commandes pour éviter les rechargements inutiles
}
```

### **B. Filtres et recherche**
- **Par statut** : en_attente, en_preparation, pret, termine
- **Par date** : Aujourd'hui, cette semaine, ce mois
- **Par montant** : Commandes par tranche de prix

### **C. Statistiques en temps réel**
- **Commandes du jour** : Nombre et montant total
- **Temps moyen** : Durée de préparation
- **Plats populaires** : Les plus commandés

---

## 🔧 **CONFIGURATION REQUISE**

### **A. Notifications Push (FCM)**
```python
# Dans keur_resto/settings.py
FCM_SERVER_KEY = 'VOTRE_CLE_FCM_ICI'

# Ou via variable d'environnement
FCM_SERVER_KEY = os.environ.get('FCM_SERVER_KEY')
```

### **B. Utilisateurs staff**
```python
# Seuls les utilisateurs avec is_staff=True reçoivent les notifications
staff_users = User.objects.filter(is_staff=True, is_active=True)
```

### **C. Tokens FCM**
- Chaque utilisateur staff doit avoir un `fcm_token` valide
- Le token est généré par l'app mobile Flutter
- Stocké dans le profil utilisateur (`UserProfile.fcm_token`)

---

## 📊 **MONITORING ET SURVEILLANCE**

### **A. Logs de commandes**
```python
# Toutes les actions sont loggées
print(f"[FCM] Erreur notif staff: {e}")
print(f"[SMS] Erreur envoi SMS: {e}")
```

### **B. Gestion des erreurs**
- **Notifications échouées** : Logs d'erreur sans blocage
- **SMS échoués** : Fallback vers logs console
- **API indisponible** : Retry automatique

### **C. Métriques de performance**
- **Temps de réponse** : API et notifications
- **Taux de succès** : Notifications délivrées
- **Latence** : Délai commande → notification

---

## 🚀 **BONNES PRATIQUES**

### **A. Réactivité**
- **Répondre rapidement** : Changer le statut dès réception
- **Mettre à jour régulièrement** : Garder le client informé
- **Gérer les pics** : Système de file d'attente

### **B. Communication**
- **Statuts clairs** : Utiliser les statuts standardisés
- **Messages informatifs** : Expliquer les délais
- **Suivi transparent** : Client toujours informé

### **C. Maintenance**
- **Vérifier les notifications** : Tester régulièrement
- **Surveiller les logs** : Détecter les problèmes
- **Mettre à jour les tokens** : Maintenir la connectivité

---

## 🎯 **RÉSUMÉ DU PROCESSUS**

```
📱 Client valide panier
    ↓
🚀 API crée commande (status: en_attente)
    ↓
🔔 Notifications envoyées (client + restaurant)
    ↓
🏪 Restaurant reçoit notification + voit dans dashboard
    ↓
👨‍🍳 Restaurant change statut (en_preparation → pret → termine)
    ↓
📱 Client reçoit notifications de progression
    ↓
✅ Commande terminée avec satisfaction client
```

**Le système est entièrement automatisé et en temps réel !** 🎉

---

## 🔗 **LIENS UTILES**

- **API Endpoints** : `/api/orders/` pour la gestion
- **Admin Dashboard** : Interface complète de gestion
- **Documentation FCM** : Configuration des notifications
- **Tests** : `python test_valider_panier.py` pour vérifier
