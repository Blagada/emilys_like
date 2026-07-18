# Emily Like 🍽️

> Projet d'apprentissage Godot — un *time management game* de gestion de restaurant, inspiré du style *Emily's* / *Diner Dash*.

Le joueur incarne un membre du personnel qui doit accueillir les clients, les placer aux tables, préparer les plats et gérer un plateau de service, le tout en essayant de garder les clients satisfaits.

---

## 🎮 État actuel du projet

**En développement actif.** Voici ce qui fonctionne aujourd'hui :

- ✅ Spawn de groupes de clients (1 à 4 personnes) avec types variés (normal, VIP, pressé, tranquille)
- ✅ Assignation automatique de table selon la taille du groupe et les places disponibles
- ✅ Déplacement du joueur et des clients via navigation (`NavigationAgent2D`)
- ✅ Système d'aliments cliquables → préparation → ajout au plateau de service
- ✅ Plateau de service avec capacité limitée et retrait d'items

**À venir :**
- ⬜ Prise de commande par les clients
- ⬜ Service des plats aux bonnes tables
- ⬜ Paiement et pourboires (le multiplicateur existe déjà dans les données clients)
- ⬜ Cycle complet table libre → sale → nettoyée
- ⬜ Plusieurs niveaux/restaurants avec layouts différents
- ⬜ Système de score / progression

---

## 🛠️ Stack technique

- **Moteur** : Godot 4.7
- **Langage** : GDScript
- **Rendu** : GL Compatibility (mobile-friendly)

---

## 🏗️ Architecture

Le projet suit une approche **orientée composants** plutôt que l'héritage classique :
scenes/
├── components/     → Logique réutilisable (déplacement, interaction, tables, plateau)
├── entities/        → Objets du jeu (clients, aliments, personnel)
└── levels/           → Scènes de niveau
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

*Section perso — notes sur les choix techniques et ce que j'apprends en cours de route.*

- **[date]** — Mise en place du pattern composants pour éviter la duplication de logique entre Player et Customer.
- **[date]** — Séparation Data/Visual pour les clients (permet de réutiliser un comportement avec plusieurs apparences).
- **[date]** — Extraction de la logique d'assignation de table hors de `level_manager.gd` pour préparer le support multi-niveaux.

*(Ajoute tes propres entrées au fil du développement — ça devient un super historique pour ton portfolio.)*

---

## 📄 Licence

*(à définir — MIT est un bon défaut pour un projet d'apprentissage public)*
