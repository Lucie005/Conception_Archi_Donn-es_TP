-- 1. Afficher le top 5 des livres les mieux notés avec leur genre et auteur
SELECT l.titre, g.nom AS genre, a.nom AS auteur, l.note_moyenne
FROM livres l
         JOIN genres g ON l.genre_id = g.id
         JOIN livre_auteur la ON l.isbn = la.livre_isbn
         JOIN auteurs a ON la.auteur_id = a.id
ORDER BY l.note_moyenne DESC NULLS LAST
    LIMIT 5;

-- 2. Identifier les membres les plus actifs (ceux qui ont publié le plus de critiques)
SELECT m.pseudo, COUNT(c.livre_isbn) AS nombre_critiques
FROM membres m
         JOIN critiques c ON m.email = c.membre_email
GROUP BY m.email, m.pseudo
ORDER BY nombre_critiques DESC
    LIMIT 5;

-- 3. Lister les livres actuellement "en cours" de lecture dans les bibliothèques des membres
SELECT m.pseudo, l.titre, b.date_ajout
FROM bibliotheque b
         JOIN membres m ON b.membre_email = m.email
         JOIN livres l ON b.livre_isbn = l.isbn
WHERE b.statut = 'en cours'
ORDER BY b.date_ajout DESC;