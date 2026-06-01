-- ============================================================
-- Exercice 4 : Agregations et statistiques
-- Projet : Gestion de l'infrastructure de donnees du ZEvent
-- Realise par : Sami Ben Hamouda
-- ============================================================

-- ============================================================
-- 1. Nombre total de streams par streamer
-- On utilise LEFT JOIN pour afficher aussi les streamers
-- qui n'ont aucun stream.
-- ============================================================

SELECT
    s.pseudo,
    COUNT(st.id_stream) AS nombre_streams
FROM streamer s
LEFT JOIN stream st
    ON s.id_streamer = st.id_streamer
GROUP BY
    s.id_streamer,
    s.pseudo
ORDER BY
    nombre_streams DESC,
    s.pseudo ASC;

-- ============================================================
-- 2. Montant total des paliers de defis par etat de validation
-- On regroupe les defis valides et non valides.
-- ============================================================

SELECT
    etat_validation,
    SUM(montant_palier) AS montant_total_paliers
FROM defi
GROUP BY
    etat_validation
ORDER BY
    etat_validation DESC;

-- ============================================================
-- 3. Streamers ayant au moins 2 defis
-- On utilise HAVING pour filtrer apres le GROUP BY.
-- ============================================================

SELECT
    s.pseudo,
    COUNT(pd.id_defi) AS nombre_defis
FROM streamer s
JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
GROUP BY
    s.id_streamer,
    s.pseudo
HAVING COUNT(pd.id_defi) >= 2
ORDER BY
    nombre_defis DESC,
    s.pseudo ASC;

-- ============================================================
-- 4. Duree des streams et duree moyenne globale
-- EXTRACT(EPOCH FROM interval) permet de convertir la duree
-- en secondes. On divise par 3600 pour obtenir des heures.
-- AVG(...) OVER() affiche la moyenne globale sur chaque ligne.
-- ============================================================

SELECT
    titre,
    ROUND(
        (EXTRACT(EPOCH FROM (heure_fin - heure_debut)) / 3600)::numeric,
        2
    ) AS duree_stream_heures,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (heure_fin - heure_debut)) / 3600)
        OVER()::numeric,
        2
    ) AS duree_moyenne_globale_heures
FROM stream
ORDER BY
    duree_stream_heures DESC;

-- ============================================================
-- 5. Streamers ayant effectivement lance au moins un stream
-- avec le titre de leur session et l'heure de debut.
-- ============================================================

SELECT
    s.pseudo,
    st.titre,
    st.heure_debut
FROM streamer s
JOIN stream st
    ON s.id_streamer = st.id_streamer
ORDER BY
    s.pseudo ASC,
    st.heure_debut ASC;
