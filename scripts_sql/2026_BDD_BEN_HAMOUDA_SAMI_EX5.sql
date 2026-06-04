-- ============================================================
-- Exercice 5 : Mises a jour UPDATE et suppressions DELETE
-- Projet : Gestion de l'infrastructure de données du ZEvent
-- Realise par : Sami Ben Hamouda
-- ============================================================

-- ========================================================================================================
-- IMPORTANT :
-- Ce script utilise une transaction avec ROLLBACK.
-- Cela permet de tester les UPDATE et DELETE sans detruire les donnees nécessaires aux exercices suivants.
-- ========================================================================================================

BEGIN;

-- =================
-- PARTIE A : UPDATE
-- =================

-- =====================================================
-- 1. Vérification avant modification du montant du défi
-- =====================================================

SELECT
    id_defi,
    intitule,
    montant_palier,
    etat_validation
FROM defi
WHERE intitule = 'Saut en parachute';

-- ====================================================================
-- 2. Augmentation de 10% du montant palier du défi "Saut en parachute"
-- ====================================================================

UPDATE defi
SET montant_palier = montant_palier * 1.10
WHERE intitule = 'Saut en parachute';

-- ==================================
-- 3. Verification après modification
-- ==================================

SELECT
    id_defi,
    intitule,
    montant_palier,
    etat_validation
FROM defi
WHERE intitule = 'Saut en parachute';

-- ====================================================================================
-- 4. Vérification des défis pas valides ayant au moins 3 participants avant validation
-- ====================================================================================

SELECT
    d.id_defi,
    d.intitule,
    d.etat_validation,
    COUNT(pd.id_streamer) AS nombre_participants
FROM defi d
JOIN participation_defi pd
    ON d.id_defi = pd.id_defi
WHERE d.etat_validation = FALSE
GROUP BY
    d.id_defi,
    d.intitule,
    d.etat_validation
HAVING COUNT(pd.id_streamer) >= 3;

-- =========================================================================
-- 5. Validation de tous les défis pas valides ayant au moins 3 participants
-- =========================================================================

UPDATE defi
SET etat_validation = TRUE
WHERE etat_validation = FALSE
  AND id_defi IN (
      SELECT
          id_defi
      FROM participation_defi
      GROUP BY
          id_defi
      HAVING COUNT(id_streamer) >= 3
  );

-- ================================
-- 6. Verification apres validation
-- ================================

SELECT
    d.id_defi,
    d.intitule,
    d.etat_validation,
    COUNT(pd.id_streamer) AS nombre_participants
FROM defi d
JOIN participation_defi pd
    ON d.id_defi = pd.id_defi
GROUP BY
    d.id_defi,
    d.intitule,
    d.etat_validation
ORDER BY
    d.id_defi ASC;

-- =================
-- PARTIE B : DELETE
-- =================

-- ==========================================================
-- 7. Vérification des streams non terminés avant suppression
-- ==========================================================

SELECT
    id_stream,
    titre,
    heure_debut,
    heure_fin,
    date_fin_effective
FROM stream
WHERE date_fin_effective IS NULL
ORDER BY
    heure_debut ASC;

-- =======================================
-- 8. Suppression des streams non terminés
-- =======================================

DELETE FROM stream
WHERE date_fin_effective IS NULL;

-- ==========================================================
-- 9. Verification apres suppression des streams non terminés
-- ==========================================================

SELECT
    id_stream,
    titre,
    heure_debut,
    heure_fin,
    date_fin_effective
FROM stream
ORDER BY
    id_stream ASC;

-- ======================================================
-- 10. Vérification des créneaux passes avant suppression
-- ======================================================

SELECT
    id_creneau,
    id_streamer,
    date_debut_autorisee,
    date_fin_autorisee
FROM creneau
WHERE date_fin_autorisee < CURRENT_DATE
ORDER BY
    date_fin_autorisee ASC;

-- =================================================================================================================
-- 11. Suppression des creneaux passés
-- Il faut faire attention car avec ON DELETE CASCADE, les streams liés à ces créneaux peuvent aussi etre supprimés.
-- =================================================================================================================

DELETE FROM creneau
WHERE date_fin_autorisee < CURRENT_DATE;

-- ======================================================
-- 12. Verification apres suppression des créneaux passés
-- ======================================================

SELECT
    id_creneau,
    id_streamer,
    date_debut_autorisee,
    date_fin_autorisee
FROM creneau
ORDER BY
    id_creneau ASC;

-- =======================================================================================================
-- 13. Annulation volontaire des modifications pour conserver la base intacte pour les exercices suivants.
-- =======================================================================================================

ROLLBACK;
