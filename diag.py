import pyodbc
import json

conn_str = "DRIVER={ODBC Driver 17 for SQL Server};SERVER=10.200.8.5;DATABASE=SACOMP;UID=sa;PWD=saint"
try:
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    
    # Check SAACXP
    cursor.execute("SELECT NumeroD, CodProv, Monto, Saldo, MtoTax FROM dbo.SAACXP WHERE NumeroD = '00002183' AND CodProv = 'MEDICAL JR 23 C.A'")
    cxp = cursor.fetchone()
    print(f"SAACXP: {cxp}")
    
    # Check Abonos
    cursor.execute("SELECT * FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE NumeroD = '00002183' AND CodProv = 'MEDICAL JR 23 C.A'")
    abonos = cursor.fetchall()
    print(f"Abonos: {abonos}")
    
    conn.close()
except Exception as e:
    print(f"Error: {e}")
