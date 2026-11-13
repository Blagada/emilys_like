# TODO — Emily Like

Liste des tâches restantes, dans un ordre suggéré. Le détail technique de ce qui est déjà fait est dans `ROADMAP.md`.

---

## Prochaines tâches (aucune dépendance bloquante)

- [ ] Rendre la cloche du comptoir plus évidente visuellement (pas assez clair que c'est là qu'il faut servir) -> idée de mettre la bulle avec les commandes au dessus de la cloche et mettre une icône pour emporter dans la bulle du client. Pourrait être le départ des commandes par livraison (multiplicateur supérieur).
- [x] Ajustement du positionnement du joueur devant les comptoirs en L ou en U (séparation `FoodMarker` / `InteractionPoint`)
- [x] Rapatriement de la configuration de jeu dans les ressources `LevelData` et `RestaurantData` (source unique de vérité)

## Décision à prendre avant de continuer l'économie

- [ ] Trancher le modèle de récompense de décoration (3 pistes déjà proposées dans la roadmap)
  → bloque : la boîte de pourboires séparée, et toute l'interface de décoration plus tard

## Comptoir et commandes

- [ ] Servir plusieurs clients de comptoir à la fois (actuellement un seul via la cloche)
- [ ] Idée exploratoire : commandes en ligne (reçues à la caisse/cloche, livreur qui entre/sort) — pas encore de plan technique
- [ ] Créer un 2e/3e restaurant avec `RestaurantEntities.tscn`/`RestaurantDecor.tscn` pour valider le système de scènes réutilisables
- [x] Les aliments dans la resource Menu du niveau se positionne automatiquement dans les zones de nourriture du comptoir (marker de position)
- [x] Assigner des zones d'aliments avec des types (ex: si c'est un aliment de type four, ne peux pas être placé n'importe où sur le comptoir)
- [ ] Menu choisi par le joueur en début de journée (dépend du joueur choisissant lui-même les aliments de son resto par niveau) -> mécanique de débloquage des aliments
- [ ] Restrictions de commande par type de client et par emplacement (ex : pouf sans table = boissons seulement, enfants = pas de café) — à faire **avant** les mécaniques de préparation avancées
  Première étape : aliment vs client
  - [x] `FoodData` : ajouter un type de préparation (enum : `DRINK`, `PREPARED`, `OVEN`...) et des tags (ex : `caffeinated`)
  - [x] `CustomerVisual` : Ajouter les tags de restriction ou requis
  - [x] Ajouter les tags de requis et supprimer les aliments avec tags de restrictions
  - [ ] Gérer le cas qu'aucun repas du menu ne correspond : valider si des gens à la table peuvent manger, et changer le comportement.
  Deuxième temps : aliment vs table, et table avec aliment allow + client
  - [x] Emplacements : `allowed_food_types` dans `TableData` (tables) et `CounterData` (comptoir)
  - [ ] Service statique de filtre (même pattern que `TableAssignmentService`) : commandes possibles = menu du niveau ∩ `allowed_food_types` de l'emplacement ∩ tags du `CustomerVisual` de la personne
  - [ ] Brancher le filtre dans `OrderFlowComponent` et `CounterOrderFlowComponent` (le comptoir lit `CounterData` : lui donner son propre `data`, le même `.tres` que `CounterOrderComponent`)
  - [ ] Garde-fou à l'assignation : vérifier que **chaque membre** du groupe peut commander quelque chose à cette table

## Mécaniques de préparation avancées (nourriture)

Prérequis : restrictions de commande (section "Comptoir et commandes") pour stabiliser le choix de commande avant d'y ajouter four et combos.

Ordre suggéré : four → combo → plaque de cuisson → four à pizza (le dernier combine les deux patterns précédents)

- [x] Associer un récipient hors de l'image de l'aliment  (`FoodContainerData`, ressource faite ; reste l'affichage en couches sur le comptoir)
- [ ] Afficher le récipient sous l'image de l'aliment au comptoir (`food_offset`)
- [ ] `CookingSlot` : emplacement d'appareil de cuisson (poêle, four, plaque), `accepted_types`, `interaction_point`, état libre/occupé, jamais rempli au démarrage ; plusieurs slots = plusieurs cuissons en parallèle
- [ ] `can_interact` : tenir compte d'un `CookingSlot` libre (comme `_has_tray_space`)
- [ ] Four (OVEN) : délai de cuisson (clic pour lancer, clic pour sortir), aliments brûlés si trop long. l'emplacement de cuisson peut être attribué a plusieurs aliments
- [ ] Plaque de cuisson (GRIDDLE) : (clic pour lancer la cuisson, clic pour arrêter la cuisson) avec délai sinon peut bruler
- [ ] Combo (ex : pain + fromage/saucisson) : clic sur 1er ingrédient affiche un "+" transparent dans le tray, clic sur le 2e ingrédient valide confirme, clic ailleurs annule
- [ ] Mijoté (SIMMER) : délai avant qu'il faille brasser, sinon état raté qui bloque les aliments adjacents
- [ ] Mijoté (`SIMMER`) : "!" au-dessus du chaudron après un intervalle ; non brassé = débordement + temps de nettoyage (champ à ajouter à `PreparationData` le moment venu)
- [ ] Sauté (SAUTE) : délai de préparation + délai de temps de cuisson (joueur reste devant la poêle)
- [ ] Un clic sur l'aliment pour `SAUTE` : préparation, déplacement vers le `CookingSlot`, cuisson, tray (une seule action dans la file, le joueur reste occupé)
- [ ] Four à pizza (PIZZA_OVEN) : combine four + combo (combo d'aliments avant de lancer la cuisson)
- [ ] Boisson (DRINK) : similaire à PREPARED mais avec restriction d'emplacement (besoin d'une machine)

## Ambiance

- [ ] Particules dans l’air : décision à prendre, activation par niveau ou par service (par ex. déjeuner), non liées à la météo (la pluie et la neige passent par overlay_scene)
- [ ] Sons pour les animations (préparation, pas, manger), cloche pour l'entrée des clients, fin de journée
- [ ] Musique/son d'ambiance à créer et a lié à la température (pluie, oiseau, vent...)


### Météo réelle
- [x] Créer `WeatherComponent` (autoload, scène) avec `current_weather` et le signal `weather_changed`
- [x] Requête au lancement du jeu via WeatherAPI.com (une seule requête, géolocalisation par IP incluse) avec `HTTPRequest`
- [x] Enum `WeatherState` (`CLEAR`, `CLOUDY`, `RAIN`, `SNOW`, `FOG`) + 5 ressources `WeatherData` avec leurs `api_codes` (60 codes)
- [x] Échec (pas d'internet, timeout, `result` ≠ `RESULT_SUCCESS`, code ≠ 200, JSON invalide) : garder le soleil par défaut, sans planter *(quota dépassé = même cas)*
- [ ] Ajouter `timeout` court au `HTTPRequest`
- [ ] Réglage « Météo réelle » (on/off) dans les paramètres : off = aucune requête
- [ ] Brancher la météo :
	- [ ] Fond de fenêtre `RestaurantData.window_backgrounds` + couche `overlay_scene` (pluie, neige) selon la météo
	- [x] Lumière : `light_color` / `light_energy` sur la source de lumière (`DirectionalLight2D` ou `CanvasModulate`) ; `LightOccluder2D` sert à bloquer la lumière, pas à la colorer
	- [ ] Ambiance sonore (pluie, vent, oiseaux) -> préalable d'avoir la musique/son dans le jeu
- [ ] Transition progressive (`Tween`) vers la météo réelle pendant la journée, une seule transition par journée
- [ ] Éventuellement `STORM` (à la fin de l'enum) si la pluie ne suffit pas
- [ ] Idée : vêtements des clients selon la météo (manteau, parapluie, etc.) via `WeatherData` ; dépend des assets de clients et de l'animation des personnages


### Saisons et événements

- [ ] `SeasonData` (Resource) : props de décor, palette, musique (structure à définir dans une conversation dédiée aux ressources)
- [ ] Couche `SeasonDecor` superposable à n'importe quel resto (pas de saison fixe par resto). Prévoir par contre que les éléments de déco s'installe dans chacun des restos.
- [ ] Sélecteur dans les paramètres de saison et événement : Auto / Printemps / Été / Automne / Halloween / Hiver / Noël / Aucune (voir si on les sépare? Mais est-ce qu'on pourrait avoir halloween en été? Noel en automne? Pas sur)
- [ ] Préparer le mode « Auto » :
	- [ ] Saison selon la date réelle
	- [ ] Plus tard : événements seulement autour des fêtes
- [ ] Plus tard : décors saisonniers comme items débloquables dans l'interface de décoration


## Économie

- [ ] Boîte de pourboires séparée (dédiée à la déco) — *dépend de la décision sur le modèle de récompense, voir plus haut*
	- [ ] Si la journée n'est pas complété, le pouboire est perdu.
- [ ] Système de bonus lorsque le service à la table est complété en 1 fois (perdu si complété en plusieurs services)
- [ ] Si plusieurs tables servies en 1 déplacement (pas de préparation entre-temps), bonus combo
- [ ] Pourboires différents dépendant de l'état de patience du groupe de client (aucun pourboire si angry)
- [ ] Plus qu'un aliment par client au comptoir (entre 1 et 2)
- [x] Réglages de bonus (combo, un seul voyage) et délai d'avance de la file déplacés dans `LevelData`
- [ ] Rendre les injections de `LevelManager` vers `SpawnOrchestratorComponent`, `DayCycleComponent` et `OrderFlowComponent` conformes au même modèle que `PaymentQueueComponent` (donner `level_data` ou `restaurant_data`, plutôt que copier les valeurs une par une)
- [ ] Recalculer `DailyGoalHelper` sans dépendre du menu choisi (ni prix ni durée de préparation, ou alors une moyenne fixe). Sinon le joueur ne peut pas choisir des aliments chers pour se faciliter la journée.

## UI

- [ ] Écran de menu principal
- [ ] Carnet (page 1) : vue d'ensemble menu + objectif + clients attendus (requis / restrictions)
- [ ] Menu de jeu (réglages dont langue, recommencer, abandonner), accessible au début de journée et en jeu ; « Retour au menu principal » après l'écran de menu principal
- [ ] Mode visite (navigation tables/aliments, seul le bouton Jouer reste) ; zone d'aide affichant le tooltip au focus clavier
- [ ] Trouver un rendu vintage qui donne de la profondeur au écran UI.
  - [ ] Look « dithering / palette limitée » pour l'UI seulement : définir la palette + police pixel dans un `Theme`, puis écrire un shader `canvas_item` (réduction de palette + seuil de Bayer) et le tester sur `OrderBubble`. Si concluent, on met partout!
- [ ] Feedback visuel quand une table ne peut pas être servie (ex : secousse)
- [ ] Ajouter version du jeu. Présentement 0.0.0, mais comme on a presque un MVP, je pourrais augmenter la version après ce qui vient après.
- [ ] Relocaliser les libellés dans un fichier séparé pour permettre la traduction.
- [x] Barre de début et fin de niveau (au bas de  l'écran) `LevelBar` : signal `primary_pressed` fonctionnel (Start et End)
- [ ] Page de crédit. Y mettre `WeatherAPI` dans les crédits du jeu si les conditions l'exigent (pas exigé)

## Accessibilité

- [ ] Paramètres du jeu (taille de police, choix de police)
- [ ] Ajouter des actions clavier dans l'`InputMap` pour tout ce qui se fait au clic : prévoir des raccourcis clavier pour se déplacer entre tables/aliment/caisse (tab et assignation de numéro par groupe. Ex: 1 = table, 2 = aliment, 3 = caisse) et un raccourci pour naviguer à même chaque groupe (flèche). Enter ou space pour activer l'action. 
- [ ] Préparer un mode visite au début de la journée pour que la personne puisse explorer le restaurant sans qu'il ne soit ouvert pour la journée. (Option toujours disponible mais pourrait être actif auto si lecteur d'écran activé)
- [ ] Créer un `AccessibilityAnnouncer` (service qui dit un texte via le lecteur d'écran, `tts_speak` en repli) et brancher les annonces sur les signaux existants (patience, table libérée, commande prête)
- [ ] Vérifier dans la doc de ma version de Godot ce qu'AccessKit supporte, et activer l'option dans les paramètres du projet
- [ ] Rendre le focus visible dans l'UI (thème) et remplir les noms accessibles des icônes sans texte
- [ ] Champs **Accessibility > Name** sur les contrôles sans libellé visible (icônes, flèches du swap, X du catalogue) ; vérifier s'ils sont traduits automatiquement


## Assets (indépendant, travail de contenu)

- [ ] Uniformiser tous les sprites d'aliments en 64x64
- [ ] Renforcer visuellement le contour des aliments dans les assets (après uniformisation 64x64)
- [ ] Créer les vraies animations `food_prep`, `cleaning`, `delivering` (actuellement `walk`/`idle` en placeholder)
- [ ] Créer les appareils ménagers : four, plaque de cuisson, planche à découper, panier, machine pour drink
- [ ] Créer de nouveaux plats
- [ ] Créer de nouveaux clients
- [ ] Raffiner les informations dans les bulles : table sale (!), mood (bonhomme), pour emporter (boîte nourriture chinoise?), prêt à payer ($), en réflexion (...), icône de combo pour les repas avec plusieurs igrédients (un + finalement)
- [ ] Créer des nouvelles fournitures de restaurant (pour au moins 5 restos)
- [ ] Créer de la décoration pour personnaliser les restos. La déco devrait se transformer selon la saison si nécessaire + ajout déco événement comme halloween et noel.

## Sauvegarde
- [ ] Sauvegarde automatique en fin de journée
	- [ ] Journée complétée -> MVP
	- [ ] Argent restant -> préalable de savoir comment gérer l'argent pour la déco
	- [ ] Personnalisations/Décorations débloquées et activé (sur perso ou dans resto) -> préalable achat de décoration/perso
	- [ ] Dernier menu choisi -> préalable choix de menu pour une journée/resto
	- [ ] Météo de fin de journée -> préalable intégration de la météo géoloc dans le jeu

## Traduction (fr / en)

- [x] `translations.csv`, `CurrencyService`, écran d'intro, fin de journée, bulles, feedback à la caisse
- [ ] Remplacer les textes de `GameEnums.SERVICE_TYPE_LABELS` et `CUSTOMER_TYPE_LABELS` par des clés (le `" et "` de `_join_with_and` disparaît avec le nouvel affichage des clients)
- [ ] Traduire le menu de l'écran d'intro (aliments : `FoodData.name` devient une clé) et les types de clients
- [ ] Bouton de changement de langue dans le menu de jeu (`TranslationServer.set_locale`) + sauvegarde du réglage
- [ ] Séparateur décimal selon la langue dans `CurrencyService` (virgule en français)
- [ ] Rechercher les textes restants en dur : Ctrl+Maj+F `.text = "` + Génération POT (Paramètres du projet > Localisation)

## Progression long terme — à faire dans cet ordre, chacune dépend de la précédente

- [ ] Décision sur le modèle de récompense de décoration (voir plus haut — prérequis)
- [ ] Interface de décoration (achat + placement)
- [ ] Interface de progression (restaurants → niveaux → journées)
- [ ] Interface de menu de début de parti : le joueur choisi quel menu sera servi (nouvelle partie / continuer)
- [ ] Animation des clients et du joueur. 2d en 3d avec squelette?

## Documentation (fiches mémo)

- [ ] Mettre à jour la fiche `FoodData` (nouveaux groupes, `PreparationData`, `FoodContainerData`, `tags`)
- [ ] Mettre à jour la fiche `CustomerData` (`tip_rate`, `thinking_time`, retrait de « Tip multiplier ») et `CustomerVisual` (`visual_scene`, restrictions de tags)
- [ ] Vérifier l'étape 4 de la fiche client (« Array Spawn Data list » du `SpawnComponent`), possiblement remplacée par `LevelData.possible_customers`
- [ ] Écrire les fiches `RestaurantData`, `LevelData`, `TableData`, `CounterData`, `WeatherData`
- [ ] Corriger la fiche `LevelMenu` (« Ajouer ») et `/stripts/models/` dans la fiche client
- [ ] Fiche mémo : traduction (CSV, clés, `tr()`, `CurrencyService`)
---

## Mis de côté volontairement (pas de date prévue)
- Multi-niveaux avec layouts différents — dépend d'avoir fini un premier niveau complet et joué
