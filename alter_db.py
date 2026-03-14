import pyodbc
import os
import sys
from dotenv import load_dotenv

def alter_table():
    load_dotenv()
    
    DB_SERVER = os.getenv("DB_SERVER")
    DB_DATABASE = os.getenv("DB_DATABASE")
    DB_USERNAME = os.getenv("DB_USERNAME")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DRIVER = os.getenv("DRIVER", "{ODBC Driver 17 for SQL Server}")

    conn_str = (
        f"DRIVER={DRIVER};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_DATABASE};"
        f"UID={DB_USERNAME};"
        f"PWD={DB_PASSWORD}"
    )
    
    print(f"Connecting to {DB_DATABASE} on {DB_SERVER}...")
    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        print("Checking/Adding column MontoRetencionBs to Procurement.DebitNotesTracking...")
        cursor.execute("IF COL_LENGTH('Procurement.DebitNotesTracking', 'MontoRetencionBs') IS NULL BEGIN ALTER TABLE EnterpriseAdmin_AMC.Procurement.DebitNotesTracking ADD MontoRetencionBs DECIMAL(18,2) DEFAULT NULL END")
        conn.commit()
        print("Done!")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    alter_table()
