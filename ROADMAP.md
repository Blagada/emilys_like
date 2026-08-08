# Emily Like 🍽️

> Projet d'apprentissage Godot — un *time management game* de gestion de restaurant, inspiré du style *Emily's* / *Diner Dash*.

Le joueur incarne un membre du personnel qui doit accueillir les clients, les placer aux tables, préparer les plats et gérer un plateau de service, le tout en essayant de garder les clients satisfaits.

> Pour l'architecture du projet et comment le lancer, voir `README.md`.
> Pour les tâches restantes, voir `TODO.md`.

---

## ✅ Fait

### Fondations (avant nos sessions + tôt dans nos sessions)
- Sélectionner un élément interactif et s'y déplacer (`InteractionComponent`)
- Sélectionner un plat/objet et l'ajouter au plateau (clic → tray)
- Clients générés par groupes de 1, 2, 3 ou 4
- Clients assignés à une table libre avec assez de places (`TableAssignmentService`)
- Menu par niveau : les aliments disponibles au comptoir sont piochés au hasard dans une liste modifiable (`LevelMenu`)

### Sessions récentes
- Nettoyage du code, extraction de `TableAssignmentService`
- Système de commande complet : phylactère par table (icône "..." puis commandes), timer basé sur la vitesse du groupe
- Renommage des dossiers en anglais, typage statique renforcé partout
- Séparation des responsabilités : `OrderComponent` (commandes/service) distinct de `TableComponent` (sièges/état)
- Cycle paiement + nettoyage + machine à états (1re passe) : file d'attente à la caisse (`PaymentQueueComponent`), `StaffComponent` (animations pilotées par état), machine à états clients complétée

### Session — Montant du paiement + nettoyage anticipé + polish visuel
- **Nettoyage anticipé** : une table encore occupée (clients en attente de paiement) peut être nettoyée par le joueur ; si nettoyée en avance, elle redevient propre instantanément au départ des clients
- **Calcul du montant réel** : le prix des commandes s'accumule par table, le pourboire se calcule à la caisse (`tip_rate`, un vrai pourcentage plutôt qu'un multiplicateur), affiché en feedback au-dessus de la caisse
- **`OrderBubble` généralisée** : un seul composant de bulle (texte libre ou grille de commandes), réutilisé pour les tables, le `$` du représentant en file, et prêt pour les futures commandes au comptoir
- **Suivi des montants** : `daily_earnings` (total du jour) et `tip_fund` (cagnotte pour la déco, persiste entre les journées)
- **Polish visuel** : animation de disparition (fade + shrink) sur les items retirés du tray, animation "pop" sur le feedback de montant à la caisse
- Fix ratio d'affichage en plein écran (`project.godot`)

### Session — Feedback visuel des interactions (hover + clic)
- **Curseur main au survol** : géré de façon centralisée dans `Interactable` (`interaction_component.gd`) via `mouse_entered`/`mouse_exited` → `Input.set_default_cursor_shape()`
- **`ClickFeedbackComponent`** (réutilisable) : `SCALE_PUNCH` (cloche) et `COLOR_FLASH` (aliments/table) — flash simple au survol, répété (x3) au clic confirmé
- **Contour noir au survol (shader) — tenté puis abandonné** : `hover_aliments.gdshader`, épaisseur incohérente selon la résolution des sprites → décision de renforcer le contour dans les assets plutôt que par shader
- **Bug résolu — `Local to Scene`** : `ShaderMaterial` partagé entre instances ; fix via `material.duplicate()` en `_ready()`
- **Bug résolu — ordre d'exécution `_ready()`** : fix via `call_deferred()` pour capturer les valeurs après tous les `_ready()` de la frame
- **Bug résolu — curseur qui ne s'affichait pas systématiquement** : `Area2D` d'aliments qui se chevauchaient ; fix par espacement dans la scène, aucun changement de code

### Session — Ménage de la boucle de jeu + validation des acquis
- **Affichage à l'écran** de `daily_earnings`/`tip_fund` : `earnings_gauge.tscn` + `tip_jar_display.tscn` déjà en place au HUD
- **Clients qui partent si aucune table disponible** : `_spawn_next_group()` vérifie la disponibilité avant même de faire apparaître un groupe — pas de spawn si aucune table valide
- **Réinitialisation complète d'une table** : validé, le nettoyage anticipé (pendant l'attente du paiement) fonctionne correctement, la table n'est libérée qu'après paiement
- **Score / objectifs de niveau** : `daily_goal_helper.gd` + `level_metrics_helper.gd` calculent automatiquement `daily_goal`/`expert_goal` selon le niveau, le menu, la vitesse des clients et les temps de déplacement réels mesurés via la navigation
- **`DELIVERING` clarifié** : l'état est bien déclenché au clic sur table/cloche (`start_task(DELIVERING, ...)` dans `table_component.gd`/`counter_order_component.gd`) — distinct de l'état "marche avec plateau en main" (`MOVING` + tray non-vide, dans `player.gd`), les deux pointent vers `walk` en placeholder pour l'instant
- **Délai par type de client** + **minuterie de journée** (services, heures d'ouverture) : validés, déjà en place
- **Patience** : création de la composante `CustomerExitService` ajouté à customer gestion de la sortie dans `payment_queue_component.gd`

### Session — Système de patience (service + caisse/comptoir)
- **`PatienceComponent`** créé : composant réutilisable, décompte générique avec paliers `HAPPY`/`IMPATIENT`/`ANGRY` (en %, seuils exportables), signaux `patience_expired` et `patience_state_changed`
- **`CustomerExitService`** créé (suivant le pattern statique de `TableAssignmentService`) : `release_table()` (libère sièges/commande, remet la table sale ou propre selon `is_dirty`) + `send_customer_to_exit()` (cache la bulle, sort le client, le libère de la scène) — réutilisé partout où un client doit sortir
- **Branché sur l'attente du service à table** (`order_flow_component.gd`) : patience démarrée à la prise de commande, annulée si servi à temps ; si expirée, le groupe entier quitte sans payer, table marquée sale
- **Branché sur la file de caisse/comptoir** (`payment_queue_component.gd`) : même file pour les clients de comptoir (`table == null`) et les représentants de groupe à table — patience démarrée à l'entrée dans la file, annulée une fois pris en charge à la caisse ; si expirée, malus voulu : perte du montant de la commande + table à nettoyer
- **`payment_queue_component.gd` refactoré** pour utiliser `CustomerExitService` au lieu de dupliquer la logique de sortie
- **Bug résolu — écran de fin de journée qui semblait ne plus s'afficher** : en fait un faux bug, le temps du service n'était simplement pas encore écoulé (`active_customer_count` fonctionnait correctement)
- **Bug résolu — collision visuelle à la caisse** : le client suivant dans la file avançait avant que le client en train de payer ait commencé à sortir ; fix en déplaçant l'appel à `_advance_queue()` juste avant la sortie du client payé plutôt qu'immédiatement après son retrait de la file — le combo de paiement groupé dépend de ce timing, ajusté à `0.9s` pour laisser le temps d'arriver
- Durée d'un service réduite de 4 à 3 minutes (`day_cycle_component.gd`, `service_duration`)

---

## 📓 Journal d'apprentissage

*Objectifs de ce jeu*

- Apprendre à déplacer des CharacterBody2D d'un endroit à un autre au clic
- Créer des composantes réutilisables le plus possible pour ne pas dupliquer de code
- Utiliser les Ressources de Godot dès qu'il y a des paramètres ou spécificité (aliments, clients, restaurant, menu)
- Générer des groupes de clients qui vont se déplacer à une table libre
- Au clic, ajouter un aliment dans le tray, et le servir à table (suppression du tray)
- Gestion des niveaux par restaurant : ajout d'une table, changement de menu, etc.
- Piloter les animations par une machine à états plutôt que par la vélocité seule

Pour les tâches restantes, voir `TODO.md`. Pour l'architecture, voir `README.md`.

---
