-- =======================================================
-- INSERTION DES DONNEES
-- =======================================================

INSERT INTO PORT (nom_port, code_port, pays, categorie, capacite, statut) VALUES
('Port de Rotterdam','NLRTM','Pays-Bas','commercial',150000,'actif'),
('Port de Singapour','SGSIN','Singapour','commercial',180000,'actif'),
('Port de Shanghai','CNSHA','Chine','industriel',200000,'actif');

INSERT INTO ROUTE (nom_route, frequence, statut) VALUES
('Europe-Asie Express','Hebdomadaire','active'),
('Transatlantique Nord','Mensuelle','active');

INSERT INTO NAVIRE (nom_navire, imo, armateur, capacite_teu, type_navire, etat) VALUES
('Global Hawk','IMO9770857','GML Corp',18000,'Porte-conteneurs','au port'),
('Ocean Runner','IMO9581995','GML Corp',12000,'Porte-conteneurs','en mer');

INSERT INTO CONTENEUR (type_conteneur, statut, categorie_marchandise, date_derniere_inspection, poids_max) VALUES
('40ft Dry','au port','Textiles','2025-11-15',26000),
('20ft Reefer','sur navire','Produits alimentaires','2025-12-01',24000),
('40ft High Cube','en inspection','Electronique','2025-12-14',28000);

INSERT INTO MARCHANDISE (description, nom, dangereux) VALUES
('Rouleaux de tissu','Tissus',FALSE),
('Cartes electroniques','Composants',FALSE),
('Produit chimique','Chimique',TRUE);

INSERT INTO EXPEDITION (code_expedition, port_depart, port_arrive, client, statut, date_creation) VALUES
('EXP-001',1,3,'Client Alpha','en transit','2025-12-10'),
('EXP-002',2,1,'Client Beta','creee','2025-12-15');

INSERT INTO SEGMENT (id_expedition, id_navire, date_depart, arrivee_prevue) VALUES
(1,2,'2025-12-10 18:00','2025-12-25 09:00');

INSERT INTO ESCALE (id_port, id_route, ordre, duree_estimee) VALUES
(1,1,1,24),(2,1,2,36),(3,1,3,48);

INSERT INTO EVENEMENT (type_evt, description, gravite) VALUES
('Meteo','Tempete en mer','critique'),
('Inspection','Controle douanier','mineur');

INSERT INTO HISTORIQUE (id_navire, id_conteneur, id_port, description, date_heure) VALUES
(1, NULL, 1, 'Navire Global Hawk a quitté le port de Rotterdam', '2025-12-10 18:00:00'),
(2, 2, NULL, 'Conteneur 20ft Reefer chargé sur Ocean Runner', '2025-12-11 09:00:00'),
(NULL, NULL, 2, 'Port de Singapour en inspection de routine', '2025-12-12 08:30:00');

INSERT INTO EXPEDITION_CONTENEUR VALUES (1,1),(1,2);
INSERT INTO MARCHANDISE_CONTENEUR VALUES (1,1);
INSERT INTO ROUTE_NAVIRE VALUES (1,2);
INSERT INTO EVENEMENT_EXPEDITION VALUES (1,1);
INSERT INTO EVENEMENT_CONTENEUR VALUES (2,3);
INSERT INTO EVENEMENT_NAVIRE VALUES (1,2);
INSERT INTO EVENEMENT_ROUTE VALUES(1, 1); 
INSERT INTO EVENEMENT_PORT VALUES(1, 1);



SET search_path = test;

SELECT * FROM port;
SELECT * FROM navire;
SELECT * FROM expedition;