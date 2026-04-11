import database
conn = database.get_db_connection()
cursor = conn.cursor()
try:
    cursor.execute("SELECT * FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE NumeroD = '64741325'")
    abonos = cursor.fetchall()
    print(f"ABONOS PORTAL: {len(abonos)}")
    for r in abonos: print(r)
    
    cursor.execute("SELECT Monto, CancelC, Saldo FROM EnterpriseAdmin_AMC.dbo.SAACXP WHERE NumeroD = '64741325' AND TipoCxP='10'")
    print(f"SAACXP: {cursor.fetchone()}")
finally:
    conn.close()
