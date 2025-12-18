-- 1. Création de la fonction d'historisation
CREATE OR REPLACE FUNCTION log_conteneur_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérifie si le statut a réellement changé
    IF OLD.statut IS DISTINCT FROM NEW.statut THEN
        INSERT INTO HISTORIQUE (
            id_conteneur,
            ancien_statut,
            nouveau_statut,
            date_changement,
            utilisateur,
            details
        )
        VALUES (
            NEW.id_conteneur,
            OLD.statut,
            NEW.statut,
            NOW(),
            current_user,
            'Changement de statut pour le conteneur ' || NEW.id_conteneur
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Création du Trigger
CREATE TRIGGER before_update_conteneur_status
BEFORE UPDATE OF statut ON CONTENEUR
FOR EACH ROW
EXECUTE FUNCTION log_conteneur_status_change();



-- La contrainte UNIQUE (id_route, ordre) peut le faire directement,
-- mais un trigger peut ajouter une logique plus complexe si nécessaire (e.g., ordre consécutif).

-- Ici, on va s'assurer qu'on ne peut pas insérer un 'ordre' déjà utilisé pour cette 'id_route'
-- (Note : Une contrainte UNIQUE(id_route, ordre) dans la table ESCALE serait plus simple
-- et plus performante pour cette règle simple.)
/*
-- Solution plus performante par contrainte
ALTER TABLE ESCALE ADD CONSTRAINT unique_ordre_par_route UNIQUE (id_route, ordre);
*/

-- Exemple de Trigger pour une logique métier plus complexe :

CREATE OR REPLACE FUNCTION check_escale_order_constraint()
RETURNS TRIGGER AS $$
DECLARE
    max_ordre INT;
BEGIN
    SELECT MAX(ordre) INTO max_ordre
    FROM ESCALE
    WHERE id_route = NEW.id_route;

    IF max_ordre IS NOT NULL AND NEW.ordre > max_ordre + 1 THEN
        RAISE EXCEPTION 'L''ordre de l''escale doit être séquentiel. Le prochain ordre pour la route % est %. Tentative d''insertion de l''ordre %.',
        NEW.id_route, max_ordre + 1, NEW.ordre;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_escale_order
BEFORE INSERT ON ESCALE
FOR EACH ROW
EXECUTE FUNCTION check_escale_order_constraint();


-- 1. Création de la fonction de vérification de statut cohérent
CREATE OR REPLACE FUNCTION check_conteneur_location_coherence()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.statut = 'au_port' THEN
        -- Logique : Si le statut passe à 'au_port', on devrait s'assurer qu'il n'est pas logiquement 'sur_navire'
        IF EXISTS (
            SELECT 1
            FROM EXPEDITION_CONTENEUR ec
            JOIN SEGMENT s ON ec.id_expedition = s.id_expedition -- Le conteneur fait partie d'une expédition
            WHERE ec.id_conteneur = NEW.id_conteneur
            AND s.arrivee_reelle IS NULL -- Le segment est en cours (en transit, donc sur navire)
        ) THEN
            RAISE EXCEPTION 'Le conteneur est en transit sur un segment actif et ne peut pas être au statut ''au_port''.';
        END IF;

    ELSIF NEW.statut = 'sur_navire' THEN
        -- Logique : Si le statut passe à 'sur_navire', il ne devrait pas y avoir d'enregistrement de présence au port.
        
        NULL; 

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Création du Trigger
CREATE TRIGGER before_update_conteneur_location
BEFORE UPDATE OF statut ON CONTENEUR
FOR EACH ROW
EXECUTE FUNCTION check_conteneur_location_coherence();