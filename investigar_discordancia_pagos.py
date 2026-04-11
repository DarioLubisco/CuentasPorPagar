import database

def find_mismatched_paid_invoices():
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    print("--- INVESTIGACIÓN DE FACTURAS PAGADAS EN SAINT vs ABONOS PORTAL (Vencimiento >= 2026-04-01) ---")
    
    query = """
    SELECT 
        cxp.NumeroD, 
        cxp.CodProv, 
        p.Descrip as Proveedor,
        cxp.Monto, 
        cxp.CancelC, 
        cxp.Saldo, 
        cxp.FechaV,
        ISNULL(portal.TotalAbonado, 0) as TotalAbonadoPortal
    FROM EnterpriseAdmin_AMC.dbo.SAACXP cxp
    INNER JOIN EnterpriseAdmin_AMC.dbo.SAPROV p ON cxp.CodProv = p.CodProv
    OUTER APPLY (
        SELECT SUM(MontoBsAbonado) as TotalAbonado
        FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos a
        WHERE a.NumeroD = cxp.NumeroD AND a.CodProv = cxp.CodProv
    ) portal
    WHERE cxp.TipoCxP = '10' -- Facturas
      AND cxp.FechaV >= '2026-04-01' -- Vencimiento solicitado
      AND (cxp.Saldo <= 0.1 OR cxp.CancelC >= cxp.Monto - 0.1) -- Marcadas como pagadas en Saint
      AND (ISNULL(portal.TotalAbonado, 0) < cxp.Monto - 0.5) -- Pero el portal no tiene el abono completo registrado
    ORDER BY cxp.FechaV ASC
    """
    
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        
        if not rows:
            print("\n[✓] No se encontraron facturas con esa discrepancia para el rango de fechas solicitado.")
        else:
            print(f"\n[!] Se encontraron {len(rows)} facturas en conflicto:")
            print(f"{'Factura':<15} | {'Proveedor':<30} | {'Monto':<12} | {'Portal Abono':<12} | {'Vencimiento'}")
            print("-" * 85)
            for r in rows:
                print(f"{r.NumeroD:<15} | {r.Proveedor[:30]:<30} | {r.Monto:12,.2f} | {r.TotalAbonadoPortal:12,.2f} | {r.FechaV.strftime('%Y-%m-%d')}")
    except Exception as e:
        print(f"Error en la consulta: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    find_mismatched_paid_invoices()
