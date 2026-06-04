-- =========================================================
-- Exercice 8 : Analyse de performance et création d'index
-- Projet : Gestion de l'infrastructure de données du ZEvent
-- Realise par : Sami Ben Hamouda
-- =========================================================

-- ==========================================================
-- Objectif :
-- 1. Charger un grand volume de donnees
-- 2. Executer une requete complexe sans index
-- 3. Observer le plan d'execution avec EXPLAIN ANALYZE
-- 4. Creer des index
-- 5. Reexecuter la meme requete et comparer les performances
-- ==========================================================

-- =========================================================
-- 1. Nettoyage des anciens index s'ils existent dejà
-- Cela permet de tester correctement la requete sans index.
-- =========================================================

DROP INDEX IF EXISTS idx_participation_defi_id_streamer;
DROP INDEX IF EXISTS idx_participation_defi_id_defi;
DROP INDEX IF EXISTS idx_stream_id_streamer;
DROP INDEX IF EXISTS idx_stream_date_fin_effective;
DROP INDEX IF EXISTS idx_stream_id_streamer_date_fin_effective;
DROP INDEX IF EXISTS idx_streamer_pseudo_trgm;


-- ======================================================
-- 2. Vidage des tables et remise a zéro des identifiants
-- ======================================================

TRUNCATE TABLE stream, participation_defi, creneau, defi, streamer
RESTART IDENTITY CASCADE;


-- =============================
-- 3. Oninsère  50 000 streamers
-- =============================

DO $$
BEGIN
    FOR i IN 1..50000 LOOP
        INSERT INTO streamer (pseudo, url_twitch)
        VALUES ('pseudo_' || i, 'https://twitch.tv/pseudo_' || i);
    END LOOP;
END $$;


-- =========================
-- 4. On insère 50 000 defis
-- =========================

DO $$
BEGIN
    FOR i IN 1..50000 LOOP
        INSERT INTO defi (intitule, montant_palier, etat_validation)
        VALUES (
            'defi_' || i,
            (random() * 50000)::DECIMAL(12,2) + 500,
            (random() < 0.5)
        );
    END LOOP;
END $$;


-- =============================================================================================
-- 5. Insertion de 250 000 participations
-- Ici, ON CONFLICT DO NOTHING évite les erreurs si le couple id_streamer / id_defi existe déja.
-- =============================================================================================

DO $$
BEGIN
    FOR i IN 1..250000 LOOP
        INSERT INTO participation_defi (id_streamer, id_defi)
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            FLOOR(random() * 50000 + 1)::INT
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
END $$;


-- ============================
-- 6. J'insère 100 000 creneaux
-- ============================

DO $$
DECLARE
    start_date TIMESTAMP;
    end_date TIMESTAMP;
BEGIN
    FOR i IN 1..100000 LOOP
        start_date := TIMESTAMP '2025-09-05 18:00:00'
                      + (random() * 48)::INT * INTERVAL '1 hour';

        end_date := start_date
                    + (random() * 4 + 1)::INT * INTERVAL '1 hour';

        INSERT INTO creneau (
            id_streamer,
            date_debut_autorisee,
            date_fin_autorisee
        )
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            start_date,
            end_date
        );
    END LOOP;
END $$;


-- ===============================
-- 7. Insertion de 100 000 streams
-- ===============================

DO $$
DECLARE
    start_date TIMESTAMP;
    end_date TIMESTAMP;
    effective_end_date TIMESTAMP;
BEGIN
    FOR i IN 1..100000 LOOP
        start_date := TIMESTAMP '2025-09-05 18:00:00'
                      + (random() * 48)::INT * INTERVAL '1 hour';

        end_date := start_date
                    + (random() * 4 + 1)::INT * INTERVAL '1 hour';

        effective_end_date := CASE
            WHEN random() < 0.7
            THEN end_date
            ELSE end_date + (random() * 3)::INT * INTERVAL '1 hour'
        END;

        INSERT INTO stream (
            id_streamer,
            id_creneau,
            titre,
            heure_debut,
            heure_fin,
            date_fin_effective
        )
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            FLOOR(random() * 100000 + 1)::INT,
            'Stream caritatif ' || i,
            start_date,
            end_date,
            effective_end_date
        );
    END LOOP;
END $$;


-- ====================================
-- 8. Verification du volume de données
-- ====================================

SELECT COUNT(*) AS nombre_streamers FROM streamer;
SELECT COUNT(*) AS nombre_defis FROM defi;
SELECT COUNT(*) AS nombre_participations FROM participation_defi;
SELECT COUNT(*) AS nombre_creneaux FROM creneau;
SELECT COUNT(*) AS nombre_streams FROM stream;


-- ===========================================================
-- 9. Requête complexe SANS index
-- On observe le temps d'execution, les Seq Scan et les couts.
-- ===========================================================

EXPLAIN ANALYZE
SELECT
    s.pseudo,
    d.intitule,
    COUNT(st.id_stream) AS nb_streams,
    COUNT(CASE WHEN st.date_fin_effective > st.heure_fin THEN 1 END) AS nb_depassements
FROM streamer s
JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
JOIN defi d
    ON pd.id_defi = d.id_defi
LEFT JOIN stream st
    ON s.id_streamer = st.id_streamer
WHERE (s.id_streamer + 0) < 5000
GROUP BY
    s.id_streamer,
    s.pseudo,
    d.id_defi,
    d.intitule
ORDER BY
    s.pseudo,
    d.intitule;


-- ======================
-- 10. Création des index
-- ======================

CREATE INDEX idx_participation_defi_id_streamer
    ON participation_defi(id_streamer);

CREATE INDEX idx_participation_defi_id_defi
    ON participation_defi(id_defi);

CREATE INDEX idx_stream_id_streamer
    ON stream(id_streamer);

CREATE INDEX idx_stream_date_fin_effective
    ON stream(date_fin_effective);

CREATE INDEX idx_stream_id_streamer_date_fin_effective
    ON stream(id_streamer, date_fin_effective);


-- ==============================================================
-- 11. Mise a jour des statistiques PostgreSQL
-- ANALYZE permet d'aide l'optimiseur à choisir un meilleur plan.
-- ==============================================================

ANALYZE streamer;
ANALYZE defi;
ANALYZE participation_defi;
ANALYZE creneau;
ANALYZE stream;


-- ======================================
-- 12. Requête complexe APRES index
-- Je compare avec le résultat précedent.
-- ======================================

EXPLAIN ANALYZE
SELECT
    s.pseudo,
    d.intitule,
    COUNT(st.id_stream) AS nb_streams,
    COUNT(CASE WHEN st.date_fin_effective > st.heure_fin THEN 1 END) AS nb_depassements
FROM streamer s
JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
JOIN defi d
    ON pd.id_defi = d.id_defi
LEFT JOIN stream st
    ON s.id_streamer = st.id_streamer
WHERE (s.id_streamer + 0) < 5000
GROUP BY
    s.id_streamer,
    s.pseudo,
    d.id_defi,
    d.intitule
ORDER BY
    s.pseudo,
    d.intitule;


-- ==========================================
-- 13. Bonus : index pour les recherches LIKE
-- ==========================================

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX idx_streamer_pseudo_trgm
    ON streamer USING gin (pseudo gin_trgm_ops);


-- =====================================
-- 14. Test du LIKE avec EXPLAIN ANALYZE
-- =====================================

EXPLAIN ANALYZE
SELECT
    s.pseudo,
    COUNT(pd.id_defi) AS nb_defis
FROM streamer s
LEFT JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
WHERE s.pseudo LIKE '%pseudo%1%'
GROUP BY
    s.id_streamer,
    s.pseudo;


-- =======================================================
-- 15. Résultats observés et conclusion sur la performance
-- =======================================================

-- Volume de donnees charge :
-- streamer : environ 50 000 lignes
-- défi : environ 50 000 lignes
-- participation_defi : environ 250 000 lignes
-- créneau : environ 100 000 lignes
-- stream : environ 100 000 lignes

-- Résultat global qu'on observe dans pgAdmin :
-- Le script complet s'est execute correctement.
-- Temps total affiche par pgAdmin : 15,195 secondes.

-- Observation avant index :
-- Avant la creation des index, PostgreSQL doit parcourir un grand nombre de lignes pour effectuer les jointures entre streamer, participation_defi, defi et stream.
-- On peut observer des Seq Scan, c'est-a-dire des parcours complets de tables, notamment sur les tables volumineuses.

-- Observation apres index :
-- Apres la création des index, PostgreSQL dispose de chemins d'acces plus efficaces pour les jointures.
-- Les index les plus utiles sont :
-- idx_participation_defi_id_streamer
-- idx_participation_defi_id_defi
-- idx_stream_id_streamer
-- idx_stream_id_streamer_date_fin_effective

-- Formule a utiliser pour gain de performance :
-- ((temps_avant - temps_apres) / temps_avant) * 100

-- Observation sur le bonus LIKE :
-- Pour la requete :
-- WHERE s.pseudo LIKE '%pseudo%1%' PostgreSQL utilise l'index trigram idx_streamer_pseudo_trgm.
-- Le plan d'exécution montre un Bitmap Index Scan puis un Bitmap Heap Scan sur la table streamer.

-- Résultats observés pour le bonus LIKE :
-- Planning Time : 1.951 ms
-- Execution Time : 140.042 ms

-- Conclusion :
-- Les index ameliorent les performances principalement sur les jointures et les filtres appliques a de grands volumes de donnees.
-- Sans index, PostgreSQL doit souvent parcourir beaucoup de lignes avec des Seq Scan.
-- Avec les index, il peut retrouver plus rapidement les lignes utiles, notamment dans les tables participation_defi et stream.
-- L'index trigram est aussi efficace pour optimiser les recherches LIKE contenant un motif au milieu de la chaine, comme '%pseudo%1%'.
