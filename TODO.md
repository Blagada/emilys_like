# TODO — Emily Like

Liste des tâches restantes, dans un ordre suggéré. Le détail technique de ce qui est déjà fait est dans `ROADMAP.md`.

---

## Prochaines tâches (aucune dépendance bloquante)

- [ ] Rendre la cloche du comptoir plus évidente visuellement (pas assez clair que c'est là qu'il faut servir)

## Rythme / difficulté

- [ ] Clients qui entrent visuellement dans le restaurant et attendent qu'une table se libère (zone d'attente)
  - [ ] Patience dans cette file d'attente (dernière phase manquante — service, caisse/comptoir déjà faits)

## Décision à prendre avant de continuer l'économie

- [ ] Trancher le modèle de récompense de décoration (3 pistes déjà proposées dans la roadmap)
  → bloque : la boîte de pourboires séparée, et toute l'interface de décoration plus tard

## Comptoir et commandes

- [ ] Servir plusieurs clients de comptoir à la fois (actuellement un seul via la cloche)
- [ ] Idée exploratoire : commandes en ligne (reçues à la caisse/cloche, livreur qui entre/sort) — pas encore de plan technique
- [ ] Créer un 2e/3e restaurant avec `RestaurantEntities.tscn`/`RestaurantDecor.tscn` pour valider le système de scènes réutilisables
- [ ] Menu choisi par le joueur en début de journée (dépend du joueur choisissant lui-même les aliments de son resto par niveau)

## Ambiance

- [ ] Réglage fin des angles/placement des `LightOccluder2D` pour la lumière directionnelle
- [ ] Particules dans l'air (objectif d'apprentissage)
- [ ] Changement de température à l'extérieur (ex : pluie dehors), vu par la fenêtre
- [ ] Sons pour les animations (préparation, pas, manger), cloche pour l'entrée des clients, fin de journée
- [ ] Musique/son d'ambiance lié à la température (pluie, oiseau, vent...)
- [ ] Température aléatoire ou basée sur la vraie température localisée du joueur (pas du tout un MVP)

## Économie

- [ ] Boîte de pourboires séparée (dédiée à la déco) — *dépend de la décision sur le modèle de récompense, voir plus haut*
- [ ] Système de bonus lorsque le service à la table est complété en 1 fois (perdu si complété en plusieurs services)
- [ ] Si plusieurs tables servies en 1 déplacement (pas de préparation entre-temps), bonus combo
- [ ] Pourboires différents dépendant de l'état de patience du groupe de client (aucun pourboire si angry)

## UI

- [ ] Écran de menu principal
- [ ] Paramètres du jeu (taille de police, choix de police)
- [ ] Feedback visuel quand une table ne peut pas être servie (ex : secousse)

## Assets (indépendant, travail de contenu)

- [ ] Uniformiser tous les sprites d'aliments en 64x64
- [ ] Renforcer visuellement le contour des aliments dans les assets (après uniformisation 64x64)
- [ ] Créer les vraies animations `food_prep`, `cleaning`, `delivering` (actuellement `walk`/`idle` en placeholder)

## Progression long terme — à faire dans cet ordre, chacune dépend de la précédente

- [ ] Décision sur le modèle de récompense de décoration (voir plus haut — prérequis)
- [ ] Interface de décoration (achat + placement)
- [ ] Sauvegarde automatique en fin de journée (niveau/journée, argent déco, décos débloquées, dernier menu)
- [ ] Interface de progression (restaurants → niveaux → journées)
- [ ] Interface de menu de début de jeu (nouvelle partie / continuer)

---

## Mis de côté volontairement (pas de date prévue)
- Multi-niveaux avec layouts différents — dépend d'avoir fini un premier niveau complet et joué
