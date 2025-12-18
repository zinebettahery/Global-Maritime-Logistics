-- =====================================================
-- HISTORISATION DES STATUTS DES CONTENEURS
-- =====================================================
CREATE OR REPLACE FUNCTION fn_historique_conteneur()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.statut IS DISTINCT FROM OLD.statut THEN
        INSERT INTO HISTORIQUE (id_conteneur, description)
        VALUES (
            NEW.id_conteneur,
            'Changement de statut : ' || OLD.statut || ' → ' || NEW.statut
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_historique_conteneur
AFTER UPDATE OF statut ON CONTENEUR
FOR EACH ROW
EXECUTE FUNCTION fn_historique_conteneur();

-- =====================================================
--  CONTRAINTE DE DATES DES SEGMENTS
-- date_depart < arrivee_prevue
-- =====================================================
CREATE OR REPLACE FUNCTION fn_check_dates_segment()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.date_depart >= NEW.arrivee_prevue THEN
        RAISE EXCEPTION
        'date_depart (%) doit être antérieure à arrivee_prevue (%)',
        NEW.date_depart, NEW.arrivee_prevue;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_dates_segment
BEFORE INSERT OR UPDATE ON SEGMENT
FOR EACH ROW
EXECUTE FUNCTION fn_check_dates_segment();

-- =====================================================
--  CO-LOCALISATION CONTENEUR
-- Un conteneur ne peut pas être à la fois
-- sur un navire ET dans un port
-- =====================================================
CREATE OR REPLACE FUNCTION fn_check_colocalisation()
RETURNS TRIGGER AS $$
DECLARE
    nb_navire INT;
    nb_port INT;
BEGIN
    SELECT COUNT(*) INTO nb_navire
    FROM HISTORIQUE
    WHERE id_conteneur = NEW.id_conteneur
      AND id_navire IS NOT NULL
      AND date_heure = (
          SELECT MAX(date_heure)
          FROM HISTORIQUE
          WHERE id_conteneur = NEW.id_conteneur
      );

    SELECT COUNT(*) INTO nb_port
    FROM HISTORIQUE
    WHERE id_conteneur = NEW.id_conteneur
      AND id_port IS NOT NULL
      AND date_heure = (
          SELECT MAX(date_heure)
          FROM HISTORIQUE
          WHERE id_conteneur = NEW.id_conteneur
      );

    IF nb_navire > 0 AND nb_port > 0 THEN
        RAISE EXCEPTION
        'Un conteneur ne peut pas être simultanément sur un navire et dans un port';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_colocalisation
AFTER INSERT ON HISTORIQUE
FOR EACH ROW
EXECUTE FUNCTION fn_check_colocalisation();

-- =====================================================
--  CONTRAINTE D’ORDRE DES ESCALES SUR UNE ROUTE
-- L’ordre doit être unique et croissant par route
-- =====================================================
CREATE OR REPLACE FUNCTION fn_check_ordre_escale()
RETURNS TRIGGER AS $$
DECLARE
    ordre_existant INT;
BEGIN
    SELECT COUNT(*) INTO ordre_existant
    FROM ESCALE
    WHERE id_route = NEW.id_route
      AND ordre = NEW.ordre
      AND id_escale <> COALESCE(NEW.id_escale, -1);

    IF ordre_existant > 0 THEN
        RAISE EXCEPTION
        'L’ordre % existe déjà pour la route %',
        NEW.ordre, NEW.id_route;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_ordre_escale
BEFORE INSERT OR UPDATE ON ESCALE
FOR EACH ROW
EXECUTE FUNCTION fn_check_ordre_escale();

-- =====================================================
-- INTERDICTION DE SUPPRESSION SUR HISTORIQUE
-- =====================================================
CREATE OR REPLACE FUNCTION fn_no_delete_historique()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION
        'Suppression interdite : la table HISTORIQUE est immuable (audit/log)';
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_no_delete_historique
BEFORE DELETE ON HISTORIQUE
FOR EACH ROW
EXECUTE FUNCTION fn_no_delete_historique();

