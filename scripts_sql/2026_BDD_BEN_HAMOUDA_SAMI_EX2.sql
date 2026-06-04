-- ==========================================================
-- Exercice 2 : Requêtes SELECT simples et filtrées
-- Projet : Gestion de l'infrastructure de données du ZEvent
-- Realise par : Sami Ben Hamouda
-- ==========================================================

-- ===========================================
-- 1. Tous les streamers avec leur URL Twitch,
--    Je les ordonne par pseudo
-- ===========================================

SELECT 
    pseudo,
    url_twitch
FROM streamer
ORDER BY pseudo ASC;

-- ===============================================
-- 2. Les créneaux du samedi 2025-09-06
--    Utilisation de DATE() pour extraire la date
-- ===============================================

SELECT 
    id_creneau,
    id_streamer,
    date_debut_autorisee,
    date_fin_autorisee
FROM creneau
WHERE DATE(date_debut_autorisee) = '2025-09-06'
ORDER BY date_debut_autorisee ASC;

-- ===================================================================
-- 3. Les défis validés ayant un montant palier supérieur à 5000 euros
-- ===================================================================

SELECT 
    id_defi,
    intitule,
    montant_palier,
    etat_validation
FROM defi
WHERE etat_validation = TRUE
  AND montant_palier > 5000
ORDER BY montant_palier DESC;

-- =====================================================
-- 4. Les streams dont la date de fin effective est NULL
--    Cela correspond aux streams non terminés
-- =====================================================

SELECT 
    id_stream,
    id_streamer,
    id_creneau,
    titre,
    heure_debut,
    heure_fin,
    date_fin_effective
FROM stream
WHERE date_fin_effective IS NULL
ORDER BY heure_debut ASC;
