SET search_path = test;

-- =======================================================
--  TEST INTEGRITE DES DONNEES DE BASE
-- =======================================================

-- Ports actifs uniquement
SELECT nom_port, statut
FROM PORT
WHERE statut NOT IN ('actif','inactif');
-- Résultat attendu : aucune ligne

-- Navires avec état valide
SELECT nom_navire, etat
FROM NAVIRE
WHERE etat NOT IN ('au port','en mer','en maintenance');
--  Résultat attendu : aucune ligne


-- =======================================================
-- TEST TRIGGER HISTORISATION CONTENEUR
-- =======================================================

-- Changement de statut du conteneur 1
UPDATE CONTENEUR
SET statut = 'sur navire'
WHERE id_conteneur = 1;

-- Vérification historique
SELECT id_conteneur, description, date_heure
FROM HISTORIQUE
WHERE id_conteneur = 1
ORDER BY date_heure DESC;
-- Résultat attendu : nouvelle ligne d’historique


-- =======================================================
-- TEST CONTRAINTE DATES SEGMENT
-- =======================================================

--  Test invalide (doit échouer)
INSERT INTO SEGMENT (id_expedition, id_navire, date_depart, arrivee_prevue)
VALUES (2, 1, '2025-12-20 10:00', '2025-12-18 10:00');
--  Erreur attendue : date_depart >= arrivee_prevue


-- =======================================================
--  TEST CO-LOCALISATION CONTENEUR
-- =======================================================

--  Tentative incohérente : conteneur 2 à la fois au port et sur navire
INSERT INTO HISTORIQUE (id_conteneur, id_port, description)
VALUES (2, 1, 'Tentative de déchargement incohérente');
--  Erreur attendue


-- =======================================================
--  TEST ORDRE DES ESCALES SUR UNE ROUTE
-- =======================================================

--  Ordre déjà existant sur la route 1
INSERT INTO ESCALE (id_port, id_route, ordre, duree_estimee)
VALUES (2, 1, 2, 20);
--  Erreur attendue : ordre dupliqué


-- =======================================================
-- 6️⃣ TEST RELATIONS METIER
-- =======================================================

-- Conteneurs par expédition
SELECT e.code_expedition, c.id_conteneur, c.type_conteneur
FROM EXPEDITION e
JOIN EXPEDITION_CONTENEUR ec ON e.id_expedition = ec.id_expedition
JOIN CONTENEUR c ON c.id_conteneur = ec.id_conteneur;

-- Navires affectés à une route
SELECT r.nom_route, n.nom_navire
FROM ROUTE r
JOIN ROUTE_NAVIRE rn ON r.id_route = rn.id_route
JOIN NAVIRE n ON n.id_navire = rn.id_navire;


-- =======================================================
--  TEST EVENEMENTS LIES
-- =======================================================

SELECT ev.type_evt, ev.gravite, ex.code_expedition
FROM EVENEMENT ev
JOIN EVENEMENT_EXPEDITION ee ON ev.id_evenement = ee.id_evenement
JOIN EXPEDITION ex ON ee.id_expedition = ex.id_expedition;


DELETE FROM HISTORIQUE WHERE id_historique = 1;

