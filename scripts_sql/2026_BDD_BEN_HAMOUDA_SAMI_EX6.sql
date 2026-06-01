-- ============================================================
-- Exercice 6 : Requetes avancees sur les donnees existantes
-- Projet : Gestion de l'infrastructure de donnees du ZEvent
-- Realise par : Sami Ben Hamouda
-- ============================================================

-- ============================================================
-- 1. Streamers ayant au moins un defi
-- Affiche le pseudo du streamer et le nombre de defis
-- auxquels il participe.
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
HAVING COUNT(pd.id_defi) >= 1
ORDER BY
    nombre_defis DESC,
    s.pseudo ASC;

-- ============================================================
-- 2. Defis n'ayant aucun participant
-- Utilisation de NOT EXISTS pour detecter les defis
-- absents de la table participation_defi.
-- ============================================================

SELECT
    d.intitule,
    d.montant_palier
FROM defi d
WHERE NOT EXISTS (
    SELECT 1
    FROM participation_defi pd
    WHERE pd.id_defi = d.id_defi
)
ORDER BY
    d.intitule ASC;

-- ============================================================
-- 3. Defis ayant plus de 2 streamers participants
-- On compte le nombre de participants par defi.
-- ============================================================

SELECT
    d.intitule,
    d.montant_palier,
    COALESCE(COUNT(pd.id_streamer), 0) AS nombre_participants
FROM defi d
LEFT JOIN participation_defi pd
    ON d.id_defi = pd.id_defi
GROUP BY
    d.id_defi,
    d.intitule,
    d.montant_palier
HAVING COUNT(pd.id_streamer) > 2
ORDER BY
    nombre_participants DESC,
    d.intitule ASC;

-- ============================================================
-- 4. Nombre de defis par streamer avec le montant total engage
-- Pour chaque streamer, on affiche :
-- pseudo, nombre de defis, montant total des paliers.
-- ============================================================

SELECT
    s.pseudo,
    COUNT(pd.id_defi) AS nombre_defis,
    COALESCE(SUM(d.montant_palier), 0) AS montant_total_engage
FROM streamer s
LEFT JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
LEFT JOIN defi d
    ON pd.id_defi = d.id_defi
GROUP BY
    s.id_streamer,
    s.pseudo
ORDER BY
    montant_total_engage DESC,
    s.pseudo ASC;

-- ============================================================
-- 5. Streamers et creneaux avec nombre de streams effectues
-- par creneau.
-- On affiche le pseudo, les dates du creneau et le nombre
-- de streams lies a ce creneau.
-- ============================================================

SELECT
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    COUNT(st.id_stream) AS nombre_streams_creneau
FROM streamer s
JOIN creneau c
    ON s.id_streamer = c.id_streamer
LEFT JOIN stream st
    ON c.id_creneau = st.id_creneau
GROUP BY
    s.id_streamer,
    s.pseudo,
    c.id_creneau,
    c.date_debut_autorisee,
    c.date_fin_autorisee
ORDER BY
    s.pseudo ASC,
    c.date_debut_autorisee ASC;
