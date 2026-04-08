import database

conn = database.get_db_connection()
cursor = conn.cursor()

query = """
SELECT COUNT(*) as Count, SUM(Monto) as TotalSum 
FROM EnterpriseAdmin_AMC.dbo.SAACXP 
WHERE TipoCxP = '10' AND Saldo = 0 AND FechaV > GETDATE()
"""
cursor.execute(query)
row = cursor.fetchone()
print(f"COUNT: {row[0]}, SUM: {row[1]}")
