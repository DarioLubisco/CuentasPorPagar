import os
import pyodbc
from dotenv import load_dotenv

load_dotenv()

DB_SERVER = os.getenv("DB_SERVER")
DB_DATABASE = os.getenv("DB_DATABASE")
DB_USERNAME = os.getenv("DB_USERNAME")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DRIVER = os.getenv("DRIVER", "{ODBC Driver 17 for SQL Server}")

def get_db_connection():
    if not all([DB_SERVER, DB_DATABASE, DB_USERNAME, DB_PASSWORD]):
         raise Exception("Missing required DB environment variables")
         
    conn_str = (
        f"DRIVER={DRIVER};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_DATABASE};"
        f"UID={DB_USERNAME};"
        f"PWD={DB_PASSWORD}"
    )
    conn = pyodbc.connect(conn_str)
    conn.timeout = 30 # Prevent Lock request timeouts
    return conn
