import os
import pyodbc
from dotenv import load_dotenv

load_dotenv()

def grant_perms():
    DB_SERVER = os.getenv("DB_SERVER")
    DB_DATABASE = "EnterpriseAdmin_AMC"
    DB_USERNAME = "sa"
    DB_PASSWORD = os.getenv("SA_PASSWORD", "Twinc3pt.")
    DRIVER = os.getenv("DRIVER", "{ODBC Driver 17 for SQL Server}")

    conn_str = (
        f"DRIVER={DRIVER};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_DATABASE};"
        f"UID={DB_USERNAME};"
        f"PWD={DB_PASSWORD}"
    )
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    
    try:
        # Give permission to READAMC to write to that specific table
        cursor.execute("GRANT SELECT, INSERT, UPDATE, DELETE ON EnterpriseAdmin_AMC.Procurement.PagosPlanificados TO READAMC")
        conn.commit()
        print("Permissions successfully granted to READAMC.")
    except Exception as e:
        print(f"Error granting permissions: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    grant_perms()
