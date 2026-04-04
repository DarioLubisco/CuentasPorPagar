import database

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CxP_Abonos' AND TABLE_SCHEMA = 'dbo'")
    print("CxP_Abonos Columns:", [r[0] for r in cursor.fetchall()])
except Exception as e:
    print(e)
finally:
    if 'conn' in locals():
        conn.close()
