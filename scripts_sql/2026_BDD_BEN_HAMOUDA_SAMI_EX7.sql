-- =========================================================
-- Exercice 7 : Gestion des validations avec CASE
-- Projet : Gestion de l'infrastructure de données du ZEvent
-- Réalise par : Sami Ben Hamouda
-- =========================================================

-- ================================================================================================
-- PARTIE A : Validation des streams contre les créneaux
-- Objectif : vérifier si chaque stream respecte son creneau autorisé.
-- Un stream est VALIDE si : heure_debut >= date_debut_autorisee ET heure_fin <= date_fin_autorisee
-- ================================================================================================

SELECT
    st.titre,
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin,
    CASE
        WHEN st.heure_debut >= c.date_debut_autorisee
         AND st.heure_fin <= c.date_fin_autorisee
        THEN 'VALIDE'
        ELSE 'INVALIDE'
    END AS validation_creneau
FROM stream st
JOIN streamer s
    ON st.id_streamer = s.id_streamer
JOIN creneau c
    ON st.id_creneau = c.id_creneau
ORDER BY
    st.heure_debut ASC;

-- ========================================================================================
-- Identification des streams invalides
-- Cette requête peut retourner 0 ligne si tous les streams respectent bien leurs créneaux.
-- ========================================================================================

SELECT
    st.titre,
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin
FROM stream st
JOIN streamer s
    ON st.id_streamer = s.id_streamer
JOIN creneau c
    ON st.id_creneau = c.id_creneau
WHERE NOT (
    st.heure_debut >= c.date_debut_autorisee
    AND st.heure_fin <= c.date_fin_autorisee
)
ORDER BY
    st.heure_debut ASC;

-- ======================================================================
-- PARTIE B : Détection des depassements de fin
-- Objectif : Comparer l'heure de fin prevue et la date de fin effective.
-- Ici, si la date_fin_effective > heure_fin, il y a qlors DEPASSEMENT.
-- ======================================================================

SELECT
    st.titre,
    s.pseudo,
    st.heure_fin AS heure_fin_prevue,
    st.date_fin_effective,
    CASE
        WHEN st.date_fin_effective IS NOT NULL
         AND st.date_fin_effective > st.heure_fin
        THEN 'DEPASSEMENT'
        ELSE 'OK'
    END AS statut_fin,
    CASE
        WHEN st.date_fin_effective IS NOT NULL
         AND st.date_fin_effective > st.heure_fin
        THEN ROUND(
            (EXTRACT(EPOCH FROM (st.date_fin_effective - st.heure_fin)) / 60)::numeric,
            2
        )
        ELSE 0
    END AS depassement_minutes
FROM stream st
JOIN streamer s
    ON st.id_streamer = s.id_streamer
ORDER BY
    st.heure_debut ASC;

-- ====================================================================================
-- Résume des dépassements
-- On compte les streams en retard et on calcule la duree moyenne de retard en minutes.
-- ====================================================================================

SELECT
    COUNT(*) AS nombre_streams_en_retard,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (date_fin_effective - heure_fin)) / 60)::numeric,
        2
    ) AS duree_moyenne_retard_minutes
FROM stream
WHERE date_fin_effective IS NOT NULL
  AND date_fin_effective > heure_fin;

-- =============================================
-- PARTIE C : Requete combinee
-- Apercu complet de la conformite des streams :
-- 1. Respect du créneau autorisé
-- 2. Détection du depassement de fin
-- =============================================

SELECT
    st.titre,
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin AS heure_fin_prevue,
    st.date_fin_effective,

    CASE
        WHEN st.heure_debut >= c.date_debut_autorisee
         AND st.heure_fin <= c.date_fin_autorisee
        THEN 'VALIDE'
        ELSE 'INVALIDE'
    END AS validation_creneau,

    CASE
        WHEN st.date_fin_effective IS NOT NULL
         AND st.date_fin_effective > st.heure_fin
        THEN 'DEPASSEMENT'
        ELSE 'OK'
    END AS statut_fin,

    CASE
        WHEN st.date_fin_effective IS NOT NULL
         AND st.date_fin_effective > st.heure_fin
        THEN ROUND(
            (EXTRACT(EPOCH FROM (st.date_fin_effective - st.heure_fin)) / 60)::numeric,
            2
        )
        ELSE 0
    END AS depassement_minutes

FROM stream st
JOIN streamer s
    ON st.id_streamer = s.id_streamer
JOIN creneau c
    ON st.id_creneau = c.id_creneau
ORDER BY
    st.heure_debut ASC;
