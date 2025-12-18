# 🚢 Projet Global Maritime Logistics (GML) - Base de Données PostgreSQL

Ce dépôt contient l'ensemble des livrables pour la conception et l'implémentation d'une base de données unifiée pour Global Maritime Logistics (GML), une entreprise spécialisée dans le transport maritime de marchandises conteneurisées.

## 📌 Contexte du Projet

Le système existant de GML était fragmenté. L'objectif de ce projet était de concevoir et d'implémenter une base de données **PostgreSQL** unifiée pour centraliser la gestion de :
* La flotte de navires.
* Le réseau global de ports.
* Le parc de conteneurs et les marchandises.
* Les routes maritimes et les expéditions (voyages).
* Le suivi des opérations et des incidents (événements).

## 💡 Objectifs et Contraintes

* **Unification** des données logistiques.
* Garantie de l'**Intégrité, Cohérence et Traçabilité** des données.
* Respect strict de la **Normalisation (1FN, 2FN, 3FN)**.
* Implémentation des **Contraintes Métier** complexes via `CHECK` et `TRIGGERs`.
* Mise en place de l'**Historisation** pour le suivi des changements de statut.

## 🛠️ Modélisation et Conception

La conception de la base de données a suivi les étapes standard :

| Phase | Description | Fichier/Dossier |
| :--- | :--- | :--- |
| **MCD** (Modèle Conceptuel de Données) | Représentation graphique des entités et relations. | `docs/MCD.pdf` |
| **MLD** (Modèle Logique de Données) | Schéma tabulaire avec clés primaires et étrangères. | `docs/MLD.png` |
| **MPD** (Modèle Physique de Données) | Scripts SQL de création des tables et contraintes. | `scripts/schema_creation.sql` |

> *Les schémas MLD/MRD ont été réalisés avec **DbSchema**.*

## ⚙️ Implémentation PostgreSQL

Les scripts SQL se trouvent dans le dossier `scripts/`.

### 1. Création du Schéma

* `scripts/schema_creation.sql`: Contient les instructions `CREATE TABLE` avec toutes les clés primaires (`PRIMARY KEY`), clés étrangères (`FOREIGN KEY`), contraintes d'unicité (`UNIQUE`), et contraintes de domaine (`CHECK`).

### 2. Triggers et Fonctions Avancées

Les triggers implémentent la logique métier et l'historisation.

* `scripts/triggers.sql`: Contient les fonctions `CREATE FUNCTION` et les `CREATE TRIGGER` pour les règles suivantes :
    * **Historisation des statuts de Conteneurs** (via la table `HISTORIQUE`).
    * **Contraintes de Dates de Segment** (`date_depart` < `arrivee_prevue`). *(Déjà partiellement dans `CHECK`)*
    * **Vérification de la co-localisation** (Un conteneur ne peut être à la fois sur un navire et dans un port).
    * **Contrainte d'Ordre des Escales** sur une Route.
    * **Protection de la table HISTORIQUE** (Un trigger BEFORE DELETE interdit toute suppression dans la table HISTORIQUE)

### 3. Jeux de Données et Tests

* `scripts/data_insertion.sql`: Instructions `INSERT INTO` pour peupler les tables de données de test.
* `scripts/test_cases.sql`: Requêtes de test pour valider l'intégrité des données, le bon fonctionnement des triggers, et les contraintes métiers.

## 🤝 Équipe de Projet (Binôme)

| Nom & Prénom | Rôle & Responsabilités |
| :--- | :--- |
| **ET-TAHERY ZINEB** | Conception MCD/MLD, Scripting PostgreSQL (Tables & Contraintes), ... |
| **ASMAE JANAH** | Implémentation Triggers Avancés/Historisation, Stratégie d'Indexation, Documentation (`README`), ... |

**Trello** : https://trello.com/invite/b/693fca8b092adc75ed420382/ATTI0898a7a2fca81feaadb0bc408866d236EC09FAB4/conception-base-de-donnees-avec-postgresql
