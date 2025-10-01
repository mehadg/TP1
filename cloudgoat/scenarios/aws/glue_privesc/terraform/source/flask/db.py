import psycopg2
import os

DB_NAME = os.environ.get("DB_NAME", "bob12cgvdb")
DB_USER = os.environ.get("DB_USER", "postgres")
DB_PASSWORD = os.environ.get("DB_PASSWORD")  # MUST be set in env or secret manager
DB_HOST = os.environ.get("AWS_RDS", "").split(":")[0]
DB_PORT = int(os.environ.get("DB_PORT", 5432))

if not DB_PASSWORD:
    raise RuntimeError("DB_PASSWORD non défini : configurez le secret dans l'environnement")

conn = psycopg2.connect(
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=DB_PORT,
)
