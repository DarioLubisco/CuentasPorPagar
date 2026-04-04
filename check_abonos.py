import database

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT name, is_identity FROM sys.columns WHERE object_id = object_id('EnterpriseAdmin_AMC.dbo.CxP_Abonos')")
    for r in cursor.fetchall():
        print(r)
except Exception as e:
    print(e)
