# Roadmap — Emily Like 🍽️

Fichier de suivi complémentaire au README (idées, avancées détaillées, apprentissages).

---

## ✅ Fait

### Fondations (avant nos sessions + tôt)
- `InteractionComponent` : sélection + déplacement vers un élément interactif
- Clic sur un plat → ajout au tray
- Spawn de groupes de clients (1 à 4)
- Assignation de table libre via `TableAssignmentService`
- `LevelMenu` : aliments du comptoir piochés aléatoirement par niveau

### Sessions précédentes
- Nettoyage du code, extraction de `TableAssignmentService`
- Commande aléatoire + service individuel par client
- Centralisation clic + déplacement dans `InteractionComponent`
- Fix `is_busy` bloqué, renommage dossiers en anglais, typage statique renforcé
- **Système de commande** : phylactère par table (`OrderComponent`/`OrderBubble`), timer groupé, fix ratio images comptoir, fix race condition sur l'arrivée des clients
- **Cycle paiement + nettoyage + machine à états (1re passe)** : `PaymentQueueComponent` (file d'attente à la caisse), `StaffComponent` (états `WAITING`/`MOVING`/`FOOD_PREP`/`DELIVERING`/`CLEANING`, animations pilotées par état), machine à états clients complète (`WAITING_TO_ORDER`→`ORDERING`→`EATING`→`WAITING_FOR_PAYMENT`/`PAYING`), fix navmesh (sortie clients), fix orientation `flip_h` à la sortie
- **Montant du paiement + nettoyage anticipé + bulle unifiée** : `is_dirty` sur `TableComponent`, `WAITING_FOR_CLEANING` (renommage), `OrderComponent.total_bill`, `OrderBubble` généralisée (`show_text`/`show_orders`), `tip_multiplier` → `tip_rate` (pourcentage réaliste), suivi `daily_earnings`/`tip_fund`, animations tray + feedback caisse, fix ratio plein écran

### Session d'aujourd'hui — Structure de niveau (Y-Sort) + ambiance lumineuse + file d'action + paiement séquentiel
- **Restructuration `level_1.tscn` pour le Y-Sort** : nouveau nœud `Entities` (`Y Sort Enabled`) regroupant tables/comptoir/nourriture/joueur/clients pour un tri de profondeur correct (avant : joueur et clients toujours dessinés par-dessus, peu importe leur position réelle, car branches séparées de l'arbre)
- **`SpawnComponent`** : `spawn_parent` ajouté, clients désormais positionnés explicitement via `spawn_point.global_position` plutôt que de compter sur l'héritage de transform du parent (bug découvert en déplaçant le spawner sous `Entities`)
- **`NavigationRegion2D` basé sur un groupe** (`Source Geometry Mode = Group Explicit`, groupe `nav_obstacles`) : permet aux tables/comptoir de vivre n'importe où dans l'arbre (Y-Sort) sans devoir être enfants directs de `ZoneDeplacement` pour être détectés au bake
- **Fix Y-Sort du comptoir** : décalage compensé (root du comptoir + enfants visuels en sens inverse) pour aligner le point de tri sur le bord avant, sans bouger le rendu — `Y Sort Origin` n'existe pas sur `Node2D` en Godot 4 (contrairement à `TileMap`), technique de compensation manuelle utilisée à la place
- **Documentation** : nouveau `level-structure.txt` (procédure Y-Sort + groupe de navigation, réutilisable pour les prochains niveaux)
- **Tests d'ambiance lumineuse** (exploratoire, hors MVP) : `CanvasModulate` + `PointLight2D` + `LightOccluder2D`, halo de lumière fonctionnel à la fenêtre, prêt pour l'animation jour/nuit plus tard
- **`ActionQueueComponent`** (nouveau, sur le joueur) : refonte majeure — remplace `is_busy` par une vraie file FIFO d'actions (déplacement + tâche), traitées une à la fois automatiquement. `Interaction_component.gd` empile désormais une action au clic au lieu de bloquer en attendant ; chaque écouteur de `player_arrived` doit appeler `interaction_component.complete_action()` en fin de tâche (nouveau contrat à respecter partout)
- **Paiement groupé séquentiel** : `PaymentQueueComponent` traite maintenant tous les clients déjà arrivés en file un par un (inventaire figé avant traitement, pas de ré-évaluation en cours de boucle), avec montant réel affiché dans la bulle du représentant (`show_bill_amount`) et bonus combo additif plafonné (`combo_bonus_per_extra_table`, `max_combo_bonus_percent`)
- **Bugs corrigés** :
  - File d'action bloquée en permanence après un clic sur la caisse : `payment_queue_component.gd` n'appelait pas encore `complete_action()` (contrat manqué lors du premier refactor)
  - Paiement groupé : un seul client traité par clic — la boucle vérifiait l'arrivée d'un client qui venait juste d'être mis en mouvement par le tour précédent (cible mouvante) ; fix en figeant la liste à traiter avant tout déplacement
  - Montant du représentant jamais visible : sa bulle était détruite la même frame par `change_state(MOVING)` déclenché immédiatement après le paiement ; fix en le sortant du groupe et en lui laissant un court délai d'affichage avant son propre départ
- **Étape 2 de la file d'action — placeholders + annulation + limite de capacité** :
  - `GameDataManager.pending_items` (registre central des préparations en attente/en cours, avec `action_id` unique)
  - `Interaction_component.gd` : nouveau signal `action_queued` (émis au clic, avant même le déplacement) en plus de `player_arrived`
  - `ActionQueueComponent.cancel()` : annulation possible tant que l'action n'a pas "démarré" (`started = false`, distingue "en route" de "tâche réellement commencée")
  - `tray_component.gd` : items en attente affichés en semi-transparent, clic dessus tente une annulation (retire immédiatement si pas encore commencé, sinon marque pour suppression automatique une fois la préparation terminée)
  - **Limite de capacité du tray sur la file** : point d'extension optionnel (`Interactable.can_interact: Callable`) branché uniquement par `aliments.gd`, sans toucher au comportement générique des tables/caisse — bloque le clic si `tray_items + pending_items >= current_max_capacity`
  - **Bugs corrigés** :
	- File bloquée en permanence si le même aliment est cliqué 2 fois rapidement (avant la fin de la 1re préparation) : `_current_action_id` était une seule variable partagée sur l'`Interactable`, écrasée par le 2e clic pendant que la 1re action tournait encore, causant un mismatch d'id à la complétion. Fix : id transmis en paramètre à travers toute la chaîne d'appels plutôt que stocké dans une variable partagée
	- File bloquée si le même item est cliqué 2 fois **lentement** (cible identique) : `NavigationAgent2D` ne réémet pas toujours `navigation_finished` quand la nouvelle cible est identique à la précédente déjà atteinte (comportement documenté comme capricieux côté Godot). Fix : vérification de distance réelle (`global_position.distance_to`) avant d'attendre le signal, court-circuite l'attente si déjà sur place

---

## 🔧 En cours

- Affichage à l'écran de `daily_earnings` et `tip_fund` (variables prêtes, UI à faire)

---

## 📋 À faire

### Boucle de jeu principale
- [ ] Clients qui partent si aucune table disponible
- [ ] Réinitialisation complète d'un groupe à une table (à revalider avec le flow `is_dirty`)

### Comptoir
- [ ] `DELIVERING` : dérivé de `MOVING` + tray non vide (option retenue, en place)

### Rythme / difficulté
- [ ] Délai différent par type de client (patience) — mis de côté
- [ ] Heures d'ouverture / fermeture, plusieurs services
- [ ] Choix du menu par le joueur en début de journée

### Assets
- [ ] Uniformiser tous les sprites d'aliments en 64x64
- [ ] Créer les vraies animations `food_prep`, `cleaning`, `delivering` (actuellement `walk`/`idle` en placeholder avec TODO)

### Plus tard
- [ ] Écran de menu principal, paramètres du jeu
- [ ] Feedback visuel table non-servable
- [ ] Animations des personnages (dont animation d'assise, liée à `sitting_animation_delay`)
- [ ] Score / objectifs de niveau
- [ ] Multi-niveaux, layouts différents

---

## 🗺️ Priorisation des nouvelles idées

### Tier 1 — court terme, extensions directes du cycle actuel (MVP)
- [x] Point d'exclamation dans la bulle quand la table est sale (`WAITING_FOR_CLEANING` / dès le départ du représentant)
- [x] `$` déplacé sur la tête du représentant dans la file (plus sur la table)
- [x] Affichage du montant payé + tip au-dessus de la caisse après paiement
- [x] Feedback visuel : animation fade + shrink sur un item du tray après une action réussie
- [x] **Liste d'action en attente pour le joueur** (`ActionQueueComponent`) — complète : placeholders semi-transparents, annulation, limite de capacité du tray

### Tier 2 — moyen terme, nouvelles mécaniques mais toujours cœur du gameplay
- [ ] Groupes de 1 client : chance aléatoire de commander directement au comptoir plutôt qu'à table (probabilité élevée comptoir / faible à table) — `OrderBubble` déjà prête pour ça (`show_orders` multi-items)
- [ ] Boîte de pourboires séparée (argent dédié à la déco) — fondation du système d'économie, `total_bill`/tip déjà calculés, reste à router vers une réserve dédiée

### Tier 3 — long terme, hors boucle de gameplay de base
- [ ] Interface de décoration : achat + placement à position prédéfinie dans le resto
- [ ] Décorations d'abord esthétiques seulement, bonus de gameplay ensuite
- [ ] Interface de menu de début de jeu (nouvelle partie / continuer)
- [ ] Interface de progression (restaurants → niveaux → journées, ex: 10 jours par niveau)
- [ ] Sauvegarde automatique en fin de journée : niveau/journée atteint, argent déco, décos débloquées, dernier menu d'aliments utilisé
- [ ] **Ambiance lumineuse dynamique** : lumière de fenêtre qui bouge/change de couleur selon l'heure de la journée (lié à `day_progress`, même logique que la jauge de revenus), + lumières d'ambiance sur les tables. Outils Godot identifiés : `CanvasModulate` (assombrissement global), `PointLight2D`/`DirectionalLight2D` (sources), `LightOccluder2D` (ombres portées sur meubles/murs). Attention pixel art : mettre le filtre d'ombre à `None (Fast)` sur chaque lumière pour garder des bords nets
- [ ] **Particules dans l'air** (poussière/ambiance) — objectif d'apprentissage explicite, inspiration Pinterest fournie par Émily (https://pin.it/7eheeGTj8)

---

## 💡 Idées / notes en vrac
- Bulle de commande : taille fixe (Top Left + Size explicite) plutôt que Full Rect sur le nœud racine
- `bubble_offset` par table (`@export` sur `OrderComponent`) pour ajuster manuellement sans coder
- **Paiement groupé à la caisse** : faire payer toute la file d'un coup, possibilité de bonus (multiplicateur de pourboire ? gain de temps ?) — à trancher
- `is_busy` chevauche de plus en plus `current_state`/`StaffComponent` — fusion à réévaluer quand la file d'attente d'action du joueur/staff sera construite (pas avant, pour éviter de refaire le travail deux fois)
- À vérifier : `PaymentQueueComponent` semble instancié par erreur dans `Curtomer.tscn` (scène client) en plus de `counter.tscn` — probablement accidentel, à retirer si confirmé
- `is_dirty` sur `TableComponent` : pattern à retenir — un booléen interne minimal peut remplacer un état d'enum supplémentaire quand l'info n'a besoin d'être consultée qu'à 1-2 endroits précis du code

## 📓 Apprentissages
- `TextureRect.expand_mode` vs `TextureButton.ignore_texture_size` : comportements différents
- Toujours vérifier l'état actuel avant d'attendre un signal (race condition classique)
- Un signal ne devrait avoir qu'un seul "consommateur" logique par usage
- **`NavigationAgent2D` + `agent_radius`** : le radius érode uniformément tous les bords du `NavigationPolygon` — dessiner le contour extérieur plus grand que la pièce visuelle pour compenser
- Un agent de navigation visant une cible hors du navmesh s'arrête au bord le plus proche et considère le trajet "terminé" sans erreur — bug silencieux à surveiller
- Toujours faire propager la vraie position cible dans les fonctions génériques de déplacement plutôt qu'une valeur par défaut qui peut sembler fonctionner par coïncidence dans un seul sens
- Avant d'ajouter un état d'enum, se demander si l'info a vraiment besoin d'être *nommée et publique*, ou si un simple booléen interne suffit à répondre à la question posée à 1-2 endroits précis
- `project.godot` → `Display/Window/Stretch` : `mode="canvas_items"` + `aspect="keep"` pour garder le ratio en plein écran sans révéler de zone hors-champ
- **Y-Sort** : ne fonctionne qu'entre enfants directs d'un même parent avec `Y Sort Enabled` — des nœuds dans des branches différentes de l'arbre ne se trient jamais entre eux, peu importe leur position à l'écran
- L'aperçu du `NavigationPolygon` en mode édition ne reflète PAS l'érosion par `agent_radius` — celle-ci n'est visible qu'au bake, en jeu, via `Debug > Visible Navigation`. Toujours juger la position des markers par rapport au résultat en jeu, jamais par rapport à l'éditeur
- `Y Sort Origin` n'existe pas sur `Node2D`/`CanvasItem` en Godot 4 (contrairement à `TileMap`) — pour décaler un point de tri sans bouger le rendu, il faut compenser manuellement (décaler le nœud racine + ses enfants visuels en sens inverse)
- **Contrat de "fermeture de boucle" dans un système asynchrone (file d'action)** : si plusieurs scripts consomment le même signal (`player_arrived`), chacun doit explicitement signaler la fin de son travail (`complete_action()`), sinon le système reste bloqué en pensant qu'une tâche est encore active. Un seul endroit oublié = blocage silencieux et difficile à tracer sans comprendre le contrat
- Dans une boucle qui traite une file en la modifiant progressivement (ex: faire avancer des clients), toujours figer l'inventaire de ce qu'il faut traiter **avant** de commencer à bouger quoi que ce soit — sinon la condition de sortie de la boucle peut évaluer un élément qu'on vient tout juste de perturber (cible mouvante)
- Une variable "id de l'action courante" stockée sur un nœud **réutilisé** (comme un `Interactable` cliqué plusieurs fois) est fragile : un 2e clic peut l'écraser pendant que la 1re action est encore active. Préférer transmettre l'id en paramètre à travers toute la chaîne d'appels plutôt que de le stocker dans une variable partagée
- `NavigationAgent2D` peut ne pas réémettre `navigation_finished` si la nouvelle cible est identique à la précédente déjà atteinte — comportement interne capricieux, pas un bug de notre code. Se fier à une vérification de distance réelle (`global_position.distance_to`) est plus robuste que de dépendre du signal dans ce cas précis
- Pour ajouter une restriction spécifique à un seul type d'usage d'un composant générique et réutilisé (ex: limiter seulement les aliments, pas les tables/caisse), un point d'extension optionnel (`Callable` vide par défaut, vérifié seulement si branché) évite de complexifier le composant générique pour tout le monde
