import database
conn = database.get_db_connection()
c = conn.cursor()
c.execute("DELETE FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE NumeroD='00092540' AND Referencia='PAGO HISTÓRICO SAINT (Surgical)'")
print(f"Deleted {c.rowcount} manual surgical rows.")
conn.commit()
conn.close()
