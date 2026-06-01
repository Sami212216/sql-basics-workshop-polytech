-- ============================================================
-- Exercice 3 : Requetes de jointure simples
-- Projet : Gestion de l'infrastructure de donnees du ZEvent
-- Realise par : Sami Ben Hamouda
-- ============================================================

-- ============================================================
-- 1. Streamers et leurs creneaux
-- Afficher le pseudo du streamer et les dates de ses creneaux.
-- Resultat ordonne par pseudo puis par date de creneau.
-- ============================================================

SELECT
    s.pseudo,
    c.date_debut_autorisee,
    c.date_fin_autorisee
FROM streamer s
JOIN creneau c
    ON s.id_streamer = c.id_streamer
ORDER BY
    s.pseudo ASC,
    c.date_debut_autorisee ASC;

-- ============================================================
-- 2. Streams avec informations du streamer et du creneau
-- Afficher le titre du stream, le pseudo du streamer,
-- et les dates du creneau.
-- Filtrer sur les streams du 2025-09-05 ou du 2025-09-06.
-- ============================================================

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
WHERE DATE(st.heure_debut) IN ('2025-09-05', '2025-09-06')
ORDER BY
    st.heure_debut ASC;

-- ============================================================
-- 3. Defis et leurs participants
-- Afficher l'intitule du defi, les pseudos des streamers
-- participants et le montant du palier.
-- Utilisation de la table de liaison participation_defi.
-- ============================================================

SELECT
    d.intitule,
    s.pseudo,
    d.montant_palier
FROM defi d
JOIN participation_defi pd
    ON d.id_defi = pd.id_defi
JOIN streamer s
    ON pd.id_streamer = s.id_streamer
ORDER BY
    d.intitule ASC,
    s.pseudo ASC;
