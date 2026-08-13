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

### Session — Icône visuelle de patience + bug de connexions multiples découvert
- **`PatienceIndicatorComponent` visuel** : icône emoji (via `AtlasTexture`) ajoutée dans `OrderBubble.tscn`, en enfant de `OrderBubbleTexture` (pas de la racine `MarginContainer`, pour éviter l'étirement automatique des `Container`)
- **`order_bubble.gd`** : nouvelle méthode `set_patience_icon(state)` — cachée pour `HAPPY`, visible pour `IMPATIENT`/`ANGRY` (choix de design : bruit visuel seulement quand ça compte)
- **Branché sur les deux contextes** : bulle personnelle du client (`customer.gd`, comptoir/caisse) et bulle partagée de table (`order_component.gd`, représentée par `group[0]`)
- **Bug découvert — la patience repart à zéro entre les phases** : un client déjà impatient à table redevient "content" en arrivant en caisse, au lieu de garder son palier
- **Bug découvert — journée qui ne se termine plus** : `active_customer_count` reste bloqué (jamais `<= 0`) après qu'un client soit passé par 2 phases de patience (table → caisse) ; hypothèse : `patience_expired` accumule plusieurs connexions non nettoyées entre les `start()` successifs, causant un comportement dupliqué/bloquant à l'expiration

### Session — Debug du système de patience (2 bugs bloquants)
- **Bug résolu — connexions multiples sur `patience_expired`** : chaque `start()` empilait un nouvel écouteur sans jamais déconnecter l'ancien ; un client passant par 2 phases (table puis caisse) déclenchait plusieurs handlers en même temps. Fix : boucle sur `get_connections()` + `disconnect()` au début de `start()`
- **Bug résolu — journée qui ne se termine plus** : `_process_queue_sequentially()` (flow de paiement normal, pas juste l'expiration de patience) appelait `CustomerExitService.send_customer_to_exit()` directement au lieu du wrapper local `_send_customer_to_exit()` — donc `customer_exited` n'était jamais émis pour les clients assis non-représentants d'un groupe qui payait normalement. Bug préexistant depuis le refactor de `CustomerExitService`, révélé seulement en testant des journées complètes avec des groupes
- **`CustomerExitService.send_customer_to_exit()`** modifié pour accepter un `Callable` optionnel (`on_complete`) plutôt qu'être attendu (`await`) par l'appelant — un `await` imbriqué à travers une fonction statique, appelé en parallèle pour plusieurs clients d'un même groupe, perdait certaines reprises d'exécution
- **Palier persistant entre phases** : `start()` accepte maintenant un `starting_state` optionnel — un client déjà `IMPATIENT`/`ANGRY` repart au **début de son palier actuel** plutôt qu'à `HAPPY`/0%, que ce soit en passant de la table à la caisse, ou lors d'un service partiel (voir plus bas)
- **Patience gelée au clic sur la caisse** : `payment_queue_component.gd` écoute maintenant `action_queued` (émis immédiatement au clic, avant le déplacement du joueur) en plus de `player_arrived` — tous les clients déjà dans la file au moment du clic voient leur patience figée pour de bon, pour ne pas perdre un client à cause du temps de trajet du joueur
- **Service partiel de commande** : si seulement une partie des plats d'un groupe est servie, les clients encore en attente relancent leur patience au début de leur palier actuel (`order_component.gd`, dans `serve_food()`) — laisse une chance au joueur plutôt que de garder un timer qui tournait déjà pendant toute la préparation
- **Bug résolu — nettoyage des connexions mal placé** : le nettoyage de `patience_expired` (ajouté il y a 2 jours) était fait à l'intérieur de `start()`, ce qui supprimait aussi les connexions valides lors d'un simple redémarrage dans la même phase (ex: service partiel). Déplacé vers le seul appelant qui change réellement d'écouteur (`payment_queue_component.gd`, dans `enqueue()`), juste avant sa propre reconnexion

### Session — File d'attente pour tables + refonte du comptoir
- **`WaitingQueueComponent`** créé (même pattern que `PaymentQueueComponent`) : groupes sans table disponible spawnent quand même et le représentant attend visuellement à l'entrée, avec bulle "Groupe de X" (`Customer.show_group_size()`)
- **Signal `table_freed`** ajouté sur `TableComponent`, émis dans `_start_cleaning()` et `CustomerExitService.release_table()` — seul moyen fiable de savoir qu'une table redevient libre
- **Sélection "best fit"** : à la libération d'une table, la file est parcourue dans l'ordre d'arrivée pour trouver le premier groupe dont la taille convient à *cette* table précise
- **`OrderFlowComponent.seat_group()`** extrait de `_on_customer_group_spawned()` — logique d'assise réutilisable, appelée directement au spawn (table libre) ou depuis la file (table libérée plus tard)
- **`SpawnOrchestratorComponent`** ne filtre plus les tailles de groupe selon les tables disponibles ; spawn même sans table, sauf si la file d'attente est pleine (`has_capacity()`)
- **Hygiène des signaux appliquée dès la conception** : `patience_expired` du représentant en file est explicitement déconnecté avant l'assise, pour éviter d'empiler un handler par-dessus celui de la phase de commande (même bug que celui déjà corrigé côté caisse)
- **Bug résolu — comptoir jamais reconnu comme obstacle de navigation** : root cause identifiée — le comptoir visuel était instancié *au runtime* (`counter.gd`, `_ready()`), donc invisible au moment du bake statique de `ZoneDeplacement` (`source_geometry_mode = 1`, scan des `nav_obstacles` présents dans la scène éditée). Les tables fonctionnaient car leur collision est physiquement présente dans la scène
- **Refonte du comptoir en composant réutilisable** : `CounterComponent` créé (parité avec `TableComponent`) ; `counter.tscn` devient un gabarit de base, chaque comptoir de restaurant est une **scène héritée** (`New Inherited Scene`) ne redéfinissant que la géométrie physique (`CounterBody`) — `PaymentQueueComponent`/`CashRegister`/`CounterOrderComponent` restent hérités, sans duplication
- **Bake de `ZoneDeplacement`** : validé que c'est fonctionnel sur le comptoir resto A après la refonte
- **Attente d'une table** : pondération du spawn selon la composition réelle des tables (fix du "resto qui ne se remplit pas en début de partie")
- **Bug résolu** : bug de patience fantôme dans serve_food() (relance de patience sur des clients déjà servis) + le garde is_instance_valid() manquant dans _on_group_patience_expired

### Session — Stabilisation de la file d'attente : pondération, best fit, fermeture
- **Bug corrigé — patience fantôme après service partiel** : `serve_food()` relançait la patience de *tous* les `seated_customers`, y compris ceux déjà servis (`current_order == null`). Un client déjà parti (payé, sorti) pouvait donc faire ressurgir un timer expiré bien plus tard, appelant `_on_group_patience_expired` avec un `group` contenant des clients déjà libérés → crash. Fix : filtrer sur `current_order != null` avant de relancer la patience
- **Garde-fou ajouté** dans `_on_group_patience_expired` (`is_instance_valid(customer)` avant `_send_customer_away`), en cohérence avec le garde déjà présent sur `cancel()`
- **Pondération du spawn selon la composition réelle des tables** (`_pick_weighted_group_size`) pour éviter que plusieurs groupes de 4 d'affilée saturent la file pendant que les petites tables restent vides — résout le "resto qui ne se remplit pas en début de partie"
- **Régression détectée et corrigée** : cette pondération empêchait `group_size == 1` d'être tiré si le resto n'a pas de table pour 1 seule personne → plus aucun client au comptoir. Le tirage "client au comptoir" (`counter_order_probability_percent`) a été découplé du tirage de taille de groupe pour tables, testé indépendamment en premier
- **Recalibration** de `counter_order_probability_percent` (70 → ~18) suite au changement de sémantique : la valeur représente maintenant directement la probabilité réelle, plus une probabilité conditionnelle à `group_size == 1`
- **Vraie sélection "best fit"** dans `WaitingQueueComponent._on_table_freed()` : à la libération d'une table, on prend le plus grand groupe compatible en file (pas juste le premier compatible) — une table de 4 qui se libère sert d'abord un groupe de 4 en attente, même arrivé après un groupe de 2
- **Fermeture propre de la file d'attente** : `WaitingQueueComponent` écoute maintenant `day_cycle.closing_time` et vide la file (`_on_closing_time`), renvoyant tous les groupes encore en attente. Logique de désinscription de patience extraite dans `_detach_patience()`, réutilisée entre l'assignation de table et la fermeture — évite la duplication

### Session — Refactor architecture : séparation components/services
- **Nouvelle convention** : `scripts/services/` pour les classes statiques, séparé de `scripts/components/` (Node attachables)
- **`payment_queue_component.gd` (256 → allégé)** : extraction de `BonusService` (calcul pur des bonus, point d'entrée unique pour les futurs bonus économiques), `BillingService` (assemble bill/tip), `PaymentFeedbackDisplay` (`scenes/entities/Counter/`, gère le tween d'affichage du montant)
- **`order_component.gd` (127 → allégé)** : extraction de `OrderBubbleComponent`, vit en nœud enfant à côté de `OrderBubbleAnchor` ; `OrderComponent` garde des méthodes déléguées minces pour ne pas casser les appels externes
- **Bug résolu — bulle qui ne se cachait plus** : `show_orders()` vérifiait `orders == null` au lieu de `orders.is_empty()` (un `Array[FoodData]` vide n'est jamais `null`)
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
