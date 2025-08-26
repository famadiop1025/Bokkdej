# Système de Polling Intelligent - Bokkdej

## Vue d'ensemble

Le système de polling intelligent a été conçu pour résoudre le problème de réinitialisation des données dans l'espace Restaurant. Il utilise une approche intelligente qui ne recharge les données que lorsque c'est nécessaire, évitant ainsi les rechargements inutiles et les réinitialisations.

## Problème résolu

**Avant :** Les commandes et le dashboard se réinitialisaient toutes les 10-30 secondes, causant une perte de contexte utilisateur et des expériences frustrantes.

**Après :** Le système détecte intelligemment les changements et ne met à jour l'interface que lorsque les données ont réellement changé.

## Composants du système

### 1. PollingConfig (`lib/services/polling_config.dart`)
- Gère la configuration centralisée des intervalles de polling
- Stocke les paramètres dans SharedPreferences
- Définit les intervalles minimaux et par défaut
- Permet d'activer/désactiver le polling globalement

### 2. PollingManager (`lib/services/polling_manager.dart`)
- Gère les timers de polling de manière centralisée
- Permet de mettre à jour dynamiquement les intervalles
- Évite les conflits entre différents composants
- Gère le cycle de vie des timers

### 3. PollingSettingsPage (`lib/polling_settings_page.dart`)
- Interface utilisateur pour configurer les paramètres de polling
- Permet d'ajuster les intervalles en temps réel
- Affiche des informations sur l'impact des paramètres

## Configuration par défaut

| Composant | Intervalle par défaut | Intervalle minimum |
|-----------|----------------------|-------------------|
| Dashboard | 60 secondes | 30 secondes |
| Commandes | 30 secondes | 15 secondes |
| Notifications | 45 secondes | 20 secondes |

## Fonctionnalités

### Polling intelligent
- **Détection de changements :** Compare les données actuelles avec les précédentes
- **Mise à jour conditionnelle :** Ne recharge que si nécessaire
- **Polling silencieux :** Les erreurs de polling n'affectent pas l'interface

### Configuration dynamique
- **Ajustement en temps réel :** Les changements prennent effet immédiatement
- **Persistance :** Les paramètres sont sauvegardés localement
- **Validation :** Respecte les intervalles minimaux pour éviter la surcharge

### Indicateurs visuels
- **Point vert "Live" :** Indique que les données sont mises à jour automatiquement
- **Intervalles affichés :** Montre la fréquence de mise à jour de chaque composant
- **Statut du polling :** Indique si le système est actif ou désactivé

## Utilisation

### Pour les développeurs

#### Enregistrer un composant pour le polling
```dart
@override
void initState() {
  super.initState();
  _loadData();
  _initializePolling();
}

Future<void> _initializePolling() async {
  final isEnabled = await PollingConfig.isPollingEnabled();
  if (isEnabled) {
    final interval = await PollingConfig.getDashboardInterval();
    _pollTimer = Timer.periodic(Duration(seconds: interval), (_) => _smartLoadData());
  }
}
```

#### Utiliser le PollingManager
```dart
// Enregistrer un timer
PollingManager().registerTimer('dashboard', _smartLoadData);

// Mettre à jour un timer
await PollingManager().updateTimer('dashboard');

// Arrêter un timer
PollingManager().stopTimer('dashboard');
```

### Pour les utilisateurs

1. **Accéder aux paramètres :** Cliquer sur l'icône ⚙️ dans le dashboard du restaurant
2. **Ajuster les intervalles :** Utiliser les sliders pour définir la fréquence souhaitée
3. **Activer/désactiver :** Utiliser le switch pour activer ou désactiver le polling
4. **Sauvegarder :** Cliquer sur "Sauvegarder" pour appliquer les changements
5. **Réinitialiser :** Utiliser "Valeurs par défaut" pour revenir aux paramètres d'origine

## Avantages

### Performance
- **Moins de requêtes réseau :** Évite les rechargements inutiles
- **Interface plus fluide :** Pas de "saut" des données
- **Économie de données :** Réduit la consommation réseau

### Expérience utilisateur
- **Contexte préservé :** Les données ne se réinitialisent plus
- **Feedback visuel :** Indicateurs clairs du statut de synchronisation
- **Contrôle utilisateur :** Possibilité d'ajuster les paramètres

### Maintenabilité
- **Configuration centralisée :** Facile à modifier et déboguer
- **Gestion des erreurs :** Polling silencieux en cas de problème
- **Extensibilité :** Facile d'ajouter de nouveaux composants

## Dépannage

### Le polling ne fonctionne pas
1. Vérifier que le polling est activé dans les paramètres
2. Vérifier la connexion réseau
3. Redémarrer l'application

### Les données ne se mettent pas à jour
1. Vérifier les intervalles dans les paramètres
2. Vérifier que les composants sont bien enregistrés
3. Vérifier les logs de console pour les erreurs

### Performance lente
1. Augmenter les intervalles de polling
2. Désactiver le polling si non nécessaire
3. Vérifier la charge du serveur

## Évolutions futures

- [ ] Polling basé sur les événements (WebSocket)
- [ ] Synchronisation intelligente selon l'activité utilisateur
- [ ] Métriques de performance du polling
- [ ] Configuration par restaurant
- [ ] Synchronisation entre appareils

## Support

Pour toute question ou problème avec le système de polling, consulter :
1. Les logs de console pour les erreurs
2. La page de paramètres pour la configuration
3. La documentation technique pour les développeurs

