import database

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    invoice = '64700083'
    print(f"--- [DEEP CHECK FACTURA {invoice}] ---")
    
    # 1. Consultar SAACXP exacto
    cursor.execute("""
        SELECT NumeroD, CodProv, Monto, CancelC, Saldo, TipoCxP
        FROM EnterpriseAdmin_AMC.dbo.SAACXP
        WHERE NumeroD = ? AND TipoCxP = '10'
    """, (invoice,))
    saacxp = cursor.fetchone()
    print("SAACXP:", saacxp)
    
    # 2. Consultar SACOMP exacto
    cursor.execute("""
        SELECT NumeroD, CodProv, MtoTotal, Contado, MtoPagos, TipoCom
        FROM EnterpriseAdmin_AMC.dbo.SACOMP
        WHERE NumeroD = ? AND TipoCom = 'H'
    """, (invoice,))
    sacomp = cursor.fetchone()
    print("SACOMP:", sacomp)
    
    # 3. Consultar Abonos Locales exactos
    cursor.execute("""
        SELECT AbonoID, MontoBsAbonado, TipoAbono
        FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos
        WHERE NumeroD = ?
    """, (invoice,))
    abonos = cursor.fetchall()
    print("CxP_Abonos:", abonos)

except Exception as e:
    print("Error:", e)
finally:
    if 'conn' in locals():
        conn.close()
