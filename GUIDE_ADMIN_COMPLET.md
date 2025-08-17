# 🏢 Guide Complet des Fonctionnalités Administrateur - BOKDEJ

## 📋 Vue d'ensemble

Ce guide détaille toutes les fonctionnalités administrateur implémentées dans l'application BOKDEJ. L'interface administrateur permet une gestion complète du restaurant depuis une interface web sécurisée.

## 🔐 Connexion Administrateur

### Connexion par PIN
```http
POST /api/auth/pin-login/
Content-Type: application/json

{
  "pin": "1234"  // PIN admin par défaut
}
```

**Réponse :**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "username": "admin",
    "role": "admin"
  }
}
```

---

## 🍽️ 1. GESTION DU MENU

### Endpoints disponibles :
- **GET** `/api/admin/menu/` - Liste tous les plats
- **POST** `/api/admin/menu/` - Créer un nouveau plat
- **GET** `/api/admin/menu/{id}/` - Détails d'un plat
- **PUT** `/api/admin/menu/{id}/` - Modifier un plat
- **DELETE** `/api/admin/menu/{id}/` - Supprimer un plat

### Actions spéciales :
- **POST** `/api/admin/menu/{id}/toggle_disponible/` - Activer/désactiver
- **POST** `/api/admin/menu/{id}/toggle_populaire/` - Marquer comme populaire
- **GET** `/api/admin/menu/statistics/` - Statistiques du menu

### Filtres disponibles :
- `?category=1` - Filtrer par catégorie
- `?type=dej` - Filtrer par type (petit_dej, dej, diner)
- `?disponible=true` - Filtrer par disponibilité

### Exemple création d'un plat :
```json
POST /api/admin/menu/
{
  "nom": "Burger Deluxe",
  "prix": "3500.00",
  "type": "dej",
  "category_id": 1,
  "calories": 650,
  "temps_preparation": 20,
  "description": "Burger premium avec frites",
  "disponible": true,
  "populaire": false
}
```

---

## 🥬 2. GESTION DES INGRÉDIENTS

### Endpoints disponibles :
- **GET** `/api/admin/ingredients/` - Liste tous les ingrédients
- **POST** `/api/admin/ingredients/` - Créer un nouvel ingrédient
- **GET** `/api/admin/ingredients/{id}/` - Détails d'un ingrédient
- **PUT** `/api/admin/ingredients/{id}/` - Modifier un ingrédient
- **DELETE** `/api/admin/ingredients/{id}/` - Supprimer un ingrédient

### Actions spéciales :
- **POST** `/api/admin/ingredients/{id}/update_stock/` - Mettre à jour le stock
- **GET** `/api/admin/ingredients/low_stock_alert/` - Alertes stock faible
- **GET** `/api/admin/ingredients/statistics/` - Statistiques des ingrédients

### Filtres disponibles :
- `?type=legume` - Filtrer par type
- `?low_stock=true` - Afficher seulement les stocks faibles
- `?disponible=true` - Filtrer par disponibilité

### Exemple création d'un ingrédient :
```json
POST /api/admin/ingredients/
{
  "nom": "Tomates fraîches",
  "prix": "200.00",
  "type": "legume",
  "stock_actuel": 100,
  "stock_min": 20,
  "unite": "kg",
  "calories_pour_100g": 18,
  "allergenes": "Aucun",
  "fournisseur": "Marché Local"
}
```

### Mise à jour du stock :
```json
POST /api/admin/ingredients/1/update_stock/
{
  "stock": 50
}
```

---

## 👥 3. GESTION DU PERSONNEL

### Endpoints disponibles :
- **GET** `/api/admin/personnel/` - Liste tout le personnel
- **POST** `/api/admin/personnel/` - Créer un nouveau membre
- **GET** `/api/admin/personnel/{id}/` - Détails d'un membre
- **PUT** `/api/admin/personnel/{id}/` - Modifier un membre
- **DELETE** `/api/admin/personnel/{id}/` - Supprimer un membre

### Actions spéciales :
- **POST** `/api/admin/personnel/{id}/toggle_active/` - Activer/désactiver
- **POST** `/api/admin/personnel/{id}/change_role/` - Changer le rôle
- **GET** `/api/admin/personnel/statistics/` - Statistiques du personnel

### Rôles disponibles :
- `admin` - Administrateur complet
- `personnel` - Personnel de service
- `chef` - Chef cuisinier
- `client` - Client (non affiché dans la gestion personnel)

### Exemple changement de rôle :
```json
POST /api/admin/personnel/2/change_role/
{
  "role": "chef"
}
```

---

## 📋 4. GESTION DES CATÉGORIES

### Endpoints disponibles :
- **GET** `/api/admin/categories/` - Liste toutes les catégories
- **POST** `/api/admin/categories/` - Créer une nouvelle catégorie
- **GET** `/api/admin/categories/{id}/` - Détails d'une catégorie
- **PUT** `/api/admin/categories/{id}/` - Modifier une catégorie
- **DELETE** `/api/admin/categories/{id}/` - Supprimer une catégorie

### Actions spéciales :
- **POST** `/api/admin/categories/{id}/toggle_active/` - Activer/désactiver

### Exemple création de catégorie :
```json
POST /api/admin/categories/
{
  "nom": "Entrées",
  "description": "Plats d'entrée",
  "ordre": 1,
  "actif": true
}
```

---

## 📊 5. STATISTIQUES GÉNÉRALES

### Endpoint principal :
**GET** `/api/admin/statistics/`

### Données retournées :
```json
{
  "orders": {
    "total": 156,
    "today": 12,
    "week": 89,
    "month": 156,
    "by_status": [
      {"status": "en_attente", "count": 5},
      {"status": "en_preparation", "count": 3},
      {"status": "pret", "count": 2}
    ]
  },
  "revenue": {
    "total": 2450000.00,
    "today": 85000.00,
    "week": 420000.00,
    "month": 2450000.00,
    "avg_order_value": 15705.13
  },
  "popular_dishes": [
    {"custom_dish__base": "Pizza Margherita", "total_quantity": 45},
    {"custom_dish__base": "Burger Classic", "total_quantity": 38}
  ],
  "alerts": {
    "low_stock_ingredients": 3,
    "pending_orders": 5
  }
}
```

---

## ⚙️ 6. PARAMÈTRES SYSTÈME

### Endpoints :
- **GET** `/api/admin/settings/` - Lire les paramètres
- **POST** `/api/admin/settings/` - Modifier les paramètres

### Structure des paramètres :
```json
{
  "restaurant": {
    "nom": "BOKDEJ Restaurant",
    "adresse": "123 Avenue de la Paix, Dakar",
    "telephone": "+221 33 123 45 67",
    "email": "contact@bokdej.sn",
    "horaires_ouverture": {
      "lundi": "08:00-22:00",
      "mardi": "08:00-22:00",
      "mercredi": "08:00-22:00",
      "jeudi": "08:00-22:00",
      "vendredi": "08:00-23:00",
      "samedi": "08:00-23:00",
      "dimanche": "10:00-22:00"
    }
  },
  "settings": {
    "commande_min": 1000.00,
    "temps_preparation_defaut": 30,
    "accepter_commandes_anonymes": true,
    "notifications_activees": true,
    "email_notifications": true,
    "sms_notifications": false,
    "devise": "F CFA",
    "langue": "fr",
    "livraison_activee": false,
    "frais_livraison": 0.00,
    "zone_livraison": ""
  }
}
```

---

## 📈 7. RAPPORTS

### Endpoint principal :
**GET** `/api/admin/reports/?type={type}&start_date={date}&end_date={date}`

### Types de rapports disponibles :

#### A. Rapport des ventes (`type=sales`)
```json
{
  "period": {"start": "2024-01-01", "end": "2024-01-31"},
  "summary": {
    "total_orders": 89,
    "total_revenue": 1456000.00,
    "avg_order_value": 16359.55
  },
  "daily_sales": [
    {"day": "2024-01-01", "orders_count": 8, "revenue": 125000.00},
    {"day": "2024-01-02", "orders_count": 12, "revenue": 189000.00}
  ],
  "top_dishes": [
    {"custom_dish__base": "Pizza", "quantity": 45}
  ]
}
```

#### B. Rapport d'inventaire (`type=inventory`)
```json
{
  "total_ingredients": 25,
  "low_stock_count": 3,
  "out_of_stock_count": 1,
  "low_stock_items": [
    {
      "id": 5,
      "nom": "Tomates",
      "stock_actuel": 5,
      "stock_min": 10
    }
  ],
  "by_type": [
    {"type": "legume", "total_items": 8, "avg_stock": 45.5}
  ]
}
```

#### C. Rapport du personnel (`type=staff`)
```json
{
  "total_staff": 12,
  "active_staff": 10,
  "inactive_staff": 2,
  "by_role": [
    {"role": "admin", "count": 2, "active_count": 2},
    {"role": "personnel", "count": 6, "active_count": 5},
    {"role": "chef", "count": 4, "active_count": 3}
  ]
}
```

---

## 🔒 Sécurité et Permissions

### Authentification requise
Tous les endpoints administrateur nécessitent :
1. **Token JWT valide** dans le header `Authorization: Bearer <token>`
2. **Rôle administrateur** (`role = 'admin'` dans UserProfile)

### Exemple de requête authentifiée :
```bash
curl -X GET "http://localhost:8000/api/admin/statistics/" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..." \
  -H "Content-Type: application/json"
```

---

## 🧪 Test des Fonctionnalités

### Script de test automatisé :
```bash
python test_admin_endpoints.py
```

Ce script teste automatiquement toutes les fonctionnalités administrateur.

---

## 📱 Intégration Frontend

### URLs d'API pour le développement Flutter :

#### Base URLs :
- **Développement local :** `http://localhost:8000/api/`
- **Android Emulator :** `http://10.0.2.2:8000/api/`

#### Endpoints principaux :
```dart
// Connexion
POST /api/auth/pin-login/

// Administration
GET /api/admin/statistics/
GET /api/admin/menu/
GET /api/admin/ingredients/
GET /api/admin/personnel/
GET /api/admin/settings/
GET /api/admin/reports/
```

---

## 🎯 Fonctionnalités Implémentées ✅

1. **✅ Gestion du menu** - CRUD complet, filtres, statistiques
2. **✅ Gestion des ingrédients** - Stock, alertes, gestion complète
3. **✅ Gestion du personnel** - Utilisateurs, rôles, permissions
4. **✅ Statistiques** - Dashboard complet avec métriques
5. **✅ Paramètres** - Configuration système complète
6. **✅ Rapports** - Ventes, inventaire, personnel

## 🚀 Prochaines Étapes

Pour utiliser ces fonctionnalités dans votre app Flutter :

1. **Implementer les écrans d'administration** dans Flutter
2. **Ajouter la navigation** vers les différentes sections
3. **Créer les formulaires** de gestion (CRUD)
4. **Implémenter les graphiques** pour les statistiques
5. **Ajouter les notifications** pour les alertes

---

**🎉 Toutes les fonctionnalités administrateur sont maintenant implémentées et prêtes à être utilisées !**