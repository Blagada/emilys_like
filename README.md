# Emily Like 🍽️

> Projet d'apprentissage Godot — un *time management game* de gestion de restaurant, inspiré du style *Emily's* / *Diner Dash*.

Le joueur incarne un membre du personnel qui doit accueillir les clients, les placer aux tables, préparer les plats et gérer un plateau de service, le tout en essayant de garder les clients satisfaits.

---

## 🎮 État actuel du projet

## ✅ Fait

### Fondations (avant nos sessions + tôt dans nos sessions)
- Sélectionner un élément interactif et s'y déplacer (`InteractionComponent`)
- Sélectionner un plat/objet et l'ajouter au plateau (clic → tray)
- Clients générés par groupes de 1, 2, 3 ou 4
- Clients assignés à une table libre avec assez de places (`TableAssignmentService`)
- Menu par niveau : les aliments disponibles au comptoir sont piochés au hasard dans une liste modifiable (`LevelMenu`)

### Session(s) récentes
- Nettoyage du code (variables/fonctions/signaux inutilisés, fichiers temporaires Godot)
- Extraction de la logique de sélection de table hors de `level_manager.gd` → `TableAssignmentService` (réutilisable pour plusieurs niveaux)
- Chaque client reçoit une commande aléatoire (`current_order`) une fois assis à table
- Service des clients : clic sur la table → si le plateau contient l'item demandé, il est retiré du plateau et retiré de la commande du client
- Service **individuel** par client (pas besoin d'avoir tout le groupe en même temps sur le plateau)
- Le joueur peut toujours se déplacer vers une table même s'il n'a rien à servir (meilleure UX, évite l'effet de bug)
- Renommage des états de table pour plus de clarté (`EN_ATTENTE_SERVICE`, `EN_REPAS`)
- Signal `all_orders_served` : quand tout le groupe est servi, tous les clients passent à `EATING` en même temps
- Centralisation de la logique clic + déplacement dans `InteractionComponent` (signal `player_arrived`), utilisé par les aliments, les tables, et le comptoir
- Fix de bugs importants :
  - `is_busy` qui restait bloqué à `true` (conflit entre `Interaction_component.gd` et le check redondant dans `player.gd`)
  - `is_busy` qui restait bloqué après un clic sur le comptoir (rien n'écoutait `player_arrived`)
- README du projet rédigé

---

## 🔧 En cours / prochaine étape discutée

- **Timer de commande basé sur la vitesse du client** : le délai avant qu'un client commande dépend de sa `speed`. Décision prise : le timer démarre seulement une **fois que tout le groupe est assis** (pas individuellement). Comme un groupe = toujours un seul type de client, tout le groupe commande, mange, et sera impatient **en même temps**.
  - *Statut : discussion entamée, aucun code écrit encore — à reprendre.*
— **bulle de dialogue au-dessus des clients** (icône de la commande, "..." pendant qu'ils réfléchissent). Actuellement l'info n'existe qu'en `print` — besoin de la valider visuellement en jeu.

---

## 📋 À faire (basé sur les notes de conception)

### Boucle de jeu principale
- [ ] Clients qui partent si aucune table disponible / bon nombre de places (actuellement ils ne gèrent pas ce refus)
- [ ] Paiement : faire payer les clients, incluant prix des commandes + pourboires dépendants du type de client
- [ ] Sortie des clients une fois payés (table redevient libre)
- [ ] Table sale → besoin d'être nettoyée avant de réassigner un nouveau groupe (`LIBRE_SALE`)

### Comptoir
- [ ] Logique du comptoir : faire passer les clients à la caisse
- [ ] File d'attente au comptoir
  - À réfléchir : probablement plusieurs `Marker2D` en ligne (position 1, 2, 3...) devant le comptoir, où chaque client en attente se place au marker libre le plus proche du comptoir. Quand le client en tête est servi/encaissé, tout le monde avance d'une position. Similaire dans l'esprit à `chair_positions` sur les tables.

### Rythme / difficulté
- [ ] Délai différent par type de client, incluant le parcours complet vers le paiement (patience — mis de côté pour le niveau 1 pour l'instant, à revoir plus tard)
- [ ] Délai/minuterie de la journée : heures d'ouverture définies pour le niveau (pas aléatoire), resto ferme une fois le dernier client sorti après l'heure de fermeture. Certains niveaux plus difficiles pourraient avoir plusieurs périodes d'ouverture (déjeuner, dîner, souper).
  - Menu choisi par le joueur en début de journée (par défaut, celui choisi la veille), avec une animation pour le changement d'aliments entre les services

### Plus tard
- [ ] Écran de menu (menu principal du jeu)
- [ ] Paramètres du jeu (ex: taille de police, choix de la police de caractère)
- [ ] Feedback visuel quand une table ne peut pas être servie (actuellement juste un `print`)
- [ ] Animations des personnages
- [ ] Score / objectifs de niveau
- [ ] Multi-niveaux avec layouts différents
- [ ] Joueur choisit lui-même les aliments de son resto par niveau (le système `LevelMenu` a été conçu pour rendre ça possible facilement)

---

## 🏗️ Architecture

Le projet suit une approche **orientée composants** plutôt que l'héritage classique :
scenes/
├── components/     → Logique réutilisable (déplacement, interaction, tables, plateau)
├── entities/        → Objets du jeu (clients, aliments, personnel)
└── levels/           → Scènes de niveau (pourrait changer en cours de route si plusieurs restaurant et plusieurs niveau  par restaurant)
ressources/           → Données (Resource) : types de clients, aliments, visuels
scripts/
├── globals/          → Autoloads (état partagé, ex: GameDataManager)
└── models/           → Enums et types partagés (GameEnums)

**Principe clé** : les entités (Customer, Player, Table) délèguent leur comportement à des composants indépendants (`MovementComponent`, `InteractionComponent`, `TableComponent`...), ce qui permet de les réutiliser et de les tester séparément.

---

## ▶️ Lancer le projet

1. Ouvrir Godot 4.7 (ou plus récent)
2. Importer le projet via `project.godot`
3. Lancer la scène principale (`level_1.tscn`)

---

## 📓 Journal d'apprentissage

*Objectifs de ce jeu*

- Apprendre à déplacer des CharacterBody2D d'un endroit à un autre au clic
- Créer des composantes réutilisables le plus possible pour ne pas dubliquer de code
- Utiliser les Ressources de Godot dès qu'il y a des paramètres ou spécificité (aliments, clients, restaurant, menu)
- Générer des groupes de clients qui vont se déplacer à une table libre
- Au clic, ajouter un aliment dans le tray, et le servir à table (supression du tray)
- Gestion des niveaux par restaurant : ajout d'une table, changement de menu, etc.
---
