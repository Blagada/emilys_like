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

### Sessions récentes
- Nettoyage du code, extraction de `TableAssignmentService`
- Système de commande complet : phylactère par table (icône "..." puis commandes), timer basé sur la vitesse du groupe
- Renommage des dossiers en anglais, typage statique renforcé partout
- Séparation des responsabilités : `OrderComponent` (commandes/service) distinct de `TableComponent` (sièges/état)
- Cycle paiement + nettoyage + machine à états (1re passe) : file d'attente à la caisse (`PaymentQueueComponent`), `StaffComponent` (animations pilotées par état), machine à états clients complétée

### Session la plus récente — Montant du paiement + nettoyage anticipé + polish visuel
- **Nettoyage anticipé** : une table encore occupée (clients en attente de paiement) peut être nettoyée par le joueur ; si nettoyée en avance, elle redevient propre instantanément au départ des clients
- **Calcul du montant réel** : le prix des commandes s'accumule par table, le pourboire se calcule à la caisse (`tip_rate`, un vrai pourcentage plutôt qu'un multiplicateur), affiché en feedback au-dessus de la caisse
- **`OrderBubble` généralisée** : un seul composant de bulle (texte libre ou grille de commandes), réutilisé pour les tables, le `$` du représentant en file, et prêt pour les futures commandes au comptoir
- **Suivi des montants** : `daily_earnings` (total du jour) et `tip_fund` (cagnotte pour la déco, persiste entre les journées) — accumulés à chaque paiement, pas encore affichés à l'écran
- **Polish visuel** : animation de disparition (fade + shrink) sur les items retirés du tray, animation "pop" sur le feedback de montant à la caisse
- Fix ratio d'affichage en plein écran (`project.godot`)

---

## 🔧 En cours / prochaine étape

- **Affichage à l'écran** de `daily_earnings` et `tip_fund` (les variables sont prêtes côté `GameDataManager`, reste l'UI)

---

## 📋 À faire (basé sur les notes de conception)

### Boucle de jeu principale
- [ ] Affichage à l'écran des montants (`daily_earnings`, `tip_fund`) — **priorité actuelle**
- [ ] Clients qui partent si aucune table disponible / bon nombre de places
- [ ] Réinitialisation complète d'un groupe à une table (à revalider avec le flow de nettoyage anticipé)

### Comptoir
- [ ] Clarifier le comportement de `DELIVERING` (actuellement dérivé de `MOVING` + tray non vide plutôt qu'un état séparé)

### Rythme / difficulté
- [ ] Délai différent par type de client, incluant le parcours complet vers le paiement (patience — mis de côté pour le niveau 1 pour l'instant)
- [ ] Délai/minuterie de la journée : heures d'ouverture, resto ferme après le dernier client, plusieurs services (déjeuner/dîner/souper)
- [ ] Menu choisi par le joueur en début de journée

### Plus tard
- [ ] Écran de menu principal
- [ ] Paramètres du jeu (taille de police, choix de police)
- [ ] Feedback visuel quand une table ne peut pas être servie
- [ ] Vraies animations des personnages (actuellement placeholders `walk`/`idle` pour `food_prep`/`cleaning`/`delivering`)
- [ ] Score / objectifs de niveau
- [ ] Multi-niveaux avec layouts différents
- [ ] Joueur choisit lui-même les aliments de son resto par niveau
- [ ] Uniformiser tous les sprites d'aliments en 64x64

---

## 🏗️ Architecture

Le projet suit une approche **orientée composants** plutôt que l'héritage classique :
```
scenes/
├── components/     → Logique réutilisable (déplacement, interaction, tables, plateau)
├── entities/        → Objets du jeu (clients, aliments, personnel)
└── levels/           → Scènes de niveau
resources/           → Données (Resource) : types de clients, aliments, visuels
scripts/
├── globals/          → Autoloads (état partagé, ex: GameDataManager)
└── models/           → Enums et types partagés (GameEnums)
```

**Principe clé** : les entités (Customer, Player, Table) délèguent leur comportement à des composants indépendants (`MovementComponent`, `InteractionComponent`, `TableComponent`, `OrderComponent`, `StaffComponent`, `PaymentQueueComponent`...), ce qui permet de les réutiliser et de les tester séparément.

---

## ▶️ Lancer le projet

1. Ouvrir Godot 4.7 (ou plus récent)
2. Importer le projet via `project.godot`
3. Lancer la scène principale (`level_1.tscn`)

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

Pour les détails techniques, bugs corrigés et idées en vrac, voir `ROADMAP.md`.

---
