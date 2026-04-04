import database

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    invoice = '64700083'
    print(f"--- [REPARANDO FACTURA {invoice}] ---")
    
    # 1. Check current state in Saint
    cursor.execute("""
        SELECT NumeroD, CodProv, Monto, CancelC
        FROM EnterpriseAdmin_AMC.dbo.SAACXP
        WHERE NumeroD = ? AND TipoCxP = '10'
    """, (invoice,))
    saacxp = cursor.fetchone()
    
    cursor.execute("""
        SELECT NumeroD, CodProv, MtoTotal, MtoPagos
        FROM EnterpriseAdmin_AMC.dbo.SACOMP
        WHERE NumeroD = ? AND TipoCom = 'H'
    """, (invoice,))
    sacomp = cursor.fetchone()
    
    if saacxp and sacomp:
        print(f"Estado Actual SAACXP: Monto={saacxp[2]}, CancelC={saacxp[3]}")
        print(f"Estado Actual SACOMP: MtoTotal={sacomp[2]}, MtoPagos={sacomp[3]}")
        
        # Consistent fix: Set CancelC = Monto and MtoPagos = MtoTotal
        # To make it 'Paid' in Saint without negatives
        monto_f = float(saacxp[2])
        cod_prov = saacxp[1]
        
        cursor.execute("""
            UPDATE EnterpriseAdmin_AMC.dbo.SAACXP 
            SET CancelC = ?, Saldo = 0
            WHERE NumeroD = ? AND CodProv = ? AND TipoCxP = '10'
        """, (monto_f, invoice, cod_prov))
        
        cursor.execute("""
            UPDATE EnterpriseAdmin_AMC.dbo.SACOMP 
            SET MtoPagos = ?
            WHERE NumeroD = ? AND CodProv = ? AND TipoCom = 'H'
        """, (monto_f, invoice, cod_prov))
        
        conn.commit()
        print("REPARACIÓN EXITOSA: Factura 64700083 ahora tiene Saldo 0 en Saint.")
        
    else:
        print("Error: No se encontró la factura en Saint para reparar.")

    # 2. Search for other invoices with FechaV > 15/03/2026 and mismatch
    print("\n--- [BUSCANDO INCONGRUENCIAS (FechaV > 15/03/2026)] ---")
    cursor.execute("""
        SELECT 
            cxp.NumeroD, 
            cxp.CodProv, 
            cxp.FechaV,
            cxp.Monto,
            comp.MtoPagos as Pagos_Saint,
            ISNULL(portal.TotalBs, 0) as Pagos_Portal
        FROM EnterpriseAdmin_AMC.dbo.SAACXP cxp
        LEFT JOIN EnterpriseAdmin_AMC.dbo.SACOMP comp ON cxp.NumeroD = comp.NumeroD AND cxp.CodProv = comp.CodProv
        LEFT JOIN (
            SELECT NumeroD, CodProv, SUM(MontoBsAbonado) as TotalBs
            FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos
            GROUP BY NumeroD, CodProv
        ) portal ON cxp.NumeroD = portal.NumeroD AND cxp.CodProv = portal.CodProv
        WHERE cxp.TipoCxP = '10' 
        AND cxp.FechaV > '20260315'
        AND ABS(ISNULL(comp.MtoPagos, 0) - ISNULL(portal.TotalBs, 0)) > 1.0
        AND ISNULL(comp.MtoPagos, 0) > 0 -- Only where there's already a payment in Saint
    """)
    
    incongruencias = cursor.fetchall()
    if incongruencias:
        print(f"Se encontraron {len(incongruencias)} facturas con incongruencias post 15/03/2026:")
        for row in incongruencias:
            print(f"Factura: {row[0]} | Prov: {row[1]} | Vence: {row[2]} | Saint: {row[4]} | Portal: {row[5]}")
    else:
        print("No se encontraron otras incongruencias significativas en ese rango de fechas.")

except Exception as e:
    print("Error:", e)
finally:
    if 'conn' in locals():
        conn.close()
