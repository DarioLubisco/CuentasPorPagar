import pyodbc
from database import get_db_connection

conn = get_db_connection()
cursor = conn.cursor()

query = """
            SELECT cxp.CodProv, cxp.NumeroD, cxp.TipoCxP
            FROM dbo.SAACXP cxp
            WHERE cxp.NumeroD LIKE '%B0119408%'
"""
try:
    cursor.execute(query)
    rows = cursor.fetchall()
    print("Found rows:", rows)
except Exception as e:
    print('Error:', e)
