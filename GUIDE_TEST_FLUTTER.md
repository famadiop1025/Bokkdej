# 🧪 Guide de Test Flutter - Application BOKDEJ

## 📋 Prérequis

### Serveurs en cours d'exécution
```bash
# Terminal 1 - Backend Django
cd BOKDEJ
python manage.py runserver

# Terminal 2 - Frontend Flutter
cd BOKDEJ/bokkdej_front
flutter run -d chrome --web-port=8081
```

### Utilisateurs de Test
- **Admin** : PIN `1234`
- **Staff** : PIN `5678`

---

## 🎯 Tests de Connexion

### 1. Test de l'API Backend
```bash
# Tester la connexion PIN
python test_pin_login.py

# Tester la connexion Flutter
python test_flutter_connection.py
```

### 2. Test de l'Interface Flutter

#### **Page de Connexion PIN**
1. **Ouvrir l'application** : http://localhost:8081
2. **Tester la connexion** :
   - Entrer le PIN `1234` (admin)
   - Vérifier que la connexion réussit
   - Vérifier que le token est sauvegardé
3. **Tester les erreurs** :
   - Entrer un PIN incorrect (ex: `9999`)
   - Vérifier que l'erreur s'affiche correctement

#### **Navigation après Connexion**
1. **Vérifier la redirection** :
   - Après connexion réussie, l'utilisateur doit être redirigé
   - Vérifier que le token est utilisé pour les requêtes API
2. **Tester la déconnexion** :
   - Vérifier que la déconnexion fonctionne
   - Vérifier que le token est supprimé

---

## 🧪 Tests Fonctionnels

### 1. **Gestion des Erreurs**
- [ ] **PIN incorrect** → Message d'erreur clair
- [ ] **Réseau indisponible** → Message d'erreur
- [ ] **API indisponible** → Gestion gracieuse
- [ ] **Token expiré** → Renouvellement automatique

### 2. **Interface Utilisateur**
- [ ] **Boutons de PIN** → Fonctionnent correctement
- [ ] **Affichage des erreurs** → Messages clairs
- [ ] **Indicateur de chargement** → Pendant la connexion
- [ ] **Validation des entrées** → PIN à 4 chiffres

### 3. **Sécurité**
- [ ] **Token JWT** → Généré et stocké correctement
- [ ] **Authentification** → Vérifiée sur chaque requête
- [ ] **Déconnexion** → Token supprimé proprement

---

## 🔧 Tests Techniques

### 1. **Requêtes API**
```dart
// Test de connexion PIN
POST http://localhost:8000/api/auth/pin-login/
{
  "pin": "1234"
}

// Réponse attendue
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 12,
    "username": "admin",
    "role": "client"
  }
}
```

### 2. **Gestion des Tokens**
- [ ] **Stockage sécurisé** → SharedPreferences
- [ ] **En-têtes d'autorisation** → Bearer token
- [ ] **Renouvellement** → Refresh token
- [ ] **Validation** → Token valide

### 3. **Gestion des Erreurs**
```dart
// Erreurs possibles
- 401 Unauthorized → Token invalide
- 400 Bad Request → Données manquantes
- 500 Internal Server Error → Erreur serveur
- Network Error → Pas de connexion
```

---

## 🐛 Debugging

### 1. **Logs de Debug**
```dart
// Dans auth_service.dart
print('Réponse API: $data');
print('Token reçu: $token');
print('Erreur: $e');
```

### 2. **Vérification des Données**
```dart
// Vérifier les données reçues
print('User data: ${data['user']}');
print('Token: ${data['access']}');
print('Role: ${data['user']['role']}');
```

### 3. **Test des Valeurs Null**
```dart
// Gestion sécurisée des valeurs null
final token = data['access'] ?? data['token'];
final userData = data['user'] ?? {};
final role = userData['role'] ?? 'client';
```

---

## 📱 Tests Spécifiques Flutter

### 1. **État de l'Application**
- [ ] **Provider Auth** → État cohérent
- [ ] **Token valide** → Stocké et accessible
- [ ] **Rôle utilisateur** → Correctement défini
- [ ] **Données utilisateur** → Complètes

### 2. **Navigation**
- [ ] **Redirection post-connexion** → Correcte
- [ ] **Stack de navigation** → Propre
- [ ] **Retour arrière** → Fonctionne
- [ ] **Paramètres** → Passés correctement

### 3. **UI/UX**
- [ ] **Responsive** → S'adapte à la taille
- [ ] **Animations** → Fluides
- [ ] **Feedback utilisateur** → SnackBar, etc.
- [ ] **Chargement** → Indicateurs visuels

---

## 🔍 Checklist de Validation

### ✅ Connexion
- [ ] Connexion PIN fonctionne
- [ ] Token JWT généré
- [ ] Données utilisateur récupérées
- [ ] Redirection après connexion
- [ ] Gestion des erreurs

### ✅ Sécurité
- [ ] Token stocké sécurisé
- [ ] Authentification vérifiée
- [ ] Déconnexion propre
- [ ] Protection contre les attaques

### ✅ Interface
- [ ] Design accessible
- [ ] Messages d'erreur clairs
- [ ] Indicateurs de chargement
- [ ] Navigation fluide

---

## 🚀 Démarrage Rapide

1. **Démarrer les serveurs** :
   ```bash
   # Terminal 1
   cd BOKDEJ
   python manage.py runserver
   
   # Terminal 2
   cd BOKDEJ/bokkdej_front
   flutter run -d chrome --web-port=8081
   ```

2. **Tester la connexion** :
   - Ouvrir http://localhost:8081
   - Entrer le PIN `1234`
   - Vérifier la connexion

3. **Tester les erreurs** :
   - Entrer un PIN incorrect
   - Vérifier les messages d'erreur

4. **Tester la navigation** :
   - Vérifier la redirection après connexion
   - Tester la déconnexion

---

## 📞 Support

En cas de problème :
1. Vérifier les logs Flutter (F12)
2. Vérifier les logs Django
3. Tester l'API directement
4. Vérifier la configuration réseau

**Application BOKDEJ - Tests Flutter** 📱 