--1 HISTORIQUE AUTOMATIQUE DES STATUTS DES CONTENEURS
CREATE OR REPLACE FUNCTION fn_historique_conteneur()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérifier si le statut a réellement changé
    IF OLD.statut IS DISTINCT FROM NEW.statut THEN
        
        -- Insérer une ligne dans la table HISTORIQUE
        INSERT INTO HISTORIQUE (
            id_conteneur,
            ancien_statut,
            nouveau_statut,
            date_changement,
            utilisateur,
            details
        )
        VALUES (
            OLD.id_conteneur,
            OLD.statut,
            NEW.statut,
            now(),
            current_user,
            'Changement automatique du statut du conteneur'
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_historique_conteneur
AFTER UPDATE OF statut ON CONTENEUR
FOR EACH ROW
EXECUTE FUNCTION fn_historique_conteneur();

--2 INTERDIRE LA MODIFICATION DES ÉVÉNEMENTS
CREATE OR REPLACE FUNCTION fn_block_evenement_update()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Modification interdite : les événements sont immuables';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_block_update_evenement
BEFORE UPDATE ON EVENEMENT
FOR EACH ROW
EXECUTE FUNCTION fn_block_evenement_update();

--3 INTERDIRE LA SUPPRESSION DES ÉVÉNEMENTS

CREATE OR REPLACE FUNCTION fn_block_evenement_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Bloquer toute suppression
    RAISE EXCEPTION 'Suppression interdite : les événements sont historisés';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_block_delete_evenement
BEFORE DELETE ON EVENEMENT
FOR EACH ROW
EXECUTE FUNCTION fn_block_evenement_delete();

--4 CONTRÔLE DES TRANSITIONS DE STATUT DES CONTENEURS
CREATE OR REPLACE FUNCTION fn_check_statut_conteneur()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.statut = NEW.statut THEN
        RETURN NEW;
    END IF;

    IF (OLD.statut = 'au_port' AND NEW.statut IN ('sur_navire','en_inspection'))
       OR (OLD.statut = 'sur_navire' AND NEW.statut IN ('au_port','en_transit'))
       OR (OLD.statut = 'en_transit' AND NEW.statut = 'au_port')
       OR (OLD.statut = 'en_inspection' AND NEW.statut = 'au_port') THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'Transition de statut conteneur invalide (% → %)', OLD.statut, NEW.statut;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_statut_conteneur
BEFORE UPDATE OF statut ON CONTENEUR
FOR EACH ROW
EXECUTE FUNCTION fn_check_statut_conteneur();

--5 DATE AUTOMATIQUE DE CRÉATION DES EXPÉDITIONS
CREATE OR REPLACE FUNCTION fn_set_date_creation_expedition()
RETURNS TRIGGER AS $$
BEGIN
    -- Si la date n’est pas fournie, on la génère automatiquement
    IF NEW.date_creation IS NULL THEN
        NEW.date_creation := CURRENT_DATE;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_date_creation_expedition
BEFORE INSERT ON EXPEDITION
FOR EACH ROW
EXECUTE FUNCTION fn_set_date_creation_expedition();



