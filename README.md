# Réseau de Lecteurs - Conception & Base de Données

Ce dépôt contient les livrables de conception et d'implémentation pour le TP d'Architecture des Données (Réseau de lecteurs).

## Arborescence du projet

* `CONCEPTION.md` : Règles de gestion, MCD et MLD (PostgreSQL) avec limites du schéma.
* `docs/` : Contient le diagramme du MCD en image.
* `docs/adr/0001-choix-sgbd.md` : Document de décision justifiant le choix de PostgreSQL et la dénormalisation de la `note_moyenne`.
* `app/` : Dossier contenant le bonus (implémentation SQL et génération de fausses données).

## Comment lancer le Bonus (Implémentation)

### 1. Démarrer la base de données
Nous utilisons un conteneur Docker PostgreSQL :
\`\`\`bash
docker run --name postgres-tp -e POSTGRES_PASSWORD=password -e POSTGRES_DB=ombelle -p 5432:5432 -d postgres:16
\`\`\`

### 2. Initialiser le schéma
Depuis le dossier `app/`, importez la structure et les triggers :
\`\`\`bash
docker exec -i postgres-tp psql -U postgres -d ombelle < schema.sql
\`\`\`

### 3. Générer les données avec Python
Le script `generer.py` peuple la base à l'aide de la librairie `Faker`.
\`\`\`bash
cd app
python3 -m venv venv
source venv/bin/activate
pip install psycopg2-binary faker
python3 generer.py
\`\`\`

### 4. Tester avec des requêtes
Vous pouvez exécuter les requêtes de test contenues dans `app/requetes.sql` pour vérifier le bon fonctionnement des jointures et des triggers.