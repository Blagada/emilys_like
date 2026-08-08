# Emily Like 🍽️

> Projet d'apprentissage Godot — un *time management game* de gestion de restaurant, inspiré du style *Emily's* / *Diner Dash*.

Le joueur incarne un membre du personnel qui doit préparer les plats, servir les commandes, nettoyer les tables et faire payer les clients pour atteindre un objectif par jour (normal ou expert).

Objectifs pour les niveaux : 
- 10 niveaux par restaurant
- 5 restautants

---

## 🏗️ Architecture

Le projet suit une approche **orientée composants** plutôt que l'héritage classique :
```
scenes/
├── components/      → Logique réutilisable (déplacement, interaction, tables, plateau)
├── entities/        → Objets du jeu (clients, aliments, personnel)
├── levels/          → Scènes de niveaux, par restaurants
└── UI/              → Scènes des contrôles (qui ne bougent pas à l'écran)
resources/           → Données (Resource) : clients, aliments, restaurants, menus, niveaux
scripts/
├── components/      → Composantes réutilisables dans n'importe quel scène
├── globals/         → Autoloads (état partagé, ex: GameDataManager)
└── models/          → Enums et types partagés (GameEnums)
```

**Principe clé** : les entités (Customer, Player, Table) délèguent leur comportement à des composants indépendants (`MovementComponent`, `InteractionComponent`, `TableComponent`, `OrderComponent`, `StaffComponent`, `PaymentQueueComponent`...), ce qui permet de les réutiliser et de les tester séparément.

---

## ▶️ Lancer le projet

1. Ouvrir Godot 4.7 (ou plus récent)
2. Importer le projet via `project.godot`
3. Lancer la scène principale (`resto_a-level_1.tscn`)
