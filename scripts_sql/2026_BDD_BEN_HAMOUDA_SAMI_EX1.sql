-- ==========================================================
-- Exercice 1 : Creation et population de la base de donnees
-- Projet : Gestion de l'infrastructure de donnees du ZEvent
-- Realise par : Sami Ben Hamouda
-- ==========================================================

-- ==================================================================
-- 1. Suppression des tables si elles existent déjà pour partir de 0
-- ==================================================================

DROP TABLE IF EXISTS stream CASCADE;
DROP TABLE IF EXISTS participation_defi CASCADE;
DROP TABLE IF EXISTS creneau CASCADE;
DROP TABLE IF EXISTS defi CASCADE;
DROP TABLE IF EXISTS streamer CASCADE;

-- =======================
-- 2. Création des tables
-- =======================

CREATE TABLE streamer (
    id_streamer SERIAL PRIMARY KEY,
    pseudo VARCHAR(100) UNIQUE NOT NULL,
    url_twitch VARCHAR(255) NOT NULL
);

CREATE TABLE creneau (
    id_creneau SERIAL PRIMARY KEY,
    id_streamer INT NOT NULL,
    date_debut_autorisee TIMESTAMP NOT NULL,
    date_fin_autorisee TIMESTAMP NOT NULL,

    CONSTRAINT fk_creneau_streamer
        FOREIGN KEY (id_streamer)
        REFERENCES streamer(id_streamer)
        ON DELETE CASCADE
);

CREATE TABLE defi (
    id_defi SERIAL PRIMARY KEY,
    intitule VARCHAR(255) NOT NULL,
    montant_palier DECIMAL(12,2) NOT NULL,
    etat_validation BOOLEAN NOT NULL
);

CREATE TABLE participation_defi (
    id_streamer INT NOT NULL,
    id_defi INT NOT NULL,

    PRIMARY KEY (id_streamer, id_defi),

    CONSTRAINT fk_participation_streamer
        FOREIGN KEY (id_streamer)
        REFERENCES streamer(id_streamer)
        ON DELETE CASCADE,

    CONSTRAINT fk_participation_defi
        FOREIGN KEY (id_defi)
        REFERENCES defi(id_defi)
        ON DELETE CASCADE
);

CREATE TABLE stream (
    id_stream SERIAL PRIMARY KEY,
    id_streamer INT NOT NULL,
    id_creneau INT NOT NULL,
    titre VARCHAR(255) NOT NULL,
    heure_debut TIMESTAMP NOT NULL,
    heure_fin TIMESTAMP NOT NULL,
    date_fin_effective TIMESTAMP NULL,

    CONSTRAINT fk_stream_streamer
        FOREIGN KEY (id_streamer)
        REFERENCES streamer(id_streamer)
        ON DELETE CASCADE,

    CONSTRAINT fk_stream_creneau
        FOREIGN KEY (id_creneau)
        REFERENCES creneau(id_creneau)
        ON DELETE CASCADE
);

-- ============================================================
-- 3. Table STREAMER
-- Dictionnaire :
-- id_streamer : identifiant unique du streamer
-- pseudo : pseudo Twitch unique du streamer
-- url_twitch : lien vers la chaine Twitch du streamer
-- J'ai choisi des streamers assez connus pour faire mes tests
-- ============================================================

INSERT INTO streamer (pseudo, url_twitch) VALUES
('ZeratoR', 'https://twitch.tv/zerator'),
('AntoineDaniel', 'https://twitch.tv/antoinedaniel'),
('MisterMV', 'https://twitch.tv/mistermv'),
('Ultia', 'https://twitch.tv/ultia'),
('BagheraJones', 'https://twitch.tv/bagherajones'),
('Domingo', 'https://twitch.tv/domingo'),
('Ponce', 'https://twitch.tv/ponce'),
('Etoiles', 'https://twitch.tv/etoiles'),
('AngleDroit', 'https://twitch.tv/angledroit'),
('JoueurDuGrenier', 'https://twitch.tv/joueurdugrenier');

-- ==============================================================================
-- 4. Table CRENEAU
-- Dictionnaire :
-- id_creneau : identifiant unique du créneau
-- id_streamer : streamer autorise sur ce créneau
-- date_debut_autorisee : debut du créneau autorisé
-- date_fin_autorisee : fin du créneau autorise
-- J'ai choisi des créneaux aléatoires mais plutôt commun à beaucoup de streamers
-- ==============================================================================

INSERT INTO creneau (id_streamer, date_debut_autorisee, date_fin_autorisee) VALUES
(1, '2025-09-05 18:00:00', '2025-09-05 21:00:00'),
(1, '2025-09-06 10:00:00', '2025-09-06 13:00:00'),

(2, '2025-09-05 21:00:00', '2025-09-06 00:00:00'),
(2, '2025-09-06 13:00:00', '2025-09-06 16:00:00'),

(3, '2025-09-06 00:00:00', '2025-09-06 03:00:00'),
(3, '2025-09-06 16:00:00', '2025-09-06 19:00:00'),

(4, '2025-09-06 03:00:00', '2025-09-06 06:00:00'),
(4, '2025-09-06 19:00:00', '2025-09-06 22:00:00'),

(5, '2025-09-06 06:00:00', '2025-09-06 09:00:00'),
(5, '2025-09-06 22:00:00', '2025-09-07 01:00:00'),

(6, '2025-09-07 01:00:00', '2025-09-07 04:00:00'),
(6, '2025-09-07 12:00:00', '2025-09-07 15:00:00'),

(7, '2025-09-07 04:00:00', '2025-09-07 07:00:00'),
(7, '2025-09-07 15:00:00', '2025-09-07 18:00:00'),

(8, '2025-09-07 07:00:00', '2025-09-07 10:00:00'),
(8, '2025-09-07 18:00:00', '2025-09-07 21:00:00'),

(9, '2025-09-07 10:00:00', '2025-09-07 12:00:00'),
(9, '2025-09-07 21:00:00', '2025-09-08 00:00:00'),

(10, '2025-09-08 00:00:00', '2025-09-08 03:00:00'),
(10, '2025-09-08 10:00:00', '2025-09-08 13:00:00');

-- =======================================================
-- 5. Table DEFI
-- Dictionnaire :
-- id_defi : identifiant unique du défi
-- intitule : nom du défi
-- montant_palier : objectif de donation en euros
-- etat_validation : indique si le defi est validé ou non
-- J'ai choisi des défis commun du ZEvent
-- =======================================================

INSERT INTO defi (intitule, montant_palier, etat_validation) VALUES
('Saut en parachute', 100000.00, FALSE),
('Teinture de cheveux', 10000.00, TRUE),
('Stream jeu horreur', 5000.00, TRUE),
('Tournoi Mario Kart', 15000.00, FALSE),
('Karaoke en direct', 3000.00, TRUE),
('Cosplay impose', 20000.00, FALSE),
('Speedrun caritatif', 8000.00, TRUE),
('Emission cuisine', 12000.00, FALSE),
('Blind test musical', 2500.00, TRUE),
('Defi sportif en live', 50000.00, FALSE);

-- ==================================================
-- 6. Table PARTICIPATION_DEFI
-- Dictionnaire :
-- id_streamer : identifiant du streamer participant
-- id_defi : identifiant du défi concerne
-- Cette table gère la relation n-n
-- ==================================================

INSERT INTO participation_defi (id_streamer, id_defi) VALUES
(1, 1),
(2, 1),
(3, 1),

(1, 2),
(4, 2),

(2, 3),
(5, 3),

(6, 4),
(7, 4),
(8, 4),

(3, 5),
(9, 5),

(4, 6),
(10, 6),

(5, 7),
(6, 8),
(7, 9),
(8, 10);

-- =================================================================
-- 7. Table STREAM
-- Dictionnaire :
-- id_stream : identifiant unique du stream
-- id_streamer : streamer qui diffuse
-- id_creneau : créneau respecte par le stream
-- titre : titre de la session
-- heure_debut : heure réelle de debut
-- heure_fin : heure prévue de fin
-- date_fin_effective : heure réelle de fin, nullable si non terminé
-- J'ai choisi pas mal de live potentiellement possible sur twitch
-- ==================================================================

INSERT INTO stream (
    id_streamer,
    id_creneau,
    titre,
    heure_debut,
    heure_fin,
    date_fin_effective
) VALUES
(1, 1, 'Ouverture du ZEvent avec ZeratoR', '2025-09-05 18:10:00', '2025-09-05 20:50:00', '2025-09-05 20:55:00'),
(1, 2, 'Session discussion donations', '2025-09-06 10:15:00', '2025-09-06 12:45:00', NULL),

(2, 3, 'Live humour et anecdotes', '2025-09-05 21:05:00', '2025-09-05 23:50:00', '2025-09-05 23:50:00'),
(2, 4, 'Gaming caritatif', '2025-09-06 13:10:00', '2025-09-06 15:45:00', NULL),

(3, 5, 'Session retro gaming', '2025-09-06 00:05:00', '2025-09-06 02:55:00', '2025-09-06 03:10:00'),
(3, 6, 'Speedrun challenge', '2025-09-06 16:15:00', '2025-09-06 18:45:00', '2025-09-06 18:45:00'),

(4, 7, 'Discussion avec la communaute', '2025-09-06 03:10:00', '2025-09-06 05:50:00', NULL),
(4, 8, 'Defi cosplay en live', '2025-09-06 19:05:00', '2025-09-06 21:30:00', '2025-09-06 21:40:00'),

(5, 9, 'Matinale du ZEvent', '2025-09-06 06:10:00', '2025-09-06 08:45:00', '2025-09-06 08:45:00'),
(5, 10, 'Live de nuit caritatif', '2025-09-06 22:10:00', '2025-09-07 00:45:00', NULL),

(6, 11, 'Emission talk-show', '2025-09-07 01:10:00', '2025-09-07 03:50:00', '2025-09-07 04:00:00'),
(7, 13, 'Gaming chill avec viewers', '2025-09-07 04:15:00', '2025-09-07 06:45:00', '2025-09-07 06:45:00'),
(8, 15, 'Quiz culture generale', '2025-09-07 07:20:00', '2025-09-07 09:30:00', NULL),
(9, 17, 'Debat et blind test', '2025-09-07 10:05:00', '2025-09-07 11:50:00', '2025-09-07 11:55:00'),
(10, 19, 'Cloture de nuit', '2025-09-08 00:10:00', '2025-09-08 02:50:00', NULL);

-- =====================================
-- 8. Vérification des données inserées
-- =====================================

SELECT * FROM streamer;
SELECT * FROM creneau;
SELECT * FROM defi;
SELECT * FROM participation_defi;
SELECT * FROM stream;
