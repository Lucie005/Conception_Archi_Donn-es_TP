-- Suppression des tables existantes pour pouvoir relancer le script proprement
DROP TABLE IF EXISTS abonnements, bibliotheque, membre_club, critiques, livre_auteur, livres, genres, auteurs, clubs, membres CASCADE;

-- ==========================================
-- 1. CRÉATION DES TABLES (ENTITÉS)
-- ==========================================

CREATE TABLE membres (
                         email VARCHAR(255) PRIMARY KEY,
                         pseudo VARCHAR(100) NOT NULL,
                         inscrit_le TIMESTAMP NOT NULL DEFAULT NOW(),
                         bio TEXT
);

CREATE TABLE genres (
                        id SERIAL PRIMARY KEY,
                        nom VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE auteurs (
                         id SERIAL PRIMARY KEY,
                         nom VARCHAR(150) NOT NULL
);

CREATE TABLE clubs (
                       id SERIAL PRIMARY KEY,
                       nom VARCHAR(150) NOT NULL UNIQUE,
                       date_creation TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE livres (
                        isbn VARCHAR(20) PRIMARY KEY,
                        titre VARCHAR(255) NOT NULL,
                        nb_pages INTEGER NOT NULL CHECK (nb_pages > 0),
                        parution DATE NOT NULL,
                        note_moyenne NUMERIC(3, 2) DEFAULT NULL, -- Dénormalisation
                        genre_id INTEGER NOT NULL REFERENCES genres(id) ON DELETE RESTRICT
);

-- ==========================================
-- 2. CRÉATION DES TABLES (ASSOCIATIONS)
-- ==========================================

CREATE TABLE livre_auteur (
                              livre_isbn VARCHAR(20) REFERENCES livres(isbn) ON DELETE CASCADE,
                              auteur_id INTEGER REFERENCES auteurs(id) ON DELETE CASCADE,
                              PRIMARY KEY (livre_isbn, auteur_id)
);

CREATE TABLE critiques (
                           membre_email VARCHAR(255) REFERENCES membres(email) ON DELETE CASCADE,
                           livre_isbn VARCHAR(20) REFERENCES livres(isbn) ON DELETE CASCADE,
                           note INTEGER NOT NULL CHECK (note BETWEEN 1 AND 5),
                           publie_le TIMESTAMP NOT NULL DEFAULT NOW(),
                           commentaire TEXT,
                           PRIMARY KEY (membre_email, livre_isbn)
);

CREATE TABLE membre_club (
                             membre_email VARCHAR(255) REFERENCES membres(email) ON DELETE CASCADE,
                             club_id INTEGER REFERENCES clubs(id) ON DELETE CASCADE,
                             PRIMARY KEY (membre_email, club_id)
);

CREATE TABLE bibliotheque (
                              membre_email VARCHAR(255) REFERENCES membres(email) ON DELETE CASCADE,
                              livre_isbn VARCHAR(20) REFERENCES livres(isbn) ON DELETE CASCADE,
                              statut VARCHAR(50) NOT NULL CHECK (statut IN ('à lire', 'en cours', 'lu')),
                              date_ajout TIMESTAMP NOT NULL DEFAULT NOW(),
                              PRIMARY KEY (membre_email, livre_isbn)
);

CREATE TABLE abonnements (
                             suiveur_email VARCHAR(255) REFERENCES membres(email) ON DELETE CASCADE,
                             suivi_email VARCHAR(255) REFERENCES membres(email) ON DELETE CASCADE,
                             PRIMARY KEY (suiveur_email, suivi_email),
                             CHECK (suiveur_email != suivi_email) -- On ne peut pas se suivre soi-même
    );

-- ==========================================
-- 3. TRIGGER POUR LA DÉNORMALISATION
-- ==========================================

-- Fonction qui recalcule la moyenne d'un livre
CREATE OR REPLACE FUNCTION maj_note_moyenne()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
UPDATE livres
SET note_moyenne = (SELECT ROUND(AVG(note), 2) FROM critiques WHERE livre_isbn = OLD.livre_isbn)
WHERE isbn = OLD.livre_isbn;
RETURN OLD;
ELSE
UPDATE livres
SET note_moyenne = (SELECT ROUND(AVG(note), 2) FROM critiques WHERE livre_isbn = NEW.livre_isbn)
WHERE isbn = NEW.livre_isbn;
RETURN NEW;
END IF;
END;
$$ LANGUAGE plpgsql;

-- Déclencheur attaché à la table critiques
CREATE TRIGGER trigger_maj_note_moyenne
    AFTER INSERT OR UPDATE OR DELETE ON critiques
    FOR EACH ROW EXECUTE FUNCTION maj_note_moyenne();