# 📱 Guide de Test - Interface Administrateur Flutter BOKDEJ

## 🎯 Vue d'ensemble

Ce guide détaille comment tester toutes les fonctionnalités administrateur dans l'application Flutter BOKDEJ. L'interface administrateur moderne offre une expérience utilisateur complète pour la gestion du restaurant.

---

## 🔐 **1. CONNEXION ADMINISTRATEUR**

### Étapes de test :

1. **Lancez l'application Flutter**
   ```bash
   cd bokkdej_front
   flutter run
   ```

2. **Page de connexion PIN**
   - Tapez le PIN administrateur : **`1234`**
   - L'application doit automatiquement détecter le rôle admin
   - Redirection automatique vers le **Dashboard Administrateur**

### Résultat attendu :
✅ Connexion réussie et redirection vers AdminDashboard
✅ Interface moderne avec statistiques en temps réel

---

## 🏠 **2. DASHBOARD ADMINISTRATEUR**

### Fonctionnalités à tester :

#### **📊 Statistiques Rapides**
- [ ] **Commandes Aujourd'hui** - Nombre affiché correctement
- [ ] **Chiffre d'Affaires** - Montant formaté en F CFA
- [ ] **Alertes** - Compteur des alertes système

#### **🎨 Interface**
- [ ] **Carte de bienvenue** avec gradient
- [ ] **Grille de fonctionnalités** avec 6 cartes :
  - 🍽️ Gestion du menu
  - 🥬 Gestion des ingrédients  
  - 👥 Gestion du personnel
  - 📊 Statistiques
  - ⚙️ Paramètres
  - 📈 Rapports

#### **⚠️ Alertes Système**
- [ ] Affichage des alertes stock faible
- [ ] Affichage des commandes en attente
- [ ] Message "Tout va bien" si aucune alerte

#### **🔄 Actions**
- [ ] **Bouton Actualiser** - Recharge les données
- [ ] **Bouton Déconnexion** - Confirme et déconnecte
- [ ] **Pull-to-refresh** - Actualise en tirant vers le bas

---

## 🍽️ **3. GESTION DU MENU**

### Tests à effectuer :

#### **📋 Liste des plats**
- [ ] Affichage de tous les plats avec images
- [ ] Informations complètes : nom, prix, temps, calories
- [ ] Badge "POPULAIRE" pour les plats populaires
- [ ] Statut disponible/indisponible avec switch

#### **🔍 Recherche et filtres**
- [ ] **Barre de recherche** - Recherche par nom
- [ ] **Filtres par type** :
  - Tous
  - Petit-déjeuner
  - Déjeuner
  - Dîner

#### **📊 Statistiques menu**
- [ ] Total plats
- [ ] Plats disponibles
- [ ] Plats populaires

#### **⚡ Actions rapides**
- [ ] **Toggle disponibilité** - Active/désactive un plat
- [ ] **Toggle populaire** - Marque/démarque comme populaire
- [ ] **Modifier** - Ouvre la boîte de dialogue d'édition
- [ ] **Supprimer** - Confirme et supprime

### Tests d'interaction :
```
1. Rechercher "burger" → Filtrer les résultats
2. Sélectionner "Déjeuner" → Afficher seulement les plats de déjeuner
3. Toggle une disponibilité → Voir le changement immédiat
4. Tenter de supprimer → Confirmer avec dialogue
```

---

## 🥬 **4. GESTION DES INGRÉDIENTS**

### Tests à effectuer :

#### **📦 Gestion du stock**
- [ ] **Stock actuel vs stock minimum** affiché
- [ ] **Barre de progression** du stock
- [ ] **Badge "STOCK FAIBLE"** en rouge si alerte
- [ ] **Mise à jour du stock** via dialogue

#### **🔍 Filtres par type**
- [ ] Tous, Légumes, Viandes, Poissons, Fromages, Sauces, Épices, Autres

#### **📊 Statistiques ingrédients**
- [ ] Total ingrédients
- [ ] Ingrédients disponibles  
- [ ] Alertes stock faible

#### **⚠️ Alertes stock faible**
- [ ] **Bouton alertes** dans l'AppBar
- [ ] **Liste des ingrédients** en stock faible
- [ ] **Détails** : stock actuel vs minimum

### Tests de stock :
```
1. Cliquer "Gérer Stock" → Ouvrir dialogue
2. Modifier stock → Sauvegarder
3. Vérifier barre de progression mise à jour
4. Tester alerte si stock < minimum
```

---

## 👥 **5. GESTION DU PERSONNEL**

### Tests à effectuer :

#### **👤 Liste du personnel**
- [ ] **Avatar coloré** par rôle (Admin=rouge, Personnel=bleu, Chef=orange)
- [ ] **Informations complètes** : nom, username, email, téléphone
- [ ] **Badge rôle** avec couleur correspondante
- [ ] **Switch actif/inactif**

#### **🔍 Filtres par rôle**
- [ ] Tous, Administrateurs, Personnel, Chefs

#### **📊 Statistiques personnel**
- [ ] Total personnel
- [ ] Personnel actif
- [ ] Personnel inactif

#### **⚙️ Gestion des rôles**
- [ ] **Bouton "Rôle"** - Ouvre dialogue de changement
- [ ] **Dropdown** avec options : Admin, Personnel, Chef
- [ ] **Sauvegarde** et mise à jour immédiate

### Tests de rôles :
```
1. Sélectionner un membre → Changer rôle
2. Vérifier badge mis à jour
3. Vérifier couleur avatar changée
4. Tester toggle actif/inactif
```

---

## 📊 **6. STATISTIQUES DÉTAILLÉES**

### Tests à effectuer :

#### **🎛️ Sélecteur de période**
- [ ] **Chips** : Aujourd'hui, Cette semaine, Ce mois, Total
- [ ] **Sélection** change les données affichées

#### **📈 Commandes**
- [ ] **4 métriques** : Total, Aujourd'hui, Semaine, Mois
- [ ] **Icônes colorées** avec valeurs

#### **💰 Chiffre d'Affaires**
- [ ] **CA total et périodique** formaté
- [ ] **Valeur moyenne** par commande

#### **⭐ Plats populaires**
- [ ] **Top 5** avec quantités vendues
- [ ] **Badges orange** avec nombres

#### **📊 Commandes par statut**
- [ ] **Couleurs par statut** :
  - En attente = Orange
  - En préparation = Bleu  
  - Prêt = Vert
  - Terminé = Gris

#### **⚠️ Alertes**
- [ ] **Stock faible** et **commandes en attente**
- [ ] **Message positif** si aucune alerte

---

## ⚙️ **7. PARAMÈTRES SYSTÈME**

### Tests à effectuer :

#### **🏪 Informations restaurant**
- [ ] **Nom, adresse, téléphone, email**
- [ ] **Sauvegarde** et persistance des données

#### **🛒 Paramètres commandes**
- [ ] **Montant minimum** en F CFA
- [ ] **Temps préparation** en minutes
- [ ] **Switch commandes anonymes**

#### **🔔 Notifications**
- [ ] **Switch principal** active/désactive tout
- [ ] **Email et SMS** dépendants du switch principal
- [ ] **Grisé** si notifications désactivées

#### **🚚 Livraison**
- [ ] **Switch livraison** affiche/cache options
- [ ] **Frais livraison** en F CFA
- [ ] **Zone de livraison** multilignes

#### **🎨 Affichage**
- [ ] **Devise** personnalisable

#### **💾 Sauvegarde**
- [ ] **FAB vert** "Sauvegarder"
- [ ] **SnackBar** de confirmation
- [ ] **Rechargement** automatique après sauvegarde

---

## 📈 **8. RAPPORTS**

### Tests à effectuer :

#### **📅 Sélection période**
- [ ] **Bouton date** dans AppBar
- [ ] **DateRangePicker** français
- [ ] **Mise à jour** automatique après sélection

#### **📊 Types de rapports**
- [ ] **3 chips** : Ventes, Inventaire, Personnel
- [ ] **Changement** automatique de contenu

#### **💰 Rapport Ventes**
- [ ] **Résumé** : commandes, CA, valeur moyenne
- [ ] **Top plats** avec quantités
- [ ] **Ventes quotidiennes** avec dates formatées

#### **📦 Rapport Inventaire**
- [ ] **Résumé** : total, stock faible
- [ ] **Liste alertes** stock faible (rouge)
- [ ] **Inventaire par type** avec compteurs

#### **👥 Rapport Personnel**
- [ ] **Résumé** : total, actifs
- [ ] **Personnel par rôle** avec compteurs actifs

### Tests de rapports :
```
1. Changer période → Vérifier données mises à jour
2. Switcher entre types → Vérifier contenu change
3. Vérifier formatage monétaire correct
4. Tester avec données vides
```

---

## 🧪 **TESTS D'INTÉGRATION COMPLETS**

### Scénario 1 : Administration quotidienne
```
1. Connexion PIN admin (1234)
2. Dashboard → Vérifier alertes
3. Ingrédients → Traiter alertes stock faible
4. Menu → Mettre à jour disponibilités
5. Personnel → Vérifier statuts actifs
6. Paramètres → Sauvegarder configuration
```

### Scénario 2 : Analyse business
```
1. Statistiques → Analyser CA du jour
2. Rapports Ventes → Période semaine
3. Identifier top plats → Marquer populaires
4. Rapports Inventaire → Prévoir commandes
5. Export mental des KPIs
```

### Scénario 3 : Gestion crise
```
1. Dashboard → Identifier alertes critiques
2. Ingrédients → Stock urgent à 0
3. Menu → Désactiver plats concernés
4. Personnel → Activer équipe renfort
5. Notifications → Activer toutes alertes
```

---

## ✅ **CHECKLIST DE VALIDATION**

### Interface générale
- [ ] **Design moderne** et cohérent
- [ ] **Navigation fluide** entre écrans
- [ ] **Indicateurs de chargement** appropriés
- [ ] **Messages d'erreur** informatifs
- [ ] **Snackbars** de confirmation

### Fonctionnalité
- [ ] **CRUD complet** sur toutes entités
- [ ] **Filtres et recherche** fonctionnels  
- [ ] **Statistiques temps réel** correctes
- [ ] **Alertes** pertinentes et utiles
- [ ] **Sauvegarde** persistante

### Performance
- [ ] **Chargement rapide** < 3 secondes
- [ ] **Actualisation fluide** sans lag
- [ ] **Gestion d'erreur** réseau robuste
- [ ] **Pull-to-refresh** responsif

### UX/UI
- [ ] **Feedback visuel** sur actions
- [ ] **Confirmations** pour suppressions
- [ ] **Formatage** approprié (monnaie, dates)
- [ ] **Accessibilité** avec tooltips

---

## 🚀 **COMMANDES DE TEST**

### Lancement rapide
```bash
# Backend
python manage.py runserver

# Frontend  
cd bokkdej_front
flutter run
```

### Test de connectivité
```bash
# Vérifier API backend
curl -X POST http://localhost:8000/api/auth/pin-login/ \
  -H "Content-Type: application/json" \
  -d '{"pin": "1234"}'
```

### Hot reload Flutter
```bash
# Dans terminal Flutter
r  # Hot reload
R  # Hot restart
q  # Quit
```

---

## 🎯 **RÉSULTATS ATTENDUS**

**🎉 Interface administrateur complète et fonctionnelle avec :**

✅ **Dashboard moderne** avec statistiques temps réel  
✅ **Gestion menu** complète (CRUD + actions)  
✅ **Gestion stock** avec alertes intelligentes  
✅ **Gestion personnel** avec rôles et permissions  
✅ **Statistiques avancées** avec graphiques  
✅ **Paramètres complets** de configuration  
✅ **Rapports détaillés** sur 3 dimensions  
✅ **Navigation intuitive** et responsive  

**🚀 L'interface administrateur Flutter est maintenant prête pour la production !**