-- =======================================================
--                  ENTITÉS PRINCIPALES
-- =======================================================

CREATE TABLE PORT (
    id_port SERIAL PRIMARY KEY,
    nom_port VARCHAR(255) NOT NULL,
    code_port VARCHAR(20) NOT NULL,
    pays VARCHAR(255) NOT NULL,
    latitude DECIMAL,
    longitude DECIMAL ,
    categorie VARCHAR(50) CHECK (categorie IN ('commercial','industriel','militaire')),
    capacite INT CHECK (capacite >= 0),
    statut VARCHAR(20) CHECK (statut IN ('actif','inactif'))
);

CREATE TABLE ROUTE (
    id_route SERIAL PRIMARY KEY,
    nom_route VARCHAR(255) NOT NULL,
    frequence VARCHAR(255) ,
    statut VARCHAR(50) CHECK (statut IN ('active','inactive'))
);

CREATE TABLE EXPEDITION (
    id_expedition SERIAL PRIMARY KEY,
    code_expedition VARCHAR(255) UNIQUE NOT NULL,
    port_depart INT REFERENCES PORT(id_port),
    port_arrive INT REFERENCES PORT(id_port),
    client VARCHAR(255),
    statut VARCHAR(50) CHECK (statut IN ('créée','chargée','en_transit','livrée','annulée')),
    date_creation DATE NOT NULL,
    CONSTRAINT fk_ports_diff CHECK (port_depart <> port_arrive)
);

CREATE TABLE CONTENEUR (
    id_conteneur SERIAL PRIMARY KEY,
    type_conteneur VARCHAR(255),
    statut VARCHAR(30) CHECK (statut IN ('au_port','en_transit','sur_navire','en_inspection'))
    categorie_marchandise VARCHAR(255),
    date_derniere_inspection DATE,
    poids_max INT CHECK (poids_max > 0)
);

CREATE TABLE NAVIRE (
    id_navire SERIAL PRIMARY KEY,
    nom_navire VARCHAR(255) NOT NULL,
    imo VARCHAR(50) UNIQUE NOT NULL,
    armateur VARCHAR(255),
    capacite_teu INT CHECK (capacite_teu >= 0),
    type_navire VARCHAR(255),
    etat VARCHAR(30) CHECK (etat IN ('en mer','au port','maintenance','hors service')))
);

CREATE TABLE SEGMENT (
    id_segment SERIAL PRIMARY KEY,
    id_expedition INT REFERENCES EXPEDITION(id_expedition) ON DELETE CASCADE,
    id_navire INT REFERENCES NAVIRE(id_navire),
    date_depart TIMESTAMP NOT NULL,
    arrivee_prevue TIMESTAMP NOT NULL,
    arrivee_reelle TIMESTAMP,
    CONSTRAINT chk_dates_segment CHECK (arrivee_prevue >= date_depart)
);

CREATE TABLE ESCALE (
    id_escale SERIAL PRIMARY KEY,
    id_port INT REFERENCES PORT(id_port),
    id_route INT REFERENCES ROUTE(id_route),
    ordre INT CHECK (ordre > 0),
    duree_estimee INT CHECK (duree_estimee >= 0)
);

CREATE TABLE EVENEMENT (
    id_evenement SERIAL PRIMARY KEY,
    date_evt TIMESTAMP NOT NULL,
    type_evt VARCHAR(255),
    description TEXT,
    gravite VARCHAR(50) CHECK (gravite IN ('mineur','critique'))
);

CREATE TABLE MARCHANDISE (
    id_marchandise SERIAL PRIMARY KEY,
    description VARCHAR(255),
    nom VARCHAR(255) NOT NULL,
    dangereux BOOLEAN
);

CREATE TABLE HISTORIQUE (
    id_historique SERIAL PRIMARY KEY,
    id_conteneur INT REFERENCES CONTENEUR(id_conteneur),
    ancien_statut VARCHAR(255),
    nouveau_statut VARCHAR(255),
    date_changement TIMESTAMP NOT NULL DEFAULT now(),
    utilisateur VARCHAR(255),
    details VARCHAR(255)
);

-- =======================================================
--               TABLES D’ASSOCIATION N..N
-- =======================================================

CREATE TABLE EVENEMENT_PORT (
    id_evenement INT REFERENCES EVENEMENT(id_evenement),
    id_port INT REFERENCES PORT(id_port),
    PRIMARY KEY (id_evenement, id_port)
);

CREATE TABLE EVENEMENT_ROUTE (
    id_evenement INT REFERENCES EVENEMENT(id_evenement),
    id_route INT REFERENCES ROUTE(id_route),
    PRIMARY KEY (id_evenement, id_route)
);

CREATE TABLE EVENEMENT_EXPEDITION (
    id_evenement INT REFERENCES EVENEMENT(id_evenement),
    id_expedition INT REFERENCES EXPEDITION(id_expedition),
    PRIMARY KEY (id_evenement, id_expedition)
);

CREATE TABLE EVENEMENT_CONTENEUR (
    id_evenement INT REFERENCES EVENEMENT(id_evenement),
    id_conteneur INT REFERENCES CONTENEUR(id_conteneur),
    PRIMARY KEY (id_evenement, id_conteneur)
);

CREATE TABLE EVENEMENT_NAVIRE (
    id_evenement INT REFERENCES EVENEMENT(id_evenement),
    id_navire INT REFERENCES NAVIRE(id_navire),
    PRIMARY KEY (id_evenement, id_navire)
);

CREATE TABLE EXPEDITION_CONTENEUR (
    id_expedition INT REFERENCES EXPEDITION(id_expedition),
    id_conteneur INT REFERENCES CONTENEUR(id_conteneur),
    PRIMARY KEY (id_expedition, id_conteneur)
);

CREATE TABLE MARCHANDISE_CONTENEUR (
    id_marchandise INT REFERENCES MARCHANDISE(id_marchandise),
    id_conteneur INT REFERENCES CONTENEUR(id_conteneur),
    PRIMARY KEY (id_marchandise, id_conteneur)
);

CREATE TABLE ROUTE_NAVIRE (
    id_route INT REFERENCES ROUTE(id_route),
    id_navire INT REFERENCES NAVIRE(id_navire),
    PRIMARY KEY (id_route, id_navire)
);




