# ADR 1 : Choix du SGBD principal pour le Réseau de Lecteurs

Date : 13 novembre 2026
Statut : Acceptée
Groupe : Lucie BARREZ, Raphaël PHAN, Thibaud TABARD

## Contexte et Faits

Notre application est un réseau social littéraire. Pour choisir notre base de données, nous devons prendre en compte les caractéristiques suivantes de nos données et de notre trafic :

Forme des données : Très structurées. Un livre a toujours un ISBN, un auteur, une date, un genre.

Ratio Lecture/Écriture : Fortement asymétrique. La page d'un livre (fiche détaillée, note moyenne, dernières critiques) sera lue des milliers de fois par jour, mais les écritures (publier une nouvelle critique) seront beaucoup plus rares.

Garanties requises (Intégrité) : Cruciales. Une critique ne peut pas exister sans être rattachée à un membre valide et à un livre existant. Un livre doit obligatoirement avoir un genre et un auteur.

Requêtes spécifiques : Une dimension sociale avec des parcours de type « les amis des membres que je suis ont aussi lu... » (recommandations).

## Options envisagées

### MongoDB (Famille Document)

Comment on l'utiliserait : Un gros objet JSON par Livre, contenant toutes ses caractéristiques, avec les critiques imbriquées directement dedans pour tout charger en une seule lecture.

Pour : Vitesse de lecture extrême de la fiche livre (zéro jointure, tout arrive d'un coup). La forme variable serait pratique si les livres avaient des attributs très différents.

Contre : Le pire scénario pour les mises à jour. Si un membre modifie son pseudonyme ou sa photo, il faudrait lancer une requête massive pour mettre à jour son profil imbriqué dans toutes les critiques de tous les livres qu'il a lus. Cela violerait la règle d'une seule source de vérité.

### Neo4j (Famille Graphe)

Comment on l'utiliserait : Des nœuds (Membres, Livres) reliés par des relations (A_CRITIQUE, SUIT, APPARTIENT_A).

Pour : Résolution native et ultra-rapide des requêtes de recommandation sociale (parcours de proche en proche à plusieurs pas).

Contre : Très mauvais pour les gros agrégats globaux (ex: calculer le chiffre d'affaires d'Ombelle, ou ici, la note moyenne d'un auteur sur toute sa bibliographie). Difficile à maintenir comme base principale pour des données très tabulaires (catalogue de livres).

### PostgreSQL (Famille Relationnel) - [Option Retenue]

Comment on l'utiliserait : Des tables classiques avec clés primaires et clés étrangères strictes.

Pour : C'est le standard pour garantir l'intégrité de données structurées. Impossible d'avoir des "critiques fantômes". Les transactions ACID garantissent que l'ajout d'un livre et de son auteur se fait en entier ou pas du tout.

Contre : Les requêtes de réseau social pur ("amis d'amis") vont nécessiter des jointures multiples coûteuses qui risquent de ralentir avec l'augmentation du nombre d'utilisateurs.

## Décision

Nous retenons PostgreSQL comme base de données principale. Notre besoin d'intégrité sur le catalogue de livres et les comptes membres prime sur l'optimisation des requêtes de recommandation sociale pour le lancement.

Décision d'architecture : Dénormalisation de la note

Pour répondre au problème de performance sur la lecture des fiches livres avec PostgreSQL, nous appliquons une décision de dénormalisation en stockant note_moyenne et nombre_avis directement dans la table LIVRE.

Justification (L/E) : Nous lisons la fiche livre infiniment plus souvent qu'on n'y ajoute de critiques. Le calcul systématique (AVG(note) avec jointure) à chaque affichage serait un gâchis de ressources. Le gain sera directement mesurable sur le temps de chargement de la page d'accueil.

Mécanisme de mise à jour : Cette copie sera tenue à jour par un trigger SQL dans PostgreSQL, déclenché à chaque INSERT, UPDATE, ou DELETE sur la table CRITIQUES.

## Conséquences

Intégrité assurée : Notre catalogue littéraire sera parfaitement propre et structuré.

Complexité technique : L'équipe devra maintenir le code du trigger SQL. Si le trigger échoue silencieusement, la note moyenne affichée sera fausse (donnée désynchronisée).

Point de bascule (Architecture Polyglotte) : Si la fonctionnalité "réseau social" devient le cœur de l'application et que PostgreSQL s'essouffle sur les jointures de membres, nous extrairons la partie "Abonnements/Suivre" et "Bibliothèques" vers une base Neo4j synchronisée en différé, gardant PostgreSQL uniquement pour le catalogue et les comptes.