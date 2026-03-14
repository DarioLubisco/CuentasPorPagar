import pyodbc
from database import get_db_connection
import json

def dec_default(obj):
    if hasattr(obj, 'isoformat'):
        return obj.isoformat()
    return float(obj)

def main():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute("SELECT * FROM dbo.SAACXP WHERE NumeroD = '64608258'")
        columns = [column[0] for column in cursor.description]
        res = [dict(zip(columns, row)) for row in cursor.fetchall()]
        print(json.dumps(res, default=dec_default, indent=2))
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    main()
