import pyodbc
from database import get_db_connection

conn = get_db_connection()
cursor = conn.cursor()

query = """
SELECT CodProv, NumeroD, TipoCxP, Monto, Saldo, NroUnico 
FROM EnterpriseAdmin_AMC.dbo.SAACXP 
WHERE NumeroD='64741323'
"""
cursor.execute(query)
for row in cursor.fetchall():
    print(row)
