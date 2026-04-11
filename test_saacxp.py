import database
c=database.get_db_connection().cursor()
c.execute("SELECT CodProv, NumeroD, Monto, CancelC, Saldo, TipoCxP FROM EnterpriseAdmin_AMC.dbo.SAACXP WHERE NumeroD='64741325'")
for r in c.fetchall():
    print(r)
