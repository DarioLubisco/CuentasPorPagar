import database

conn = database.get_db_connection()
cursor = conn.cursor()

print("--- SAACXP ---")
query = """
SELECT NroUnico, TipoCxP, Monto, Saldo, MontoNeto, MtoTax, RetenIVA, CancelT
FROM EnterpriseAdmin_AMC.dbo.SAACXP 
WHERE NumeroD = '64741323'
"""
cursor.execute(query)
rows = cursor.fetchall()
for r in rows:
    print(f"[{r.NroUnico}] TipoCxP: {r.TipoCxP} | Monto: {r.Monto} | Saldo: {r.Saldo} | MtoTax: {r.MtoTax} | RetenIVA: {r.RetenIVA} | CancelT: {r.CancelT}")
    
print("\n--- SAPAGCXP (Pagos en Saint) ---")
q2 = """
SELECT NroUnico, NroRegi, Monto, EsReten
FROM EnterpriseAdmin_AMC.dbo.SAPAGCXP
WHERE NumeroD = '64741323' OR NroRegi IN (SELECT NroUnico FROM EnterpriseAdmin_AMC.dbo.SAACXP WHERE NumeroD='64741323')
"""
cursor.execute(q2)
pagos = cursor.fetchall()
for p in pagos:
    print(f"[{p.NroUnico}] NroRegi: {p.NroRegi} | Monto: {p.Monto} | EsReten: {p.EsReten}")

print("\n--- CxP_Abonos (Portal) ---")
q3 = """
SELECT AbonoID, TipoAbono, MontoBsAbonado
FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos
WHERE NumeroD = '64741323'
"""
cursor.execute(q3)
abonos = cursor.fetchall()
if not abonos:
    print("Ninguno")
for a in abonos:
    print(f"[{a.AbonoID}] {a.TipoAbono} - {a.MontoBsAbonado}")

