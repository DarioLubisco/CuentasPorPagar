import database

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT CodProv, NumeroD, NotaDebitoID FROM EnterpriseAdmin_AMC.Procurement.DebitNotesTracking WHERE Id = 1")
    row = cursor.fetchone()
    print("row:", row)
except Exception as e:
    print(e)
