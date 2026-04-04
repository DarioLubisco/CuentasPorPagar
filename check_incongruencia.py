import database

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    invoice = '64700083'
    print(f"--- [REVISANDO FACTURA {invoice}] ---")
    
    # 1. Check native Saint data (SAACXP and SACOMP)
    cursor.execute("""
        SELECT 
            cxp.NumeroD, 
            cxp.CodProv, 
            cxp.Monto, 
            cxp.Saldo as Saldo_SAACXP,
            comp.MtoTotal, 
            comp.Contado, 
            comp.MtoPagos,
            (ISNULL(comp.MtoTotal, cxp.Monto) - ISNULL(comp.Contado, 0) - ISNULL(comp.MtoPagos, 0)) AS Saldo_Calculado_SACOMP,
            comp.Factor
        FROM EnterpriseAdmin_AMC.dbo.SAACXP cxp
        LEFT JOIN EnterpriseAdmin_AMC.dbo.SACOMP comp ON cxp.NumeroD = comp.NumeroD AND cxp.CodProv = comp.CodProv
        WHERE cxp.NumeroD = ? AND cxp.TipoCxP = '10'
    """, (invoice,))
    
    row = cursor.fetchone()
    if row:
        print(f"NúmeroD: {row[0]} | CodProv: {row[1]}")
        print(f"Monto Original: {row[2]} | Factor (Tasa Emisión): {row[8]}")
        print(f"Saldo SAACXP (Nativo): {row[3]}")
        print(f"SACOMP -> Total: {row[4]} | Contado: {row[5]} | Pagos: {row[6]}")
        print(f"Saldo Calculado (SACOMP Logic): {row[7]}")
    else:
        print("No se encontró la factura en las tablas maestras.")

    # 2. Check Portal Abonos (CxP_Abonos)
    print("\n--- [ABONOS EN PORTAL (CxP_Abonos)] ---")
    cursor.execute("""
        SELECT AbonoID, FechaAbono, MontoBsAbonado, AmortizadoUSD, TasaBCV, TipoAbono
        FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos
        WHERE NumeroD = ?
    """, (invoice,))
    abonos = cursor.fetchall()
    if abonos:
        for a in abonos:
            print(f"ID: {a[0]} | Fecha: {a[1]} | MontoBs: {a[2]} | USD: {a[3]} | Tasa: {a[4]} | Tipo: {a[5]}")
    else:
        print("No hay abonos registrados en el portal para esta factura.")

    # 3. Search for other potential discrepancies (Mismatches between Portal and Saint)
    print("\n--- [BÚSQUEDA DE OTRAS INCONGRUENCIAS EN EL SISTEMA] ---")
    # Facs where Portal sum != Saint MtoPagos (Approx)
    cursor.execute("""
        SELECT TOP 5
            cxp.NumeroD,
            comp.MtoPagos as Pagos_Saint,
            portal.TotalBs as Pagos_Portal
        FROM EnterpriseAdmin_AMC.dbo.SAACXP cxp
        JOIN EnterpriseAdmin_AMC.dbo.SACOMP comp ON cxp.NumeroD = comp.NumeroD AND cxp.CodProv = comp.CodProv
        OUTER APPLY (
            SELECT SUM(MontoBsAbonado) as TotalBs
            FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos a
            WHERE a.NumeroD = cxp.NumeroD AND a.CodProv = cxp.CodProv
        ) portal
        WHERE cxp.TipoCxP = '10' 
        AND ABS(ISNULL(comp.MtoPagos,0) - ISNULL(portal.TotalBs,0)) > 1.0
    """)
    mismatches = cursor.fetchall()
    if mismatches:
        print("Muestra de facturas donde los pagos de Saint NO coinciden con los del Portal:")
        for m in mismatches:
            print(f"Inv: {m[0]} | Saint: {m[1]} | Portal: {m[2]}")
    else:
        print("No se encontraron discrepancias obvias de cuadre entre Portal y Saint en la muestra.")

except Exception as e:
    print("Error:", e)
finally:
    if 'conn' in locals():
        conn.close()
