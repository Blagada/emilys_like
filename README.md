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

### Session la plus récente — Cycle paiement + nettoyage + machine à états complète
- File d'attente à la caisse (`PaymentQueueComponent`) : les clients se placent aux markers devant le comptoir, le représentant du groupe se déplace et paie au clic du joueur sur la caisse
- Cycle client complet, de bout en bout : commande → service → manger → attente de paiement (bulle `$`) → file d'attente → sortie du restaurant
- Nettoyage de table : clic sur une table sale (`UNOCCUPIED_AND_DIRTY`) → le joueur nettoie (délai) → table redevient propre et réutilisable
- `StaffComponent` créé (réutilisable joueur + futur staff) : gère un état (`WAITING`, `MOVING`, `FOOD_PREP`, `DELIVERING`, `CLEANING`)
- Les animations du joueur sont maintenant pilotées par son état, plus par sa vélocité seule
- Machine à états des clients complétée : tous les moments (commande, manger, paiement) déclenchent maintenant le bon `CustomerState`, visible en temps réel dans l'onglet Distant
- Plusieurs bugs de navigation/timing corrigés (voir `ROADMAP.md` pour le détail technique)

---

## 🔧 En cours / prochaine étape

- **Paiement à la caisse** : calculer le montant dû selon le prix des aliments commandés à la table + le `tip_multiplier` du type de client. C'est la prochaine priorité.

---

## 📋 À faire (basé sur les notes de conception)

### Boucle de jeu principale
- [ ] Calcul du paiement (prix des commandes + pourboires selon type de client) — **priorité actuelle**
- [ ] Clients qui partent si aucune table disponible / bon nombre de places
- [ ] Réinitialisation complète d'un groupe à une table (à valider une fois le paiement en place)

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
