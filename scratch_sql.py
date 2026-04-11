import database
conn = database.get_db_connection()
cursor = conn.cursor()

try:
    cursor.execute("SELECT NroUnico, TipoCxP, Monto, NumeroD, CancelC, Saldo FROM EnterpriseAdmin_AMC.dbo.SAACXP WHERE NumeroD = '00092540'")
    print("SAACXP para 00092540:")
    for r in cursor.fetchall():
        print(r)
finally:
    conn.close()
