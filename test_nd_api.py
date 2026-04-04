import database
import json

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    # 1. Find a negative balance invoice
    cursor.execute("""
        SELECT TOP 1 cxp.NumeroD, cxp.CodProv, cxp.Monto, comp.MtoPagos
        FROM EnterpriseAdmin_AMC.dbo.SAACXP cxp
        JOIN EnterpriseAdmin_AMC.dbo.SACOMP comp ON cxp.NumeroD = comp.NumeroD AND cxp.CodProv = comp.CodProv
        WHERE cxp.TipoCxP = '10' AND (ISNULL(comp.MtoPagos,0) - cxp.Monto) > 1.0
    """)
    inv = cursor.fetchone()
    if not inv:
        print("No negative balance invoice found.")
    else:
        print("Found Invoice for Testing:", inv)
        
        # We simulate the API call to /api/procurement/debit-notes/register
        import requests
        payload = {
            "Invoices": [
                {
                    "NumeroD": inv[0],
                    "CodProv": inv[1],
                    "MontoRetencionBs": 0
                }
            ],
            "NotaDebitoID": "ND-TEST-001",
            "ControlID": "00-TEST-001"
        }
        res = requests.post("http://127.0.0.1:8080/api/procurement/debit-notes/register", json=payload)
        print("API Response:", res.status_code, res.text)
        
        # Check DB State after
        cursor.execute("SELECT Monto, Saldo, CancelC FROM EnterpriseAdmin_AMC.dbo.SAACXP WHERE NumeroD=? AND CodProv=? AND TipoCxP='10'", (inv[0], inv[1]))
        print("Invoice SAACXP After:", cursor.fetchone())
        
        cursor.execute("SELECT MtoTotal, MtoPagos FROM EnterpriseAdmin_AMC.dbo.SACOMP WHERE NumeroD=? AND CodProv=?", (inv[0], inv[1]))
        print("Invoice SACOMP After:", cursor.fetchone())
        
        cursor.execute("SELECT Monto, Saldo, CancelC FROM EnterpriseAdmin_AMC.dbo.SAACXP WHERE NumeroD='ND-TEST-001' AND TipoCxP='20'")
        print("ND SAACXP After:", cursor.fetchone())
        
except Exception as e:
    print(e)
finally:
    if 'conn' in locals():
        conn.close()
