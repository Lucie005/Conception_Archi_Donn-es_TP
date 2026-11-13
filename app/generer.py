import psycopg2
from faker import Faker
import random

fake = Faker('fr_FR')

DB_CONFIG = {
    "dbname": "ombelle",
    "user": "postgres",
    "password": "password",
    "host": "localhost",
    "port": "5432"
}

def generer_donnees():
    conn = None
    cur = None
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        print("Connexion à la base réussie.")

        genres = ['Science-Fiction', 'Polar', 'Fantasy', 'Romance', 'Historique']
        for g in genres:
            cur.execute("INSERT INTO genres (nom) VALUES (%s) ON CONFLICT DO NOTHING RETURNING id;", (g,))
        cur.execute("SELECT id FROM genres;")
        genre_ids = [row[0] for row in cur.fetchall()]

        auteur_ids = []
        for _ in range(10):
            cur.execute("INSERT INTO auteurs (nom) VALUES (%s) RETURNING id;", (fake.name(),))
            auteur_ids.append(cur.fetchone()[0])

        isbns = []
        for _ in range(20):
            isbn = fake.isbn13().replace("-", "")
            titre = fake.sentence(nb_words=4)[:-1]
            nb_pages = random.randint(100, 800)
            parution = fake.date_between(start_date='-50y', end_date='today')
            genre_id = random.choice(genre_ids)

            cur.execute("""
                        INSERT INTO livres (isbn, titre, nb_pages, parution, genre_id)
                        VALUES (%s, %s, %s, %s, %s) ON CONFLICT DO NOTHING;
                        """, (isbn, titre, nb_pages, parution, genre_id))
            isbns.append(isbn)

            cur.execute("INSERT INTO livre_auteur (livre_isbn, auteur_id) VALUES (%s, %s) ON CONFLICT DO NOTHING;",
                        (isbn, random.choice(auteur_ids)))

        emails = []
        for _ in range(15):
            email = fake.unique.email()
            pseudo = fake.user_name()
            bio = fake.text(max_nb_chars=200)
            cur.execute("INSERT INTO membres (email, pseudo, bio) VALUES (%s, %s, %s);", (email, pseudo, bio))
            emails.append(email)

        for email in emails:
            livres_critiques = random.sample(isbns, random.randint(0, 3))
            for isbn in livres_critiques:
                note = random.randint(1, 5)
                commentaire = fake.paragraph() if random.choice([True, False]) else None
                cur.execute("""
                            INSERT INTO critiques (membre_email, livre_isbn, note, commentaire)
                            VALUES (%s, %s, %s, %s) ON CONFLICT DO NOTHING;
                            """, (email, isbn, note, commentaire))

        conn.commit()
        print("✅ Données générées avec succès ! Les triggers ont calculé les moyennes automatiquement.")

    except Exception as e:
        print(f"Erreur : {e}")
        if conn:
            conn.rollback()
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

if __name__ == '__main__':
    generer_donnees()