import database
conn = database.get_db_connection()
cursor = conn.cursor()

invs = ('0565206', '05655205')
print("--- VITALCLINIC INVOICES ---")
cursor.execute("SELECT NumeroD, CodProv, Saldo, Monto, FechaE FROM EnterpriseAdmin_AMC.dbo.SAACXP WHERE NumeroD IN (?, ?)", invs)
for row in cursor.fetchall():
    print("SAACXP:", row)

cursor.execute("SELECT NumeroD, MtoTotal, Factor, MontoMEx FROM EnterpriseAdmin_AMC.dbo.SACOMP WHERE NumeroD IN (?, ?)", invs)
for row in cursor.fetchall():
    print("SACOMP:", row)
