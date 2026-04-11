import database

def mass_force_portal_truth():
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    print("--- [MODO REVERSIÓN: FORZANDO SAINT A MATCH CON EL PORTAL (RESTABLECER DEUDA)] ---")
    
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
    WHERE cxp.TipoCxP = '10' 
      AND cxp.FechaV >= '2026-04-01' 
      AND (cxp.Saldo <= 0.1 OR cxp.CancelC >= cxp.Monto - 0.1) 
      AND ISNULL(portal.TotalAbonado, 0) <= 0.01 
    ORDER BY cxp.FechaV ASC
    """
    
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        
        if not rows:
            print("\n[✓] No se encontraron facturas con Abono Cero que necesiten reversión.")
            return

        print(f"\n[!] Se detectaron {len(rows)} facturas que nacieron como 'Contado' en Saint pero no tienen pagos en el Portal.")
        print("Realizando limpieza nativa (Borrando Pagos y Restaurando Saldo a la Deuda Original)...\n")
        
        restored_count = 0
        for r in rows:
            numeroD = r.NumeroD
            codProv = r.CodProv
            monto_orig = float(r.Monto)
            
            # Borrar Pagos en Saint asociados (TipoCxP '41') si existen
            cursor.execute("""
                DELETE FROM EnterpriseAdmin_AMC.dbo.SAACXP 
                WHERE NumeroD = ? AND CodProv = ? AND TipoCxP IN ('41')
            """, (numeroD, codProv))
            pagos_borrados = cursor.rowcount
            
            # Restaurar Factura Principal (TipoCxP '10') dejándola 100% Viva
            cursor.execute("""
                UPDATE EnterpriseAdmin_AMC.dbo.SAACXP 
                SET CancelC = 0, Saldo = ?
                WHERE NumeroD = ? AND CodProv = ? AND TipoCxP = '10'
            """, (monto_orig, numeroD, codProv))
            
            # Restaurar Tabla de Compras (SACOMP) para indicar que no hay MtoPagos y no es Contado
            # (El usuario ya editó 'Contado', pero asegurarse MtoPagos está limpio)
            cursor.execute("""
                UPDATE EnterpriseAdmin_AMC.dbo.SACOMP 
                SET MtoPagos = 0
                WHERE NumeroD = ? AND CodProv = ? AND TipoCom = 'H'
            """, (numeroD, codProv))
            
            print(f" -> {numeroD:<15} ({r.Proveedor.strip()[:20]:<20}) Restablecida a Deuda {monto_orig:,.2f} Bs (Borrados {pagos_borrados} pagos nativos).")
            restored_count += 1
            
        conn.commit()
        print(f"\n--- [ÉXITO: {restored_count} facturas han sido restauradas como deuda viva] ---")
        
    except Exception as e:
        print(f"Error en la consulta: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    mass_force_portal_truth()
